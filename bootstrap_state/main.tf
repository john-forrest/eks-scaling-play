
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

variable "aws_dynamodb_table" {
  type    = string
  default = "cluster-tfstatelock"
}

resource "random_integer" "rand" {
  min = 10000
  max = 99999
}

locals {
  dynamodb_table_name = "${var.aws_dynamodb_table}-${random_integer.rand.result}"
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

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = local.dynamodb_table_name
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

##################################################################################
# OUTPUT
##################################################################################

output "s3_bucket" {
  value = aws_s3_bucket.terraform_state.bucket
}

output "dynamodb_statelock" {
  value = aws_dynamodb_table.terraform_state_lock.name
}
