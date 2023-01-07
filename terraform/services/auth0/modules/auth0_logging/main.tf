
resource "aws_iam_user" "iam_user_auth0_logging" {
  name = "auth0-logging"
}

resource "aws_iam_user_policy_attachment" "iam_policy_attachment_user_auth0_logging" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  user = "auth0-logging"
}
