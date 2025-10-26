
terraform {
  backend "s3" {
    bucket         = "terraform-save-state-lp"
    key            = "terraform.tfstate"  # path in the bucket
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.5.0"
}




provider "aws" {
  region = var.aws_region
}

