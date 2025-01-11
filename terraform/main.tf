provider "aws" {
  region = "ap-south-1" # Asia Pacific (Mumbai)
}

resource "aws_s3_bucket" "example" {
  bucket = "my-cicdpipeline-bucket"
  acl    = "private"  # Set ACL directly here
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.example.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = false
  restrict_public_buckets = true
}

