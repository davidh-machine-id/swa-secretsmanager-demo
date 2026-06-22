#!/usr/bin/env bash
set -aeuo pipefail

# Load workload group, authenticator grant, and secrets policies

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
GEN_DIR="${PROJECT_ROOT}/policies/generated"

source "${PROJECT_ROOT}/setup.env"

# conjur policy load -b data -f secrets.yaml
# conjur variable set -i data/${PROJECT_PREFIX}/secrets/${PROJECT_PREFIX}-app/api-key -v "sk-1234567890abcdef"

echo ""
echo "==> Loading secrets policy..."
conjur policy load -b data -f "${GEN_DIR}/secrets.yaml"
echo "    ✓ Secret and permissions created"

echo ""
echo "==> Setting secret value..."
conjur variable set -i "${APP_SECRET_PATH}" -v "${APP_SECRET_VALUE}"
echo "    ✓ Secret value set"

echo ""
echo "==> Workload policies setup complete"
echo "    SPIFFE ID: ${SPIFFE_ID}"
echo "    Secret: ${APP_SECRET_PATH}"
