provider "aws" {
  region = "ap-south-1"
}

resource "random_id" "bucket_suffix" {
  byte_length = 8
}

resource "aws_s3_bucket" "example" {
  bucket = "my-cicdpipeline-bucket-unique-${random_id.bucket_suffix.hex}"
}

# Use data block to refer to an existing VPC
data "aws_vpc" "existing" {
  id = "vpc-0bb9937060d9b6bf1"
}

# Use the data block references correctly
data "aws_subnet" "subnet_a" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]  # Corrected to use data.aws_vpc.existing.id
  }
  filter {
    name   = "availability-zone"
    values = ["ap-south-1a"]
  }
}

data "aws_subnet" "subnet_b" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]  # Corrected to use data.aws_vpc.existing.id
  }
  filter {
    name   = "availability-zone"
    values = ["ap-south-1b"]
  }
}

resource "aws_security_group" "app_sg" {
  vpc_id = data.aws_vpc.existing.id  # Corrected to use data.aws_vpc.existing.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_instance" "app" {
  ami           = "ami-0c55b159cbfafe1f0"  # Replace with a valid AMI
  instance_type = "t2.micro"
  subnet_id     = data.aws_subnet.subnet_a.id
  security_groups = [aws_security_group.app_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install docker -y
              sudo service docker start
              sudo docker login -u "${var.docker_username}" -p "${var.docker_password}"
              sudo docker run -d -p 80:80 ${var.docker_username}/dotnetcoreapp:latest
              EOF
}

resource "aws_db_subnet_group" "main" {
  name       = "main"
  subnet_ids = [data.aws_subnet.subnet_a.id, data.aws_subnet.subnet_b.id]
}

resource "aws_security_group" "db" {
  vpc_id = data.aws_vpc.existing.id  # Corrected to use data.aws_vpc.existing.id

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

resource "aws_db_instance" "default" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0.34"
  instance_class       = "db.t3.micro"
  db_name              = "mydatabase"
  username             = "admin"
  password             = "password"
  parameter_group_name = "default.mysql8.0"
  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name = aws_db_subnet_group.main.name
}

output "bucket_name" {
  value = aws_s3_bucket.example.bucket
}

output "app_public_ip" {
  value = aws_instance.app.public_ip
}

output "db_endpoint" {
  value = aws_db_instance.default.endpoint
}
