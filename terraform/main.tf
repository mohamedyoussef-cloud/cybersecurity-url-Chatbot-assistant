terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "main" {
  cidr_block           = "10.50.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.netid}-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.50.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.netid}-public-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.netid}-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.netid}-public-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "main_sg" {
  name        = "${var.netid}-sg"
  description = "Security group for SSH, Ollama, and OpenWebUI"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.netid}-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.main_sg.id
  cidr_ipv4         = var.my_ip_cidr
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "openwebui" {
  security_group_id = aws_security_group.main_sg.id
  cidr_ipv4         = var.my_ip_cidr
  from_port         = 3000
  ip_protocol       = "tcp"
  to_port           = 3000
}

resource "aws_vpc_security_group_ingress_rule" "ollama" {
  security_group_id = aws_security_group.main_sg.id
  cidr_ipv4         = var.my_ip_cidr
  from_port         = 11434
  ip_protocol       = "tcp"
  to_port           = 11434
}

resource "aws_vpc_security_group_egress_rule" "all_out" {
  security_group_id = aws_security_group.main_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_s3_bucket" "project_bucket" {
  bucket = "${var.netid}-cisc886-url-assistant"

  tags = {
    Name = "${var.netid}-cisc886-url-assistant"
  }
}

resource "aws_key_pair" "project_key" {
  key_name   = "${var.netid}-key"
  public_key = file(var.public_key_path)
}

resource "aws_instance" "llm_ec2" {
  ami                         = var.ami_id
  instance_type               = "t3.large"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.main_sg.id]
  key_name                    = aws_key_pair.project_key.key_name
  associate_public_ip_address = true

  root_block_device {
    volume_size = 80
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.netid}-ec2-ollama-openwebui"
  }
}
