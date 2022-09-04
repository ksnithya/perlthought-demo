locals {
  owner       = "perlthoughtt"
  module_name = "${var.env}-${local.owner}"
}

resource "aws_key_pair" "TF_key" {
  key_name   = "TF_key"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "TF-key" {
    content  = tls_private_key.rsa.private_key_pem
    filename = "tfkey"
}

module "networking" {
  source          = "G:\\perlthought-project\\perl-core-infra\\project\\modules\\networking"
  env             = var.env
  vpc_cidr        = var.vpc_cidr
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
}
module "compute" {
  source = "G:\\perlthought-project\\perl-core-infra\\project\\modules\\compute"
  env    = var.env
  configuration = [
    {
      "instance_name" : "${local.module_name}-frontend-server",
      "ami" : "ami-06489866022e12a14",
      "no_of_instances" : "1",
      "instance_type" : "t2.micro",
      "subnet_id" : module.networking.public_subnets_ids[0],
      "vpc_security_group_ids" : [module.networking.allow_ssh_pub],
      "public_ip" : "true",
      "user_data_template" : "default_instance_http",
      "ssh_key" : aws_key_pair.TF_key.key_name 
    },
    {
      "instance_name" : "${local.module_name}-backend",
      "ami" : "ami-06489866022e12a14",
      "no_of_instances" : "1",
      "instance_type" : "t2.micro",
      "subnet_id" : module.networking.vpc.private_subnets[1],
      "vpc_security_group_ids" : [module.networking.instance_dev_server_sg, module.networking.allow_ssh_pub],
      "public_ip" : "false",
      "user_data_template" : "default_instance_data",
      "ssh_key" : aws_key_pair.TF_key.key_name
    }
  ]
}
resource "aws_instance" "vpn_access_server" {
  ami                         = "ami-029cb972e1b8a4bca"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [module.networking.allow_ssh_pub]
  associate_public_ip_address = true
  subnet_id                   = module.networking.public_subnets_ids[0]
  key_name                    = aws_key_pair.TF_key.key_name

  tags = {
    Name = "vpn-access-server"
  }
}
resource "aws_eip" "vpn_access_server" {
  instance = "${aws_instance.vpn_access_server.id}"
  vpc = true
}

output "vpn_access_server_link" {
  value = "https://${aws_eip.vpn_access_server.public_dns}:943/admin"
}

resource "random_password" "master" {
  length = 10
}

module "aurora_rds" {
  source = "G:\\perlthought-project\\perl-core-infra\\project\\modules\\storage\\rds"
  env    = var.env
  rds_configuration = {
    name                    = "${local.module_name}-db"
    engine                  = "aurora-postgresql"
    engine_version          = "13.5"
    instance_class          = "db.t3.medium"
    vpc_id                  = "${module.networking.vpc.vpc_id}"
    subnets                 = "${module.networking.vpc.public_subnets}"
    allowed_cidr_blocks     = "${var.vpc_cidr}"
    allowed_security_groups = "${module.networking.instance_dev_server_sg}"
    master_password         = "${random_password.master.result}"
  }
}

output "master_password" {
  description = "The password is:"
  value       = random_password.master.result
  sensitive   = true
}

resource "null_resource" "password" {
  provisioner "local-exec" {
    command = "echo ${random_password.master.result} >> master_db_password.txt"
  }
}

module "s3_bucket" {
  source = "G:\\perlthought-project\\perl-core-infra\\project\\modules\\storage\\s3"
  env = var.env
  s3_configuration = [
    {
      "bucket_name" : "${local.module_name}-sample-videos",
      "policy" : "default",
      "versioning" : "false",
      "acl" : "private",
      "enable_s3_public_access_block" : "true"
    },
    {
      "bucket_name" : "${local.module_name}-sample-image",
      "policy" : "default",
      "versioning" : "false",
      "acl" : "private",
      "enable_s3_public_access_block" : "true"
    }
  ]
}
   
