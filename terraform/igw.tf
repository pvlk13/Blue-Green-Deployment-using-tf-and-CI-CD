resource "aws_internet_gateway" "igw" {
   vpc_id = aws_vpc.vpc-green-blue.id
   tags = {
     Name = "blue-green-igw"
   }
   }