provider "aws" {
  region = "ap-south-1"  # Specify your AWS region here
  # Purpose: Configure the AWS provider.
  # Why: Tells Terraform to use AWS and specifies the region where resources will be created.
}

resource "random_id" "bucket_suffix" {
  byte_length = 8
  # Purpose: Generate a random suffix for the bucket name.
  # Why: Ensures that the bucket name is unique, as S3 bucket names must be globally unique.
}

resource "aws_s3_bucket" "example" {
  bucket = "my-cicdpipeline-bucket-unique-${random_id.bucket_suffix.hex}"  # Ensure unique name
  # Purpose: Define an S3 bucket resource.
  # Why: Creates an S3 bucket with a unique name using the random suffix.
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.example.id

  block_public_acls   = false
  ignore_public_acls  = false
  block_public_policy = false
  restrict_public_buckets = false
  # Purpose: Manage public access settings for the S3 bucket.
  # Why: Configures the bucket to allow public policies and ACLs, which is necessary for applying the bucket policy.
}

resource "aws_s3_bucket_policy" "example_bucket_policy" {
  bucket = aws_s3_bucket.example.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "s3:*"
        Effect    = "Allow"
        Resource  = [
          "${aws_s3_bucket.example.arn}",
          "${aws_s3_bucket.example.arn}/*"
        ]
        Principal = "*"
      }
    ]
  })
  # Purpose: Define a bucket policy for the S3 bucket.
  # Why: Allows all actions (s3:*) on the bucket and its contents to any principal (*), effectively making the bucket publicly accessible.
}
