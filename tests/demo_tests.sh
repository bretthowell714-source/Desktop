#!/bin/bash
# Quick demonstration of test capabilities
# Run a sample from each test category

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Termix Desktop - Test Demo${NC}"
echo -e "${BLUE}========================================${NC}"

echo -e "\n${YELLOW}Running sample unit test...${NC}"
if [ -f "$SCRIPT_DIR/unit/test_update_cask.sh" ]; then
    "$SCRIPT_DIR/unit/test_update_cask.sh" | head -30
    echo "... (output truncated)"
fi

echo -e "\n${YELLOW}Running sample validation test...${NC}"
if [ -f "$SCRIPT_DIR/validation/test_json_configs.py" ]; then
    "$SCRIPT_DIR/validation/test_json_configs.py" | head -30
    echo "... (output truncated)"
fi

echo -e "\n${YELLOW}Running sample integration test...${NC}"
if [ -f "$SCRIPT_DIR/integration/test_script_integration.sh" ]; then
    "$SCRIPT_DIR/integration/test_script_integration.sh" | head -30
    echo "... (output truncated)"
fi

echo -e "\n${GREEN}Demo complete!${NC}"
echo -e "Run ${YELLOW}./run_all_tests.sh${NC} to execute the full test suite."