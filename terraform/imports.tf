import {
  to = aws_elastic_beanstalk_application.app
  id = "vijaya-blue-green-app"
}

import {
  to = aws_s3_bucket.eb_artifacts
  id = "vijaya-eb-artifacts-272183979798"
}

import {
  to = aws_elastic_beanstalk_environment.blue-tf
  id = "app-blue-tf"
}

import {
  to = aws_elastic_beanstalk_environment.green-tf
  id = "app-green-tf"
}
