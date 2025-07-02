# ArgoCD Repository - AI Assistant Guide

## Overview

This repository implements the ArgoCD "App of Apps" pattern for managing Kubernetes applications across multiple environments using GitOps principles. ArgoCD is a declarative, GitOps continuous delivery tool for Kubernetes that automatically synchronizes application states based on Git-sourced configurations.

## Architecture

### App of Apps Pattern
- A root ArgoCD application manages multiple child applications
- Centralized application management through a single entry point
- Automated synchronization and deployment of all applications
- Version controlled configurations with Git as the source of truth

### Environments
The repository supports four environments:
- **alpha** - Development environment
- **delta** - Staging environment
- **gamma** - Pre-production environment
- **omega** - Production environment

Each environment has:
- Dedicated GCP project
- Separate Kubernetes cluster
- Independent ArgoCD instance
- Isolated configuration values

## Repository Structure

```
/argocd/
├── charts/                    # Helm charts for all applications
│   ├── app-of-apps/          # Root application that manages all others
│   ├── app-registry-service/
│   ├── argocd/
│   ├── cert-manager/
│   ├── datadog/
│   ├── external-dns/
│   ├── external-secrets/
│   ├── main-alb/
│   ├── metrics-aggregator/
│   ├── notification-service/
│   ├── river-node/
│   ├── rpc-gateway/
│   ├── subgraph/
│   └── xchain-monitor/
├── environments/             # Environment-specific configurations
│   ├── alpha/
│   ├── delta/
│   ├── gamma/
│   └── omega/
│       ├── applications.yaml # ArgoCD app definition
│       ├── values.yaml      # Environment values
│       └── rendered/        # Generated value files
├── templates/               # Jinja2 templates for value generation
│   ├── *.j2                # Template files
│   ├── environment.py      # Template rendering script
│   └── set_values.py       # Value update script
└── scripts/                # Database configuration scripts
```

## Key Components

### Applications Managed
1. **Infrastructure Components**
   - `argocd` - ArgoCD itself
   - `cert-manager` - TLS certificate management
   - `external-dns` - DNS record management
   - `external-secrets` - Secret management via GCP Secret Manager
   - `datadog` - Monitoring and observability
   - `main-alb` - Main application load balancer

2. **Core Services**
   - `app-registry-service` - Application registry
   - `notification-service` - Notification handling
   - `metrics-aggregator` - Metrics collection
   - `river-node` - River node service
   - `rpc-gateway` - RPC gateway with Redis
   - `subgraph` - GraphQL subgraph
   - `xchain-monitor` - Cross-chain monitoring

### Templating System
- Uses Jinja2 templates to generate environment-specific values
- Templates located in `/templates/*.j2`
- Rendered values stored in `/environments/{env}/rendered/`
- Python scripts handle template rendering and value updates

## Development Workflow

### Initial Setup
```bash
# Create virtual environment
python -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt
yarn
```

### Common Operations

#### Render Values for an Environment
```bash
make render_values ENV=gamma
```
This command:
1. Reads environment values from `/environments/{env}/values.yaml`
2. Processes Jinja2 templates in `/templates/`
3. Generates rendered value files in `/environments/{env}/rendered/`
4. Formats the output files with Prettier

#### Debug a Specific Chart
```bash
make debug_chart ENV=gamma CHART=notification-service NAMESPACE=default
```
This uses `helm template` to render the chart and show the generated Kubernetes manifests.

#### Update Values
```bash
make set_values ENV=gamma VALUES="key.nested.value=newvalue"
```
Updates specific values in the environment's values.yaml file and re-renders templates.

#### Initialize Environment
```bash
make init ENV=gamma
```
Creates a new environment by:
1. Installing ArgoCD
2. Applying the app-of-apps application
3. Triggering synchronization of all child applications

## Adding a New Application

1. Create a new Helm chart in `/charts/{app-name}/`
2. Add the application name to `TEMPLATE_NAMES` in `/templates/environment.py`
3. Create a Jinja2 template in `/templates/{app-name}.j2`
4. Update `/templates/app-of-apps.j2` to include the new application
5. Run `make render_values ENV={env}` to generate configurations
6. Commit and push changes - ArgoCD will automatically deploy

## Testing and Validation

### Lint and Type Checking
When modifying Python scripts, ensure code quality:
```bash
# No specific linting commands defined in makefile
# Consider running standard Python linters
python -m pylint templates/*.py
python -m mypy templates/*.py
```

### Verify Rendered Values
After rendering templates, always check the generated files:
```bash
cat environments/{env}/rendered/{app}.yaml
```

### Dry Run Deployment
Use `helm template` (via `make debug_chart`) to preview changes before deployment.

## Important Notes

1. **GitOps Workflow**: All changes must be committed to Git. ArgoCD syncs from the repository.
2. **Automated Sync**: Most applications have automated sync enabled (prune, selfHeal).
3. **Secrets Management**: Secrets are managed via external-secrets operator and GCP Secret Manager.
4. **Multi-Environment**: Each environment is isolated with its own cluster and ArgoCD instance.
5. **Trunk-Based Development**: Uses main branch with tags for releases.

## Troubleshooting

### Template Rendering Issues
- Check `/templates/environment.py` for the rendering logic
- Verify template syntax in `/templates/*.j2` files
- Ensure all required values exist in `/environments/{env}/values.yaml`

### ArgoCD Sync Issues
- Check application status in ArgoCD UI
- Verify Git repository accessibility
- Check for Kubernetes resource conflicts
- Review ArgoCD application logs

### Missing Applications
- Ensure the application is listed in `TEMPLATE_NAMES`
- Verify the corresponding template exists
- Check if the application is disabled in the app-of-apps values

## Dependencies

- Python 3.10+ with packages:
  - jinja2==3.1.4 (templating)
  - ruamel.yaml==0.18.6 (YAML processing)
  - PyYAML==6.0.1 (YAML parsing)
- Node.js/Yarn (for Prettier formatting)
- Helm 3.x
- kubectl
- Access to GCP and Kubernetes clusters