# Monitoring & Observability

> Comprehensive monitoring setup with Prometheus and Grafana

## Table of Contents

- [Overview](#overview)
- [Prometheus Setup](#prometheus-setup)
- [Grafana Dashboards](#grafana-dashboards)
- [Alert Rules](#alert-rules)
- [Custom Metrics](#custom-metrics)
- [Accessing Dashboards](#accessing-dashboards)

## Overview

This platform uses a complete observability stack to monitor infrastructure, applications, and business metrics.

### Monitoring Stack Components

- **Prometheus**: Metrics collection and storage
- **Grafana**: Visualization and dashboards
- **AlertManager**: Alert routing and notifications
- **Node Exporter**: System-level metrics
- **kube-state-metrics**: Kubernetes cluster metrics

## Prometheus Setup

### Installation

Prometheus is deployed via Helm chart with custom configuration.

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack \
  -f monitoring/prometheus/values.yaml
```

### Metrics Collection

**System Metrics**
- CPU usage per pod
- Memory usage per pod
- Network I/O
- Disk usage

**Application Metrics**
- HTTP request rate
- Request latency (P50, P95, P99)
- Error rate
- Active connections

**Database Metrics**
- Connection pool usage
- Query performance
- Transaction rate
- Replication lag

## Grafana Dashboards

### 1. System Overview Dashboard

**Metrics Displayed**:
- Cluster CPU/Memory usage
- Pod count and status
- Node health
- Network traffic

**Use Case**: Quick health check of entire infrastructure

### 2. Application Metrics Dashboard

**Metrics Displayed**:
- Request rate (requests/second)
- Latency percentiles (P50, P95, P99)
- Error rate (4xx, 5xx)
- Active users/sessions

**Use Case**: Application performance monitoring

### 3. Database Metrics Dashboard

**Metrics Displayed**:
- Connection pool utilization
- Query execution time
- Transaction throughput
- Cache hit ratio

**Use Case**: Database performance optimization

## Alert Rules

### Critical Alerts

**High Pod CPU Usage**
```yaml
alert: HighPodCPU
expr: container_cpu_usage_seconds_total > 0.8
for: 5m
severity: warning
```

**Pod Crash Loop**
```yaml
alert: PodCrashLooping
expr: rate(kube_pod_container_status_restarts_total[15m]) > 0
for: 5m
severity: critical
```

**High API Latency**
```yaml
alert: HighAPILatency
expr: http_request_duration_seconds{quantile="0.95"} > 1
for: 5m
severity: warning
```

### Warning Alerts

- Memory usage > 80%
- Disk usage > 85%
- High error rate (> 5%)
- Database connection pool > 80%

## Custom Metrics

### Backend API Metrics

**Endpoint**: `/metrics`

**Custom Metrics Exposed**:
- `api_requests_total`: Total API requests
- `api_request_duration_seconds`: Request latency histogram
- `api_errors_total`: Total errors by type
- `active_sessions`: Current active user sessions

### Implementation Example

```python
from prometheus_client import Counter, Histogram

request_count = Counter('api_requests_total', 'Total API requests', ['method', 'endpoint'])
request_latency = Histogram('api_request_duration_seconds', 'Request latency')
```

## Accessing Dashboards

### Local Access (Port Forward)

```bash
# Grafana
kubectl port-forward svc/prometheus-grafana 3000:80

# Prometheus
kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090
```

### Production Access

- Grafana: https://grafana.yoursite.com
- Prometheus: https://prometheus.yoursite.com (internal only)

**Default Credentials**:
- Username: admin
- Password: [Retrieved from Kubernetes secret]

---

**Last Updated**: [To be filled during implementation]
