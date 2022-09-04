locals {
  owner       = "perlthought"
  module_name = "${var.env}-${local.owner}"

  s3_data = flatten([
    for bucket in var.s3_configuration : [{
      bucket_name                   = bucket.bucket_name
      policy                        = bucket.policy
      versioning                    = bucket.versioning
      acl                           = bucket.acl
      enable_s3_public_access_block = bucket.enable_s3_public_access_block
    }]
  ])
}

resource "aws_s3_bucket" "perl_buckets" {
  //for_each = var.s3_configuration
  for_each = { for s3_config in local.s3_data : s3_config.bucket_name => s3_config }

  bucket = each.value["bucket_name"]
  tags = {
    Name = "${each.value["bucket_name"]}"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  for_each = { for s3_config in local.s3_data : s3_config.bucket_name => s3_config if s3_config.enable_s3_public_access_block == true }

  bucket = each.value["bucket_name"]
  # Block new public ACLs and uploading public objects
  block_public_acls = true
  # Retroactively remove public access granted through public ACLs
  ignore_public_acls = true
  # Block new public bucket policies
  block_public_policy = true
  # Retroactivley block public and cross-account access if bucket has public policies
  restrict_public_buckets = true
}

