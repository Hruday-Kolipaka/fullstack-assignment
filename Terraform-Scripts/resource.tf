# PROVIDER SECTION
provider "aws" {
  region = var.aws_region
}

# VPC CREATION
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name        = "${var.project}-${var.environment}-vpc"
    Environment = var.environment
    Project     = var.project
  }
}

# SUBNETS CREATION 
resource "aws_subnet" "public" {
  count                   = length(var.subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project}-${var.environment}-subnet-${count.index}"
    Environment = var.environment
    Project     = var.project
  }
}

# SECURITY GROUP CREATION
resource "aws_security_group" "allow_all" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project}-${var.environment}-sg"
    Environment = var.environment
    Project     = var.project
  }
}

# EC2 INSTANCE CREATION
resource "aws_instance" "web_app" {
  count                   = var.instance_count
  ami                     = var.ami_id
  instance_type           = var.instance_type
  subnet_id               = element(aws_subnet.public.*.id, count.index)
  vpc_security_group_ids  = [aws_security_group.allow_all.id]
  key_name                = "HRUDAY-KEYPAIR"  # Add this line

  tags = {
    Name        = "${var.project}-${var.environment}-web-app-${count.index}"
    Environment = var.environment
    Project     = var.project
  }
}

# S3 BUCKET CREATION
resource "aws_s3_bucket" "app_bucket" {
  bucket = "${var.s3_bucket_name}-${var.environment}"

  tags = {
    Name        = "${var.s3_bucket_name}-${var.environment}"
    Environment = var.environment
    Project     = var.project
  }
}
