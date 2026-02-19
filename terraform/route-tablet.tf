
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