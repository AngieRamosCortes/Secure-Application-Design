#!/bin/bash

echo "======================================"
echo "Application Testing Script"
echo "======================================"
echo ""

SPRING_SERVER="100.25.218.56"
APACHE_SERVER="3.91.202.237"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' 

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

print_test() {
    echo -e "${BLUE}→ $1${NC}"
}

# Test counter
PASSED=0
FAILED=0

run_test() {
    local test_name="$1"
    local test_command="$2"
    
    print_test "$test_name"
    
    if eval "$test_command"; then
        print_success "PASSED"
        ((PASSED++))
    else
        print_error "FAILED"
        ((FAILED++))
    fi
    echo ""
}

echo "Testing Spring Boot Server..."
echo "======================================"

# Test 1: Server is reachable
run_test "Test 1: Server is reachable" \
    "curl -k -s -o /dev/null -w '%{http_code}' https://${SPRING_SERVER}/api/status | grep -q '200'"

# Test 2: Status endpoint returns valid JSON
run_test "Test 2: Status endpoint returns valid JSON" \
    "curl -k -s https://${SPRING_SERVER}/api/status | jq -e '.status == \"OK\"' > /dev/null"

# Test 3: Hello endpoint is accessible
run_test "Test 3: Hello endpoint is accessible" \
    "curl -k -s https://${SPRING_SERVER}/api/hello | jq -e '.message' > /dev/null"

# Test 4: Login with valid credentials (admin)
echo "Test 4: Login with valid credentials (admin)"
RESPONSE=$(curl -k -s -X POST https://${SPRING_SERVER}/api/login \
    -H "Content-Type: application/json" \
    -d '{"username":"admin","password":"password123"}')

if echo "$RESPONSE" | jq -e '.success == true' > /dev/null; then
    print_success "PASSED"
    echo "Response: $RESPONSE"
    ((PASSED++))
else
    print_error "FAILED"
    echo "Response: $RESPONSE"
    ((FAILED++))
fi
echo ""

# Test 5: Login with valid credentials (angie)
echo "Test 5: Login with valid credentials (angie)"
RESPONSE=$(curl -k -s -X POST https://${SPRING_SERVER}/api/login \
    -H "Content-Type: application/json" \
    -d '{"username":"angie","password":"angie123"}')

if echo "$RESPONSE" | jq -e '.success == true' > /dev/null; then
    print_success "PASSED"
    echo "Response: $RESPONSE"
    ((PASSED++))
else
    print_error "FAILED"
    echo "Response: $RESPONSE"
    ((FAILED++))
fi
echo ""

# Test 6: Login with invalid credentials
echo "Test 6: Login with invalid credentials (should fail)"
RESPONSE=$(curl -k -s -X POST https://${SPRING_SERVER}/api/login \
    -H "Content-Type: application/json" \
    -d '{"username":"admin","password":"wrongpassword"}')

if echo "$RESPONSE" | jq -e '.success == false' > /dev/null; then
    print_success "PASSED"
    echo "Response: $RESPONSE"
    ((PASSED++))
else
    print_error "FAILED"
    echo "Response: $RESPONSE"
    ((FAILED++))
fi
echo ""

# Test 7: Login with non-existent user
echo "Test 7: Login with non-existent user (should fail)"
RESPONSE=$(curl -k -s -X POST https://${SPRING_SERVER}/api/login \
    -H "Content-Type: application/json" \
    -d '{"username":"nonexistent","password":"password"}')

if echo "$RESPONSE" | jq -e '.success == false' > /dev/null; then
    print_success "PASSED"
    echo "Response: $RESPONSE"
    ((PASSED++))
else
    print_error "FAILED"
    echo "Response: $RESPONSE"
    ((FAILED++))
fi
echo ""

echo "======================================"
echo "Testing Apache Server..."
echo "======================================"

# Test 8: Apache server is reachable
run_test "Test 8: Apache server is reachable (HTTPS)" \
    "curl -k -s -o /dev/null -w '%{http_code}' https://${APACHE_SERVER}/ | grep -q '200\|301\|302'"

# Test 9: HTML content is served
run_test "Test 9: HTML content is served" \
    "curl -k -s https://${APACHE_SERVER}/ | grep -q '<title>'"

echo "======================================"
echo "Summary"
echo "======================================"
echo ""
echo "Total Tests: $((PASSED + FAILED))"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    print_success "All tests passed! 🎉"
    exit 0
else
    print_error "Some tests failed. Please check the output above."
    exit 1
fi
