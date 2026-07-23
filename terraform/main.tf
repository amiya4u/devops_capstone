terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

#Create S3 Bucket
resource "aws_s3_bucket" "capstone_bucket" {
  bucket = "devops-capstone-amiya-2026"

  tags = {
    Name        = "DevOps Capstone Bucket"
    Environment = "learning"
    ManagedBy   = "terraform"
  }
}

# Create VPC
resource "aws_vpc" "capstone_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "capstone-vpc"
    ManagedBy = "terraform"
  }
}

# Subnet
resource "aws_subnet" "capstone_subnet" {
    vpc_id = aws_vpc.capstone_vpc.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true

    tags = {
    Name = "capstone-public-subnet"
    ManagedBy ="terraform"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "capstone_igw" {
   vpc_id = aws_vpc.capstone_vpc.id

  tags = {
    Name = "capstone_igw"
    ManagedBy = "terraform"
  }
}

# Route Table
resource "aws_route_table" "capstone_rt" {
  vpc_id = aws_vpc.capstone_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.capstone_igw.id
  }
tags = {
    Name = "capstone_rt"
    ManagedBy = "terraform"
  }
}
# Associate Route Table with Subnet
resource "aws_route_table_association" "capstone_rta" {
  subnet_id      = aws_subnet.capstone_subnet.id
  route_table_id = aws_route_table.capstone_rt.id
}
# Security Group
resource "aws_security_group" "capstone_sg" {
  name        = "capstone_sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.capstone_vpc.id

  tags = {
    Name = "capstone_sg"
    ManagedBy = "terraform"
  }
}
# Security Group Rule
resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.capstone_sg.id
  
}
resource "aws_security_group_rule" "http" {
  type   = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.capstone_sg.id
}
resource "aws_security_group_rule" "outbound" {
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.capstone_sg.id
  
}
# Create EC2
resource "aws_instance" "capstone_ec2" {
    ami = "ami-0b6d9d3d33ba97d99"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.capstone_subnet.id
    vpc_security_group_ids = [aws_security_group.capstone_sg.id]
    key_name = "TestDevops"
  
  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt install -y docker.io awscli
    service docker start
    usermod -aG docker ubuntu
  EOF
  tags = {
    Name      = "capstone-ec2"
    ManagedBy = "terraform"
  }
  iam_instance_profile = "ec2-ecr-read-role"

}

# Output public IP
output "ec2_public_ip" {
  value = aws_instance.capstone_ec2.public_ip
}

