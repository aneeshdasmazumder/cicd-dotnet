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

# Use an existing VPC
data "aws_vpc" "existing" {
  id = "vpc-0bb9937060d9b6bf1"
  # Purpose: Reference the existing VPC by its ID.
  # Why: Ensures that the resources are created within the specified VPC.
}

# Use existing subnets in the VPC
data "aws_subnet" "subnet_a" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }
  filter {
    name   = "availability-zone"
    values = ["ap-south-1a"]
  }
  # Purpose: Fetch the subnet in the specified VPC and availability zone.
  # Why: Ensures that the resources are created within the specified subnet.
}

data "aws_subnet" "subnet_b" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }
  filter {
    name   = "availability-zone"
    values = ["ap-south-1b"]
  }
  # Purpose: Fetch the subnet in the specified VPC and availability zone.
  # Why: Ensures that the resources are created within the specified subnet.
}

resource "aws_security_group" "app_sg" {
  vpc_id = data.aws_vpc.existing.id
  # Purpose: Create a security group in the specified VPC.
  # Why: Allows control over inbound and outbound traffic for the EC2 instance.

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Purpose: Allow inbound traffic on port 22 (SSH).
  # Why: Ensures that the EC2 instance can be accessed via SSH.

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Purpose: Allow inbound traffic on port 80 (HTTP).
  # Why: Ensures that the application can be accessed via HTTP.

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Purpose: Allow all outbound traffic.
  # Why: Ensures that the EC2 instance can communicate with other services.
}

resource "aws_instance" "app" {
  ami           = "ami-0c55b159cbfafe1f0"  # Example AMI ID, replace with a valid one
  instance_type = "t2.micro"
  subnet_id     = data.aws_subnet.subnet_a.id
  security_groups = [aws_security_group.app_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              docker run -d -p 80:80 ${DOCKER_USERNAME}/dotnetcoreapp:latest
              EOF
}

resource "aws_security_group" "db" {
  vpc_id = data.aws_vpc.existing.id
  # Purpose: Create a security group in the specified VPC.
  # Why: Allows control over inbound and outbound traffic for the RDS instance.

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Purpose: Allow inbound traffic on port 3306 (MySQL).
  # Why: Ensures that the RDS instance can be accessed on the MySQL port.

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Purpose: Allow all outbound traffic.
  # Why: Ensures that the RDS instance can communicate with other services.
}

# RDS instance
resource "aws_db_instance" "default" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0.34"  # Supported engine version
  instance_class       = "db.t3.micro"  # Supported instance class
  db_name              = "mydatabase"  # Corrected argument name
  username             = "admin"
  password             = "password"
  parameter_group_name = "default.mysql8.0"
  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name = aws_db_subnet_group.main.name  # Updated name
  # Purpose: Create an RDS instance with the specified configuration.
  # Why: Ensures that the RDS instance is created with the desired settings.
}

resource "aws_db_subnet_group" "main" {  # Updated name
  name       = "main"  # Updated name
  subnet_ids = [data.aws_subnet.subnet_a.id, data.aws_subnet.subnet_b.id]
  # Purpose: Create a DB subnet group with the specified subnets.
  # Why: Ensures that the RDS instance is created within the specified subnets.
}

output "bucket_name" {
  value = aws_s3_bucket.example.bucket
  # Purpose: Output the name of the S3 bucket.
  # Why: Provides the S3 bucket name as an output for reference.
}

output "app_public_ip" {
  value = aws_instance.app.public_ip
}

output "db_endpoint" {
  value = aws_db_instance.default.endpoint
  # Purpose: Output the endpoint of the RDS instance.
  # Why: Provides the RDS endpoint as an output for reference.
}