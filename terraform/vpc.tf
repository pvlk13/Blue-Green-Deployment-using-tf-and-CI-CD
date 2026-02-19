resource "aws_vpc" "vpc-green-blue" {
  
  cidr_block       =  var.my_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "blue-green-vpc"
  }
}