output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnets
}

output "first_public_subnet" {
  value = module.vpc.public_subnets[0] # This returns the first subnet ID
}
output "private_subnets" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnets
}

output "web_lb_dns_name" {
  description = "DNS name of the web load balancer"
  value       = aws_lb.web_lb.dns_name
}

output "auto_scaling_group_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.web_auto_scaling.name
}

output "web_restart_user" {
  description = "IAM user for restarting web server"
  value       = aws_iam_user.web_restart_user.name
}

output "web_lb_arn" {
  description = "ARN of the load balancer"
  value       = aws_lb.web_lb.arn
}
