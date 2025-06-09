provider "aws" {
  region     = "us-east-1"
  profile = "devops-lab"
}


terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

