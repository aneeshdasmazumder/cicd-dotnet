provider "aws" {
  region = "ap-south-1" # Asia Pacific (Mumbai)
}

resource "aws_s3_bucket" "example" {
  bucket = "my-cicdpipeline-bucket"
}

resource "aws_s3_bucket_acl" "example_acl" {
  bucket = aws_s3_bucket.example.bucket
  acl    = "private"
}