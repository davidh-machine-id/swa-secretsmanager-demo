#!/usr/bin/env bash
set -aeuo pipefail

# ============================================================
# Deploy demo-app using Helm
# ============================================================
# This script deploys the demo-app to Kubernetes using the
# Helm chart in app/helm/, reading configuration from setup.env
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# shellcheck disable=SC1091
source     "${PROJECT_ROOT}/setup.env"

# Validate required variables
REQUIRED_VARS=(
	"APP_NAMESPACE"
	"APP_SERVICE_ACCT"
	"APP_IMAGE_REPOSITORY"
	"APP_IMAGE_TAG"
	"SWA_NODEGROUP"
	"CONJUR_APPLIANCE_URL"
	"PROJECT_PREFIX"
	"APP_SECRET_PATH"
)

for var in "${REQUIRED_VARS[@]}"; do
	if [[ -z "${!var:-}" ]]; then
		echo "ERROR: Required variable ${var} is not set in setup.env" >&2
		exit 1
	fi
done

# Set defaults for optional variables
CONJUR_ACCOUNT="${CONJUR_ACCOUNT:-conjur}"
CONJUR_JWT_AUDIENCE="${CONJUR_JWT_AUDIENCE:-conjur}"

# Helm chart path
HELM_CHART="${PROJECT_ROOT}/app/helm"

if [[ ! -d "${HELM_CHART}" ]]; then
	echo "ERROR: Helm chart not found at ${HELM_CHART}" >&2
	exit 1
fi

echo "==> Deploying demo-app with Helm..."
echo "    Namespace:        ${APP_NAMESPACE}"
echo "    Service Account:  ${APP_SERVICE_ACCT}"
echo "    Image Tag:        ${APP_IMAGE_TAG}"
echo "    SWA Nodegroup:    ${SWA_NODEGROUP}"
echo "    Conjur URL:       ${CONJUR_APPLIANCE_URL}"
echo "    Secret Path:      ${APP_SECRET_PATH}"
echo ""

# Deploy with Helm
helm upgrade --install demo-app "${HELM_CHART}" \
	--namespace "${APP_NAMESPACE}" \
	--create-namespace \
	--set namespace="${APP_NAMESPACE}" \
	--set image.repository="${APP_IMAGE_REPOSITORY}" \
	--set image.tag="${APP_IMAGE_TAG}" \
	--set serviceAccount.name="${APP_SERVICE_ACCT}" \
	--set swa.nodegroup="${SWA_NODEGROUP}" \
	--set conjur.applianceUrl="${CONJUR_APPLIANCE_URL}" \
	--set conjur.account="${CONJUR_ACCOUNT}" \
	--set conjur.authnJwtServiceId="${PROJECT_PREFIX}" \
	--set conjur.jwtAudience="${CONJUR_JWT_AUDIENCE}" \
	--set conjur.secretId="${APP_SECRET_PATH}"

echo ""
echo "==> Deployment complete!"
echo ""
echo "To view the deployment status:"
echo "  kubectl get deployments -n ${APP_NAMESPACE}"
echo ""
echo "To view pod logs:"
echo "  kubectl logs -n ${APP_NAMESPACE} -l app=${APP_NAME}"
echo ""
echo "To access the demo app:"
echo "  kubectl port-forward -n ${APP_NAMESPACE} deployment/${APP_NAME} 8080:8080"
echo "  Then browse to http://localhost:8080"
echo ""
echo "To delete the deployment:"
echo "  helm uninstall demo-app -n ${APP_NAMESPACE}"
