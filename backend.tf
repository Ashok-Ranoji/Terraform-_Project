terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  backend "s3" {
    bucket = "zantec-tfstate"
    key    = "terraform/state.tfstate"
    region = "ap-south-1"
    #dynamodb_table = "terraform-locks"
    encrypt = true
  }
}

resource "aws_s3_bucket" "zantec_tfstate" {
  bucket = "zantec-tfstate"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "zantec_tfstate_versioning" {
  bucket = aws_s3_bucket.zantec_tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}
