# Monitoring Stack

This directory contains configurations for the monitoring and observability stack.

## Components

- **Prometheus**: Metrics collection and storage
- **Grafana**: Visualization and dashboards
- **AlertManager**: Alert routing and notifications

## Installation

### Install Prometheus Stack

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install prometheus prometheus-community/kube-prometheus-stack \
  -f prometheus/values.yaml \
  -n monitoring --create-namespace
```

## Accessing Dashboards

### Grafana

```bash
kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring
```

Open: http://localhost:3000

**Default Credentials**:
- Username: admin
- Password: prom-operator

### Prometheus

```bash
kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090 -n monitoring
```

Open: http://localhost:9090

## Dashboards

Pre-configured dashboards are available in `grafana/dashboards/`:

1. **overview.json**: System overview with cluster metrics
2. **api-metrics.json**: Application performance metrics
3. **database.json**: Database performance metrics

### Import Dashboards

1. Access Grafana UI
2. Go to Dashboards → Import
3. Upload JSON files from `grafana/dashboards/`

## Alert Rules

Alert rules are defined in `prometheus/alerts.yaml`:

- High CPU usage
- High memory usage
- Pod crash loops
- High API latency
- Database connection issues

## Custom Metrics

Applications expose custom metrics on `/metrics` endpoint:

- `api_requests_total`: Total API requests
- `api_request_duration_seconds`: Request latency
- `api_errors_total`: Total errors
- `active_sessions`: Active user sessions

## Troubleshooting

### Check Prometheus Targets

```bash
kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090 -n monitoring
```

Visit: http://localhost:9090/targets

### Check Alert Rules

Visit: http://localhost:9090/alerts

### View Logs

```bash
kubectl logs -l app.kubernetes.io/name=prometheus -n monitoring
kubectl logs -l app.kubernetes.io/name=grafana -n monitoring
```
