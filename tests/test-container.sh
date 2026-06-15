#!/usr/bin/env bash
# test-container.sh – smoke-tests a Vega Utility Docker image locally.
# Usage: ./tests/test-container.sh [IMAGE]
#   IMAGE defaults to archetypicalsoftware/vega-utility:latest

set -euo pipefail

IMAGE="${1:-archetypicalsoftware/vega-utility:latest}"
PASS=0
FAIL=0

run_test() {
    local name="$1"; shift
    printf "  Testing %-40s " "$name ..."
    if docker run --rm "$IMAGE" sh -c "$*" >/dev/null 2>&1; then
        echo "PASS"
        PASS=$((PASS + 1))
    else
        echo "FAIL"
        FAIL=$((FAIL + 1))
    fi
}

echo ""
echo "=== Vega Utility Container Tests ==="
echo "Image: $IMAGE"
echo ""

run_test "kubectl on PATH"       "command -v kubectl"
run_test "kubectl client version" "kubectl version --client -o json"
run_test "helm on PATH"          "command -v helm"
run_test "helm version"          "helm version --short"
run_test "pwsh on PATH"          "command -v pwsh"
run_test "pwsh executes"         "pwsh -Command 'Write-Host ok'"
run_test "curl on PATH"          "command -v curl"
run_test "non-root user"         "id -u | grep -qv '^0$'"

echo ""
if [ "$FAIL" -gt 0 ]; then
    echo "FAILED: $FAIL test(s) failed, $PASS passed."
    exit 1
else
    echo "All $PASS tests passed."
fi
