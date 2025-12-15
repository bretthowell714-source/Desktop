# Test Suite for Desktop Repository

This directory contains comprehensive tests for the shell scripts in the Termix Desktop repository.

## Overview

The test suite uses [Bats](https://github.com/bats-core/bats-core) (Bash Automated Testing System) to provide thorough testing coverage for:

1. **update-cask.sh** - Homebrew Cask update automation (61 tests)
2. **prepare-flatpak.sh** - Flatpak package preparation (86 tests)
3. **build-flatpak-bundle.sh** - Flatpak bundle building (85 tests)

**Total: 232 comprehensive tests**

## Prerequisites

### Install Bats

**macOS:**
```bash
brew install bats-core
```

**Linux (Debian/Ubuntu):**
```bash
sudo apt-get update
sudo apt-get install bats
```

**Linux (Arch):**
```bash
sudo pacman -S bats
```

**From Source:**
```bash
git clone https://github.com/bats-core/bats-core.git
cd bats-core
sudo ./install.sh /usr/local
```

### Optional Tools

**ShellCheck** (for static analysis):
```bash
# macOS
brew install shellcheck

# Linux
sudo apt-get install shellcheck
```

## Running Tests

### Run all tests:
```bash
cd /path/to/Desktop
bats tests/
```

### Run specific test file:
```bash
bats tests/test_update_cask.bats
bats tests/test_prepare_flatpak.bats
bats tests/test_build_flatpak_bundle.bats
```

### Run with verbose output:
```bash
bats -t tests/
```

### Run with TAP (Test Anything Protocol) output:
```bash
bats --tap tests/
```

### Run with timing information:
```bash
bats --timing tests/
```

### Run specific test by name:
```bash
bats tests/ --filter "update-cask.sh has correct shebang"
```

## Test Coverage

### update-cask.sh Tests (61 tests)

**Structural Tests:**
- Script existence and permissions
- Shebang validation
- Error handling configuration (`set -e`)

**Variable Definition Tests:**
- REPO variable validation
- CASK_FILE path construction with dirname
- LATEST_VERSION extraction pipeline

**GitHub CLI Integration:**
- gh command usage and flags
- JSON output parsing with jq
- Version tag format handling (release-X.Y.Z-tag)

**Version Processing:**
- Prefix removal (`release-`)
- Suffix removal (`-tag`)
- Multi-part version handling
- Empty version validation and error handling

**Download & Checksum:**
- URL construction for GitHub releases
- curl configuration (silent mode, follow redirects)
- SHA256 calculation with shasum
- Checksum validation and error handling

**File Updates:**
- sed pattern matching for version and sha256
- Temporary file usage for safe updates
- Atomic file replacement with mv

**Cask File Validation:**
- Ruby DSL structure
- Required fields presence (version, sha256, url, name, desc, homepage)
- URL interpolation with #{version}
- Livecheck configuration with github_latest strategy
- Zap trash entries for cleanup

### prepare-flatpak.sh Tests (86 tests)

**Argument Validation:**
- VERSION parameter handling
- CHECKSUM parameter handling
- RELEASE_DATE parameter handling
- Complete validation logic with error messages
- Usage message validation with examples

**Icon Processing:**
- SVG icon copying from public directory
- ImageMagick convert command detection
- PNG generation (256x256, 128x128)
- Fallback handling when ImageMagick unavailable
- Success and warning messages

**Manifest Updates:**
- VERSION_PLACEHOLDER replacement
- CHECKSUM_PLACEHOLDER replacement (x64)
- sed in-place editing with -i flag
- Global replacement flag usage

**Metainfo Updates:**
- VERSION_PLACEHOLDER replacement in XML
- DATE_PLACEHOLDER replacement
- XML structure preservation

**File Structure Validation:**
- Manifest YAML structure and syntax
- Runtime and SDK configuration
- Permission declarations (network, IPC, filesystem, ssh-auth)
- Module definitions and build commands
- Architecture support (x86_64, aarch64)

**Desktop File Validation:**
- Desktop Entry format compliance
- Name, Exec, Icon fields
- Category assignments (Development, Network, System)
- Keyword definitions for searchability

**Metainfo XML Validation:**
- XML declaration and structure
- Component type specification
- License declarations (metadata and project)
- Release information structure
- URL elements (homepage, bugtracker, help)

### build-flatpak-bundle.sh Tests (85 tests)

**Four-Argument Validation:**
- VERSION parameter capture
- CHECKSUM_X64 parameter capture
- CHECKSUM_ARM64 parameter capture
- RELEASE_DATE parameter capture
- Complete validation with error handling

**Script Integration:**
- prepare-flatpak.sh invocation
- Correct argument passing
- ARM64 checksum separate handling
- Comment documentation verification

**flatpak-builder Tests:**
- Command invocation verification
- Flag usage (--repo, --force-clean)
- Build directory specification
- Manifest file usage

**Bundle Creation:**
- flatpak build-bundle command
- Repository path specification
- Output file naming (.flatpak)
- App-id specification
- Branch targeting (stable)

**flatpakref Updates:**
- VERSION_PLACEHOLDER replacement
- sed global replacement verification
- File path correctness

**Output Messages:**
- Progress indicators
- Success confirmations with checkmarks
- Generated files list
- Installation instructions
- Alternative installation methods

**File Validation:**
- flatpakref structure and fields
- Flathub.json format and architecture list
- README documentation coverage
- Supporting script presence and executability

## Test Structure

Each test file follows this pattern:

```bash
#!/usr/bin/env bats

setup() {
  # Prepare test environment
  # Create backups of files to be modified
  # Set environment variables
}

teardown() {
  # Restore backups
  # Clean up artifacts
  # Reset state
}

@test "descriptive test name that explains what is being tested" {
  # Test implementation
  run command_to_test
  [ "${status}" -eq 0 ]
  [[ "${output}" =~ expected_pattern ]]
}
```

## Continuous Integration

### GitHub Actions Example

Create `.github/workflows/test.yml`:

```yaml
name: Test Shell Scripts

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Install Bats
        run: |
          sudo apt-get update
          sudo apt-get install -y bats
      
      - name: Run tests
        run: bats tests/
      
      - name: Run ShellCheck (optional)
        run: |
          sudo apt-get install -y shellcheck
          shellcheck *.sh flatpak/*.sh
```

### GitLab CI Example

Create `.gitlab-ci.yml`:

```yaml
test:
  image: ubuntu:latest
  before_script:
    - apt-get update
    - apt-get install -y bats git
  script:
    - bats tests/
```

## Test Categories

### 1. Static Analysis Tests
- File existence and permissions
- Shebang validation (#!)
- Error handling presence (`set -e`)
- Variable definitions
- Comment documentation

### 2. Functional Tests
- Argument parsing and validation
- Command execution flow
- File operations (copy, move, sed)
- String manipulations
- Conditional logic

### 3. Integration Tests
- Script-to-script invocation
- Multi-step processes
- External command verification
- File system interactions

### 4. Validation Tests
- Configuration file structure
- Placeholder presence and format
- Output message verification
- Return code checking

### 5. Edge Case Tests
- Empty argument handling
- Multi-part version numbers
- Special characters in paths
- Missing external commands

## Writing New Tests

When adding new tests:

1. **Follow naming conventions:**
   ```bash
   @test "component: specific behavior being tested" {
     # test implementation
   }
   ```

2. **Include setup/teardown:**
   ```bash
   setup() {
     # Backup files that will be modified
     # Set test-specific environment variables
   }
   
   teardown() {
     # Restore original files
     # Clean up test artifacts
   }
   ```

3. **Use descriptive assertions:**
   ```bash
   run command_to_test
   [ "${status}" -eq 0 ]  # Check exit code
   [[ "${output}" =~ pattern ]]  # Check output content
   ```

4. **Test both success and failure paths:**
   ```bash
   @test "script handles missing argument" {
     run script.sh
     [ "${status}" -ne 0 ]
     [[ "${output}" =~ "Usage:" ]]
   }
   ```

5. **Document complex tests:**
   ```bash
   @test "complex behavior" {
     # Setup: create test fixture
     # Action: run command
     # Assert: verify results
     # Cleanup: handled by teardown()
   }
   ```

## Troubleshooting

### Tests fail with "command not found"
**Solution:** Ensure Bats is properly installed and in your PATH:
```bash
which bats
bats --version
```

### Tests fail due to file modifications
**Solution:** Check that teardown() is properly restoring backups:
```bash
ls -la Casks/*.backup
ls -la flatpak/*.backup
```

### Permission denied errors
**Solution:** Ensure scripts have execute permissions:
```bash
chmod +x update-cask.sh
chmod +x flatpak/*.sh
```

### sed -i behaves differently on macOS
**Solution:** Tests account for this by using portable sed patterns. If issues persist, install GNU sed:
```bash
brew install gnu-sed
```

## Best Practices

1. **Isolation:** Each test should be independent and not rely on other tests
2. **Cleanup:** Always clean up in teardown() to prevent side effects
3. **Assertions:** Use clear, specific assertions with helpful error messages
4. **Coverage:** Test both happy paths and error conditions
5. **Documentation:** Comment complex test logic
6. **Speed:** Keep tests fast by avoiding unnecessary external calls
7. **Determinism:** Tests should produce consistent results

## Contributing

When contributing changes to scripts:

1. Add corresponding tests to the appropriate test file
2. Ensure all existing tests still pass
3. Add integration tests for new features
4. Update this README if adding new test categories
5. Run the full test suite before submitting PR:
   ```bash
   bats tests/
   ```

## Test Statistics

- **Total Tests:** 232
- **Test Files:** 3
- **Average Tests per File:** 77
- **Coverage Areas:** 15+
- **Lines of Test Code:** ~1,400

## Key Testing Patterns

### Testing sed replacements
```bash
@test "sed replacement preserves structure" {
  local test_file="${BATS_TMPDIR}/test.rb"
  echo 'version "1.0.0"' > "${test_file}"
  sed -e 's/version ".*"/version "2.0.0"/' "${test_file}" > "${test_file}.tmp"
  run grep 'version "2.0.0"' "${test_file}.tmp"
  [ "${status}" -eq 0 ]
  rm -f "${test_file}" "${test_file}.tmp"
}
```

### Testing command pipelines
```bash
@test "version extraction pipeline works correctly" {
  local test_tag="release-1.9.0-tag"
  local result=$(echo "${test_tag}" | sed 's/release-//' | sed 's/-tag//')
  [ "${result}" = "1.9.0" ]
}
```

### Testing file structure
```bash
@test "cask file has required fields" {
  run grep 'version' "${CASK_FILE}"
  [ "${status}" -eq 0 ]
  run grep 'sha256' "${CASK_FILE}"
  [ "${status}" -eq 0 ]
}
```

## License

These tests are part of the Desktop repository and follow the same license (see LICENSE file in repository root).

## Support

For issues or questions about the test suite:
- Open an issue in the repository
- Check existing tests for examples
- Review Bats documentation: https://bats-core.readthedocs.io/

---

**Last Updated:** December 2024  
**Bats Version:** 1.11.0+  
**Maintainer:** Desktop Repository Contributors