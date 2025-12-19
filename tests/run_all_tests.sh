#!/bin/bash
# Master test runner - executes all test suites
# Run this script to execute the complete test suite

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TOTAL_SUITES=0
PASSED_SUITES=0
FAILED_SUITES=0

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Termix Desktop - Test Suite Runner${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

run_test_suite() {
    local test_file="$1"
    local test_name="$2"
    
    TOTAL_SUITES=$((TOTAL_SUITES + 1))
    
    echo -e "\n${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}Running: $test_name${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    if [ -f "$test_file" ]; then
        if "$test_file"; then
            PASSED_SUITES=$((PASSED_SUITES + 1))
            echo -e "${GREEN}✓ $test_name PASSED${NC}"
        else
            FAILED_SUITES=$((FAILED_SUITES + 1))
            echo -e "${RED}✗ $test_name FAILED${NC}"
        fi
    else
        FAILED_SUITES=$((FAILED_SUITES + 1))
        echo -e "${RED}✗ Test file not found: $test_file${NC}"
    fi
}

# Run unit tests
echo -e "\n${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}UNIT TESTS${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"

run_test_suite "$SCRIPT_DIR/unit/test_update_cask.sh" "Update Cask Script Tests"
run_test_suite "$SCRIPT_DIR/unit/test_build_flatpak_bundle.sh" "Build Flatpak Bundle Tests"
run_test_suite "$SCRIPT_DIR/unit/test_prepare_flatpak.sh" "Prepare Flatpak Tests"
run_test_suite "$SCRIPT_DIR/unit/test_termix_cask.rb" "Termix Cask Definition Tests"

# Run validation tests
echo -e "\n${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}VALIDATION TESTS${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"

run_test_suite "$SCRIPT_DIR/validation/test_json_configs.py" "JSON Configuration Tests"
run_test_suite "$SCRIPT_DIR/validation/test_flatpak_configs.py" "Flatpak Configuration Tests"

# Run integration tests
echo -e "\n${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}INTEGRATION TESTS${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"

run_test_suite "$SCRIPT_DIR/integration/test_script_integration.sh" "Script Integration Tests"

# Print final summary
echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}FINAL TEST SUMMARY${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "Total test suites: $TOTAL_SUITES"
echo -e "${GREEN}Passed: $PASSED_SUITES${NC}"
if [ "$FAILED_SUITES" -gt 0 ]; then
    echo -e "${RED}Failed: $FAILED_SUITES${NC}"
    echo ""
    echo -e "${RED}⚠ Some tests failed!${NC}"
    exit 1
else
    echo -e "${GREEN}Failed: 0${NC}"
    echo ""
    echo -e "${GREEN}🎉 All test suites passed!${NC}"
    exit 0
fi