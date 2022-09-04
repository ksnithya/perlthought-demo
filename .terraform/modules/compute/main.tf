locals {
  owner       = "perlthought"
  module_name = "${var.env}-${local.owner}"

  serverconfig = [
    for srv in var.configuration : [
      for i in range(1, srv.no_of_instances + 1) : {
        instance_name           = srv.instance_name
        instance_type           = srv.instance_type
        subnet_id               = srv.subnet_id
        ami                     = srv.ami
        security_groups         = srv.vpc_security_group_ids
        public_ip               = srv.public_ip
        user_data_template      = srv.user_data_template
        ssh_key                 = srv.ssh_key
      }
    ]
  ]
}

locals {
  instances = flatten(local.serverconfig)
}

resource "aws_iam_role" "ec2_instance" {
  name               = "${local.module_name}-ec2-instance"
  assume_role_policy = file("G:\\perlthought-project\\perl-core-infra\\project\\modules\\compute\\policy\\ec2-instance.json")

  lifecycle { create_before_destroy = true }
}

resource "aws_iam_instance_profile" "ec2_instance" {
  name = "${local.module_name}-ec2-instance"
  role = aws_iam_role.ec2_instance.name
  lifecycle { create_before_destroy = true }
}

resource "aws_iam_role_policy" "ec2_instance_policy" {
  name   = "${local.module_name}-ec2-instance-policy"
  role   = aws_iam_role.ec2_instance.id
  policy = file("G:\\perlthought-project\\perl-core-infra\\project\\modules\\compute\\policy\\ec2-instance-policy.json")

  lifecycle { create_before_destroy = true }
}

#template for user-data
data "template_file" "dev_instance_data" {
  template = file("G:\\perlthought-project\\perl-core-infra\\project\\modules\\compute\\user-data\\dev_instance_data.tpl")
}

data "template_file" "default_instance_data" {
  template = file("G:\\perlthought-project\\perl-core-infra\\project\\modules\\compute\\user-data\\default_instance_data.tpl")
}

module "sh_instance" {
  source   = "terraform-aws-modules/ec2-instance/aws"
  for_each = { for server in local.instances : server.instance_name => server }

  name                        = each.value.instance_name
  ami                         = each.value.ami
  user_data                   = each.value.user_data_template == "default_instance_http" ? data.template_file.dev_instance_data.rendered : data.template_file.default_instance_data.rendered
  associate_public_ip_address = each.value.public_ip
  instance_type               = each.value.instance_type
  subnet_id                   = each.value.subnet_id
  vpc_security_group_ids      = each.value.security_groups
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance.name
#  key_name                    = aws_key_pair.TF_key.key_name
  key_name                    = each.value.ssh_key
  enable_volume_tags = true
  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = 20
    }
  ]

  tags = {
    "Name"        = "${each.value.instance_name}"
    "environment" = "${var.env}"
  }
}

