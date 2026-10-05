#!/bin/bash
set -e
DB_DIR="${1:-/opt/alphafold3/public_databases}"
echo "=== [2/5] Downloading AlphaFold 3 databases into: $DB_DIR ==="
mkdir -p "$DB_DIR"
if [ ! -f /opt/alphafold3/src/fetch_databases.sh ]; then
    mkdir -p /opt/alphafold3/src
    git clone https://github.com/google-deepmind/alphafold3.git /opt/alphafold3/src
fi
bash /opt/alphafold3/src/fetch_databases.sh "$DB_DIR"
echo "=== Database download finished ==="
