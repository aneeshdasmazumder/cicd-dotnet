provider "aws" {
  region = "ap-south-1"  # Asia Pacific (Mumbai)
}

# Create an S3 bucket
resource "aws_s3_bucket" "example" {
  bucket = "my-cicdpipeline-bucket-unique-12345"  # Replace with a unique bucket name

  # Block public access settings for the bucket
  block_public_access {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = false
    restrict_public_buckets = true
  }
}
