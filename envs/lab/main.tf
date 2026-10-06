terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

// Credentials come from ~/.aws/credentials (aws configure)
provider "aws" {
  region = var.region

  // Every resource gets these tags
  default_tags {
    tags = {
      Project     = "aws-lab"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

module "network" {
  source = "../../modules/network"

  name                = var.environment
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  my_ip               = var.my_ip
}
