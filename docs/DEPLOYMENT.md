# Deployment Guide

> Step-by-step guide to deploy the platform infrastructure

## Table of Contents

- [Prerequisites](#prerequisites)
- [Initial Setup](#initial-setup)
- [Infrastructure Deployment](#infrastructure-deployment)
- [Application Deployment](#application-deployment)
- [Monitoring Setup](#monitoring-setup)
- [CI/CD Pipeline](#cicd-pipeline)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Tools

- **AWS CLI** (v2.x): `aws --version`
- **kubectl** (v1.28+): `kubectl version --client`
- **Terraform** (v1.0+): `terraform version`
- **Docker** (v20.x+): `docker --version`
- **Helm** (v3.x): `helm version`

### AWS Account Setup

1. Create AWS account with appropriate permissions
2. Configure AWS CLI credentials:
   ```bash
   aws configure
   ```
3. Verify access:
   ```bash
   aws sts get-caller-identity
   ```

## Initial Setup

### 1. Clone Repository

```bash
git clone https://github.com/yourusername/platform-showcase.git
cd platform-showcase
```

### 2. Configure Variables

Edit `infrastructure/terraform/aws/terraform.tfvars`:

```hcl
region           = "us-east-1"
cluster_name     = "demo-eks-cluster"
environment      = "production"
enable_rds       = true
instance_type    = "t3.medium"
```

## Infrastructure Deployment

### Step 1: Initialize Terraform

```bash
cd infrastructure/terraform/aws
terraform init
```

### Step 2: Plan Infrastructure

```bash
terraform plan -out=tfplan
```

Review the plan to ensure resources are correct.

### Step 3: Apply Infrastructure

```bash
terraform apply tfplan
```

**Expected Duration**: 10-15 minutes

**Resources Created**:
- VPC with public/private subnets
- EKS cluster
- RDS PostgreSQL instance
- Application Load Balancer
- Security groups and IAM roles

### Step 4: Configure kubectl

```bash
aws eks update-kubeconfig --name demo-eks-cluster --region us-east-1
```

Verify connection:
```bash
kubectl get nodes
```

## Application Deployment

### Step 1: Build Docker Images

```bash
cd app/frontend
docker build -t your-registry/frontend:latest .

cd ../backend
docker build -t your-registry/backend:latest .
```

### Step 2: Push Images

```bash
docker push your-registry/frontend:latest
docker push your-registry/backend:latest
```

### Step 3: Deploy to Kubernetes

```bash
cd infrastructure/kubernetes
kubectl apply -k base/
```

### Step 4: Verify Deployment

```bash
kubectl get pods -n default
kubectl get services -n default
kubectl get ingress -n default
```

Wait for all pods to be in `Running` state.

## Monitoring Setup

### Step 1: Install Prometheus Stack

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install prometheus prometheus-community/kube-prometheus-stack \
  -f monitoring/prometheus/values.yaml \
  -n monitoring --create-namespace
```

### Step 2: Access Grafana

```bash
kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring
```

Open browser: http://localhost:3000

**Default Login**:
- Username: admin
- Password: prom-operator

### Step 3: Import Dashboards

Import dashboard JSON files from `monitoring/grafana/dashboards/`

## CI/CD Pipeline

### GitHub Actions Setup

1. Add secrets to GitHub repository:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `DOCKER_USERNAME`
   - `DOCKER_PASSWORD`

2. Push to main branch to trigger deployment:
   ```bash
   git push origin main
   ```

3. Monitor workflow in GitHub Actions tab

## Troubleshooting

### Pods Not Starting

```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Database Connection Issues

```bash
kubectl get secret db-credentials -o yaml
kubectl exec -it <backend-pod> -- env | grep DB
```

### Ingress Not Working

```bash
kubectl describe ingress
kubectl get svc -n kube-system
```

### Terraform Errors

```bash
terraform refresh
terraform plan
```

## Cleanup

### Destroy Infrastructure

```bash
cd infrastructure/terraform/aws
terraform destroy
```

**Warning**: This will delete all resources and data.

---

**Last Updated**: [To be filled during implementation]
