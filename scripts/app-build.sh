#!/usr/bin/env bash
set -aeuo pipefail

# Build, load, and deploy the JWT-SVID fetch demo app with Secrets Manager integration

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${PROJECT_ROOT}/setup.env"

cd "${PROJECT_ROOT}/app"

echo "Building Docker image..."
docker build -t $APP_NAME:$APP_IMAGE_TAG .

echo "Loading image to kind cluster..."
kind load docker-image $APP_NAME:$APP_IMAGE_TAG --name "$SWA_CLUSTER_NAME"
