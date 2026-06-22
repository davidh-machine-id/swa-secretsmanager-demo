#!/usr/bin/env bash
set -aeuo pipefail

# Render policy templates with environment variable substitution

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${PROJECT_ROOT}/setup.env"

TEMPLATE_DIR="${PROJECT_ROOT}/policies/templates"
GEN_DIR="${PROJECT_ROOT}/policies/generated"

echo "==> Rendering policy templates..."

mkdir -p "${GEN_DIR}"

# envsubst <"${TEMPLATE_DIR}/policy-tree.yaml.tmpl"  >"${GEN_DIR}/policy-tree.yaml"
# echo "    ✓ policy-tree.yaml"

envsubst <"${TEMPLATE_DIR}/jwt-authenticator.yaml.tmpl"  >"${GEN_DIR}/jwt-authenticator.yaml"
echo "    ✓ jwt-authenticator.yaml"

envsubst <"${TEMPLATE_DIR}/workload-group.yaml.tmpl"  >"${GEN_DIR}/workload-group.yaml"
echo "    ✓ workload-group.yaml"

envsubst <"${TEMPLATE_DIR}/authn-jwt-grant.yaml.tmpl"  >"${GEN_DIR}/authn-jwt-grant.yaml"
echo "    ✓ authn-jwt-grant.yaml"

envsubst <"${TEMPLATE_DIR}/secrets.yaml.tmpl"  >"${GEN_DIR}/secrets.yaml"
echo "    ✓ secrets.yaml"

echo "==> Done. Rendered policies are in ${GEN_DIR}"
