provider "aws" {
  region = "ap-south-1" # Asia Pacific (Mumbai)
}

resource "aws_s3_bucket" "example" {
  bucket = "my-cicdpipeline-bucket"
  acl    = "private"  # Set ACL directly here

  # Configure Block Public Access settings
  block_public_acls = true
  block_public_policy = true
}
