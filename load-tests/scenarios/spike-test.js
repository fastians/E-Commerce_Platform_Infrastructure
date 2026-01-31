import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

const errorRate = new Rate('errors');

// Spike test configuration
export const options = {
  stages: [
    { duration: '1m', target: 10 },    // Warm up
    { duration: '30s', target: 500 },  // Sudden spike to 500 users
    { duration: '3m', target: 500 },   // Stay at 500 users
    { duration: '30s', target: 10 },   // Quick ramp down
    { duration: '1m', target: 0 },     // Cool down
  ],
  thresholds: {
    http_req_duration: ['p(95)<1000'],  // 95% < 1s (more lenient for spike)
    http_req_failed: ['rate<0.10'],     // Error rate < 10% (spike test)
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:3000';

export default function () {
  // Simulate user browsing behavior
  const endpoints = [
    '/health',
    '/api/products',
    '/api/products/1',
    '/api/products/search?q=test',
  ];

  const randomEndpoint = endpoints[Math.floor(Math.random() * endpoints.length)];
  
  let res = http.get(`${BASE_URL}${randomEndpoint}`);
  check(res, {
    'status is 200': (r) => r.status === 200,
  }) || errorRate.add(1);

  sleep(Math.random() * 2 + 1); // Random sleep 1-3 seconds
}

export function setup() {
  console.log('Starting spike test...');
  console.log('This test simulates sudden traffic spikes');
}
