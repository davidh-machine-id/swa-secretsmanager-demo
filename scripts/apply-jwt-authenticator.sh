#!/usr/bin/env bash
set -aeuo pipefail

# Load JWT authenticator policy and set configuration variables
# REF: https://docs.cyberark.com/secrets-manager-saas/latest/en/content/operations/services/cjr-authn-jwt-swa.htm

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
GEN_DIR="${PROJECT_ROOT}/policies/generated"

source "${PROJECT_ROOT}/setup.env"

conjur policy load -b conjur/authn-jwt -f "${GEN_DIR}/jwt-authenticator.yaml"

# JWKS URI — SWA publishes per-trust-domain JWKS at this path
conjur variable set -i conjur/authn-jwt/${PROJECT_PREFIX}/jwks-uri -v "${CONJUR_APPLIANCE_URL}/swa/trust-domains/${SWA_TRUST_DOMAIN}/.well-known/jwks"

# JWT claim used as the application identity (SPIFFE ID)
conjur variable set -i conjur/authn-jwt/${PROJECT_PREFIX}/token-app-property -v "sub"

# Branch where SWA registers workload identities — must match your trust domain
conjur variable set -i conjur/authn-jwt/${PROJECT_PREFIX}/identity-path -v "data/swa/trust-domains/${SWA_TRUST_DOMAIN}/workloads"

# Issuer — SWA OIDC issuer is scoped per trust domain
conjur variable set -i conjur/authn-jwt/${PROJECT_PREFIX}/issuer -v "${CONJUR_APPLIANCE_URL}/swa/trust-domains/${SWA_TRUST_DOMAIN}"

# Audience — must match the value configured in the SWA Server Helm chart (controlPlane.auth.audience)
conjur variable set -i conjur/authn-jwt/${PROJECT_PREFIX}/audience -v "conjur"

# Enable the authn-jwt/secureWorkloadAccess authenticator.
conjur authenticator enable --id authn-jwt/${PROJECT_PREFIX}
