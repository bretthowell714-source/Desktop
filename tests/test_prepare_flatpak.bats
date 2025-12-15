#!/usr/bin/env bats

# Test suite for flatpak/prepare-flatpak.sh
# This script tests the Flatpak package preparation functionality

setup() {
  export TEST_DIR="${BATS_TEST_DIRNAME}"
  export REPO_ROOT="${TEST_DIR}/.."
  export FLATPAK_DIR="${REPO_ROOT}/flatpak"
  export PREPARE_SCRIPT="${FLATPAK_DIR}/prepare-flatpak.sh"
  
  # Create backups of files that will be modified
  for file in "${FLATPAK_DIR}/com.karmaa.termix.yml" "${FLATPAK_DIR}/com.karmaa.termix.metainfo.xml"; do
    if [ -f "${file}" ]; then
      cp "${file}" "${file}.backup"
    fi
  done
}

teardown() {
  # Restore original files
  for file in "${FLATPAK_DIR}/com.karmaa.termix.yml" "${FLATPAK_DIR}/com.karmaa.termix.metainfo.xml"; do
    if [ -f "${file}.backup" ]; then
      mv "${file}.backup" "${file}"
    fi
  done
  
  # Clean up generated icon files
  rm -f "${FLATPAK_DIR}/com.karmaa.termix.svg"
  rm -f "${FLATPAK_DIR}/icon-256.png"
  rm -f "${FLATPAK_DIR}/icon-128.png"
}

@test "prepare-flatpak.sh exists and is executable" {
  [ -f "${PREPARE_SCRIPT}" ]
  [ -x "${PREPARE_SCRIPT}" ]
}

