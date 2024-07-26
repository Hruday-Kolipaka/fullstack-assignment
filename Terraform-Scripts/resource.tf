## AWS RESOURCES CREATION ##

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


# EC2 INSTANCE CREATION

resource "aws_instance" "web" {
  count         = var.instance_count
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = element(aws_subnet.public.*.id, count.index)

  tags = {
    Name        = "${var.project}-${var.environment}-web-${count.index}"
    Environment = var.environment
    Project     = var.project
  }
}


# RDS DATABASE CREATION

resource "aws_db_instance" "main" {
  identifier         = "${var.project}-${var.environment}-db"
  engine             = "mysql"
  instance_class     = "db.t3.micro"
  name               = var.db_name
  username           = var.db_user
  password           = var.db_password
  allocated_storage  = 20
  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  tags = {
    Name        = "${var.project}-${var.environment}-db"
    Environment = var.environment
    Project     = var.project
  }
}


# S3 BUCKET CREATION

resource "aws_s3_bucket" "app_bucket" {
  bucket = "${var.s3_bucket_name}-${var.environment}"
  acl    = "private"

  tags = {
    Name        = "${var.s3_bucket_name}-${var.environment}"
    Environment = var.environment
    Project     = var.project
  }
}

