#!/bin/bash

# Run all load tests and generate reports
# Usage: ./run-load-tests.sh [BASE_URL]

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
BASE_URL=${1:-"http://localhost:3000"}
RESULTS_DIR="./results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo -e "${YELLOW}🚀 Starting Load Tests${NC}"
echo "Target URL: $BASE_URL"
echo "Results directory: $RESULTS_DIR"
echo ""

# Check if k6 is installed
if ! command -v k6 &> /dev/null; then
    echo -e "${RED}❌ k6 not found. Installing...${NC}"
    
    # Install k6 based on OS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install k6
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo gpg -k
        sudo gpg --no-default-keyring --keyring /usr/share/keyrings/k6-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
        echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
        sudo apt-get update
        sudo apt-get install k6
    else
        echo -e "${RED}❌ Unsupported OS. Please install k6 manually: https://k6.io/docs/getting-started/installation/${NC}"
        exit 1
    fi
fi

# Create results directory
mkdir -p "$RESULTS_DIR"

# Function to run a test
run_test() {
    local test_name=$1
    local test_file=$2
    local output_file="$RESULTS_DIR/${test_name}_${TIMESTAMP}.json"
    
    echo -e "${YELLOW}📊 Running $test_name...${NC}"
    
    k6 run \
        --out json="$output_file" \
        --summary-export="$RESULTS_DIR/${test_name}_${TIMESTAMP}_summary.json" \
        -e BASE_URL="$BASE_URL" \
        "$test_file"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $test_name completed successfully${NC}"
    else
        echo -e "${RED}❌ $test_name failed${NC}"
    fi
    
    echo ""
}

# Run tests
echo -e "${YELLOW}Starting test suite...${NC}"
echo ""

# 1. API Load Test (24 minutes)
run_test "api-load-test" "scenarios/api-load-test.js"

# 2. Spike Test (6 minutes)
run_test "spike-test" "scenarios/spike-test.js"

# 3. Stress Test (27 minutes) - Optional, uncomment to run
# echo -e "${YELLOW}⚠️  Stress test will take ~27 minutes. Skip? (y/n)${NC}"
# read -r skip_stress
# if [ "$skip_stress" != "y" ]; then
#     run_test "stress-test" "scenarios/stress-test.js"
# fi

# 4. Soak Test (70 minutes) - Optional, uncomment to run
# echo -e "${YELLOW}⚠️  Soak test will take ~70 minutes. Skip? (y/n)${NC}"
# read -r skip_soak
# if [ "$skip_soak" != "y" ]; then
#     run_test "soak-test" "scenarios/soak-test.js"
# fi

# Generate summary report
echo -e "${YELLOW}📝 Generating summary report...${NC}"

cat > "$RESULTS_DIR/test_summary_${TIMESTAMP}.md" << EOF
# Load Test Summary

**Date**: $(date)
**Target URL**: $BASE_URL

## Tests Executed

### 1. API Load Test
- **Duration**: ~24 minutes
- **Max Users**: 200
- **Results**: See \`api-load-test_${TIMESTAMP}_summary.json\`

### 2. Spike Test
- **Duration**: ~6 minutes
- **Max Users**: 500
- **Results**: See \`spike-test_${TIMESTAMP}_summary.json\`

## Key Metrics

Review the JSON files in \`$RESULTS_DIR\` for detailed metrics:
- Request duration (p95, p99)
- Error rate
- Requests per second
- Custom metrics

## Next Steps

1. Review Grafana dashboards for system metrics during tests
2. Check Prometheus for resource utilization
3. Analyze any errors or performance degradation
4. Adjust resource limits if needed

EOF

echo -e "${GREEN}✅ All tests completed!${NC}"
echo ""
echo "Results saved to: $RESULTS_DIR"
echo "Summary report: $RESULTS_DIR/test_summary_${TIMESTAMP}.md"
echo ""
echo -e "${YELLOW}📊 View results:${NC}"
echo "  cat $RESULTS_DIR/test_summary_${TIMESTAMP}.md"
echo ""
echo -e "${YELLOW}📈 Next steps:${NC}"
echo "  1. Review Grafana dashboards"
echo "  2. Check Prometheus metrics"
echo "  3. Analyze test results"
