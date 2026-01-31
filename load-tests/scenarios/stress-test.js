import http from 'k6/http';
import { check, sleep } from 'k6';

// Stress test configuration - push system to its limits
export const options = {
  stages: [
    { duration: '2m', target: 100 },   // Ramp up
    { duration: '5m', target: 200 },   // Increase load
    { duration: '5m', target: 300 },   // Further increase
    { duration: '5m', target: 400 },   // Push to limits
    { duration: '5m', target: 500 },   // Maximum load
    { duration: '5m', target: 0 },     // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<2000'],  // More lenient for stress test
    http_req_failed: ['rate<0.20'],     // Allow up to 20% errors
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:3000';

export default function () {
  let res = http.get(`${BASE_URL}/api/products`);
  check(res, {
    'status is 200 or 503': (r) => r.status === 200 || r.status === 503,
  });

  sleep(0.5); // Aggressive request rate
}

export function setup() {
  console.log('Starting stress test...');
  console.log('This test will push the system to its limits');
  console.log('Expected: Some failures at peak load');
}

export function teardown(data) {
  console.log('Stress test completed!');
  console.log('Review metrics to identify breaking point');
}