@test "prepare-flatpak.sh has correct shebang" {
  run head -n 1 "${PREPARE_SCRIPT}"
  [[ "${output}" =~ ^#!/bin/bash ]]
}

@test "prepare-flatpak.sh sets error handling with 'set -e'" {
  run grep -q "set -e" "${PREPARE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script captures VERSION from first argument" {
  run grep 'VERSION="\$1"' "${PREPARE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script captures CHECKSUM from second argument" {
  run grep 'CHECKSUM="\$2"' "${PREPARE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script captures RELEASE_DATE from third argument" {
  run grep 'RELEASE_DATE="\$3"' "${PREPARE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script validates VERSION is provided" {
  run grep 'if \[ -z "\$VERSION" \]' "${PREPARE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script validates CHECKSUM is provided" {
  run grep '|| \[ -z "\$CHECKSUM" \]' "${PREPARE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script validates RELEASE_DATE is provided" {
  run grep '|| \[ -z "\$RELEASE_DATE" \]' "${PREPARE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script provides usage instructions" {
  run grep 'echo "Usage:' "${PREPARE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "usage message includes all three parameters" {
  run grep 'Usage.*version.*checksum.*release-date' "${PREPARE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script provides example usage" {
  run grep 'echo "Example:' "${PREPARE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "example includes version format" {
  run grep 'Example.*1.8.0' "${PREPARE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "example includes date format" {
  run grep 'Example.*2025-10-26' "${PREPARE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script exits with code 1 on missing arguments" {
  run grep 'exit 1' "${PREPARE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script outputs preparation message" {
  run grep 'echo "Preparing Flatpak submission for version \$VERSION"' "${PREPARE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script copies SVG icon from public directory" {
  run grep 'cp public/icon.svg flatpak/com.karmaa.termix.svg' "${PREPARE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script confirms SVG icon copy" {
  run grep 'echo "✓ Copied SVG icon"' "${PREPARE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script checks for ImageMagick convert command" {
  run grep 'if command -v convert' "${PREPARE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "convert command check redirects output" {
  run grep 'command -v convert &> /dev/null' "${PREPARE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script generates 256x256 PNG icon with convert" {
  run grep 'convert public/icon.png -resize 256x256' "${PREPARE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "256x256 icon saved to correct location" {
  run grep 'convert.*256x256 flatpak/icon-256.png' "${PREPARE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script generates 128x128 PNG icon with convert" {
  run grep 'convert public/icon.png -resize 128x128' "${PREPARE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "128x128 icon saved to correct location" {
  run grep 'convert.*128x128 flatpak/icon-128.png' "${PREPARE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script confirms PNG icon generation" {
  run grep 'echo "✓ Generated PNG icons"' "${PREPARE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script has fallback when ImageMagick unavailable" {
  run grep 'else' "${PREPARE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "fallback copies original PNG as 256x256" {
  run grep 'cp public/icon.png flatpak/icon-256.png' "${PREPARE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "fallback copies original PNG as 128x128" {
  run grep 'cp public/icon.png flatpak/icon-128.png' "${PREPARE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "fallback shows warning message" {
  run grep 'echo "⚠ ImageMagick not found, using original icon"' "${PREPARE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script updates manifest VERSION_PLACEHOLDER with sed" {
  run grep 'sed -i "s/VERSION_PLACEHOLDER/\$VERSION/g" flatpak/com.karmaa.termix.yml' "${PREPARE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script updates manifest CHECKSUM_PLACEHOLDER with sed" {
  run grep 'sed -i "s/CHECKSUM_PLACEHOLDER/\$CHECKSUM/g" flatpak/com.karmaa.termix.yml' "${PREPARE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script confirms manifest update" {
  run grep 'echo "✓ Updated manifest with version \$VERSION"' "${PREPARE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script updates metainfo VERSION_PLACEHOLDER" {
  run grep 'sed -i "s/VERSION_PLACEHOLDER/\$VERSION/g" flatpak/com.karmaa.termix.metainfo.xml' "${PREPARE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "script updates metainfo DATE_PLACEHOLDER" {
  run grep 'sed -i "s/DATE_PLACEHOLDER/\$RELEASE_DATE/g" flatpak/com.karmaa.termix.metainfo.xml' "${PREPARE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "sed uses -i flag for in-place editing" {
  local sed_count=$(grep -c 'sed -i' "${PREPARE_SCRIPT}")
  [ "${sed_count}" -ge 4 ]
}

@test "sed uses global replacement flag" {
  run grep 'sed -i.*g"' "${PREPARE_SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "flatpak directory exists" {
  [ -d "${FLATPAK_DIR}" ]
}

@test "flatpak manifest file exists" {
  [ -f "${FLATPAK_DIR}/com.karmaa.termix.yml" ]
}

@test "flatpak metainfo file exists" {
  [ -f "${FLATPAK_DIR}/com.karmaa.termix.metainfo.xml" ]
}

@test "flatpak desktop file exists" {
  [ -f "${FLATPAK_DIR}/com.karmaa.termix.desktop" ]
}

@test "flatpak README exists" {
  [ -f "${FLATPAK_DIR}/README.md" ]
}

@test "manifest contains VERSION_PLACEHOLDER before running" {
  run grep 'VERSION_PLACEHOLDER' "${FLATPAK_DIR}/com.karmaa.termix.yml"
  [ "${status}" -eq 0 ]
}

@test "manifest contains CHECKSUM_X64_PLACEHOLDER" {
  run grep 'CHECKSUM_X64_PLACEHOLDER' "${FLATPAK_DIR}/com.karmaa.termix.yml"
  [ "${status}" -eq 0 ]
}

@test "manifest contains CHECKSUM_ARM64_PLACEHOLDER" {
  run grep 'CHECKSUM_ARM64_PLACEHOLDER' "${FLATPAK_DIR}/com.karmaa.termix.yml"
  [ "${status}" -eq 0 ]
}

@test "manifest specifies correct app-id" {
  run grep 'app-id: com.karmaa.termix' "${FLATPAK_DIR}/com.karmaa.termix.yml"
  [ "${status}" -eq 0 ]
}

@test "manifest uses org.freedesktop.Platform runtime" {
  run grep 'runtime: org.freedesktop.Platform' "${FLATPAK_DIR}/com.karmaa.termix.yml"
  [ "${status}" -eq 0 ]
}

@test "manifest specifies runtime version" {
  run grep 'runtime-version:' "${FLATPAK_DIR}/com.karmaa.termix.yml"
  [ "${status}" -eq 0 ]
}

@test "manifest uses org.freedesktop.Sdk" {
  run grep 'sdk: org.freedesktop.Sdk' "${FLATPAK_DIR}/com.karmaa.termix.yml"
  [ "${status}" -eq 0 ]
}

@test "manifest uses Electron base app" {
  run grep 'base: org.electronjs.Electron2.BaseApp' "${FLATPAK_DIR}/com.karmaa.termix.yml"
  [ "${status}" -eq 0 ]
}

@test "manifest specifies command" {
  run grep 'command: termix' "${FLATPAK_DIR}/com.karmaa.termix.yml"
  [ "${status}" -eq 0 ]
}

@test "manifest includes network sharing permission" {
  run grep -- '--share=network' "${FLATPAK_DIR}/com.karmaa.termix.yml"
  [ "${status}" -eq 0 ]
}

@test "manifest includes IPC sharing permission" {
  run grep -- '--share=ipc' "${FLATPAK_DIR}/com.karmaa.termix.yml"
  [ "${status}" -eq 0 ]
}

@test "manifest includes home filesystem access" {
  run grep -- '--filesystem=home' "${FLATPAK_DIR}/com.karmaa.termix.yml"
  [ "${status}" -eq 0 ]
}

@test "manifest includes ssh-auth socket" {
  run grep -- '--socket=ssh-auth' "${FLATPAK_DIR}/com.karmaa.termix.yml"
  [ "${status}" -eq 0 ]
}

@test "manifest includes x11 socket" {
  run grep -- '--socket=x11' "${FLATPAK_DIR}/com.karmaa.termix.yml"
  [ "${status}" -eq 0 ]
}

@test "manifest includes wayland socket" {
  run grep -- '--socket=wayland' "${FLATPAK_DIR}/com.karmaa.termix.yml"
  [ "${status}" -eq 0 ]
}

@test "manifest includes pulseaudio socket" {
  run grep -- '--socket=pulseaudio' "${FLATPAK_DIR}/com.karmaa.termix.yml"
  [ "${status}" -eq 0 ]
}

@test "manifest includes DRI device access" {
  run grep -- '--device=dri' "${FLATPAK_DIR}/com.karmaa.termix.yml"
  [ "${status}" -eq 0 ]
}

@test "manifest includes module definition" {
  run grep 'modules:' "${FLATPAK_DIR}/com.karmaa.termix.yml"
  [ "${status}" -eq 0 ]
}

@test "manifest has termix module" {
  run grep 'name: termix' "${FLATPAK_DIR}/com.karmaa.termix.yml"
  [ "${status}" -eq 0 ]
}

@test "manifest uses simple buildsystem" {
  run grep 'buildsystem: simple' "${FLATPAK_DIR}/com.karmaa.termix.yml"
  [ "${status}" -eq 0 ]
}

@test "manifest extracts AppImage" {
  run grep 'appimage-extract' "${FLATPAK_DIR}/com.karmaa.termix.yml"
  [ "${status}" -eq 0 ]
}

@test "manifest supports x86_64 architecture" {
  run grep 'x86_64' "${FLATPAK_DIR}/com.karmaa.termix.yml"
  [ "${status}" -eq 0 ]
}

@test "manifest supports aarch64 architecture" {
  run grep 'aarch64' "${FLATPAK_DIR}/com.karmaa.termix.yml"
  [ "${status}" -eq 0 ]
}

@test "metainfo has valid XML declaration" {
  run head -n 1 "${FLATPAK_DIR}/com.karmaa.termix.metainfo.xml"
  [[ "${output}" =~ "<?xml" ]]
}

@test "metainfo has component type desktop-application" {
  run grep 'type="desktop-application"' "${FLATPAK_DIR}/com.karmaa.termix.metainfo.xml"
  [ "${status}" -eq 0 ]
}

@test "metainfo specifies correct component id" {
  run grep '<id>com.karmaa.termix</id>' "${FLATPAK_DIR}/com.karmaa.termix.metainfo.xml"
  [ "${status}" -eq 0 ]
}

@test "metainfo has name element" {
  run grep '<name>Termix</name>' "${FLATPAK_DIR}/com.karmaa.termix.metainfo.xml"
  [ "${status}" -eq 0 ]
}

@test "metainfo has summary element" {
  run grep '<summary>' "${FLATPAK_DIR}/com.karmaa.termix.metainfo.xml"
  [ "${status}" -eq 0 ]
}

@test "metainfo has metadata_license" {
  run grep '<metadata_license>' "${FLATPAK_DIR}/com.karmaa.termix.metainfo.xml"
  [ "${status}" -eq 0 ]
}

@test "metainfo has project_license" {
  run grep '<project_license>' "${FLATPAK_DIR}/com.karmaa.termix.metainfo.xml"
  [ "${status}" -eq 0 ]
}

@test "metainfo has description element" {
  run grep '<description>' "${FLATPAK_DIR}/com.karmaa.termix.metainfo.xml"
  [ "${status}" -eq 0 ]
}

@test "metainfo has releases element" {
  run grep '<releases>' "${FLATPAK_DIR}/com.karmaa.termix.metainfo.xml"
  [ "${status}" -eq 0 ]
}

@test "metainfo has release with VERSION_PLACEHOLDER" {
  run grep 'version="VERSION_PLACEHOLDER"' "${FLATPAK_DIR}/com.karmaa.termix.metainfo.xml"
  [ "${status}" -eq 0 ]
}

@test "metainfo has release with DATE_PLACEHOLDER" {
  run grep 'date="DATE_PLACEHOLDER"' "${FLATPAK_DIR}/com.karmaa.termix.metainfo.xml"
  [ "${status}" -eq 0 ]
}

@test "metainfo has homepage URL" {
  run grep '<url type="homepage">' "${FLATPAK_DIR}/com.karmaa.termix.metainfo.xml"
  [ "${status}" -eq 0 ]
}

@test "metainfo has bugtracker URL" {
  run grep '<url type="bugtracker">' "${FLATPAK_DIR}/com.karmaa.termix.metainfo.xml"
  [ "${status}" -eq 0 ]
}

@test "metainfo has categories" {
  run grep '<categories>' "${FLATPAK_DIR}/com.karmaa.termix.metainfo.xml"
  [ "${status}" -eq 0 ]
}

@test "metainfo includes Development category" {
  run grep '<category>Development</category>' "${FLATPAK_DIR}/com.karmaa.termix.metainfo.xml"
  [ "${status}" -eq 0 ]
}

@test "desktop file has Desktop Entry section" {
  run grep '\[Desktop Entry\]' "${FLATPAK_DIR}/com.karmaa.termix.desktop"
  [ "${status}" -eq 0 ]
}

@test "desktop file has Name field" {
  run grep 'Name=Termix' "${FLATPAK_DIR}/com.karmaa.termix.desktop"
  [ "${status}" -eq 0 ]
}

@test "desktop file has Exec field" {
  run grep 'Exec=termix' "${FLATPAK_DIR}/com.karmaa.termix.desktop"
  [ "${status}" -eq 0 ]
}

@test "desktop file has Icon field" {
  run grep 'Icon=com.karmaa.termix' "${FLATPAK_DIR}/com.karmaa.termix.desktop"
  [ "${status}" -eq 0 ]
}

@test "desktop file has Type=Application" {
  run grep 'Type=Application' "${FLATPAK_DIR}/com.karmaa.termix.desktop"
  [ "${status}" -eq 0 ]
}

@test "desktop file has Categories" {
  run grep 'Categories=' "${FLATPAK_DIR}/com.karmaa.termix.desktop"
  [ "${status}" -eq 0 ]
}

@test "sed replacement works correctly on test data" {
  local test_file="${BATS_TMPDIR}/test_manifest.yml"
  echo "version: VERSION_PLACEHOLDER" > "${test_file}"
  echo "checksum: CHECKSUM_PLACEHOLDER" >> "${test_file}"
  
  sed -i 's/VERSION_PLACEHOLDER/1.9.0/g' "${test_file}"
  sed -i 's/CHECKSUM_PLACEHOLDER/abc123/g' "${test_file}"
  
  run grep 'version: 1.9.0' "${test_file}"
  [ "${status}" -eq 0 ]
  
  run grep 'checksum: abc123' "${test_file}"
  [ "${status}" -eq 0 ]
  
  rm -f "${test_file}"
}