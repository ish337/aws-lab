output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_id" {
  value = module.network.public_subnet_id
}

output "private_subnet_id" {
  value = module.network.private_subnet_id
}

output "nat_public_ip" {
  value = module.network.nat_public_ip
}

output "flow_log_group" {
  value       = module.network.flow_log_group
  description = "aws logs tail <group> --follow shows the traffic"
}

output "web_public_ip" {
  value = module.web.public_ip
}

output "app_private_ip" {
  value = module.app.private_ip
}

output "ami" {
  value = module.web.ami
}

output "ssh_web" {
  value = "ssh -i ~/.ssh/lab_ed25519 ubuntu@${module.web.public_ip}"
}

output "ssh_app" {
  value       = "ssh -J ubuntu@${module.web.public_ip} ubuntu@${module.app.private_ip}"
  description = "Through the web instance, run ssh-add ~/.ssh/lab_ed25519 first"
}

output "bucket_name" {
  value = module.storage.bucket_name
}

output "readonly_role_arn" {
  value = module.storage.readonly_role_arn
}

output "readwrite_role_arn" {
  value = module.storage.readwrite_role_arn
}
