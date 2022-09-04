output "s3_bucket_ids" {
  description = "The name of the bucket."
  /* value       = {
    for k, s3_config in var.s3_configuration : k => aws_s3_bucket.ks_buckets.id
    }*/
  value = values(aws_s3_bucket.perl_buckets)[*].id
}

