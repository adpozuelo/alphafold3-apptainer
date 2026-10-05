#!/bin/bash
set -e
echo "=== [5/5] Running fast GPU inference validation test (AlphaFold 3) ==="
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_INPUT="$SCRIPT_DIR/../examples/ubiquitin_test_data.json"
TEST_OUTPUT="/opt/alphafold3/test/output"
mkdir -p "$TEST_OUTPUT"
alphafold3 --json_path="$TEST_INPUT" --output_dir="$TEST_OUTPUT" --run_data_pipeline=false
echo "=== Validation test completed successfully! Results in: $TEST_OUTPUT ==="
ls -lh "$TEST_OUTPUT"/ubiquitin_v4_test/
