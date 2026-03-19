terraform {
  backend "s3" {
    bucket         = "data-platform-tfstate-prd"
    key            = "prd/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "data-platform-tflock-prd"
  }
}
