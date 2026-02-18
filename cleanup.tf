removed {
  from = aws_elastic_beanstalk_environment.blue-tf

  lifecycle {
    destroy = false # This tells Terraform: "Forget it from state, but DON'T kill it in AWS"
  }
}

removed {
  from = aws_elastic_beanstalk_environment.green-tf

  lifecycle {
    destroy = false
  }
}