# Monitoring Stack Quick Reference

## Installation

```bash
# Install monitoring stack
cd monitoring
./install-monitoring.sh

# Or manually with Helm
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack \
  -f prometheus/values.yaml \
  -n monitoring --create-namespace
```

## Access Dashboards

### Grafana
```bash
kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring
```
- URL: http://localhost:3000
- Username: `admin`
- Password: Get with `kubectl get secret -n monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode`

### Prometheus
```bash
kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090 -n monitoring
```
- URL: http://localhost:9090

### AlertManager
```bash
kubectl port-forward svc/prometheus-kube-prometheus-alertmanager 9093:9093 -n monitoring
```
- URL: http://localhost:9093

## Dashboards

1. **System Overview** - Cluster CPU, memory, pods, nodes, network I/O
2. **API Metrics** - Request rate, latency, errors, status codes
3. **Database Metrics** - Connections, query performance, cache hit ratio

## Alert Rules

- **Pod Alerts**: Crash loops, not ready, high CPU/memory
- **Node Alerts**: Not ready, high CPU/memory/disk
- **Application Alerts**: High latency, error rate, service down
- **Database Alerts**: Connection pool high, database down

## Useful Commands

```bash
# Check monitoring pods
kubectl get pods -n monitoring

# View Prometheus targets
kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090 -n monitoring
# Then visit: http://localhost:9090/targets

# View active alerts
# Visit: http://localhost:9090/alerts

# Check Grafana logs
kubectl logs -l app.kubernetes.io/name=grafana -n monitoring

# Check Prometheus logs
kubectl logs -l app.kubernetes.io/name=prometheus -n monitoring
```

## Metrics Endpoints

- Backend API: `http://backend:9090/metrics`
- PostgreSQL: Monitored via postgres-exporter (if installed)
- Kubernetes: Monitored via kube-state-metrics

## Customization

- **Prometheus values**: `prometheus/values.yaml`
- **Alert rules**: `prometheus/alerts.yaml`
- **Grafana dashboards**: `grafana/dashboards/*.json`
- **AlertManager config**: `alertmanager-config.yaml`
