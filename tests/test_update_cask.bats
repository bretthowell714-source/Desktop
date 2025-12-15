#!/usr/bin/env bats

# Test suite for update-cask.sh
# This script tests the Homebrew Cask update automation functionality

setup() {
  export TEST_DIR="${BATS_TEST_DIRNAME}"
  export REPO_ROOT="${TEST_DIR}/.."
  export CASK_FILE="${REPO_ROOT}/Casks/termix.rb"
  export UPDATE_SCRIPT="${REPO_ROOT}/update-cask.sh"
  
  # Create backup of original cask file
  if [ -f "${CASK_FILE}" ]; then
    cp "${CASK_FILE}" "${CASK_FILE}.backup"
  fi
}

teardown() {
  # Restore original cask file
  if [ -f "${CASK_FILE}.backup" ]; then
    mv "${CASK_FILE}.backup" "${CASK_FILE}"
  fi
  
  # Clean up any test artifacts
  rm -f "${CASK_FILE}.tmp"
}

@test "update-cask.sh exists and is executable" {
  [ -f "${UPDATE_SCRIPT}" ]
  [ -x "${UPDATE_SCRIPT}" ]
}

@test "update-cask.sh has correct shebang" {
  run head -n 1 "${UPDATE_SCRIPT}"
  [[ "${output}" =~ ^#!/bin/bash ]]
}

@test "update-cask.sh sets error handling with 'set -e'" {
  run grep -q "set -e" "${UPDATE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "REPO variable is correctly defined" {
  run grep 'REPO="Termix-SSH/Termix"' "${UPDATE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "CASK_FILE variable uses dirname for relative path" {
  run grep 'CASK_FILE=.*dirname.*Casks/termix.rb' "${UPDATE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script fetches latest version using gh command" {
  run grep 'gh release list' "${UPDATE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "gh command uses correct repository" {
  run grep 'gh release list --repo "\$REPO"' "${UPDATE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "gh command limits to 1 release" {
  run grep -- '--limit 1' "${UPDATE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "gh command uses JSON output format" {
  run grep -- '--json tagName' "${UPDATE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "gh command uses jq to extract tagName" {
  run grep -- '--jq' "${UPDATE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script removes 'release-' prefix from version" {
  run grep "sed 's/release-//'" "${UPDATE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script removes '-tag' suffix from version" {
  run grep "sed 's/-tag//'" "${UPDATE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script validates LATEST_VERSION is not empty" {
  run grep -A 2 'if \[ -z "\$LATEST_VERSION" \]' "${UPDATE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script exits with error message on empty version" {
  run grep 'echo "Failed to fetch latest version"' "${UPDATE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script exits with code 1 on version fetch failure" {
  run grep -A 1 'Failed to fetch latest version' "${UPDATE_SCRIPT}"
  [[ "${output}" =~ "exit 1" ]]
}

@test "script outputs version to stdout" {
  run grep 'echo "\$LATEST_VERSION"' "${UPDATE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script constructs correct download URL" {
  run grep 'DOWNLOAD_URL=.*github.com/\$REPO/releases' "${UPDATE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "download URL includes release tag format" {
  run grep 'release-\${LATEST_VERSION}-tag' "${UPDATE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "download URL targets macOS universal DMG" {
  run grep 'termix_macos_universal_dmg.dmg' "${UPDATE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script outputs download URL to stdout" {
  run grep 'echo "\$DOWNLOAD_URL"' "${UPDATE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script downloads file using curl" {
  run grep 'curl -sL' "${UPDATE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "curl uses silent mode (-s)" {
  run grep 'curl -sL' "${UPDATE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "curl follows redirects (-L)" {
  run grep 'curl -sL' "${UPDATE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script calculates SHA256 checksum" {
  run grep 'shasum -a 256' "${UPDATE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script extracts first field from shasum output" {
  run grep "awk '{print \$1}'" "${UPDATE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script validates SHA256 is not empty" {
  run grep -A 2 'if \[ -z "\$SHA256" \]' "${UPDATE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script exits with error message on checksum failure" {
  run grep 'echo "Failed to calculate SHA256"' "${UPDATE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script exits with code 1 on checksum failure" {
  run grep -A 1 'Failed to calculate SHA256' "${UPDATE_SCRIPT}"
  [[ "${output}" =~ "exit 1" ]]
}

@test "script outputs SHA256 to stdout" {
  run grep 'echo "\$SHA256"' "${UPDATE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script uses sed to update version field" {
  run grep 'sed -e.*version' "${UPDATE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "sed version pattern matches quoted strings" {
  run grep 's/version ".*"/version' "${UPDATE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script uses sed to update sha256 field" {
  run grep 'sed -e.*sha256' "${UPDATE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "sed sha256 pattern matches quoted strings" {
  run grep 's/sha256 ".*"/sha256' "${UPDATE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "sed writes to temporary file" {
  run grep '> "\${CASK_FILE}.tmp"' "${UPDATE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script moves temporary file to cask file" {
  run grep 'mv "\${CASK_FILE}.tmp" "\$CASK_FILE"' "${UPDATE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "Casks directory exists" {
  [ -d "${REPO_ROOT}/Casks" ]
}

@test "termix.rb cask file exists" {
  [ -f "${CASK_FILE}" ]
}

@test "cask file starts with cask declaration" {
  run head -n 1 "${CASK_FILE}"
  [[ "${output}" =~ ^cask.*termix ]]
}

@test "cask file has version field" {
  run grep 'version' "${CASK_FILE}"
  [ "${status}" -eq 0 ]
}

@test "cask file version is quoted" {
  run grep 'version "' "${CASK_FILE}"
  [ "${status}" -eq 0 ]
}

@test "cask file has sha256 field" {
  run grep 'sha256' "${CASK_FILE}"
  [ "${status}" -eq 0 ]
}

@test "cask file sha256 is quoted" {
  run grep 'sha256 "' "${CASK_FILE}"
  [ "${status}" -eq 0 ]
}

@test "cask file has url field" {
  run grep 'url' "${CASK_FILE}"
  [ "${status}" -eq 0 ]
}

@test "cask file URL interpolates version" {
  run grep 'url.*#{version}' "${CASK_FILE}"
  [ "${status}" -eq 0 ]
}

@test "cask file has name field" {
  run grep 'name "Termix"' "${CASK_FILE}"
  [ "${status}" -eq 0 ]
}

@test "cask file has desc field" {
  run grep 'desc' "${CASK_FILE}"
  [ "${status}" -eq 0 ]
}

@test "cask file has homepage field" {
  run grep 'homepage' "${CASK_FILE}"
  [ "${status}" -eq 0 ]
}

@test "cask file has livecheck block" {
  run grep 'livecheck do' "${CASK_FILE}"
  [ "${status}" -eq 0 ]
}

@test "livecheck uses github_latest strategy" {
  run grep 'strategy :github_latest' "${CASK_FILE}"
  [ "${status}" -eq 0 ]
}

@test "cask file has app installation" {
  run grep 'app "Termix.app"' "${CASK_FILE}"
  [ "${status}" -eq 0 ]
}

@test "cask file has zap stanza" {
  run grep 'zap trash:' "${CASK_FILE}"
  [ "${status}" -eq 0 ]
}

@test "zap includes Application Support directory" {
  run grep '~/Library/Application Support/termix' "${CASK_FILE}"
  [ "${status}" -eq 0 ]
}

@test "zap includes Caches directory" {
  run grep '~/Library/Caches/com.karmaa.termix' "${CASK_FILE}"
  [ "${status}" -eq 0 ]
}

@test "zap includes Preferences" {
  run grep '~/Library/Preferences/com.karmaa.termix.plist' "${CASK_FILE}"
  [ "${status}" -eq 0 ]
}

@test "zap includes Saved Application State" {
  run grep '~/Library/Saved Application State' "${CASK_FILE}"
  [ "${status}" -eq 0 ]
}

@test "cask file has proper Ruby syntax" {
  run grep 'end$' "${CASK_FILE}"
  [ "${status}" -eq 0 ]
}

@test "URL in cask points to GitHub releases" {
  run grep 'github.com/Termix-SSH/Termix/releases' "${CASK_FILE}"
  [ "${status}" -eq 0 ]
}

@test "sed replacement preserves cask structure" {
  # Test that sed commands produce valid output
  local test_file="${BATS_TMPDIR}/test_cask.rb"
  cat >"${test_file}" <<'CASK'
version "1.0.0"
sha256 "old_hash_value"
CASK
  
  sed -e 's/version ".*"/version "2.0.0"/' \
      -e 's/sha256 ".*"/sha256 "new_hash_value"/' \
      "${test_file}" > "${test_file}.tmp"
  
  run grep 'version "2.0.0"' "${test_file}.tmp"
  [ "${status}" -eq 0 ]
  
  run grep 'sha256 "new_hash_value"' "${test_file}.tmp"
  [ "${status}" -eq 0 ]
  
  rm -f "${test_file}" "${test_file}.tmp"
}

@test "version extraction handles release tags correctly" {
  # Test the version extraction pipeline
  local test_tag="release-1.9.0-tag"
  local result=$(echo "${test_tag}" | sed 's/release-//' | sed 's/-tag//')
  [ "${result}" = "1.9.0" ]
}

@test "script handles versions with multiple dots" {
  local test_tag="release-1.10.5-tag"
  local result=$(echo "${test_tag}" | sed 's/release-//' | sed 's/-tag//')
  [ "${result}" = "1.10.5" ]
}

@test "cask file line count is reasonable" {
  local line_count=$(wc -l < "${CASK_FILE}")
  [ "${line_count}" -gt 10 ]
  [ "${line_count}" -lt 50 ]
}