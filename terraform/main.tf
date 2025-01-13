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
}

# Networking components
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
}

resource "aws_subnet" "subnet_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1b"
}

resource "aws_security_group" "db" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS instance
resource "aws_db_instance" "default" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0.28"  # Supported engine version
  instance_class       = "db.t3.micro"  # Supported instance class
  db_name              = "mydatabase"  # Corrected argument name
  username             = "admin"
  password             = "password"
  parameter_group_name = "default.mysql8.0"
  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name = aws_db_subnet_group.main_new.name  # Updated name
}

resource "aws_db_subnet_group" "main_new" {  # Updated name
  name       = "main_new"  # Updated name
  subnet_ids = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
}

output "bucket_name" {
  value = aws_s3_bucket.example.bucket
}

output "db_endpoint" {
  value = aws_db_instance.default.endpoint
}
