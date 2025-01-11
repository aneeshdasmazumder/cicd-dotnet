provider "aws" {
  region = "ap-south-1" # Asia Pacific (Mumbai)
}

resource "aws_s3_bucket" "example" {
  bucket = "my-cicdpipeline-bucket"
  
  block_public_access {
    block_public_acls = true
    block_public_policy = true
  }
}
