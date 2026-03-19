terraform {
  backend "s3" {
    bucket         = "data-platform-tfstate-stg"
    key            = "stg/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "data-platform-tflock-stg"
  }
}
