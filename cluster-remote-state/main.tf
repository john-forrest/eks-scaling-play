
variable "region" {
  type    = string
  default = "eu-west-2"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.region
}

#Bucket variables
variable "aws_bucket_prefix" {
  type    = string
  default = "cluster-tfstate"
}

resource "random_integer" "rand" {
  min = 10000
  max = 99999
}

locals {
  bucket_name         = "${var.aws_bucket_prefix}-${random_integer.rand.result}"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = local.bucket_name
     
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
    bucket = aws_s3_bucket.terraform_state.id

    versioning_configuration {
      status = "Enabled"
    }
}

##################################################################################
# OUTPUT
##################################################################################

output "s3_bucket" {
  value = aws_s3_bucket.terraform_state.bucket
}
