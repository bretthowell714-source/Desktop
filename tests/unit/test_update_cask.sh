#!/bin/bash
# Unit tests for update-cask.sh
# This test suite validates the update-cask.sh script functionality

set -e

# Test framework setup
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
TEST_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$TEST_SCRIPT_DIR/../.." && pwd)"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test helper functions
assert_equals() {
    local expected="$1"
    local actual="$2"
    local test_name="$3"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [ "$expected" = "$actual" ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${NC} PASS: $test_name"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗${NC} FAIL: $test_name"
        echo "  Expected: $expected"
        echo "  Actual:   $actual"
        return 1
    fi
}

assert_not_empty() {
    local value="$1"
    local test_name="$2"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [ -n "$value" ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${NC} PASS: $test_name"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗${NC} FAIL: $test_name"
        echo "  Value should not be empty"
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
        echo "  File does not exist: $file"
        return 1
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local test_name="$3"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if echo "$haystack" | grep -q "$needle"; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${NC} PASS: $test_name"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗${NC} FAIL: $test_name"
        echo "  String '$needle' not found in: $haystack"
        return 1
    fi
}

assert_exit_code() {
    local expected_code="$1"
    local actual_code="$2"
    local test_name="$3"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [ "$expected_code" -eq "$actual_code" ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${NC} PASS: $test_name"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗${NC} FAIL: $test_name"
        echo "  Expected exit code: $expected_code"
        echo "  Actual exit code:   $actual_code"
        return 1
    fi
}

# Test 1: Script file exists and is executable
test_script_exists() {
    echo -e "\n${YELLOW}Test Suite: Script Existence and Permissions${NC}"
    assert_file_exists "$REPO_ROOT/update-cask.sh" "update-cask.sh exists"
}

test_script_executable() {
    if [ -x "$REPO_ROOT/update-cask.sh" ]; then
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${NC} PASS: update-cask.sh is executable"
    else
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗${NC} FAIL: update-cask.sh is not executable"
    fi
}

# Test 2: Script has proper shebang
test_shebang() {
    echo -e "\n${YELLOW}Test Suite: Script Structure${NC}"
    local shebang=$(head -n 1 "$REPO_ROOT/update-cask.sh")
    assert_contains "$shebang" "#!/bin/bash" "Script has correct shebang"
}

# Test 3: Script uses set -e for error handling
test_error_handling() {
    local content=$(cat "$REPO_ROOT/update-cask.sh")
    assert_contains "$content" "set -e" "Script uses 'set -e' for error handling"
}

# Test 4: Required variables are defined
test_required_variables() {
    echo -e "\n${YELLOW}Test Suite: Variable Definitions${NC}"
    local content=$(cat "$REPO_ROOT/update-cask.sh")
    assert_contains "$content" "REPO=" "REPO variable is defined"
    assert_contains "$content" "CASK_FILE=" "CASK_FILE variable is defined"
    assert_contains "$content" "LATEST_VERSION=" "LATEST_VERSION variable is defined"
    assert_contains "$content" "DOWNLOAD_URL=" "DOWNLOAD_URL variable is defined"
    assert_contains "$content" "SHA256=" "SHA256 variable is defined"
}

# Test 5: Script validates LATEST_VERSION
test_version_validation() {
    echo -e "\n${YELLOW}Test Suite: Version Validation${NC}"
    local content=$(cat "$REPO_ROOT/update-cask.sh")
    assert_contains "$content" 'if \[ -z "$LATEST_VERSION" \]' "Script validates LATEST_VERSION is not empty"
    assert_contains "$content" "exit 1" "Script exits on empty LATEST_VERSION"
}

# Test 6: Script validates SHA256
test_sha256_validation() {
    echo -e "\n${YELLOW}Test Suite: SHA256 Validation${NC}"
    local content=$(cat "$REPO_ROOT/update-cask.sh")
    assert_contains "$content" 'if \[ -z "$SHA256" \]' "Script validates SHA256 is not empty"
}

# Test 7: Script uses gh CLI correctly
test_gh_usage() {
    echo -e "\n${YELLOW}Test Suite: GitHub CLI Usage${NC}"
    local content=$(cat "$REPO_ROOT/update-cask.sh")
    assert_contains "$content" "gh release list" "Script uses 'gh release list'"
    assert_contains "$content" "--repo" "Script specifies --repo flag"
    assert_contains "$content" "--limit 1" "Script limits to 1 release"
    assert_contains "$content" "--json tagName" "Script requests tagName in JSON"
    assert_contains "$content" "--jq" "Script uses jq for JSON parsing"
}

# Test 8: Script constructs proper download URL
test_download_url_construction() {
    echo -e "\n${YELLOW}Test Suite: URL Construction${NC}"
    local content=$(cat "$REPO_ROOT/update-cask.sh")
    assert_contains "$content" "github.com.*releases/download" "Script constructs GitHub releases URL"
    assert_contains "$content" "release-.*-tag" "Script uses proper release tag format"
    assert_contains "$content" "termix_macos_universal_dmg.dmg" "Script references correct DMG file"
}

# Test 9: Script uses curl for downloading
test_curl_usage() {
    echo -e "\n${YELLOW}Test Suite: Download Mechanism${NC}"
    local content=$(cat "$REPO_ROOT/update-cask.sh")
    assert_contains "$content" "curl" "Script uses curl for downloading"
    assert_contains "$content" "curl -sL" "Script uses silent and location-follow flags"
}

# Test 10: Script calculates SHA256 correctly
test_sha256_calculation() {
    echo -e "\n${YELLOW}Test Suite: SHA256 Calculation${NC}"
    local content=$(cat "$REPO_ROOT/update-cask.sh")
    assert_contains "$content" "shasum -a 256" "Script uses shasum with SHA256 algorithm"
    assert_contains "$content" "awk.*print" "Script extracts hash with awk"
}

# Test 11: Script uses sed for file updates
test_sed_usage() {
    echo -e "\n${YELLOW}Test Suite: File Update Mechanism${NC}"
    local content=$(cat "$REPO_ROOT/update-cask.sh")
    assert_contains "$content" "sed -e" "Script uses sed for replacements"
    assert_contains "$content" 'version \\"' "Script updates version field"
    assert_contains "$content" 'sha256 \\"' "Script updates sha256 field"
}

# Test 12: Script creates temporary file safely
test_temp_file_handling() {
    echo -e "\n${YELLOW}Test Suite: Temporary File Handling${NC}"
    local content=$(cat "$REPO_ROOT/update-cask.sh")
    assert_contains "$content" ".tmp" "Script creates temporary file"
    assert_contains "$content" "mv.*tmp.*CASK_FILE" "Script moves temp file to original"
}

# Test 13: Script references correct repository
test_repo_reference() {
    echo -e "\n${YELLOW}Test Suite: Repository Configuration${NC}"
    local content=$(cat "$REPO_ROOT/update-cask.sh")
    assert_contains "$content" "Termix-SSH/Termix" "Script references correct GitHub repository"
}

# Test 14: Script finds Cask file correctly
test_cask_file_path() {
    echo -e "\n${YELLOW}Test Suite: Cask File Path${NC}"
    local content=$(cat "$REPO_ROOT/update-cask.sh")
    assert_contains "$content" 'dirname "$0"' "Script uses dirname for relative path"
    assert_contains "$content" "Casks/termix.rb" "Script references correct Cask file"
}

# Test 15: Cask file actually exists
test_cask_file_exists() {
    assert_file_exists "$REPO_ROOT/Casks/termix.rb" "Cask file exists at expected location"
}

# Test 16: Version format processing
test_version_format() {
    echo -e "\n${YELLOW}Test Suite: Version Format Processing${NC}"
    local content=$(cat "$REPO_ROOT/update-cask.sh")
    assert_contains "$content" "sed 's/release-//'" "Script removes 'release-' prefix"
    assert_contains "$content" "sed 's/-tag//'" "Script removes '-tag' suffix"
}

# Test 17: Error messages are informative
test_error_messages() {
    echo -e "\n${YELLOW}Test Suite: Error Messages${NC}"
    local content=$(cat "$REPO_ROOT/update-cask.sh")
    assert_contains "$content" "Failed to fetch latest version" "Script has version fetch error message"
    assert_contains "$content" "Failed to calculate SHA256" "Script has SHA256 error message"
}

# Test 18: Script outputs debug information
test_debug_output() {
    echo -e "\n${YELLOW}Test Suite: Debug Output${NC}"
    local content=$(cat "$REPO_ROOT/update-cask.sh")
    # Count echo statements for version, URL, and SHA256
    local echo_count=$(grep -c '^echo' "$REPO_ROOT/update-cask.sh" || true)
    if [ "$echo_count" -ge 3 ]; then
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${NC} PASS: Script outputs debug information (found $echo_count echo statements)"
    else
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗${NC} FAIL: Script should output debug information"
    fi
}

# Test 19: Script validates environment (gh CLI availability check would be in integration tests)
test_script_structure() {
    echo -e "\n${YELLOW}Test Suite: Script Structure Validation${NC}"
    # Verify script has reasonable line count
    local line_count=$(wc -l < "$REPO_ROOT/update-cask.sh")
    if [ "$line_count" -ge 20 ] && [ "$line_count" -le 100 ]; then
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${NC} PASS: Script has reasonable length ($line_count lines)"
    else
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗${NC} FAIL: Script length is unusual ($line_count lines)"
    fi
}

# Test 20: Script uses proper quoting
test_variable_quoting() {
    echo -e "\n${YELLOW}Test Suite: Variable Quoting${NC}"
    local content=$(cat "$REPO_ROOT/update-cask.sh")
    # Check for proper quoting patterns
    assert_contains "$content" '"$LATEST_VERSION"' "Script properly quotes LATEST_VERSION"
    assert_contains "$content" '"$SHA256"' "Script properly quotes SHA256"
    assert_contains "$content" '"$DOWNLOAD_URL"' "Script properly quotes DOWNLOAD_URL"
}

# Run all tests
main() {
    echo -e "${YELLOW}========================================${NC}"
    echo -e "${YELLOW}Running Update-Cask.sh Test Suite${NC}"
    echo -e "${YELLOW}========================================${NC}"
    
    test_script_exists
    test_script_executable
    test_shebang
    test_error_handling
    test_required_variables
    test_version_validation
    test_sha256_validation
    test_gh_usage
    test_download_url_construction
    test_curl_usage
    test_sha256_calculation
    test_sed_usage
    test_temp_file_handling
    test_repo_reference
    test_cask_file_path
    test_cask_file_exists
    test_version_format
    test_error_messages
    test_debug_output
    test_script_structure
    test_variable_quoting
    
    # Print summary
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