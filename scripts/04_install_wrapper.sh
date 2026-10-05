#!/bin/bash
set -e
echo "=== [4/5] Installing wrapper script to /usr/local/bin/alphafold3 ==="
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "$SCRIPT_DIR/../bin/alphafold3" /usr/local/bin/alphafold3
chmod +x /usr/local/bin/alphafold3
echo "=== Wrapper installed. You can now run 'alphafold3' system-wide ==="
