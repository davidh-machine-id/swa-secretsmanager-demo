#!/usr/bin/env bash
set -aeuo pipefail

# Load workload group, authenticator grant, and secrets policies

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
GEN_DIR="${PROJECT_ROOT}/policies/generated"

source "${PROJECT_ROOT}/setup.env"

echo "==> Loading workload group policy..."
conjur policy load -b "data/swa/trust-domains/${SWA_TRUST_DOMAIN}" \
	-f "${GEN_DIR}/workload-group.yaml"
echo "    ✓ Workload group and host annotation created"

echo ""
echo "==> Loading authenticator grant policy..."
conjur policy load -b "conjur/authn-jwt/${PROJECT_PREFIX}" \
	-f "${GEN_DIR}/authn-jwt-grant.yaml"
echo "    ✓ Workloads group granted access to authenticator"

echo ""
echo "==> Workload policies setup complete"
echo "    SPIFFE ID: ${SPIFFE_ID}"
