resource "aws_s3_bucket" "example" {
  bucket = "my-cicdpipeline-bucket-unique-${random_id.bucket_suffix.hex}"  # Ensure unique name
}

resource "random_id" "bucket_suffix" {
  byte_length = 8
}

resource "aws_s3_bucket_acl" "example_acl" {
  bucket = aws_s3_bucket.example.bucket
  acl    = "private"
}
