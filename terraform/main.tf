# Configuring the AWS provider
provider "aws" {
  region = "ap-south-1"
  # Purpose: Specify the AWS region where resources will be created.
  # Why: Terraform needs to know the target AWS region to deploy the infrastructure.
}

# Generating a random suffix for bucket names
resource "random_id" "bucket_suffix" {
  byte_length = 8
  # Purpose: Generate a random suffix for the S3 bucket name.
  # Why: Ensures S3 bucket names are globally unique to avoid conflicts.
}

# Creating an S3 bucket
resource "aws_s3_bucket" "example" {
  bucket = "my-cicdpipeline-bucket-unique-${random_id.bucket_suffix.hex}"
  # Purpose: Define an S3 bucket resource with a unique name.
  # Why: S3 buckets are used to store objects like logs, artifacts, and configurations.
}

# Setting public access controls for the S3 bucket
resource "aws_s3_bucket_public_access_block" "example" {
  bucket                  = aws_s3_bucket.example.id
  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false
  # Purpose: Control the public access settings for the S3 bucket.
  # Why: Allows flexibility in controlling access to the bucket as needed.
}

# Referencing an existing VPC by ID
data "aws_vpc" "existing" {
  id = "vpc-0bb9937060d9b6bf1"
  # Purpose: Fetch details of an existing VPC.
  # Why: Ensures resources are created within the existing network infrastructure.
}

# Fetching subnet details in the VPC for availability zone "ap-south-1a"
data "aws_subnet" "subnet_a" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }
  filter {
    name   = "availability-zone"
    values = ["ap-south-1a"]
  }
  # Purpose: Retrieve a subnet in the specified VPC and availability zone.
  # Why: Ensures resources are launched in the correct subnet for zone "ap-south-1a".
}

# Fetching subnet details in the VPC for availability zone "ap-south-1b"
data "aws_subnet" "subnet_b" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }
  filter {
    name   = "availability-zone"
    values = ["ap-south-1b"]
  }
  # Purpose: Retrieve a subnet in the specified VPC and availability zone.
  # Why: Ensures resources are launched in the correct subnet for zone "ap-south-1b".
}

# Creating a security group for the application server
resource "aws_security_group" "app_sg" {
  vpc_id = data.aws_vpc.existing.id
  # Purpose: Create a security group in the specified VPC.
  # Why: Control inbound and outbound traffic for the EC2 instance hosting the application.

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Purpose: Allow inbound SSH traffic.
  # Why: Enables remote management of the instance via SSH.

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Purpose: Allow inbound HTTP traffic.
  # Why: Ensures the application running on port 80 can be accessed publicly.

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Purpose: Allow all outbound traffic.
  # Why: Ensures the instance can communicate with other resources or the internet.
}

# Creating an EC2 instance to run the application
resource "aws_instance" "app" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id     = data.aws_subnet.subnet_a.id
  security_groups = [aws_security_group.app_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install docker -y
              sudo service docker start
              sudo docker login -u "${DOCKER_USERNAME}" -p "${DOCKER_PASSWORD}"
              sudo docker run -d -p 80:80 ${DOCKER_USERNAME}/dotnetcoreapp:latest
              EOF
  # Purpose: Launch an EC2 instance with Docker pre-installed.
  # Why: Hosts the .NET Core application as a Docker container on the EC2 instance.
}

# Outputting the public IP of the application server
output "app_public_ip" {
  value = aws_instance.app.public_ip
  # Purpose: Provide the public IP address of the EC2 instance.
  # Why: Allows users to access the deployed application via the internet.
}

# Outputting the S3 bucket name
output "bucket_name" {
  value = aws_s3_bucket.example.bucket
  # Purpose: Provide the name of the created S3 bucket.
  # Why: Useful for referencing the bucket in logs, tools, or subsequent configurations.
}
