# 1. Security Group for the Load Balancer (Public)
resource "aws_security_group" "eb_lb_sg" {
  name        = "eb-lb-sg"
  vpc_id      = aws_vpc.vpc-green-blue.id
  description = "Allows public traffic into the Beanstalk LB"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound (to reach instances)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. Security Group for the EC2 Instances (Private)
resource "aws_security_group" "eb_instance_sg" {
  name        = "eb-instance-sg"
  vpc_id      = aws_vpc.vpc-green-blue.id
  description = "Allows traffic ONLY from the LB"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.eb_lb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
