provider "aws" {
  region = "us-east-1"
}

resource "random_id" "suffix" {
  byte_length = 2
}

resource "aws_vpc" "vpc-green-blue" {
  
  cidr_block       =  var.my_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "blue-green-vpc"
  }
}
resource "aws_subnet" "subnet-blue-green-private" {
  vpc_id     =  aws_vpc.vpc-green-blue.id
  count      = length(var.private_subnets)
  cidr_block =  var.private_subnets[count.index]
  tags = {
    Name = "subnet-private-${count.index}"
  }
}
resource "aws_subnet" "subnet-blue-green-public" {
  vpc_id     =  aws_vpc.vpc-green-blue.id
  count      = length(var.public_subnets)
  cidr_block =  var.public_subnets[count.index]
  tags = {
    Name = "subnet-public-${count.index}"
  }
}
resource "aws_internet_gateway" "igw" {
   vpc_id = aws_vpc.vpc-green-blue.id
   tags = {
     Name = "blue-green-igw"
   }
   }
resource "aws_eip" "nat" {
    domain = "vpc"
    depends_on = [aws_internet_gateway.igw]
    tags = {Name = "nat-eip"}
}  

resource "aws_nat_gateway" "main" {
    allocation_id = aws_eip.nat.id 
    subnet_id = aws_subnet.subnet-blue-green-public[0].id
    tags = {Name = "main-nat-gw"}
    depends_on = [ aws_internet_gateway.igw ]
  
}



resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc-green-blue.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}
resource "aws_route_table_association" "public_assoc" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.subnet-blue-green-public[count.index].id
  route_table_id = aws_route_table.public.id
}
# 1. The Route Table for Private Subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc-green-blue.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "private-route-table"
  }
}
resource "aws_route_table_association" "private_assoc" {
    count = length(var.private_subnets)
    subnet_id = aws_subnet.subnet-blue-green-private[count.index].id
    route_table_id = aws_route_table.private.id
  
}