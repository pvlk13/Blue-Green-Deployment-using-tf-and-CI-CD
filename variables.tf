variable "my_cidr" {
    description = "CIDR block for the VPC"
    default     = "10.0.0.0/16"
  
}
variable "regions" {
    type = list(string)
    description = "AWS region to deploy resources"  
  
}
variable "private_subnets" {
       type = list(string)
       description = "List of private subnet CIDR blocks"  
}
variable "public_subnets" {
        type = list(string)
        description = "List of public subnet CIDR blocks"  
}

variable "app_version" {
    description = "The version of app to deploy"
    type = string  
}