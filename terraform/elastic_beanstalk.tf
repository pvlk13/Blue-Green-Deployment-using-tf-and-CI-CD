# This file defines the Elastic Beanstalk application for blue-green deployment.
resource "aws_elastic_beanstalk_application" "app" {
  name        = "vijaya-app-${random_id.suffix.hex}"
  description = "Production application for blue-green deployment"

  appversion_lifecycle {
    service_role          = aws_iam_role.test_role.arn
    max_count             = 10
    delete_source_from_s3 = false
  }
  lifecycle {
    ignore_changes = all
  }
}
# The Blue Environment (Production)
resource "aws_elastic_beanstalk_environment" "blue-tf" {
  name                = "app-blue-${random_id.suffix.hex}"
  application         = aws_elastic_beanstalk_application.app.name
  solution_stack_name = "64bit Amazon Linux 2023 v4.9.3 running Python 3.9"
  
  # We keep Blue stable
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "eb-instance-profile"
  }
}

# # The Green Environment (Staging/Target)
 resource "aws_elastic_beanstalk_environment" "green-tf" {
   name                = "app-green-${random_id.suffix.hex}"
   application         = aws_elastic_beanstalk_application.app.name
   solution_stack_name = "64bit Amazon Linux 2023 v4.9.3 running Python 3.9"
   version_label       = aws_elastic_beanstalk_application_version.default.name # Pipeline injects this!
   depends_on = [
     aws_elastic_beanstalk_application_version.default,
     aws_internet_gateway.igw,
     aws_nat_gateway.main,
     aws_route_table.public,
   ]
   setting {
     namespace = "aws:ec2:vpc"
     name      = "VPCId"
     value     = aws_vpc.vpc-green-blue.id
   }
   # 2. Tell it which subnets to use for the instances
   setting {
     namespace = "aws:ec2:vpc"
     name      = "Subnets"
     value     = join("," , aws_subnet.subnet-blue-green-private[*].id)
   }
    setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.eb_profile.name
  }
   setting {
     namespace = "aws:ec2:vpc"
     name      = "AssociatePublicIpAddress"
     # Set to false because you are using private subnets and a NAT Gateway
     value     = "false"
   }
 }
#This resource 'registers' the code from s3 into Beanstalk
resource "aws_elastic_beanstalk_application_version" "default" {
  name        = var.app_version
  application = aws_elastic_beanstalk_application.app.name
  description = "Apllication version ${var.app_version} created by CI/CD pipeline"
  bucket      = aws_s3_bucket.eb_artifacts.id
  key         = "${var.app_version}.zip"

  # This ensures that the application version is created only after the application itself exists.
  depends_on = [ aws_elastic_beanstalk_application.app ]
}
# In your instance security group
resource "aws_security_group" "eb_instance_sg" {
  vpc_id = aws_vpc.vpc-green-blue.id
  
  # Allow all outbound traffic (so it can reach the NAT Gateway)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
