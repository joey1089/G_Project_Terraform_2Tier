# --- root/output.tf ---

output "dns_hostname_of_alb" {
   value = module.resource_network.load_balancer_dns_name
}

output "resource_network_output" {
  value = module.resource_network.Instance_Key_name
}

output "Security_group_Name" {
  value = module.resource_network.Security_group
}

output "Instance01_AMI-id" {
  value = module.resource_network.Instance_01_ami
}


