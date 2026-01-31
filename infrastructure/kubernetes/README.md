# Kubernetes Manifests

This directory contains Kubernetes manifests for deploying the application.

## Structure

```
kubernetes/
├── base/                    # Base configurations
│   ├── frontend/           # Frontend deployment and service
│   ├── backend/            # Backend deployment and service
│   ├── database/           # Database StatefulSet (if not using RDS)
│   └── ingress.yaml        # Ingress configuration
└── monitoring/             # Monitoring stack configurations
```

## Deployment

### Deploy All Resources

```bash
kubectl apply -k base/
```

### Deploy Individual Components

```bash
# Frontend only
kubectl apply -f base/frontend/

# Backend only
kubectl apply -f base/backend/

# Database only
kubectl apply -f base/database/
```

## Configuration

### Resource Limits

**Frontend Pods**:
- CPU: 200m (request), 500m (limit)
- Memory: 256Mi (request), 512Mi (limit)

**Backend Pods**:
- CPU: 500m (request), 1000m (limit)
- Memory: 512Mi (request), 1Gi (limit)

### Autoscaling

**Frontend HPA**:
- Min replicas: 2
- Max replicas: 10
- Target CPU: 70%

**Backend HPA**:
- Min replicas: 2
- Max replicas: 20
- Target CPU: 70%

## Health Checks

All deployments include:
- **Liveness Probe**: Restart unhealthy pods
- **Readiness Probe**: Remove unhealthy pods from service
- **Startup Probe**: Handle slow-starting containers

## Monitoring

Pods expose metrics on `/metrics` endpoint for Prometheus scraping.

## Troubleshooting

### Check Pod Status

```bash
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Check Services

```bash
kubectl get services
kubectl describe service <service-name>
```

### Check Ingress

```bash
kubectl get ingress
kubectl describe ingress
```
