provider "aws" {
  region = "ap-south-1" # Asia Pacific (Mumbai)
}

resource "aws_s3_bucket" "example" {
  bucket = "my-cicd-pipeline-bucket" # Replace with a globally unique name
  acl    = "private"

  tags = {
    Name        = "my-cicd-pipeline"
    Environment = "Dev"
  }
}
