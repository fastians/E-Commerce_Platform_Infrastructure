# Terraform AWS Infrastructure

This directory contains Terraform configurations for deploying the AWS infrastructure.

## Resources Created

- **VPC**: Virtual Private Cloud with public and private subnets across multiple AZs
- **EKS**: Elastic Kubernetes Service cluster with managed node groups
- **RDS**: PostgreSQL database in Multi-AZ configuration
- **ALB**: Application Load Balancer for ingress traffic
- **Security Groups**: Network security rules
- **IAM Roles**: Service roles for EKS and worker nodes

## Usage

### Initialize Terraform

```bash
terraform init
```

### Plan Infrastructure

```bash
terraform plan -out=tfplan
```

### Apply Infrastructure

```bash
terraform apply tfplan
```

### Destroy Infrastructure

```bash
terraform destroy
```

## Configuration

Create a `terraform.tfvars` file with your configuration:

```hcl
region           = "us-east-1"
cluster_name     = "demo-eks-cluster"
environment      = "production"
enable_rds       = true
instance_type    = "t3.medium"
min_nodes        = 2
max_nodes        = 10
```

## Outputs

After successful deployment, Terraform will output:

- EKS cluster endpoint
- RDS database endpoint
- Load balancer DNS name
- VPC ID

## Cost Estimation

Estimated monthly cost: ~$150-200 (varies by region and usage)

- EKS cluster: ~$73/month
- EC2 instances (2x t3.medium): ~$60/month
- RDS (db.t3.small): ~$30/month
- Load balancer: ~$20/month
- Data transfer: ~$10/month

## Files

- `main.tf`: Main configuration and provider setup
- `vpc.tf`: VPC, subnets, and networking
- `eks.tf`: EKS cluster and node groups
- `rds.tf`: RDS database configuration
- `variables.tf`: Input variables
- `outputs.tf`: Output values
