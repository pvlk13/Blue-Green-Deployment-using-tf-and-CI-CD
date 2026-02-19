### AWS Elastic Beanstalk Blue/Green Infrastructure
This project contains a Terraform configuration for a highly available, secure web application environment using AWS Elastic Beanstalk. It implements a Blue/Green deployment strategy within a custom VPC.

## Architecture Overview
The infrastructure is designed for security and high availability across two Availability Zones ($us-east-1a$ and $us-east-1b$).
   - **Public Subnets**: Host the Application Load Balancers (ALB), NAT Gateway, and Internet Gateway.
   - **Private Subnets**: Host the EC2 Instances running the Python application. These instances have no public IPs and are inaccessible from the internet.
   - **NAT Gateway**: Provides the private instances with outbound-only internet access for updates and CloudWatch log streaming.
   - **Blue/Green** Setup: Two identical Elastic Beanstalk environments (Blue and Green) each with their own dedicated Load Balancer.
## Blue/Green Deployment Workflow
To update the application without downtime:
   - **Deploy to Green**: Update the app_version in Terraform and apply it to the Green environment.

   - **Verify**: Access the Green environment via its unique Beanstalk URL to ensure the new version is stable.

   - **Swap**: Use the Elastic Beanstalk "Swap Environment URLs" feature in the AWS Console or CLI.

   Note: DNS propagation usually takes 1–2 minutes.

   - **Decommission**: Once verified, the old Blue environment can be terminated or kept as a rollback target.   

# Security & Monitoring
## Security Groups:
   - **Load Balancer SG**: Allows Inbound HTTP (Port 80) from 0.0.0.0/0.

   - **Instance SG**: Only allows Inbound traffic from the Load Balancer Security Group.   

![alt text](image-1.png)    


The above image is the Architecture of this project for a single AZ in project I implemented for two AZ but represented single AZ in picture for simplicity.

### main.tf
``` hcl
provider "aws" {
  region = "us-east-1"
}

resource "random_id" "suffix" {
  byte_length = 2
}


resource "aws_eip" "nat" {
    domain = "vpc"
    depends_on = [aws_internet_gateway.igw]
    tags = {Name = "nat-eip"}
}  
``` hcl

### vpc.tf

``` hcl
resource "aws_vpc" "vpc-green-blue" {
  
  cidr_block       =  var.my_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "blue-green-vpc"
  }
}
``` hcl