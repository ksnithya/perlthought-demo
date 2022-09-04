locals {
  owner       = "perlthought"
  module_name = "${var.env}-${local.owner}"
}

module "cluster" {
  source = "terraform-aws-modules/rds-aurora/aws"

  // for_each = var.rds_configuration
  name           = var.rds_configuration["name"]
  engine         = var.rds_configuration["engine"]
  engine_version = var.rds_configuration["engine_version"]
  instance_class = var.rds_configuration["instance_class"]
  instances = {
    1 = {
      instance_class = var.rds_configuration["instance_class"]
    }
  }

  vpc_id  = var.rds_configuration["vpc_id"]
  subnets = var.rds_configuration["subnets"]

  allowed_security_groups = [var.rds_configuration["allowed_security_groups"]]
  allowed_cidr_blocks     = [var.rds_configuration["allowed_cidr_blocks"]]

  master_password        = var.rds_configuration["master_password"]
  create_random_password = false

  storage_encrypted   = true
  apply_immediately   = true
  monitoring_interval = 60

  db_parameter_group_name         = aws_db_parameter_group.perl_rds_parameter_group.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.perl_rds_cluster_parameter_group.id

  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = {
    Environment = "${var.env}"
    Name        = "${local.module_name}"
  }
}

resource "aws_db_parameter_group" "perl_rds_parameter_group" {
  name        = "${local.module_name}-aurora-db-postgres13-parameter-group"
  family      = "aurora-postgresql13"
  description = "${local.module_name}-aurora-db-postgres13-parameter-group"
  tags = {
    Name = "${local.module_name}"
  }
}

resource "aws_rds_cluster_parameter_group" "perl_rds_cluster_parameter_group" {
  name        = "${local.module_name}-aurora-postgres13-cluster-parameter-group"
  family      = "aurora-postgresql13"
  description = "${local.module_name}-aurora-postgres13-cluster-parameter-group"
  tags = {
    Name = "${local.module_name}"
  }
}

