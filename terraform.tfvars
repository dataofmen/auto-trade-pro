# AWS EC2 Configuration for Auto-Trade Pro
# This file contains the configuration for setting up AWS infrastructure

variables {
  region = "ap-northeast-2"
  
  vpc_cidr = "10.0.0.0/16"
  public_subnet_cidr = "10.0.1.0/24"
  private_subnet_cidr = "10.0.2.0/24"
  
  ec2_instance_type = "t3.micro"
  
  # Security group rules
  ssh_port = 22
  app_port = 8080
  
  tags = {
    Project = "auto-trade-pro"
    Environment = "production"
    Owner = "admin"
  }
}

# VPC Configuration
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = merge(var.tags, {
    Name = "auto-trade-pro-vpc"
  })
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
  
  tags = merge(var.tags, {
    Name = "auto-trade-pro-public-subnet"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = merge(var.tags, {
    Name = "auto-trade-pro-igw"
  })
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  
  tags = merge(var.tags, {
    Name = "auto-trade-pro-public-rt"
  })
}

# Route Table Association
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group
resource "aws_security_group" "app" {
  name        = "auto-trade-pro-sg"
  description = "Security group for auto-trade-pro"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }
  
  ingress {
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Application port"
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
  
  tags = merge(var.tags, {
    Name = "auto-trade-pro-sg"
  })
}

# EC2 Instance
resource "aws_instance" "app" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.ec2_instance_type
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.app.id]
  
  tags = merge(var.tags, {
    Name = "auto-trade-pro-instance"
  })
}

# AMI Data Source
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Output
output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.app.public_ip
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}
