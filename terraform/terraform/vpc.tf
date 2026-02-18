module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "blue-green-vpc"
  cidr = var.my_cidr
  azs             = var.regions
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_nat_gateway = true
  single_nat_gateway = true # Saves cost in dev; set to false for high-prod
  
  tags = {
    Terraform   = "true"
    Environment = "prod"
    Project     = "Blue-Green-EB"
  }
  
}