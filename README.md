### ArgoCD

ArgoCD is a declarative, GitOps continuous delivery tool for Kubernetes. This repository follows the "App of Apps" pattern, where a root ArgoCD application manages multiple child applications.

The App of Apps pattern allows us to declaratively define and manage multiple applications through a single entry point. The root application acts as a control plane that automatically synchronizes and deploys all child applications based on their Git-sourced configurations.

Key benefits of this approach:

- Centralized application management
- Automated synchronization of application states
- Version controlled application configurations
- Simplified multi-application deployments
- Consistent deployment patterns across applications

#### Requirements

- Python 3.10+
- pip
- yarn

#### Usage

```
# create a virtual environment to render templates
python -m venv .venv
source .venv/bin/activate

# install dependencies
pip install -r requirements.txt

make render_values ENV=gamma
```

See `notes` for more information.
