resource "aws_iam_instance_profile" "instance-profile" {
  name = "ebinejar-profile"
  role = aws_iam_role.iam-role.name
}
