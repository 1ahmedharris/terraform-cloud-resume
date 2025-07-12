terraform {
  backend "s3" {
    bucket         = "resume-remote-backend"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    use_lockfile   = true 
  }

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

resource "aws_s3_bucket" "resume_remote_backend" {
  bucket = "resume-remote-backend"
}

resource "aws_dynamodb_table" "resume_state_lock_table" {
  name         = "resume-state-lock-table" 
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID" 

  attribute {
    name = "LockID"
    type = "S" 
  }
}
