#!/usr/bin/env bash
set -euo pipefail

# Directory where the script lives (execution directory)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ARCHIVE_URL="https://cococubed.com/codes/eos/helmholtz.tbz"
ARCHIVE_FILE="helmholtz.tbz"
TARGET_FILE="helm_table_timmes_x1.dat"
TMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

echo "Downloading archive..."
curl -fsSL "$ARCHIVE_URL" -o "$TMP_DIR/$ARCHIVE_FILE"

echo "Unpacking archive..."
tar -xjf "$TMP_DIR/$ARCHIVE_FILE" -C "$TMP_DIR"

echo "Locating helm_table.dat..."
HELM_TABLE="$(find "$TMP_DIR" -name "helm_table.dat" -type f | head -n 1)"

if [[ -z "$HELM_TABLE" ]]; then
  echo "Error: helm_table.dat not found in archive." >&2
  exit 1
fi

echo "Copying to $SCRIPT_DIR/$TARGET_FILE ..."
cp "$HELM_TABLE" "$SCRIPT_DIR/$TARGET_FILE"

echo "Done. File saved as: $SCRIPT_DIR/$TARGET_FILE"
