#!/usr/bin/env python3
import aws_cdk.aws_ec2 as ec2
import aws_cdk.aws_ecs as ecs
import aws_cdk.aws_efs as efs
from aws_cdk import Stack
from constructs import Construct


vpc_cidr = "192.168.0.0/16"
minecraft_port = 25565


class MinecraftServer(Stack):
    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        vpc = ec2.Vpc(
            self,
            "MinecraftVpc",
            max_azs=2,
            cidr=vpc_cidr,
            subnet_configuration=[
                ec2.SubnetConfiguration(
                    name="public", subnet_type=ec2.SubnetType.PUBLIC
                )
            ],
        )

        cluster = ecs.Cluster(
            self,
            "MinecraftCluster",
            vpc=vpc,
            cluster_name="minecraft-cluster",
            enable_fargate_capacity_providers=True,
        )

        minecraft_endpoint_sg = ec2.SecurityGroup(
            self,
            "MinecraftEndpointSG",
            vpc=vpc,
            security_group_name="minecraft-endpoint-sg",
        )
        minecraft_endpoint_sg.add_ingress_rule(
            ec2.Peer.any_ipv4(), ec2.Port.tcp(minecraft_port)
        )

        minecraft_efs_allow_mark_sg = ec2.SecurityGroup(
            self,
            "MinecraftEfsAllowMarkSG",
            vpc=vpc,
            security_group_name="minecraft-efs-allow-mark-sg",
        )
        minecraft_efs_sg = ec2.SecurityGroup(
            self, "MinecraftEfsSG", vpc=vpc, security_group_name="minecraft-efs-sg"
        )
        minecraft_efs_sg.add_ingress_rule(
            ec2.Peer.security_group_id(minecraft_efs_allow_mark_sg.security_group_id),
            ec2.Port.tcp(2049),
        )

        minecraft_efs = efs.FileSystem(
            self,
            "MinecraftEfs",
            vpc=vpc,
            file_system_name="minecraft-efs",
            vpc_subnets=ec2.SubnetSelection(subnet_type=ec2.SubnetType.PUBLIC),
            security_group=minecraft_efs_sg,
        )

        minecraft_data_volume = ecs.Volume(
            name="data",
            efs_volume_configuration=ecs.EfsVolumeConfiguration(
                file_system_id=minecraft_efs.file_system_id
            ),
        )

        minecraft_task = ecs.FargateTaskDefinition(
            self,
            "MinecraftTask",
            cpu=512,
            memory_limit_mib=4096,
            volumes=[minecraft_data_volume],
        )

        minecraft_container = ecs.ContainerDefinition(
            self,
            "MinecraftContainer",
            image=ecs.ContainerImage.from_registry("itzg/minecraft-server:latest"),
            task_definition=minecraft_task,
            environment={"EULA": "TRUE", "MEMORY": "4G", "TYPE": "PAPER"},
            port_mappings=[
                ecs.PortMapping(
                    container_port=minecraft_port,
                    protocol=ecs.Protocol.TCP,
                )
            ],
        )
        minecraft_container.add_mount_points(
            ecs.MountPoint(
                container_path="/data",
                read_only=False,
                source_volume=minecraft_data_volume.name,
            )
        )

        ecs.FargateService(
            self,
            "MinecraftService",
            cluster=cluster,
            security_groups=[minecraft_endpoint_sg, minecraft_efs_allow_mark_sg],
            task_definition=minecraft_task,
            assign_public_ip=True,
            desired_count=0,
            vpc_subnets=ec2.SubnetSelection(subnet_type=ec2.SubnetType.PUBLIC),
            capacity_provider_strategies=[
                ecs.CapacityProviderStrategy(
                    capacity_provider="FARGATE_SPOT", base=1, weight=1
                )
            ],
        )
