# Termix Flatpak Distribution

This directory contains the Flatpak manifest and related files for distributing Termix via Flatpak.

## Files Overview

- `com.karmaa.termix.yml` - Main Flatpak manifest
- `com.karmaa.termix.desktop` - Desktop entry file
- `com.karmaa.termix.metainfo.xml` - AppStream metadata
- `com.karmaa.termix.flatpakref` - Reference file for one-command installation
- `flathub.json` - Flathub configuration (for official submission)
- `prepare-flatpak.sh` - Prepares files for build
- `build-flatpak-bundle.sh` - Builds the distributable Flatpak bundle

## Building a Flatpak Bundle

To create a `.flatpak` bundle that users can install:

```bash
cd flatpak
./build-flatpak-bundle.sh <version> <checksum-x64> <checksum-arm64> <release-date>
```

Example:
```bash
./build-flatpak-bundle.sh 1.9.0 abc123... def456... 2025-11-24
```

This will generate:
- `com.karmaa.termix.flatpak` - The installable bundle
- Updated `com.karmaa.termix.flatpakref` - Reference file

## Distribution Methods

### Option 1: Direct Bundle Installation

Upload `com.karmaa.termix.flatpak` to GitHub Releases, then users can install:

```bash
# Download and install
wget https://github.com/Termix-SSH/Desktop/releases/download/v1.9.0/com.karmaa.termix.flatpak
flatpak install com.karmaa.termix.flatpak
```

### Option 2: Flatpakref File (Recommended)

Host `com.karmaa.termix.flatpakref` on GitHub Pages or your website:

```bash
# One-command installation
flatpak install --from https://termix-ssh.github.io/Desktop/com.karmaa.termix.flatpakref
```

Update the `Url=` line in `com.karmaa.termix.flatpakref` to point to where you host the `.flatpak` bundle.

### Option 3: Custom Repository

Set up a custom Flatpak repository:

```bash
# After building
flatpak build-bundle repo com.karmaa.termix.flatpak com.karmaa.termix stable

# Users add your repo
flatpak remote-add --user termix-repo https://your-repo-url/repo
flatpak install termix-repo com.karmaa.termix
```

## Submitting to Flathub

To submit to the official Flathub repository:

1. Fork https://github.com/flathub/flathub
2. Create a new repository for your app
3. Submit the manifest files
4. Follow Flathub's submission guidelines

Once approved, users can install with:
```bash
flatpak install flathub com.karmaa.termix
```

## Requirements

- `flatpak-builder`
- `flatpak`
- ImageMagick (optional, for icon conversion)

## Notes

- The bundle must be built on Linux (or WSL)
- Ensure the AppImage checksums are correct
- The `.flatpakref` file should be hosted publicly for one-command installation
