# Demo App Helm Chart

Minimal Helm chart for deploying the SWA-enabled Conjur demo web application.

## Prerequisites

- Kubernetes cluster with SWA agent running
- Helm 3.x installed
- `setup.env` configured with required values

## Structure

```text
helm/
├── Chart.yaml              # Chart metadata
├── values.yaml             # Default configuration values
├── templates/
│   ├── configmap.yaml      # Environment configuration
│   ├── serviceaccount.yaml # Kubernetes service account
│   ├── deployment.yaml     # Deployment for the web app
│   └── service.yaml        # ClusterIP service
└── README.md              # This file
```

## Quick Deploy

Use the provided deployment script:

```bash
PROJECT_ROOT/scripts/app-deploy.sh
```

## Manual Deploy

```bash
helm upgrade --install demo-app ./app/helm \
    --namespace "${APP_NAMESPACE}" \
    --create-namespace \
    --set image.repository="${APP_IMAGE_REPOSITORY}" \
    --set image.tag="${APP_IMAGE_TAG}" \
    --set namespace="${APP_NAMESPACE}" \
    --set serviceAccount.name="${APP_SERVICE_ACCT}" \
    --set swa.nodegroup="${SWA_NODEGROUP}" \
    --set conjur.applianceUrl="${CONJUR_APPLIANCE_URL}" \
    --set conjur.account="${CONJUR_ACCOUNT}" \
    --set conjur.authnJwtServiceId="${PROJECT_PREFIX}" \
    --set conjur.jwtAudience="${CONJUR_JWT_AUDIENCE}" \
    --set conjur.secretId="${APP_SECRET_PATH}"
```

## Configuration

Key configuration values in `values.yaml`:

| Parameter                  | Description             | Default                      |
| -------------------------- | ----------------------- | ---------------------------- |
| `image.repository`         | Docker image repository | `docker.io/library/demo-app` |
| `image.tag`                | Docker image tag        | `latest`                     |
| `namespace`                | Kubernetes namespace    | `demo-app`                   |
| `serviceAccount.name`      | Service account name    | `demo-app-sa`                |
| `swa.nodegroup`            | SWA node group label    | `k8s-nodegroup`              |
| `conjur.applianceUrl`      | Secrets Manager URL     | (required)                   |
| `conjur.authnJwtServiceId` | JWT authenticator ID    | (required)                   |
| `conjur.secretId`          | Path to secret          | (required)                   |
| `deployment.replicas`      | Number of pod replicas  | `1`                          |
| `service.type`             | Service type            | `ClusterIP`                  |
| `service.port`             | Service port            | `80`                         |

## Access the Application

After deployment, access the web interface via port-forward:

```bash
# Port-forward to the deployment
kubectl port-forward -n demo-app deployment/demo-app 8080:8080

# Then browse to http://localhost:8080
```

## View Deployment Status

```bash
# List deployments
kubectl get deployments -n ${APP_NAMESPACE}

# View pod logs (follow mode)
kubectl logs -n ${APP_NAMESPACE} -l app=demo-app -f

# Describe deployment
kubectl describe deployment -n ${APP_NAMESPACE} demo-app

# Check service
kubectl get svc -n ${APP_NAMESPACE}
```

## Cleanup

```bash
helm uninstall demo-app -n ${APP_NAMESPACE}
```
