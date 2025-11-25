#!/bin/bash
set -e

REPO="Termix-SSH/Termix"
CASK_FILE="$(dirname "$0")/Casks/termix.rb"

LATEST_VERSION=$(gh release list --repo "$REPO" --limit 1 --json tagName --jq '.[0].tagName' | sed 's/release-//' | sed 's/-tag//')

if [ -z "$LATEST_VERSION" ]; then
    echo "Failed to fetch latest version"
    exit 1
fi

echo "$LATEST_VERSION"

DOWNLOAD_URL="https://github.com/$REPO/releases/download/release-${LATEST_VERSION}-tag/termix_macos_universal_dmg.dmg"

echo "$DOWNLOAD_URL"

SHA256=$(curl -sL "$DOWNLOAD_URL" | shasum -a 256 | awk '{print $1}')

if [ -z "$SHA256" ]; then
    echo "Failed to calculate SHA256"
    exit 1
fi

echo "$SHA256"

sed -e "s/version \".*\"/version \"$LATEST_VERSION\"/" \
    -e "s/sha256 \".*\"/sha256 \"$SHA256\"/" \
    "$CASK_FILE" > "${CASK_FILE}.tmp"

mv "${CASK_FILE}.tmp" "$CASK_FILE"
