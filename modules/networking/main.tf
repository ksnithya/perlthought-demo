locals {
  owner       = "perlthought"
  module_name = "${var.env}-${local.owner}"
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source          = "terraform-aws-modules/vpc/aws"
  name            = "${local.module_name}-vpc"
  cidr            = var.vpc_cidr
  azs             = data.aws_availability_zones.available.names
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  #assign_generated_ipv6_cidr_block = true
  create_database_subnet_group = true
  enable_nat_gateway           = true
  single_nat_gateway           = true
  enable_dns_hostnames         = true
  enable_dns_support           = true
}

// SG to allow SSH connections from anywhere
resource "aws_security_group" "allow_ssh_pub" {
  name        = "${var.env}-allow_ssh"
  description = "Allow SSH/OpenVPN inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH from the internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP Access from the internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol  = "tcp"
    from_port = 943
    to_port   = 943
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol  = "udp"
    from_port = 1194
    to_port   = 1194
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.module_name}-allow_ssh_pub"
  }
}
/*
resource "aws_security_group" "alb_sg" {
  name        = "${var.env}-alb-sg"
  description = "Allow inbound public traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Public HTTPS-443 Access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Public HTTP-80 access"
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
    Name = "${local.module_name}-alb-sg"
  }
}*/

resource "aws_security_group" "instance_dev_server_sg" {
  name        = "${var.env}-instance-dev-server-sg"
  description = "Allow inbound traffic only from security group"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH only from internal network"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.1.0.0/16", "10.2.0.0/16"]
  }
/*
  ingress {
    description     = "Application access from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
*/
  ingress {
    description = "Application access from entire network"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.1.0.0/16", "10.2.0.0/16"]
  }
  
  ingress {
    description = "Application access from entire network"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description = "Access all within same network"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.module_name}-instance-dev-server-sg"
  }
}
