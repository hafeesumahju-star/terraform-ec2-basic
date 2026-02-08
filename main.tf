terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.0"
}

provider "aws" {
  region = "ap-south-1"
}

# 1) VPC
resource "aws_vpc" "dev" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "dev-vpc"
  }
}

# 2) Public subnets in two AZs
resource "aws_subnet" "dev_public_subnet_1" {
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "dev-public-subnet-1"
  }
}

resource "aws_subnet" "dev_public_subnet_2" {
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "dev-public-subnet-2"
  }
}

# 3) Internet Gateway
resource "aws_internet_gateway" "dev_igw" {
  vpc_id = aws_vpc.dev.id

  tags = {
    Name = "dev-igw"
  }
}

# 4) Route table for public subnets
resource "aws_route_table" "dev_public_rt" {
  vpc_id = aws_vpc.dev.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev_igw.id
  }

  tags = {
    Name = "dev-public-rt"
  }
}

# Associate route table with both public subnets
resource "aws_route_table_association" "dev_public_rt_assoc_1" {
  subnet_id      = aws_subnet.dev_public_subnet_1.id
  route_table_id = aws_route_table.dev_public_rt.id
}

resource "aws_route_table_association" "dev_public_rt_assoc_2" {
  subnet_id      = aws_subnet.dev_public_subnet_2.id
  route_table_id = aws_route_table.dev_public_rt.id
}

# 5) Security group allowing SSH and HTTP
resource "aws_security_group" "dev_sg" {
  name        = "dev-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.dev.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
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

  tags = {
    Name = "dev-sg"
  }
}

# 6) Two EC2 instances with Nginx and custom web page (Ubuntu)

resource "aws_instance" "dev_server_1" {
  ami                    = "ami-03f4878755434977f"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.dev_public_subnet_1.id
  vpc_security_group_ids = [aws_security_group.dev_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y nginx
              systemctl enable nginx
              systemctl start nginx

              echo "<html><h1>Welcome from dev-server-1 (Terraform + Nginx on Ubuntu)</h1></html>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "dev-server-1"
  }
}

resource "aws_instance" "dev_server_2" {
  ami                    = "ami-03f4878755434977f"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.dev_public_subnet_2.id
  vpc_security_group_ids = [aws_security_group.dev_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y nginx
              systemctl enable nginx
              systemctl start nginx

              echo "<html><h1>Welcome from dev-server-2 (Terraform + Nginx on Ubuntu)</h1></html>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "dev-server-2"
  }
}
