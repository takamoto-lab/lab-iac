moved {
  from = aws_iam_user.iam-user-auth0-logging
  to = aws_iam_user.iam_user_auth0_logging
}

moved {
  from = aws_iam_user_policy_attachment.iam-policy-attachment-user-auth0-logging
  to = aws_iam_user_policy_attachment.iam_policy_attachment_user_auth0_logging
}
