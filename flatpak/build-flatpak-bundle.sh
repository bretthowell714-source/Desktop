#!/bin/bash
set -e

VERSION="$1"
CHECKSUM_X64="$2"
CHECKSUM_ARM64="$3"
RELEASE_DATE="$4"

if [ -z "$VERSION" ] || [ -z "$CHECKSUM_X64" ] || [ -z "$CHECKSUM_ARM64" ] || [ -z "$RELEASE_DATE" ]; then
  echo "Usage: $0 <version> <checksum-x64> <checksum-arm64> <release-date>"
  echo "Example: $0 1.9.0 abc123... def456... 2025-11-24"
  exit 1
fi

echo "Building Flatpak bundle for version $VERSION"

# Prepare the files
./prepare-flatpak.sh "$VERSION" "$CHECKSUM_X64" "$RELEASE_DATE"

# Update ARM64 checksum separately (prepare-flatpak.sh handles x64)
sed -i "s/CHECKSUM_ARM64_PLACEHOLDER/$CHECKSUM_ARM64/g" com.karmaa.termix.yml

# Build the Flatpak
echo "Building Flatpak package..."
flatpak-builder --repo=repo --force-clean build-dir com.karmaa.termix.yml

# Create the bundle
echo "Creating Flatpak bundle..."
flatpak build-bundle repo com.karmaa.termix.flatpak com.karmaa.termix stable

# Update the .flatpakref file
echo "Updating .flatpakref file..."
sed -i "s/VERSION_PLACEHOLDER/$VERSION/g" com.karmaa.termix.flatpakref

echo "✓ Build complete!"
echo ""
echo "Generated files:"
echo "  - com.karmaa.termix.flatpak (upload this to GitHub releases)"
echo "  - com.karmaa.termix.flatpakref (host this file publicly)"
echo ""
echo "Users can install with:"
echo "  flatpak install --from https://termix-ssh.github.io/Desktop/com.karmaa.termix.flatpakref"
echo ""
echo "Or install directly from bundle:"
echo "  flatpak install com.karmaa.termix.flatpak"
