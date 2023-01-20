# --- network/output.tf ---

output "load_balancer_dns_name" {
  description = "Get load balancer name"
  value       = aws_lb.web_alb.dns_name

}

# output "instance_ip_addr" {
#   value = aws_instance.server.private_ip
#   value = aws_instance.instance01
# }
