#!/usr/bin/env bash
set -euo pipefail

# Directory where the script lives (execution directory)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

REACLIB_URL="https://reaclib.jinaweb.org/difout.php?action=cfreaclib2&library=default&rateall=1&cached=&no910=0"
REACLIB_TARGET_FILE="jina_reaclib_default"

TMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

# --- JINA ReacLib default library ---
echo ""
echo "Downloading JINA ReacLib default library..."
# Use -OJ so curl writes the file under the server-supplied filename (result<number>)
(cd "$TMP_DIR" && curl -fsSL -OJ "$REACLIB_URL")

REACLIB_FILE="$(find "$TMP_DIR" -maxdepth 1 -name "result*" -type f | head -n 1)"

if [[ -z "$REACLIB_FILE" ]]; then
  echo "Error: JINA ReacLib file (result<number>) not found after download." >&2
  exit 1
fi

echo "Downloaded as: $(basename "$REACLIB_FILE")"
echo "Copying to $SCRIPT_DIR/$REACLIB_TARGET_FILE ..."
cp "$REACLIB_FILE" "$SCRIPT_DIR/$REACLIB_TARGET_FILE"

echo "Done. File saved as: $SCRIPT_DIR/$REACLIB_TARGET_FILE"
