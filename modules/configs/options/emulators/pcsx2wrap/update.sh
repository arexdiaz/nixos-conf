#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq gnused

set -euo pipefail

cd "$(dirname "$0")" || exit 1

# Grab latest version, ignoring "latest" and "preview" tags
LATEST_VER="$(curl "https://api.github.com/repos/PCSX2/pcsx2/releases" | jq -r '.[0].tag_name' | sed 's/^v//')"
# CURRENT_VER="$(grep -oP 'version = "\K[^"]+' package.nix)"

# if [[ "$LATEST_VER" == "$CURRENT_VER" ]]; then
#     echo "pcsx2-bin is up-to-date"
#     exit 0
# fi

HASH="$(nix-hash --to-sri --type sha256 "$(nix-prefetch-url --type sha256 "https://github.com/PCSX2/pcsx2/releases/download/v${LATEST_VER}/pcsx2-v${LATEST_VER}-linux-appimage-x64-Qt.AppImage")")"

echo "hash = \"$HASH\""
echo "version = \"$LATEST_VER\""