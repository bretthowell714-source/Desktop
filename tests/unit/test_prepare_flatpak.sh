#!/bin/bash
# Unit tests for flatpak/prepare-flatpak.sh
# This test suite validates the prepare-flatpak.sh script functionality

set -e

# Test framework setup
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
TEST_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$TEST_SCRIPT_DIR/../.." && pwd)"
SCRIPT_PATH="$REPO_ROOT/flatpak/prepare-flatpak.sh"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test helper functions
assert_file_exists() {
    local file="$1"
    local test_name="$2"
    TESTS_RUN=$((TESTS_RUN + 1))
    if [ -f "$file" ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${NC} PASS: $test_name"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗${NC} FAIL: $test_name (file: $file)"
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
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗${NC} FAIL: $test_name"
    fi
}

# Test Suite 1: Basic structure
test_script_exists() {
    echo -e "\n${YELLOW}Test Suite: Script Existence${NC}"
    assert_file_exists "$SCRIPT_PATH" "prepare-flatpak.sh exists"
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
    assert_contains "$content" "set -e" "Script uses 'set -e'"
}

# Test Suite 3: Argument handling
test_argument_parsing() {
    echo -e "\n${YELLOW}Test Suite: Argument Handling${NC}"
    local content=$(cat "$SCRIPT_PATH")
    assert_contains "$content" 'VERSION="$1"' "Parses VERSION argument"
    assert_contains "$content" 'CHECKSUM="$2"' "Parses CHECKSUM argument"
    assert_contains "$content" 'RELEASE_DATE="$3"' "Parses RELEASE_DATE argument"
}

test_argument_validation() {
    local content=$(cat "$SCRIPT_PATH")
    assert_contains "$content" 'if \[ -z "$VERSION" \]' "Validates VERSION presence"
    assert_contains "$content" 'if \[ -z "$VERSION" \].*\[ -z "$CHECKSUM" \].*\[ -z "$RELEASE_DATE" \]' "Validates all arguments"
    assert_contains "$content" "Usage:" "Provides usage message"
    assert_contains "$content" "Example:" "Provides example"
}

# Test Suite 4: Icon handling
test_icon_operations() {
    echo -e "\n${YELLOW}Test Suite: Icon Operations${NC}"
    local content=$(cat "$SCRIPT_PATH")
    assert_contains "$content" "cp.*icon.svg" "Copies SVG icon"
    assert_contains "$content" "com.karmaa.termix.svg" "Names SVG correctly"
    assert_contains "$content" "convert" "Uses ImageMagick convert command"
    assert_contains "$content" "256x256" "Creates 256x256 icon"
    assert_contains "$content" "128x128" "Creates 128x128 icon"
}

test_imagemagick_detection() {
    local content=$(cat "$SCRIPT_PATH")
    assert_contains "$content" "command -v convert" "Checks for ImageMagick"
    assert_contains "$content" "&> /dev/null" "Suppresses command check output"
}

test_icon_fallback() {
    local content=$(cat "$SCRIPT_PATH")
    assert_contains "$content" "else" "Has fallback for missing ImageMagick"
    assert_contains "$content" "cp.*public/icon.png.*flatpak/icon-256.png" "Falls back to copying original icon"
}

# Test Suite 5: File updates
test_manifest_updates() {
    echo -e "\n${YELLOW}Test Suite: Manifest Updates${NC}"
    local content=$(cat "$SCRIPT_PATH")
    assert_contains "$content" "sed.*com.karmaa.termix.yml" "Updates YAML manifest"
    assert_contains "$content" "VERSION_PLACEHOLDER" "Replaces VERSION_PLACEHOLDER"
    assert_contains "$content" "CHECKSUM_PLACEHOLDER" "Replaces CHECKSUM_PLACEHOLDER"
}

test_metainfo_updates() {
    local content=$(cat "$SCRIPT_PATH")
    assert_contains "$content" "sed.*com.karmaa.termix.metainfo.xml" "Updates metainfo XML"
    assert_contains "$content" "DATE_PLACEHOLDER" "Replaces DATE_PLACEHOLDER"
}

# Test Suite 6: sed usage
test_sed_inplace_editing() {
    echo -e "\n${YELLOW}Test Suite: sed Operations${NC}"
    local content=$(cat "$SCRIPT_PATH")
    assert_contains "$content" "sed -i" "Uses sed in-place editing"
}

# Test Suite 7: Status messages
test_status_messages() {
    echo -e "\n${YELLOW}Test Suite: User Feedback${NC}"
    local content=$(cat "$SCRIPT_PATH")
    assert_contains "$content" "Preparing Flatpak submission" "Shows preparation message"
    assert_contains "$content" "Copied SVG icon" "Shows SVG copy confirmation"
    assert_contains "$content" "Generated PNG icons" "Shows PNG generation confirmation"
    assert_contains "$content" "Updated manifest" "Shows manifest update confirmation"
}

test_success_indicators() {
    local content=$(cat "$SCRIPT_PATH")
    assert_contains "$content" "✓" "Uses checkmark for success"
}

test_warning_messages() {
    local content=$(cat "$SCRIPT_PATH")
    assert_contains "$content" "⚠" "Uses warning symbol"
    assert_contains "$content" "ImageMagick not found" "Warns about missing ImageMagick"
}

# Test Suite 8: Path references
test_path_references() {
    echo -e "\n${YELLOW}Test Suite: Path References${NC}"
    local content=$(cat "$SCRIPT_PATH")
    assert_contains "$content" "public/icon.svg" "References public icon directory"
    assert_contains "$content" "public/icon.png" "References PNG icon"
    assert_contains "$content" "flatpak/" "References flatpak directory"
}

# Test Suite 9: File naming conventions
test_file_naming() {
    echo -e "\n${YELLOW}Test Suite: File Naming${NC}"
    local content=$(cat "$SCRIPT_PATH")
    assert_contains "$content" "com.karmaa.termix" "Uses consistent app ID"
}

# Test Suite 10: Example in usage
test_usage_example() {
    echo -e "\n${YELLOW}Test Suite: Usage Documentation${NC}"
    local content=$(cat "$SCRIPT_PATH")
    assert_contains "$content" "1.8.0" "Provides version example"
    assert_contains "$content" "abc123" "Provides checksum example"
    assert_contains "$content" "2025-10-26" "Provides date example"
}

# Run all tests
main() {
    echo -e "${YELLOW}========================================${NC}"
    echo -e "${YELLOW}Running Prepare-Flatpak.sh Tests${NC}"
    echo -e "${YELLOW}========================================${NC}"
    
    test_script_exists
    test_script_executable
    test_shebang
    test_error_handling
    test_argument_parsing
    test_argument_validation
    test_icon_operations
    test_imagemagick_detection
    test_icon_fallback
    test_manifest_updates
    test_metainfo_updates
    test_sed_inplace_editing
    test_status_messages
    test_success_indicators
    test_warning_messages
    test_path_references
    test_file_naming
    test_usage_example
    
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