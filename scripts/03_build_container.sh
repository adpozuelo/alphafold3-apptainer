#!/bin/bash
set -e
BASE_DIR="${1:-/opt/alphafold3}"
echo "=== [3/5] Building Apptainer container image at: $BASE_DIR/container/alphafold3.sif ==="
mkdir -p "$BASE_DIR"/{src,container,models,public_databases,bin,test,cache/apptainer,cache/tmp}
if [ ! -d "$BASE_DIR/src/.git" ]; then
    echo "Cloning official AlphaFold 3 repository..."
    git clone https://github.com/google-deepmind/alphafold3.git "$BASE_DIR/src"
fi
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "$SCRIPT_DIR/../container/AF3.def" "$BASE_DIR/container/AF3.def"
cd "$BASE_DIR/src"
APPTAINER_CACHEDIR="$BASE_DIR/cache/apptainer" APPTAINER_TMPDIR="$BASE_DIR/cache/tmp" apptainer build "$BASE_DIR/container/alphafold3.sif" "$BASE_DIR/container/AF3.def"
echo "=== Container built successfully: $BASE_DIR/container/alphafold3.sif ==="
