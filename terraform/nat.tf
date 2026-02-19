resource "aws_nat_gateway" "main" {
    allocation_id = aws_eip.nat.id 
    subnet_id = aws_subnet.subnet-blue-green-public[0].id
    tags = {Name = "main-nat-gw"}
    depends_on = [ aws_internet_gateway.igw ]
  
}
