#!/bin/bash
# Unit tests for flatpak/build-flatpak-bundle.sh
# This test suite validates the build-flatpak-bundle.sh script functionality

set -e

# Test framework setup
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
TEST_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$TEST_SCRIPT_DIR/../.." && pwd)"
SCRIPT_PATH="$REPO_ROOT/flatpak/build-flatpak-bundle.sh"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

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
        echo "  String '$needle' not found"
        return 1
    fi
}

assert_line_count_greater_than() {
    local file="$1"
    local min_lines="$2"
    local test_name="$3"
    TESTS_RUN=$((TESTS_RUN + 1))
    local actual_lines=$(wc -l < "$file")
    if [ "$actual_lines" -gt "$min_lines" ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${NC} PASS: $test_name (found $actual_lines lines)"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗${NC} FAIL: $test_name"
        echo "  Expected more than $min_lines lines, found $actual_lines"
        return 1
    fi
}

# Test Suite 1: File existence and structure
test_script_exists() {
    echo -e "\n${YELLOW}Test Suite: Script Existence${NC}"
    assert_file_exists "$SCRIPT_PATH" "build-flatpak-bundle.sh exists"
}

test_script_executable() {
    TESTS_RUN=$((TESTS_RUN + 1))
    if [ -x "$SCRIPT_PATH" ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${NC} PASS: Script is executable"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗${NC} FAIL: Script is not executable"
    fi
}

test_shebang() {
    local shebang=$(head -n 1 "$SCRIPT_PATH")
    assert_contains "$shebang" "#!/bin/bash" "Script has correct shebang"
}

# Test Suite 2: Error handling
test_error_handling() {
    echo -e "\n${YELLOW}Test Suite: Error Handling${NC}"
    local content=$(cat "$SCRIPT_PATH")
    assert_contains "$content" "set -e" "Script uses 'set -e' for error handling"
}

# Test Suite 3: Argument validation
test_argument_parsing() {
    echo -e "\n${YELLOW}Test Suite: Argument Parsing${NC}"
    local content=$(cat "$SCRIPT_PATH")
    assert_contains "$content" 'VERSION="$1"' "Script parses VERSION argument"
    assert_contains "$content" 'CHECKSUM_X64="$2"' "Script parses CHECKSUM_X64 argument"
    assert_contains "$content" 'CHECKSUM_ARM64="$3"' "Script parses CHECKSUM_ARM64 argument"
    assert_contains "$content" 'RELEASE_DATE="$4"' "Script parses RELEASE_DATE argument"
}

test_argument_validation() {
    local content=$(cat "$SCRIPT_PATH")
    assert_contains "$content" 'if \[ -z "$VERSION" \]' "Script validates VERSION is provided"
    assert_contains "$content" 'if \[ -z "$VERSION" \].*\[ -z "$CHECKSUM_X64" \]' "Script validates all required arguments"
    assert_contains "$content" "Usage:" "Script provides usage information"
    assert_contains "$content" "exit 1" "Script exits on missing arguments"
}

# Test Suite 4: Usage documentation
test_usage_message() {
    echo -e "\n${YELLOW}Test Suite: Usage Documentation${NC}"
    local content=$(cat "$SCRIPT_PATH")
    assert_contains "$content" "Usage:" "Script has usage message"
    assert_contains "$content" "Example:" "Script provides example usage"
    assert_contains "$content" "<version>" "Usage shows version parameter"
    assert_contains "$content" "<checksum-x64>" "Usage shows x64 checksum parameter"
    assert_contains "$content" "<checksum-arm64>" "Usage shows arm64 checksum parameter"
    assert_contains "$content" "<release-date>" "Usage shows release-date parameter"
}

# Test Suite 5: Script calls prepare-flatpak.sh
test_prepare_script_invocation() {
    echo -e "\n${YELLOW}Test Suite: Prepare Script Integration${NC}"
    local content=$(cat "$SCRIPT_PATH")
    assert_contains "$content" "./prepare-flatpak.sh" "Script calls prepare-flatpak.sh"
    assert_contains "$content" '"$VERSION".*"$CHECKSUM_X64".*"$RELEASE_DATE"' "Script passes correct arguments to prepare-flatpak.sh"
}

# Test Suite 6: ARM64 checksum replacement
test_arm64_checksum_replacement() {
    echo -e "\n${YELLOW}Test Suite: ARM64 Checksum Handling${NC}"
    local content=$(cat "$SCRIPT_PATH")
    assert_contains "$content" "sed.*CHECKSUM_ARM64_PLACEHOLDER" "Script replaces ARM64 checksum placeholder"
    assert_contains "$content" "CHECKSUM_ARM64_PLACEHOLDER.*CHECKSUM_ARM64" "Script uses correct ARM64 checksum variable"
    assert_contains "$content" "com.karmaa.termix.yml" "Script modifies the correct YAML file"
}

# Test Suite 7: Flatpak build commands
test_flatpak_builder_command() {
    echo -e "\n${YELLOW}Test Suite: Flatpak Build Commands${NC}"
    local content=$(cat "$SCRIPT_PATH")
    assert_contains "$content" "flatpak-builder" "Script uses flatpak-builder command"
    assert_contains "$content" "--repo=repo" "Script specifies repository directory"
    assert_contains "$content" "--force-clean" "Script uses force-clean option"
    assert_contains "$content" "build-dir" "Script specifies build directory"
}

test_flatpak_bundle_command() {
    local content=$(cat "$SCRIPT_PATH")
    assert_contains "$content" "flatpak build-bundle" "Script creates flatpak bundle"
    assert_contains "$content" "com.karmaa.termix.flatpak" "Script creates correct bundle file"
    assert_contains "$content" "com.karmaa.termix" "Script uses correct app ID"
    assert_contains "$content" "stable" "Script targets stable branch"
}

# Test Suite 8: Flatpakref file update
test_flatpakref_update() {
    echo -e "\n${YELLOW}Test Suite: Flatpakref File Update${NC}"
    local content=$(cat "$SCRIPT_PATH")
    assert_contains "$content" "com.karmaa.termix.flatpakref" "Script updates flatpakref file"
    assert_contains "$content" "VERSION_PLACEHOLDER" "Script replaces version placeholder"
}

# Test Suite 9: User feedback
test_status_messages() {
    echo -e "\n${YELLOW}Test Suite: Status Messages${NC}"
    local content=$(cat "$SCRIPT_PATH")
    assert_contains "$content" "Building Flatpak bundle" "Script shows build start message"
    assert_contains "$content" "Building Flatpak package" "Script shows package build message"
    assert_contains "$content" "Creating Flatpak bundle" "Script shows bundle creation message"
    assert_contains "$content" "Updating .flatpakref file" "Script shows flatpakref update message"
    assert_contains "$content" "Build complete" "Script shows completion message"
}

test_output_documentation() {
    local content=$(cat "$SCRIPT_PATH")
    assert_contains "$content" "Generated files:" "Script documents generated files"
    assert_contains "$content" "Users can install with:" "Script provides installation instructions"
    assert_contains "$content" "flatpak install" "Script shows flatpak install command"
}

# Test Suite 10: File references
test_file_references() {
    echo -e "\n${YELLOW}Test Suite: File References${NC}"
    local content=$(cat "$SCRIPT_PATH")
    assert_contains "$content" "com.karmaa.termix.yml" "Script references manifest file"
    assert_contains "$content" "com.karmaa.termix.flatpakref" "Script references flatpakref file"
    assert_contains "$content" "com.karmaa.termix.flatpak" "Script references bundle file"
}

# Test Suite 11: Installation instructions
test_installation_urls() {
    echo -e "\n${YELLOW}Test Suite: Installation Instructions${NC}"
    local content=$(cat "$SCRIPT_PATH")
    assert_contains "$content" "termix-ssh.github.io" "Script provides hosted URL"
    assert_contains "$content" "--from" "Script shows --from flag for remote install"
}

# Test Suite 12: Script comments
test_inline_comments() {
    echo -e "\n${YELLOW}Test Suite: Code Documentation${NC}"
    local content=$(cat "$SCRIPT_PATH")
    local comment_count=$(grep -c "^#" "$SCRIPT_PATH" || true)
    TESTS_RUN=$((TESTS_RUN + 1))
    if [ "$comment_count" -ge 5 ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${NC} PASS: Script has adequate comments ($comment_count comment lines)"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗${NC} FAIL: Script should have more comments (found $comment_count)"
    fi
}

# Test Suite 13: Output formatting
test_output_formatting() {
    echo -e "\n${YELLOW}Test Suite: Output Formatting${NC}"
    local content=$(cat "$SCRIPT_PATH")
    assert_contains "$content" "echo \"\"" "Script uses blank lines for formatting"
    assert_contains "$content" "✓" "Script uses checkmark for success indication"
}

# Test Suite 14: Script length validation
test_script_length() {
    echo -e "\n${YELLOW}Test Suite: Script Structure${NC}"
    assert_line_count_greater_than "$SCRIPT_PATH" 30 "Script has substantial content"
}

# Run all tests
main() {
    echo -e "${YELLOW}========================================${NC}"
    echo -e "${YELLOW}Running Build-Flatpak-Bundle.sh Tests${NC}"
    echo -e "${YELLOW}========================================${NC}"
    
    test_script_exists
    test_script_executable
    test_shebang
    test_error_handling
    test_argument_parsing
    test_argument_validation
    test_usage_message
    test_prepare_script_invocation
    test_arm64_checksum_replacement
    test_flatpak_builder_command
    test_flatpak_bundle_command
    test_flatpakref_update
    test_status_messages
    test_output_documentation
    test_file_references
    test_installation_urls
    test_inline_comments
    test_output_formatting
    test_script_length
    
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