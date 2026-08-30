terraform {
  # State is per environment. A shared key is the fastest way to destroy
  # production from a dev apply.
  backend "s3" {
    bucket         = "data-platform-tfstate-dev"
    key            = "dev/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "data-platform-tflock-dev"
  }
}
