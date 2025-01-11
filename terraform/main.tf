provider "aws" {
  region = "ap-south-1"
}

resource "aws_s3_bucket" "example" {
  bucket = "my-cicdpipeline-bucket-unique-12345"  # Replace with a unique bucket name

  acl    = "private"  # Set ACL directly here
}
