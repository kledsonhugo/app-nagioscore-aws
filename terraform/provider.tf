# PROVIDER
terraform {

  required_version = "~> 1.8.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.46"
    }
  }

  # backend "s3" {
  #   bucket         = "tf-state-nagioscore-bucket"
  #   key            = "terraform.tfstate"
  #   dynamodb_table = "tf-state-nagioscore-table"
  # }

}

provider "aws" {
  region                   = "us-east-1"
  shared_config_files      = ["./.aws/config"]
  shared_credentials_files = ["./.aws/credentials"]
  profile                  = "fiap-iac"
}