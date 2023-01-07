
resource "aws_iam_user" "iam-user-auth0-logging" {
  name = "auth0-logging"
}

resource "aws_iam_user_policy_attachment" "iam-policy-attachment-user-auth0-logging" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  user = "auth0-logging"
}
