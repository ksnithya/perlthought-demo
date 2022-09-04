output "sh_instance_public_ip" {
  value = {
    for k, instance_details in module.sh_instance : k => instance_details.public_ip
  }
}
output "sh_instance_private_ip" {
  value = {
    for k, instance_details in module.sh_instance : k => instance_details.private_ip
  }
}
output "sh_instance_ids" {
  description = "The ID of the instance"
  value = {
    for k, sh_instance in module.sh_instance : k => sh_instance.id
  }
}

