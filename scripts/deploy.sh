#!/bin/bash

# Deployment script for platform-showcase
# This script deploys the infrastructure and application to AWS

set -e

echo "🚀 Starting deployment..."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

if ! command -v terraform &> /dev/null; then
    echo -e "${RED}❌ Terraform not found. Please install Terraform.${NC}"
    exit 1
fi

if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl not found. Please install kubectl.${NC}"
    exit 1
fi

if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI not found. Please install AWS CLI.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ All prerequisites met${NC}"

# Deploy infrastructure
echo -e "${YELLOW}📦 Deploying infrastructure with Terraform...${NC}"
cd infrastructure/terraform/aws

if [ ! -f "terraform.tfvars" ]; then
    echo -e "${YELLOW}⚠️  terraform.tfvars not found. Creating from example...${NC}"
    cp terraform.tfvars.example terraform.tfvars
    echo -e "${RED}Please edit terraform.tfvars with your configuration and run this script again.${NC}"
    exit 1
fi

terraform init
terraform plan -out=tfplan
terraform apply tfplan

echo -e "${GREEN}✅ Infrastructure deployed${NC}"

# Get cluster name from Terraform output
CLUSTER_NAME=$(terraform output -raw cluster_name)
REGION=$(terraform output -raw region)

# Configure kubectl
echo -e "${YELLOW}⚙️  Configuring kubectl...${NC}"
aws eks update-kubeconfig --name $CLUSTER_NAME --region $REGION

echo -e "${GREEN}✅ kubectl configured${NC}"

# Wait for nodes to be ready
echo -e "${YELLOW}⏳ Waiting for nodes to be ready...${NC}"
kubectl wait --for=condition=Ready nodes --all --timeout=300s

# Deploy application
echo -e "${YELLOW}📦 Deploying application to Kubernetes...${NC}"
cd ../../..
kubectl apply -k infrastructure/kubernetes/base/

echo -e "${GREEN}✅ Application deployed${NC}"

# Wait for pods to be ready
echo -e "${YELLOW}⏳ Waiting for pods to be ready...${NC}"
kubectl wait --for=condition=Ready pods --all --timeout=300s

# Get ingress URL
echo -e "${YELLOW}🔍 Getting application URL...${NC}"
sleep 10  # Wait for ALB to be provisioned
INGRESS_URL=$(kubectl get ingress platform-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo ""
echo -e "${GREEN}✅ Deployment complete!${NC}"
echo ""
echo "📊 Deployment Information:"
echo "  Cluster: $CLUSTER_NAME"
echo "  Region: $REGION"
echo "  Application URL: http://$INGRESS_URL"
echo ""
echo "📝 Useful commands:"
echo "  kubectl get pods"
echo "  kubectl get services"
echo "  kubectl get ingress"
echo "  kubectl logs -l app=backend"
echo ""
echo "🎉 Your platform is now running!"
