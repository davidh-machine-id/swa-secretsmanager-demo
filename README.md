# SWA + Secrets Manager Demo

A demonstration of CyberArk Secure Workload Access (SWA) integration with Secrets Manager using SPIFFE workload identity.

## Requirements

- Go 1.26+ (for local development)
- Docker
- [Taskfile runner](https://taskfile.dev/docs/installation)
- Kubernetes cluster (kind recommended for local)
  - Docker
  - Kind (Kubernetes in Docker)
- Helm 3.x
- CyberArk Secrets Manager SaaS tenant
  - [Create a service user](<https://docs.cyberark.com/snapshot/identity-administration/en/content/ispss/ispss-add-service-user.htm#Createaserviceuser>) and add the user to the ["Secret Manager – Conjur Cloud Admin"](<https://docs.cyberark.com/secrets-manager-saas/latest/en/content/conjurcloud/cl_usermanage.htm#SecretsManagerrolesandusergroups>) role.
- SWA agent running in cluster
- [Secrets Manager SaaS CLI](https://docs.cyberark.com/secrets-manager-saas/latest/en/content/conjurcloud/cli/cli-setup-new.htm)
  
## Quick Start

1. **Download SWA Tarball from marketplace:**

Go to Idira Marketplace, go to Software -> Products: Secure Workload Access and download Version 1.0.

NOTE: you only need the `swa-release-v1.x.y.tgz` file.  If you download all files it will download as a zip file.  Extract the `.tgz` file from the zip file.

Copy the `swa-release-v1.x.y.tgz` file into the project `./dist` directory.

   ```bash
   # Check the tarball exists
   ls ./dist/*.tgz
   swa-release-v1.x.y.tgz
   ```

2. **Configure environment:**

These variables must be set by the user:

| Variable             | Purpose                                   | Example Value               | Notes                                                               |
| -------------------- | ----------------------------------------- | --------------------------- | ------------------------------------------------------------------- |
| **PROJECT_PREFIX**   | Unique identifier for all resources       | `my-demo`                   | Used to compute cluster names, trust domains, resource groups, etc. |
| **CONJUR_TENANT**    | Secrets Manager tenant subdomain          | `my-tenant`                 | For `https://my-tenant.secretsmgr.cyberark.cloud`                   |
| **CONJUR_USER**      | Secrets Manager user email (service user) | `user@cyberark.cloud.xxxxx` | Required for `conjur login` CLI operations                          |
| **CONJUR_PASS**      | Secrets Manager user password             | `your-password`             | Required for `conjur login` CLI operations                          |
| **APP_SECRET_VALUE** | Initial demo secret value                 | `YourSecretHere`            | Has default but should be changed for security                      |

   ```bash
   cp setup.env.example setup.env
   # Edit setup.env with your values
   ```

1. **Deploy Kind Cluster with SWA Provider, Server, and Agent:**

   ```bash
   task deploy-kind-swa
   ```

2. **Deploy the application:**

   ```bash
   task deploy-app
   ```

3. **Access the web UI:**

   ```bash
   kubectl port-forward -n demo-app deployment/demo-app 8080:8080
   # Browse to http://localhost:8080
   ```

The web interface displays:

- Conjur configuration
- Retrieved secret value
- SPIFFE identity
- JWT-SVID token and decoded claims

## License

Licensed under the Apache 2.0 License. See [LICENSE](LICENSE) for details.
