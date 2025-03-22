terraform {
    #backend "s3" {
    #    bucket = "terraform-state-2021"
    #    key    = "terraform.tfstate"
    #    region = "us-east-1"
    #}
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 5.0"
        }
    }
}

provider "aws" {
  region = "us-east-1"
}

module "EC2" {
  source = "./EC2"
  subnet_id = module.VPC.subnet_id
  vpc_id = module.VPC.vpc_id
}

module "VPC" {
  source = "./VPC"
}