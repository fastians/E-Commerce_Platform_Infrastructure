import http from 'k6/http';
import { check, sleep } from 'k6';

// Soak test - sustained load over extended period
export const options = {
  stages: [
    { duration: '5m', target: 100 },   // Ramp up
    { duration: '60m', target: 100 },  // Stay at 100 users for 1 hour
    { duration: '5m', target: 0 },     // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],
    http_req_failed: ['rate<0.05'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:3000';

export default function () {
  // Simulate realistic user behavior
  let res = http.get(`${BASE_URL}/api/products`);
  check(res, {
    'status is 200': (r) => r.status === 200,
  });

  sleep(3); // Realistic think time
}

export function setup() {
  console.log('Starting soak test...');
  console.log('Duration: ~70 minutes');
  console.log('This test checks for memory leaks and stability');
}
