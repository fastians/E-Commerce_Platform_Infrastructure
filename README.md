# E-Commerce Platform Infrastructure Project

## 🎯 Project Overview

A complete, production-ready e-commerce platform infrastructure deployed on AWS EKS, demonstrating enterprise-level DevOps practices, cloud architecture, and platform engineering skills.

**Live Demo**: [Deployment Guide](./docs/DEPLOYMENT.md)  
**Architecture**: [System Design](./docs/ARCHITECTURE.md)  
**Monitoring**: [Observability Stack](./docs/MONITORING.md)

## 📊 Key Achievements

### Infrastructure
- ✅ **AWS EKS Cluster** with multi-AZ deployment
- ✅ **Terraform IaC** for complete infrastructure automation
- ✅ **Auto-scaling** with HPA and Cluster Autoscaler
- ✅ **Cost Optimization** via spot instances and nightly cleanup (~93% savings)

### Monitoring & Observability
- ✅ **Prometheus** for metrics collection (15-day retention)
- ✅ **Grafana** with 3 custom dashboards
- ✅ **15+ Alert Rules** for proactive monitoring
- ✅ **Custom Metrics** for application performance

### CI/CD Pipeline
- ✅ **GitHub Actions** with 5 automated workflows
- ✅ **Multi-environment** support (dev/staging/production)
- ✅ **Automated Rollback** on deployment failures
- ✅ **Security Scanning** with Trivy on every PR
- ✅ **Nightly Cleanup** for cost optimization

### Performance & Testing
- ✅ **Load Testing** with k6 (4 test scenarios)
- ✅ **Performance Thresholds** (P95 < 500ms, P99 < 1s)
- ✅ **Capacity Planning** (validated up to 500 concurrent users)
- ✅ **Stability Testing** (70-minute soak tests)

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                      AWS Cloud                           │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ┌──────────────────────────────────────────────────┐  │
│  │  VPC (Multi-AZ)                                  │  │
│  │  ├── Public Subnets (3 AZs)                      │  │
│  │  ├── Private Subnets (3 AZs)                     │  │
│  │  └── NAT Gateways (HA)                           │  │
│  └──────────────────────────────────────────────────┘  │
│                                                           │
│  ┌──────────────────────────────────────────────────┐  │
│  │  EKS Cluster                                     │  │
│  │  ├── Control Plane (Managed)                     │  │
│  │  ├── Worker Nodes (On-demand + Spot)            │  │
│  │  ├── Cluster Autoscaler                          │  │
│  │  └── AWS Load Balancer Controller               │  │
│  └──────────────────────────────────────────────────┘  │
│                                                           │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Application Layer                               │  │
│  │  ├── Frontend (React + Nginx)                    │  │
│  │  ├── Backend (Node.js + Express)                 │  │
│  │  ├── Database (PostgreSQL)                       │  │
│  │  └── Ingress (ALB)                               │  │
│  └──────────────────────────────────────────────────┘  │
│                                                           │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Monitoring Stack                                │  │
│  │  ├── Prometheus (Metrics)                        │  │
│  │  ├── Grafana (Dashboards)                        │  │
│  │  └── AlertManager (Notifications)                │  │
│  └──────────────────────────────────────────────────┘  │
│                                                           │
└─────────────────────────────────────────────────────────┘
```

## 🚀 Quick Start

### Prerequisites
- AWS Account with credentials configured
- Terraform >= 1.6.0
- kubectl >= 1.28
- Docker
- Helm >= 3.0

### Deploy Infrastructure
```bash
# 1. Configure AWS credentials
aws configure

# 2. Deploy infrastructure
cd infrastructure/terraform/aws
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your settings
terraform init
terraform apply

# 3. Configure kubectl
aws eks update-kubeconfig --name demo-eks-cluster --region us-east-1

# 4. Deploy application
kubectl apply -k infrastructure/kubernetes/base/

# 5. Install monitoring
cd monitoring
./install-monitoring.sh

