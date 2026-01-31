# Load Testing Guide

## Overview

This directory contains k6 load testing scenarios to validate the performance and scalability of the e-commerce platform.

## Test Scenarios

### 1. API Load Test (`api-load-test.js`)
**Purpose**: Validate API performance under realistic load

**Configuration**:
- Duration: ~24 minutes
- Max concurrent users: 200
- Stages: Gradual ramp-up with spike

**Thresholds**:
- P95 latency < 500ms
- P99 latency < 1000ms
- Error rate < 5%

**Endpoints Tested**:
- `/health` - Health check
- `/api/products` - Product listing
- `/api/products/:id` - Single product
- `/api/products/search` - Search functionality
- `/metrics` - Prometheus metrics

### 2. Spike Test (`spike-test.js`)
**Purpose**: Test system behavior under sudden traffic spikes

**Configuration**:
- Duration: ~6 minutes
- Spike to 500 users in 30 seconds
- Sustained spike for 3 minutes

**Thresholds**:
- P95 latency < 1000ms
- Error rate < 10%

### 3. Stress Test (`stress-test.js`)
**Purpose**: Identify system breaking point

**Configuration**:
- Duration: ~27 minutes
- Gradual increase to 500 users
- Aggressive request rate

**Expected**:
- Some failures at peak load
- Identifies maximum capacity

### 4. Soak Test (`soak-test.js`)
**Purpose**: Detect memory leaks and stability issues

**Configuration**:
- Duration: ~70 minutes
- Sustained 100 users
- Realistic think time

**Monitors**:
- Memory usage over time
- Response time degradation
- Error rate stability

## Installation

### Install k6

**macOS**:
```bash
brew install k6
```

**Linux**:
```bash
sudo gpg -k
sudo gpg --no-default-keyring --keyring /usr/share/keyrings/k6-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
sudo apt-get update
sudo apt-get install k6
```

**Windows**:
```powershell
choco install k6
```

## Usage

### Run All Tests
```bash
./run-load-tests.sh http://your-app-url.com
```

### Run Individual Test
```bash
# API Load Test
k6 run -e BASE_URL=http://your-app-url.com scenarios/api-load-test.js

# Spike Test
k6 run -e BASE_URL=http://your-app-url.com scenarios/spike-test.js

# Stress Test
k6 run -e BASE_URL=http://your-app-url.com scenarios/stress-test.js

# Soak Test
k6 run -e BASE_URL=http://your-app-url.com scenarios/soak-test.js
```

### Run with Custom Options
```bash
# Run with specific VUs and duration
k6 run --vus 100 --duration 5m scenarios/api-load-test.js

# Run with JSON output
k6 run --out json=results.json scenarios/api-load-test.js

# Run with cloud output (requires k6 cloud account)
k6 run --out cloud scenarios/api-load-test.js
```

## Interpreting Results

### Key Metrics

**http_req_duration**: Request duration
- `p(95)`: 95th percentile (95% of requests faster than this)
- `p(99)`: 99th percentile
- `avg`: Average duration
- `max`: Maximum duration

**http_req_failed**: Failed request rate
- Should be < 5% for normal load
- < 10% for spike tests
- May be higher for stress tests

**http_reqs**: Total requests
- Requests per second (RPS)
- Total request count

**Custom Metrics**:
- `errors`: Custom error rate
- `api_latency`: API-specific latency trend

### Success Criteria

✅ **Pass**:
- P95 < 500ms
- P99 < 1000ms
- Error rate < 5%
- No crashes or OOM errors

⚠️ **Warning**:
- P95 500-1000ms
- Error rate 5-10%
- Occasional pod restarts

❌ **Fail**:
- P95 > 1000ms
- Error rate > 10%
- System crashes
- Persistent errors

## Monitoring During Tests

### Grafana Dashboards
```bash
kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring
# Open: http://localhost:3000
```

**Watch**:
- CPU usage per pod
- Memory usage per pod
- Request rate
- Error rate
- Database connections

### Prometheus Metrics
```bash
kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090 -n monitoring
# Open: http://localhost:9090
```

**Queries**:
```promql
# Request rate
rate(http_requests_total[5m])

# P95 latency
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

# Error rate
rate(http_requests_total{status_code=~"5.."}[5m])

# Pod CPU
rate(container_cpu_usage_seconds_total[5m])

# Pod Memory
container_memory_working_set_bytes
```

### Kubernetes Resources
```bash
# Watch pod status
kubectl get pods -w

# Watch HPA
kubectl get hpa -w

# Check pod resources
kubectl top pods

# Check node resources
kubectl top nodes
```

## Expected Results

### API Load Test (200 users)
- **P95 latency**: 200-400ms
- **P99 latency**: 400-800ms
- **Error rate**: < 1%
- **RPS**: 150-200
- **Pod scaling**: 2-8 pods

### Spike Test (500 users)
- **P95 latency**: 500-1000ms
- **P99 latency**: 1000-2000ms
- **Error rate**: < 5%
- **RPS**: 300-400
- **Pod scaling**: 8-15 pods

### Stress Test (500 users sustained)
- **P95 latency**: 1000-2000ms
- **Error rate**: 5-15%
- **RPS**: 200-300
- **Pod scaling**: 15-20 pods (max)
- **Expected**: Some failures at peak

## Troubleshooting

### High Error Rate
```bash
# Check pod logs
kubectl logs -l app=backend --tail=100

# Check pod status
kubectl describe pod <pod-name>

# Check HPA
kubectl describe hpa backend
```

### High Latency
- Check database connection pool
- Review Grafana dashboards
- Check node resources
- Review application logs

### Pod Crashes
- Check resource limits
- Review OOM errors
- Check database connections
- Review application code

## Best Practices

1. **Start Small**: Begin with low load and increase gradually
2. **Monitor Everything**: Watch Grafana during tests
3. **Baseline First**: Run tests on stable system to establish baseline
4. **Isolate Tests**: Run one test at a time
5. **Document Results**: Save results for comparison
6. **Review Metrics**: Analyze Prometheus data after tests
7. **Iterate**: Adjust thresholds based on requirements

## Cost Optimization

- Run tests during development hours only
- Use spot instances for test environments
- Destroy infrastructure after testing
- Use nightly cleanup for demo environments

## Next Steps

1. Run baseline tests
2. Document results
3. Optimize based on findings
4. Re-test after optimizations
5. Set up automated performance testing in CI/CD
