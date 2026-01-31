import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

// Custom metrics
const errorRate = new Rate('errors');
const apiLatency = new Trend('api_latency');

// Test configuration
export const options = {
  stages: [
    { duration: '2m', target: 50 },   // Ramp up to 50 users
    { duration: '5m', target: 50 },   // Stay at 50 users
    { duration: '2m', target: 100 },  // Ramp up to 100 users
    { duration: '5m', target: 100 },  // Stay at 100 users
    { duration: '2m', target: 200 },  // Spike to 200 users
    { duration: '5m', target: 200 },  // Stay at 200 users
    { duration: '3m', target: 0 },    // Ramp down to 0 users
  ],
  thresholds: {
    http_req_duration: ['p(95)<500', 'p(99)<1000'], // 95% < 500ms, 99% < 1s
    http_req_failed: ['rate<0.05'],                  // Error rate < 5%
    errors: ['rate<0.05'],                           // Custom error rate < 5%
  },
};

// Base URL - update this with your actual endpoint
const BASE_URL = __ENV.BASE_URL || 'http://localhost:3000';

export default function () {
  // Test 1: Health check
  let healthRes = http.get(`${BASE_URL}/health`);
  check(healthRes, {
    'health check status is 200': (r) => r.status === 200,
    'health check response time < 200ms': (r) => r.timings.duration < 200,
  }) || errorRate.add(1);

  sleep(1);

  // Test 2: API endpoint - Get products
  let productsRes = http.get(`${BASE_URL}/api/products`);
  check(productsRes, {
    'products status is 200': (r) => r.status === 200,
    'products response time < 500ms': (r) => r.timings.duration < 500,
    'products response has data': (r) => r.json().length > 0,
  }) || errorRate.add(1);
  
  apiLatency.add(productsRes.timings.duration);

  sleep(1);

  // Test 3: API endpoint - Get single product
  let productId = 1;
  let productRes = http.get(`${BASE_URL}/api/products/${productId}`);
  check(productRes, {
    'product status is 200': (r) => r.status === 200,
    'product response time < 300ms': (r) => r.timings.duration < 300,
  }) || errorRate.add(1);

  sleep(1);

  // Test 4: API endpoint - Search
  let searchRes = http.get(`${BASE_URL}/api/products/search?q=test`);
  check(searchRes, {
    'search status is 200': (r) => r.status === 200,
    'search response time < 600ms': (r) => r.timings.duration < 600,
  }) || errorRate.add(1);

  sleep(2);

  // Test 5: Metrics endpoint
  let metricsRes = http.get(`${BASE_URL}/metrics`);
  check(metricsRes, {
    'metrics status is 200': (r) => r.status === 200,
    'metrics contains prometheus data': (r) => r.body.includes('http_requests_total'),
  }) || errorRate.add(1);

  sleep(1);
}

// Setup function - runs once before the test
export function setup() {
  console.log('Starting load test...');
  console.log(`Target URL: ${BASE_URL}`);
  console.log('Test duration: ~24 minutes');
  console.log('Max concurrent users: 200');
}

// Teardown function - runs once after the test
export function teardown(data) {
  console.log('Load test completed!');
}
