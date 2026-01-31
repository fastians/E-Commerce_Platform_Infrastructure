# Load Testing

This directory contains load testing scenarios and results using k6.

## Installation

### Install k6

**macOS**:
```bash
brew install k6
```

**Linux**:
```bash
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
echo "deb https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
sudo apt-get update
sudo apt-get install k6
```

## Test Scenarios

### 1. Normal Load Test (`scenarios/normal-load.js`)

Simulates steady traffic with gradual ramp-up.

**Parameters**:
- Virtual Users: 100
- Duration: 5 minutes
- Ramp-up: 30 seconds

**Run**:
```bash
k6 run scenarios/normal-load.js
```

### 2. Spike Traffic Test (`scenarios/spike-traffic.js`)

Simulates sudden traffic spikes to test autoscaling.

**Parameters**:
- Virtual Users: 1000 (spike)
- Duration: 10 minutes
- Spike duration: 2 minutes

**Run**:
```bash
k6 run scenarios/spike-traffic.js
```

## Expected Results

### Performance Targets

- **P95 Latency**: < 200ms
- **P99 Latency**: < 500ms
- **Error Rate**: < 1%
- **Throughput**: > 1000 req/s

### Autoscaling Behavior

- Pods should scale from 2 to 10+ during spike
- Scale-down should occur within 5 minutes after load decreases
- No pod crashes or restarts during scaling

## Viewing Results

Results are saved to `results/` directory:

- HTML reports
- JSON metrics
- Screenshots of Grafana during tests

## Monitoring During Tests

### Watch Pod Scaling

```bash
watch kubectl get pods
```

### Watch HPA

```bash
watch kubectl get hpa
```

### View Grafana

```bash
kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring
```

## Custom Scenarios

Create custom scenarios in `scenarios/` directory using k6 JavaScript API.

Example:
```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  vus: 100,
  duration: '5m',
};

export default function() {
  let res = http.get('https://your-app-url.com');
  check(res, { 'status is 200': (r) => r.status === 200 });
  sleep(1);
}
```
