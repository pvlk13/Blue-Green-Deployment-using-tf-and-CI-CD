# 1. The Application Version (Your pipeline uses this)
resource "aws_elastic_beanstalk_application" "app" { # This name must be "app"
  name = "vijaya-app-${random_id.suffix.hex}"
  description = "Production application for blue-green deployment"

  appversion_lifecycle {
    service_role          = aws_iam_role.test_role.arn
    max_count             = 10
    delete_source_from_s3 = false
  }
}

resource "aws_elastic_beanstalk_application_version" "default" {
  name        = var.app_version
  application = aws_elastic_beanstalk_application.app.name
  bucket      = aws_s3_bucket.eb_artifacts.id
  key         = "${var.app_version}.zip"
}

# 2. THE BLUE ENVIRONMENT
resource "aws_elastic_beanstalk_environment" "blue-tf" {
  name                = "app-blue-${random_id.suffix.hex}"
  application         = aws_elastic_beanstalk_application.app.name
  solution_stack_name = "64bit Amazon Linux 2023 v4.9.3 running Python 3.9"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.eb_profile.name # Use the resource, not a string
  }

  # --- NETWORK & SECURITY ---
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = aws_vpc.vpc-green-blue.id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", aws_subnet.subnet-blue-green-private[*].id) # PRIVATE for EC2
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = join(",", aws_subnet.subnet-blue-green-public[*].id)  # PUBLIC for Load Balancer
  }

  setting {
    namespace = "aws:elb:loadbalancer" # Correct for Classic LB
    name      = "SecurityGroups"
    value     = aws_security_group.eb_lb_sg.id
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = aws_security_group.eb_instance_sg.id
  }

  # Enable log streaming to CloudWatch
  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "StreamLogs"
    value     = "true"
  }

  # How long to keep the logs (in days)
  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "RetentionInDays"
    value     = "7"
  }

  # Health reporting is also useful to see in logs
  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "SystemType"
    value     = "enhanced"
  }

}

# 3. THE GREEN ENVIRONMENT (Identical settings, different version)
resource "aws_elastic_beanstalk_environment" "green-tf" {
  name                = "app-green-${random_id.suffix.hex}"
  application         = aws_elastic_beanstalk_application.app.name
  solution_stack_name = "64bit Amazon Linux 2023 v4.9.3 running Python 3.9"
  version_label       = aws_elastic_beanstalk_application_version.default.name

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.eb_profile.name
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = aws_vpc.vpc-green-blue.id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", aws_subnet.subnet-blue-green-private[*].id)
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = join(",", aws_subnet.subnet-blue-green-public[*].id)
  }

  setting {
    namespace = "aws:elb:loadbalancer"
    name      = "SecurityGroups"
    value     = aws_security_group.eb_lb_sg.id
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = aws_security_group.eb_instance_sg.id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = "false" # Keep them private!
  }

  # Enable log streaming to CloudWatch
  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "StreamLogs"
    value     = "true"
  }

  # How long to keep the logs (in days)
  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "RetentionInDays"
    value     = "7"
  }

  # Health reporting is also useful to see in logs
  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "SystemType"
    value     = "enhanced"
  }
}