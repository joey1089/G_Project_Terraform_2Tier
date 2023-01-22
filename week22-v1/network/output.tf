# --- network/output.tf ---

output "load_balancer_dns_name" {
  description = "Get load balancer name"
  value       = aws_lb.web_alb.dns_name
}

# output "instance_ip_addr" {
#   value = aws_instance.server.private_ip
#   value = aws_instance.instance01
# }

output "Security_group" {
  value = aws_security_group.web_sg.name
}

output "Instance_Key_name" {
  value = aws_instance.Instance_01.key_name
}

output "Instance_0_Name" {
  value = aws_instance.Instance_01.tags.name
}