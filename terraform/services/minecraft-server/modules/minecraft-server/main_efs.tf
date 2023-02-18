# 以下のような EFS を作成:
# - sg_allow_ingress_to_efs のセキュリティグループからのみアクセスが出来る。

resource "aws_efs_file_system" "efs" {
  creation_token = "minecraft-server"
}

resource "aws_security_group" "sg_allow_ingress_to_efs" {
  name   = "minecraft-server_allow-ingress-to-efs"
  vpc_id = aws_vpc.vpc.id
}

resource "aws_security_group" "sg_efs" {
  name   = "minecraft-server_efs"
  vpc_id = aws_vpc.vpc.id
  ingress {
    # https://docs.aws.amazon.com/efs/latest/ug/accessing-fs-create-security-groups.html
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_allow_ingress_to_efs.id]
  }
}

resource "aws_efs_mount_target" "efs_endpoint" {
  for_each        = aws_subnet.subnets
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = each.value.id
  security_groups = [aws_security_group.sg_efs.id]
}
