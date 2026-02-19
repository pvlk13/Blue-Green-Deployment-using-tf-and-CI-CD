resource "aws_subnet" "subnet-blue-green-private" {
  vpc_id     =  aws_vpc.vpc-green-blue.id
  count      = length(var.private_subnets)
  cidr_block =  var.private_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "subnet-private-${count.index}"
  }
}
resource "aws_subnet" "subnet-blue-green-public" {
  vpc_id     =  aws_vpc.vpc-green-blue.id
  count      = length(var.public_subnets)
  cidr_block =  var.public_subnets[count.index]
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "subnet-public-${count.index}"
       }
 }
