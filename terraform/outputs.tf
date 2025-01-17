output "bucket_name" {
  value = aws_s3_bucket.example.bucket
}

output "app_public_ip" {
  value = aws_instance.app.public_ip
}

output "db_endpoint" {
  value = aws_db_instance.default.endpoint
}
