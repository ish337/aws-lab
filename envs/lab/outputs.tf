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
