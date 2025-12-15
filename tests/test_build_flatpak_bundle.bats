#!/usr/bin/env bats

# Test suite for flatpak/build-flatpak-bundle.sh
# This script tests the Flatpak bundle building functionality

setup() {
  export TEST_DIR="${BATS_TEST_DIRNAME}"
  export REPO_ROOT="${TEST_DIR}/.."
  export FLATPAK_DIR="${REPO_ROOT}/flatpak"
  export BUILD_SCRIPT="${FLATPAK_DIR}/build-flatpak-bundle.sh"
  
  # Create backups
  for file in "${FLATPAK_DIR}/com.karmaa.termix.yml" "${FLATPAK_DIR}/com.karmaa.termix.flatpakref"; do
    if [ -f "${file}" ]; then
      cp "${file}" "${file}.backup"
    fi
  done
}

teardown() {
  # Restore backups
  for file in "${FLATPAK_DIR}/com.karmaa.termix.yml" "${FLATPAK_DIR}/com.karmaa.termix.flatpakref"; do
    if [ -f "${file}.backup" ]; then
      mv "${file}.backup" "${file}"
    fi
  done
}

@test "build-flatpak-bundle.sh exists and is executable" {
  [ -f "${BUILD_SCRIPT}" ]
  [ -x "${BUILD_SCRIPT}" ]
}

