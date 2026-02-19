resource "aws_iam_role" "test_role" {
  name = "eb-role-${random_id.suffix.hex}"

  # Terraform's "jsonencode" function converts .
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

}
resource "aws_iam_role_policy_attachment" "eb_webtier_attach" {
  role       = aws_iam_role.test_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}
resource "aws_iam_group" "test_group" {
  name = "test-management-group-v2"
  path = "/"
}
resource "aws_iam_group_policy_attachment" "test-attach" {
  group      = aws_iam_group.test_group.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_instance_profile" "eb_profile" {
  name = "eb-profile-${random_id.suffix.hex}"
  role = aws_iam_role.test_role.name
}
# Add this for health reporting and logging
resource "aws_iam_role_policy_attachment" "eb_worker_tier" {
  role       = aws_iam_role.test_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
  
}

#For looking into Cloudwatch for private instances
resource "aws_iam_role_policy_attachment" "logs"{
  role = aws_iam_role.test_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
# Add this if you are using Docker or Multi-container Python
resource "aws_iam_role_policy_attachment" "eb_multicontainer" {
  role       = aws_iam_role.test_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
}