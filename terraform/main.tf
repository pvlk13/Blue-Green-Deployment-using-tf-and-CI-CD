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
