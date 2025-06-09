module "dynamodb_table" {
  source   = "terraform-aws-modules/dynamodb-table/aws"
  name     = "g1-datnguyen-dynamodbstatelock-dev-339712730141-us-east-1"
  hash_key = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attributes = [
    {
      name = "LockID"
      type = "S"
    }
  ]

  tags = {
    Terraform   = "true"
    Environment = "development"
  }
}