# 6. Get application URL
kubectl get ingress
```

### One-Command Deployment
```bash
make deploy
```

## 📈 Performance Metrics

### Load Test Results
- **Max Concurrent Users**: 500
- **P95 Latency**: < 500ms
- **P99 Latency**: < 1000ms
- **Error Rate**: < 5%
- **Requests/Second**: 200+

### Resource Utilization
- **CPU Usage**: 40-60% under normal load
- **Memory Usage**: 50-70% under normal load
- **Auto-scaling**: 2-20 pods based on demand
- **Database Connections**: < 80% pool utilization

### Cost Metrics
- **Full Deployment**: ~$150/month
- **With Optimization**: ~$10/month
- **Savings**: 93% via spot instances + nightly cleanup

## 🛠️ Technology Stack

### Infrastructure
- **Cloud**: AWS (EKS, VPC, RDS, ALB)
- **IaC**: Terraform
- **Orchestration**: Kubernetes
- **Package Manager**: Helm

### Application
- **Frontend**: React, Vite, Nginx
- **Backend**: Node.js, Express
- **Database**: PostgreSQL
- **Containerization**: Docker

### Monitoring
- **Metrics**: Prometheus
- **Visualization**: Grafana
- **Alerting**: AlertManager
- **Logging**: CloudWatch

### CI/CD
- **Pipeline**: GitHub Actions
- **Registry**: Docker Hub
- **Testing**: k6, Jest
- **Security**: Trivy

## 📁 Project Structure

```
.
├── infrastructure/
│   ├── terraform/aws/          # AWS infrastructure
│   └── kubernetes/             # K8s manifests
├── app/
│   ├── frontend/               # React application
│   ├── backend/                # Node.js API
│   └── docker/                 # Docker Compose
├── monitoring/
│   ├── prometheus/             # Prometheus config
│   └── grafana/                # Grafana dashboards
├── ci-cd/
│   └── .github/workflows/      # GitHub Actions
├── load-tests/
│   └── scenarios/              # k6 test scripts
├── docs/                       # Documentation
└── screenshots/                # Portfolio screenshots
```

## 🎯 Key Features

### High Availability
- Multi-AZ deployment across 3 availability zones
- Auto-scaling based on CPU and memory metrics
- Health checks and automatic pod recovery
- Load balancing with AWS ALB

### Security
- Private subnets for application workloads
- Security groups with least privilege
- Secrets management via Kubernetes secrets
- IMDSv2 for EC2 metadata
- Vulnerability scanning in CI/CD

### Observability
- Real-time metrics with Prometheus
- Custom Grafana dashboards
- Proactive alerting for critical issues
- Application performance monitoring
- Resource utilization tracking

### Cost Optimization
- Spot instances for 70% cost savings
- Nightly infrastructure cleanup
- Auto-scaling to match demand
- Resource limits and requests
- Optional RDS vs in-cluster PostgreSQL

## 📊 Monitoring Dashboards

### System Overview
- Cluster CPU and memory usage
- Pod count by namespace
- Node status and health
- Network I/O metrics

### API Metrics
- Request rate by endpoint
- Latency percentiles (P50, P95, P99)
- Error rates and status codes
- Active connections

### Database Metrics
- Connection pool utilization
- Query performance
- Cache hit ratio
- Transaction rates

## 🔄 CI/CD Pipeline

### Automated Workflows
1. **Build and Deploy** - Triggered on push to main
2. **PR Checks** - Linting, validation, security scanning
3. **Deploy Infrastructure** - Manual Terraform deployment
4. **Nightly Cleanup** - Automated cost optimization
5. **Destroy** - Safe infrastructure teardown

### Deployment Flow
```
Code Push → Build → Test → Security Scan → Deploy → Health Check → Rollback (if needed)
```

## 💰 Cost Analysis

### Monthly Costs

**Full Deployment**:
- EKS Control Plane: $73
- EC2 Instances: $60
- RDS (optional): $30
- Load Balancer: $20
- Monitoring: $20
- **Total**: ~$150/month

**Optimized**:
- Spot Instances: -70% on EC2
- In-cluster PostgreSQL: -$30
- Nightly Cleanup: -90% uptime
- **Total**: ~$10/month

## 🎓 Skills Demonstrated

### Cloud & Infrastructure
- AWS services (EKS, VPC, RDS, ALB, IAM)
- Infrastructure as Code (Terraform)
- Kubernetes orchestration
- Multi-AZ high availability
- Cost optimization strategies

### DevOps & SRE
- CI/CD pipeline design
- Automated deployment
- Monitoring and alerting
- Incident response
- Capacity planning

### Platform Engineering
- Container orchestration
- Service mesh concepts
- Auto-scaling strategies
- Resource management
- Performance optimization

### Security
- Network security (VPC, security groups)
- Secrets management
- Vulnerability scanning
- Least privilege access
- Security best practices

## 📚 Documentation

- [Architecture Overview](./docs/ARCHITECTURE.md)
- [Deployment Guide](./docs/DEPLOYMENT.md)
- [Monitoring Setup](./docs/MONITORING.md)
- [CI/CD Configuration](./ci-cd/README.md)
- [Load Testing Guide](./load-tests/README.md)

## 🔗 Quick Links

- **Makefile Commands**: `make help`
- **Terraform Docs**: `infrastructure/terraform/aws/README.md`
- **Kubernetes Docs**: `infrastructure/kubernetes/README.md`
- **Monitoring Docs**: `monitoring/README.md`

## 📝 License

This is a portfolio project for demonstration purposes.

---
