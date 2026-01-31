# Terraform Outputs

output "region" {
  description = "AWS region"
  value       = var.region
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = module.eks.cluster_oidc_issuer_url
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets
}

output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.region}"
}

# RDS outputs (only if enabled)
output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = var.enable_rds ? aws_db_instance.postgres[0].endpoint : "RDS not enabled"
}

output "rds_database_name" {
  description = "RDS database name"
  value       = var.enable_rds ? var.db_name : "RDS not enabled"
}

output "rds_username" {
  description = "RDS master username"
  value       = var.enable_rds ? var.db_username : "RDS not enabled"
  sensitive   = true
}

# Useful commands
output "useful_commands" {
  description = "Useful commands for working with the cluster"
  value = <<-EOT
    # Configure kubectl
    ${module.eks.cluster_name != "" ? "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.region}" : ""}

    # Get nodes
    kubectl get nodes

    # Get all resources
    kubectl get all --all-namespaces

    # Access Grafana (after monitoring stack is deployed)
    kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring
  EOT
}
