provider "aws" {
  region = "ap-south-1"  # Specify your AWS region here
}

resource "random_id" "bucket_suffix" {
  byte_length = 8
}

resource "aws_s3_bucket" "example" {
  bucket = "my-cicdpipeline-bucket-unique-${random_id.bucket_suffix.hex}"  # Ensure unique name
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.example.id

  block_public_acls   = false
  ignore_public_acls  = false
  block_public_policy = false
  restrict_public_buckets = false
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
}
