terraform {
  backend "s3" {
    bucket         = "g1-datnguyen-backendstatelock-dev-339712730141-us-east-1"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "g1-datnguyen-dynamodbstatelock-dev-339712730141-us-east-1"
  }
}

