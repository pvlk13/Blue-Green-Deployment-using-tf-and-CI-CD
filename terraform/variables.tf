variable "my_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "regions" {
  type        = list(string)
  description = "AWS region to deploy resources"
  default     = ["us-east-1"]
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet CIDR blocks"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnet CIDR blocks"
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "app_version" {
  description = "The version of app to deploy"
  type        = string
  default     = "v1"
}

variable "azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}