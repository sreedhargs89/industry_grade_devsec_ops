# Industry Grade DevSecOps Infrastructure Outputs

# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "vpc_arn" {
  description = "ARN of the VPC"
  value       = module.vpc.vpc_arn
}

# Subnet Outputs
output "public_subnet_ids" {
  description = "List of IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_cidrs" {
  description = "List of CIDR blocks of the public subnets"
  value       = module.vpc.public_subnet_cidrs
}

output "private_subnet_cidrs" {
  description = "List of CIDR blocks of the private subnets"
  value       = module.vpc.private_subnet_cidrs
}

# Gateway Outputs
output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = module.vpc.internet_gateway_id
}

output "nat_gateway_ids" {
  description = "List of IDs of the NAT Gateways"
  value       = module.vpc.nat_gateway_ids
}

# Security Group Outputs
output "bastion_security_group_id" {
  description = "ID of the bastion security group"
  value       = module.security.bastion_security_group_id
}

output "app_security_group_id" {
  description = "ID of the application security group"
  value       = module.security.app_security_group_id
}

output "database_security_group_id" {
  description = "ID of the database security group"
  value       = module.security.database_security_group_id
}

# EC2 Outputs
output "bastion_instance_id" {
  description = "ID of the bastion host instance"
  value       = module.ec2.bastion_instance_id
}

output "bastion_public_ip" {
  description = "Public IP address of the bastion host"
  value       = module.ec2.bastion_public_ip
}

output "bastion_public_dns" {
  description = "Public DNS name of the bastion host"
  value       = module.ec2.bastion_public_dns
}

# Auto Scaling Group Outputs
output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.ec2.autoscaling_group_name
}

output "autoscaling_group_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = module.ec2.autoscaling_group_arn
}

output "launch_template_id" {
  description = "ID of the Launch Template"
  value       = module.ec2.launch_template_id
}

# Load Balancer Outputs
output "application_load_balancer_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.ec2.application_load_balancer_dns_name
}

output "application_load_balancer_arn" {
  description = "ARN of the Application Load Balancer"
  value       = module.ec2.application_load_balancer_arn
}

# IAM Outputs
output "ec2_instance_profile_arn" {
  description = "ARN of the EC2 instance profile"
  value       = module.ec2.ec2_instance_profile_arn
}

output "ec2_role_arn" {
  description = "ARN of the EC2 IAM role"
  value       = module.ec2.ec2_role_arn
}

# Flow Logs Output
output "vpc_flow_log_id" {
  description = "ID of the VPC Flow Log"
  value       = module.vpc.vpc_flow_log_id
}

# Connection Information
output "ssh_connection_command" {
  description = "SSH connection command for bastion host"
  value       = "ssh -i ~/.ssh/${var.key_pair_name}.pem ec2-user@${module.ec2.bastion_public_ip}"
}

output "application_url" {
  description = "URL to access the application"
  value       = "http://${module.ec2.application_load_balancer_dns_name}"
}