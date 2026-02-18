terraform {
    backend "s3" {
        bucket = "vijaya-blue-green-tf"
        region = "us-east-1"
        key = "prod/eb-blue-green.tfstate"
        dynamodb_table = "terraform-lock-table"
      
    }
}