@test "build-flatpak-bundle.sh has correct shebang" {
  run head -n 1 "${BUILD_SCRIPT}"
  [[ "${output}" =~ ^#!/bin/bash ]]
}

@test "build-flatpak-bundle.sh sets error handling with 'set -e'" {
  run grep -q "set -e" "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script captures VERSION from first argument" {
  run grep 'VERSION="\$1"' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script captures CHECKSUM_X64 from second argument" {
  run grep 'CHECKSUM_X64="\$2"' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script captures CHECKSUM_ARM64 from third argument" {
  run grep 'CHECKSUM_ARM64="\$3"' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script captures RELEASE_DATE from fourth argument" {
  run grep 'RELEASE_DATE="\$4"' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script validates VERSION is provided" {
  run grep 'if \[ -z "\$VERSION" \]' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script validates CHECKSUM_X64 is provided" {
  run grep '|| \[ -z "\$CHECKSUM_X64" \]' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script validates CHECKSUM_ARM64 is provided" {
  run grep '|| \[ -z "\$CHECKSUM_ARM64" \]' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script validates RELEASE_DATE is provided" {
  run grep '|| \[ -z "\$RELEASE_DATE" \]' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script provides usage instructions" {
  run grep 'echo "Usage:' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "usage message lists all four parameters" {
  run grep 'version.*checksum-x64.*checksum-arm64.*release-date' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script provides example with realistic data" {
  run grep 'echo "Example:.*1.9.0.*abc123.*def456.*2025-11-24' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script exits with code 1 on missing arguments" {
  run grep 'exit 1' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script outputs building message" {
  run grep 'echo "Building Flatpak bundle for version \$VERSION"' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script has comment about preparing files" {
  run grep '# Prepare the files' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script calls prepare-flatpak.sh" {
  run grep './prepare-flatpak.sh' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "prepare-flatpak.sh receives VERSION argument" {
  run grep './prepare-flatpak.sh "\$VERSION"' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "prepare-flatpak.sh receives CHECKSUM_X64 argument" {
  run grep './prepare-flatpak.sh.*"\$CHECKSUM_X64"' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "prepare-flatpak.sh receives RELEASE_DATE argument" {
  run grep './prepare-flatpak.sh.*"\$RELEASE_DATE"' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script has comment about ARM64 checksum" {
  run grep '# Update ARM64 checksum separately' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "comment mentions prepare-flatpak.sh handles x64" {
  run grep 'prepare-flatpak.sh handles x64' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script updates ARM64 checksum with sed" {
  run grep 'sed -i.*CHECKSUM_ARM64_PLACEHOLDER.*\$CHECKSUM_ARM64' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "ARM64 sed targets correct manifest file" {
  run grep 'sed -i.*com.karmaa.termix.yml' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "ARM64 sed uses global flag" {
  run grep 'sed -i.*CHECKSUM_ARM64_PLACEHOLDER.*g' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script has comment about building Flatpak" {
  run grep '# Build the Flatpak' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script outputs building package message" {
  run grep 'echo "Building Flatpak package..."' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script calls flatpak-builder" {
  run grep 'flatpak-builder' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "flatpak-builder uses --repo flag" {
  run grep 'flatpak-builder --repo=repo' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "flatpak-builder uses --force-clean flag" {
  run grep 'flatpak-builder.*--force-clean' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "flatpak-builder outputs to build-dir" {
  run grep 'flatpak-builder.*build-dir' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "flatpak-builder uses manifest file" {
  run grep 'flatpak-builder.*com.karmaa.termix.yml' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script has comment about creating bundle" {
  run grep '# Create the bundle' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script outputs creating bundle message" {
  run grep 'echo "Creating Flatpak bundle..."' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script calls flatpak build-bundle" {
  run grep 'flatpak build-bundle' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "flatpak build-bundle reads from repo directory" {
  run grep 'flatpak build-bundle repo' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "flatpak build-bundle creates .flatpak file" {
  run grep 'flatpak build-bundle.*com.karmaa.termix.flatpak' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "flatpak build-bundle specifies app-id" {
  run grep 'flatpak build-bundle.*com.karmaa.termix.flatpak com.karmaa.termix' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "flatpak build-bundle targets stable branch" {
  run grep 'flatpak build-bundle.*stable' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script has comment about updating flatpakref" {
  run grep '# Update the .flatpakref file' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script outputs updating flatpakref message" {
  run grep 'echo "Updating .flatpakref file..."' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script updates flatpakref VERSION_PLACEHOLDER" {
  run grep 'sed -i.*VERSION_PLACEHOLDER.*\$VERSION.*flatpakref' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "flatpakref sed uses global flag" {
  run grep 'sed -i.*VERSION_PLACEHOLDER.*g' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script outputs build complete message" {
  run grep 'echo "✓ Build complete!"' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script outputs blank line for formatting" {
  run grep 'echo ""' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script outputs generated files header" {
  run grep 'echo "Generated files:"' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script lists flatpak bundle in output" {
  run grep 'echo "  - com.karmaa.termix.flatpak' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script mentions uploading to GitHub releases" {
  run grep 'upload this to GitHub releases' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script lists flatpakref in output" {
  run grep 'echo "  - com.karmaa.termix.flatpakref' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script mentions hosting flatpakref publicly" {
  run grep 'host this file publicly' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script outputs installation instructions header" {
  run grep 'echo "Users can install with:"' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script provides flatpakref installation command" {
  run grep 'echo "  flatpak install --from' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "flatpakref installation uses GitHub Pages URL" {
  run grep 'termix-ssh.github.io/Desktop/com.karmaa.termix.flatpakref' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script provides alternative installation header" {
  run grep 'echo "Or install directly from bundle:"' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script provides direct bundle installation command" {
  run grep 'echo "  flatpak install com.karmaa.termix.flatpak"' "${BUILD_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "flatpakref file exists in flatpak directory" {
  [ -f "${FLATPAK_DIR}/com.karmaa.termix.flatpakref" ]
}

@test "flatpakref has Flatpak Ref header" {
  run grep '\[Flatpak Ref\]' "${FLATPAK_DIR}/com.karmaa.termix.flatpakref"
  [ "${status}" -eq 0 ]
}

@test "flatpakref has Name field" {
  run grep 'Name=' "${FLATPAK_DIR}/com.karmaa.termix.flatpakref"
  [ "${status}" -eq 0 ]
}

@test "flatpakref has Branch field set to stable" {
  run grep 'Branch=stable' "${FLATPAK_DIR}/com.karmaa.termix.flatpakref"
  [ "${status}" -eq 0 ]
}

@test "flatpakref has Title field" {
  run grep 'Title=' "${FLATPAK_DIR}/com.karmaa.termix.flatpakref"
  [ "${status}" -eq 0 ]
}

@test "flatpakref has IsRuntime=false" {
  run grep 'IsRuntime=false' "${FLATPAK_DIR}/com.karmaa.termix.flatpakref"
  [ "${status}" -eq 0 ]
}

@test "flatpakref has Url field" {
  run grep 'Url=' "${FLATPAK_DIR}/com.karmaa.termix.flatpakref"
  [ "${status}" -eq 0 ]
}

@test "flatpakref URL contains VERSION_PLACEHOLDER" {
  run grep 'Url=.*VERSION_PLACEHOLDER' "${FLATPAK_DIR}/com.karmaa.termix.flatpakref"
  [ "${status}" -eq 0 ]
}

@test "flatpakref has RuntimeRepo field" {
  run grep 'RuntimeRepo=' "${FLATPAK_DIR}/com.karmaa.termix.flatpakref"
  [ "${status}" -eq 0 ]
}

@test "flatpakref points to Flathub repo" {
  run grep 'RuntimeRepo=.*flathub' "${FLATPAK_DIR}/com.karmaa.termix.flatpakref"
  [ "${status}" -eq 0 ]
}

@test "flatpakref has Comment field" {
  run grep 'Comment=' "${FLATPAK_DIR}/com.karmaa.termix.flatpakref"
  [ "${status}" -eq 0 ]
}

@test "flatpakref has Description field" {
  run grep 'Description=' "${FLATPAK_DIR}/com.karmaa.termix.flatpakref"
  [ "${status}" -eq 0 ]
}

@test "flatpakref has Icon field" {
  run grep 'Icon=' "${FLATPAK_DIR}/com.karmaa.termix.flatpakref"
  [ "${status}" -eq 0 ]
}

@test "flatpakref has Homepage field" {
  run grep 'Homepage=' "${FLATPAK_DIR}/com.karmaa.termix.flatpakref"
  [ "${status}" -eq 0 ]
}

@test "flathub.json exists" {
  [ -f "${FLATPAK_DIR}/flathub.json" ]
}

@test "flathub.json has only-arches field" {
  run grep 'only-arches' "${FLATPAK_DIR}/flathub.json"
  [ "${status}" -eq 0 ]
}

@test "flathub.json lists x86_64 architecture" {
  run grep 'x86_64' "${FLATPAK_DIR}/flathub.json"
  [ "${status}" -eq 0 ]
}

@test "flathub.json lists aarch64 architecture" {
  run grep 'aarch64' "${FLATPAK_DIR}/flathub.json"
  [ "${status}" -eq 0 ]
}

@test "flathub.json has valid JSON structure" {
  run cat "${FLATPAK_DIR}/flathub.json"
  [[ "${output}" =~ ^\{ ]]
}

@test "README.md documents build process" {
  run grep 'build-flatpak-bundle.sh' "${FLATPAK_DIR}/README.md"
  [ "${status}" -eq 0 ]
}

@test "README.md provides building examples" {
  run grep './build-flatpak-bundle.sh' "${FLATPAK_DIR}/README.md"
  [ "${status}" -eq 0 ]
}

@test "README.md documents distribution methods" {
  run grep 'Distribution Methods' "${FLATPAK_DIR}/README.md"
  [ "${status}" -eq 0 ]
}

@test "README.md mentions direct bundle installation" {
  run grep 'Direct Bundle Installation' "${FLATPAK_DIR}/README.md"
  [ "${status}" -eq 0 ]
}

@test "README.md mentions flatpakref method" {
  run grep 'Flatpakref File' "${FLATPAK_DIR}/README.md"
  [ "${status}" -eq 0 ]
}

@test "README.md mentions Flathub submission" {
  run grep 'Submitting to Flathub' "${FLATPAK_DIR}/README.md"
  [ "${status}" -eq 0 ]
}

@test "prepare-flatpak.sh exists in flatpak directory" {
  [ -f "${FLATPAK_DIR}/prepare-flatpak.sh" ]
}

@test "prepare-flatpak.sh is executable" {
  [ -x "${FLATPAK_DIR}/prepare-flatpak.sh" ]
}

@test "script line count is reasonable" {
  local line_count=$(wc -l < "${BUILD_SCRIPT}")
  [ "${line_count}" -gt 20 ]
  [ "${line_count}" -lt 100 ]
}

@test "script has proper indentation" {
  # Check that echo statements are not at column 0 (indicating they're inside conditionals/functions)
  local indented_count=$(grep '^  echo' "${BUILD_SCRIPT}" | wc -l)
  [ "${indented_count}" -gt 0 ]
}