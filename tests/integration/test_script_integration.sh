#!/bin/bash
# Integration tests for shell scripts
# These tests verify that scripts work together and handle edge cases

set -e

TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
TEST_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$TEST_SCRIPT_DIR/../.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

assert_command_exists() {
    local cmd="$1"
    local test_name="$2"
    TESTS_RUN=$((TESTS_RUN + 1))
    if command -v "$cmd" >/dev/null 2>&1; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${NC} PASS: $test_name"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗${NC} FAIL: $test_name"
        echo "  Command '$cmd' not found"
        return 1
    fi
}

assert_file_exists() {
    local file="$1"
    local test_name="$2"
    TESTS_RUN=$((TESTS_RUN + 1))
    if [ -f "$file" ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${NC} PASS: $test_name"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗${NC} FAIL: $test_name"
        return 1
    fi
}

assert_exit_code() {
    local expected="$1"
    local actual="$2"
    local test_name="$3"
    TESTS_RUN=$((TESTS_RUN + 1))
    if [ "$expected" -eq "$actual" ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${NC} PASS: $test_name"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗${NC} FAIL: $test_name"
        echo "  Expected exit code: $expected, Got: $actual"
        return 1
    fi
}

# Test Suite 1: Script dependencies
test_script_dependencies() {
    echo -e "\n${YELLOW}Test Suite: Script Dependencies${NC}"
    
    # Commands used by update-cask.sh
    if [ -f "$REPO_ROOT/update-cask.sh" ]; then
        echo "Checking dependencies for update-cask.sh..."
        # Note: gh, curl, shasum, sed, awk are required but may not be in sandbox
        assert_command_exists "sed" "sed command available"
        assert_command_exists "awk" "awk command available"
    fi
    
    # Commands used by flatpak scripts
    if [ -f "$REPO_ROOT/flatpak/prepare-flatpak.sh" ]; then
        echo "Checking dependencies for prepare-flatpak.sh..."
        assert_command_exists "sed" "sed command available for flatpak scripts"
        # convert (ImageMagick) is optional, script handles its absence
    fi
}

# Test Suite 2: File structure integrity
test_file_structure() {
    echo -e "\n${YELLOW}Test Suite: File Structure Integrity${NC}"
    
    # Check that all referenced files exist
    assert_file_exists "$REPO_ROOT/Casks/termix.rb" "Cask file exists for update script"
    assert_file_exists "$REPO_ROOT/flatpak/com.karmaa.termix.yml" "YAML manifest exists"
    assert_file_exists "$REPO_ROOT/flatpak/com.karmaa.termix.metainfo.xml" "Metainfo XML exists"
    assert_file_exists "$REPO_ROOT/flatpak/com.karmaa.termix.desktop" "Desktop file exists"
    assert_file_exists "$REPO_ROOT/flatpak/com.karmaa.termix.flatpakref" "Flatpakref file exists"
}

# Test Suite 3: Script argument validation
test_script_argument_validation() {
    echo -e "\n${YELLOW}Test Suite: Script Argument Validation${NC}"
    
    # Test build-flatpak-bundle.sh without arguments
    if [ -f "$REPO_ROOT/flatpak/build-flatpak-bundle.sh" ]; then
        cd "$REPO_ROOT/flatpak"
        ./build-flatpak-bundle.sh >/dev/null 2>&1
        exit_code=$?
        assert_exit_code 1 $exit_code "build-flatpak-bundle.sh exits with error when no arguments provided"
    fi
    
    # Test prepare-flatpak.sh without arguments
    if [ -f "$REPO_ROOT/flatpak/prepare-flatpak.sh" ]; then
        cd "$REPO_ROOT/flatpak"
        ./prepare-flatpak.sh >/dev/null 2>&1
        exit_code=$?
        assert_exit_code 1 $exit_code "prepare-flatpak.sh exits with error when no arguments provided"
    fi
}

# Test Suite 4: Script output validation
test_script_usage_output() {
    echo -e "\n${YELLOW}Test Suite: Usage Message Output${NC}"
    
    # Check that scripts output usage when called without args
    if [ -f "$REPO_ROOT/flatpak/build-flatpak-bundle.sh" ]; then
        cd "$REPO_ROOT/flatpak"
        output=$(./build-flatpak-bundle.sh 2>&1 || true)
        TESTS_RUN=$((TESTS_RUN + 1))
        if echo "$output" | grep -q "Usage:"; then
            TESTS_PASSED=$((TESTS_PASSED + 1))
            echo -e "${GREEN}✓${NC} PASS: build-flatpak-bundle.sh shows usage message"
        else
            TESTS_FAILED=$((TESTS_FAILED + 1))
            echo -e "${RED}✗${NC} FAIL: build-flatpak-bundle.sh should show usage message"
        fi
    fi
    
    if [ -f "$REPO_ROOT/flatpak/prepare-flatpak.sh" ]; then
        cd "$REPO_ROOT/flatpak"
        output=$(./prepare-flatpak.sh 2>&1 || true)
        TESTS_RUN=$((TESTS_RUN + 1))
        if echo "$output" | grep -q "Usage:"; then
            TESTS_PASSED=$((TESTS_PASSED + 1))
            echo -e "${GREEN}✓${NC} PASS: prepare-flatpak.sh shows usage message"
        else
            TESTS_FAILED=$((TESTS_FAILED + 1))
            echo -e "${RED}✗${NC} FAIL: prepare-flatpak.sh should show usage message"
        fi
    fi
}

# Test Suite 5: Placeholder consistency
test_placeholder_consistency() {
    echo -e "\n${YELLOW}Test Suite: Placeholder Consistency${NC}"
    
    # Check that placeholders match between scripts and config files
    TESTS_RUN=$((TESTS_RUN + 1))
    if grep -q "VERSION_PLACEHOLDER" "$REPO_ROOT/flatpak/com.karmaa.termix.yml" && \
       grep -q "VERSION_PLACEHOLDER" "$REPO_ROOT/flatpak/prepare-flatpak.sh"; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${NC} PASS: VERSION_PLACEHOLDER used consistently"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗${NC} FAIL: VERSION_PLACEHOLDER should be used consistently"
    fi
    
    TESTS_RUN=$((TESTS_RUN + 1))
    if grep -q "CHECKSUM_X64_PLACEHOLDER" "$REPO_ROOT/flatpak/com.karmaa.termix.yml"; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${NC} PASS: CHECKSUM_X64_PLACEHOLDER exists in manifest"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗${NC} FAIL: CHECKSUM_X64_PLACEHOLDER should exist in manifest"
    fi
    
    TESTS_RUN=$((TESTS_RUN + 1))
    if grep -q "CHECKSUM_ARM64_PLACEHOLDER" "$REPO_ROOT/flatpak/com.karmaa.termix.yml"; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${NC} PASS: CHECKSUM_ARM64_PLACEHOLDER exists in manifest"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗${NC} FAIL: CHECKSUM_ARM64_PLACEHOLDER should exist in manifest"
    fi
}

# Test Suite 6: App ID consistency
test_app_id_consistency() {
    echo -e "\n${YELLOW}Test Suite: App ID Consistency${NC}"
    
    APP_ID="com.karmaa.termix"
    
    # Check that app ID is consistent across all files
    files_to_check=(
        "$REPO_ROOT/flatpak/com.karmaa.termix.yml"
        "$REPO_ROOT/flatpak/com.karmaa.termix.metainfo.xml"
        "$REPO_ROOT/flatpak/com.karmaa.termix.desktop"
        "$REPO_ROOT/flatpak/build-flatpak-bundle.sh"
        "$REPO_ROOT/Casks/termix.rb"
    )
    
    for file in "${files_to_check[@]}"; do
        if [ -f "$file" ]; then
            TESTS_RUN=$((TESTS_RUN + 1))
            if grep -q "$APP_ID" "$file"; then
                TESTS_PASSED=$((TESTS_PASSED + 1))
                echo -e "${GREEN}✓${NC} PASS: $APP_ID found in $(basename $file)"
            else
                TESTS_FAILED=$((TESTS_FAILED + 1))
                echo -e "${RED}✗${NC} FAIL: $APP_ID should be in $(basename $file)"
            fi
        fi
    done
}

# Test Suite 7: Repository reference consistency
test_repo_consistency() {
    echo -e "\n${YELLOW}Test Suite: Repository Reference Consistency${NC}"
    
    REPO_NAME="Termix-SSH/Termix"
    
    files=(
        "$REPO_ROOT/update-cask.sh"
        "$REPO_ROOT/Casks/termix.rb"
        "$REPO_ROOT/flatpak/com.karmaa.termix.yml"
    )
    
    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            TESTS_RUN=$((TESTS_RUN + 1))
            if grep -q "$REPO_NAME" "$file"; then
                TESTS_PASSED=$((TESTS_PASSED + 1))
                echo -e "${GREEN}✓${NC} PASS: Repository reference in $(basename $file)"
            else
                TESTS_FAILED=$((TESTS_FAILED + 1))
                echo -e "${RED}✗${NC} FAIL: Repository reference missing in $(basename $file)"
            fi
        fi
    done
}

# Test Suite 8: Version format consistency
test_version_format() {
    echo -e "\n${YELLOW}Test Suite: Version Format${NC}"
    
    # Extract version from Cask file
    if [ -f "$REPO_ROOT/Casks/termix.rb" ]; then
        version=$(grep 'version' "$REPO_ROOT/Casks/termix.rb" | head -1 | sed 's/.*"\(.*\)".*/\1/')
        TESTS_RUN=$((TESTS_RUN + 1))
        if echo "$version" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
            TESTS_PASSED=$((TESTS_PASSED + 1))
            echo -e "${GREEN}✓${NC} PASS: Version in Cask follows semver format ($version)"
        else
            TESTS_FAILED=$((TESTS_FAILED + 1))
            echo -e "${RED}✗${NC} FAIL: Version should follow semver format (found: $version)"
        fi
    fi
}

# Main test execution
main() {
    echo -e "${YELLOW}========================================${NC}"
    echo -e "${YELLOW}Running Integration Tests${NC}"
    echo -e "${YELLOW}========================================${NC}"
    
    test_script_dependencies
    test_file_structure
    test_script_argument_validation
    test_script_usage_output
    test_placeholder_consistency
    test_app_id_consistency
    test_repo_consistency
    test_version_format
    
    echo -e "\n${YELLOW}========================================${NC}"
    echo -e "${YELLOW}Test Summary${NC}"
    echo -e "${YELLOW}========================================${NC}"
    echo -e "Total tests run: $TESTS_RUN"
    echo -e "${GREEN}Tests passed: $TESTS_PASSED${NC}"
    if [ "$TESTS_FAILED" -gt 0 ]; then
        echo -e "${RED}Tests failed: $TESTS_FAILED${NC}"
        exit 1
    else
        echo -e "${GREEN}All tests passed!${NC}"
        exit 0
    fi
}

main