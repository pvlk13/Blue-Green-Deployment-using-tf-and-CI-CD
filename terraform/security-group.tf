# 1. Security Group for the Load Balancer (Public)
resource "aws_security_group" "eb_lb_sg" {
  name        = "eb-lb-sg"
  vpc_id      = aws_vpc.vpc-green-blue.id
  description = "Allows public traffic into the Beanstalk LB"

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. THE HANDSHAKE: Separate rules to prevent "Error: Cycle"
resource "aws_vpc_security_group_ingress_rule" "lb_http_in" {
  security_group_id = aws_security_group.eb_lb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "instance_from_lb" {
  security_group_id            = aws_security_group.eb_instance_sg.id
  referenced_security_group_id = aws_security_group.eb_lb_sg.id # The LB is the ONLY source
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

