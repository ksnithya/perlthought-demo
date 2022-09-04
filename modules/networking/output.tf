output "vpc" {
  value = module.vpc
}
output "allow_ssh_pub" {
  value = aws_security_group.allow_ssh_pub.id
}

output "instance_dev_server_sg" {
  value = aws_security_group.instance_dev_server_sg.id
}
output "public_subnets_ids" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}
output "private_subnets_ids" {
  description = "List of IDs of public subnets"
  value       = module.vpc.private_subnets
}


