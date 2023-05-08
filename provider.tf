#set up the the provider/aws
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = ["c:/Users/amin/.aws/credentials"]
  profile                  = "default"
}
