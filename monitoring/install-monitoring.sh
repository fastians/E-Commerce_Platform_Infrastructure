#!/bin/bash

# Install Prometheus + Grafana monitoring stack
# This script installs the kube-prometheus-stack Helm chart

set -e

echo "📊 Installing Prometheus + Grafana monitoring stack..."

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

if ! command -v helm &> /dev/null; then
    echo "❌ Helm not found. Installing Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl not found. Please install kubectl."
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites met${NC}"

# Add Helm repository
echo -e "${YELLOW}Adding Prometheus Helm repository...${NC}"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Create monitoring namespace
echo -e "${YELLOW}Creating monitoring namespace...${NC}"
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Create ConfigMap for Grafana dashboards
echo -e "${YELLOW}Creating Grafana dashboard ConfigMaps...${NC}"
kubectl create configmap grafana-dashboards \
  --from-file=grafana/dashboards/ \
  -n monitoring \
  --dry-run=client -o yaml | kubectl apply -f -

# Apply alert rules
echo -e "${YELLOW}Applying Prometheus alert rules...${NC}"
kubectl apply -f prometheus/alerts.yaml

# Install Prometheus stack
echo -e "${YELLOW}Installing Prometheus stack...${NC}"
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  -f prometheus/values.yaml \
  -n monitoring \
  --wait \
  --timeout 10m

echo -e "${GREEN}✅ Monitoring stack installed!${NC}"

# Wait for pods to be ready
echo -e "${YELLOW}Waiting for pods to be ready...${NC}"
kubectl wait --for=condition=Ready pods --all -n monitoring --timeout=300s

# Get Grafana password
GRAFANA_PASSWORD=$(kubectl get secret -n monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode)

echo ""
echo -e "${GREEN}✅ Installation complete!${NC}"
echo ""
echo "📊 Access Information:"
echo "  Grafana:"
echo "    URL: kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring"
echo "    Then open: http://localhost:3000"
echo "    Username: admin"
echo "    Password: ${GRAFANA_PASSWORD}"
echo ""
echo "  Prometheus:"
echo "    URL: kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090 -n monitoring"
echo "    Then open: http://localhost:9090"
echo ""
echo "  AlertManager:"
echo "    URL: kubectl port-forward svc/prometheus-kube-prometheus-alertmanager 9093:9093 -n monitoring"
echo "    Then open: http://localhost:9093"
echo ""
echo "📝 Useful commands:"
echo "  kubectl get pods -n monitoring"
echo "  kubectl logs -l app.kubernetes.io/name=prometheus -n monitoring"
echo "  kubectl logs -l app.kubernetes.io/name=grafana -n monitoring"
echo ""
echo "🎉 Monitoring stack is ready!"
