# Subgraph Helm Chart

A Helm chart for deploying the River Subgraph service on Kubernetes. This chart provides the necessary resources to run the River Subgraph, a Ponder-based GraphQL service that indexes blockchain events for the River protocol.

## Features

- Deploys a River Subgraph application in Kubernetes
- Creates a service to expose the GraphQL API
- Configures TLS via cert-manager
- Sets up health checks
- Manages secrets for RPC endpoints and database connection

## Prerequisites

- Kubernetes 1.16+
- Helm 3.0+
- cert-manager for TLS certificate management
- External PostgreSQL database

## Installing the Chart

To install the chart with the release name `subgraph`:

```bash
$ helm install subgraph ./subgraph
```

## Configuration

The following table lists the configurable parameters of the Subgraph chart and their default values.

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Container image repository | `towns-subgraph` |
| `image.tag` | Container image tag | `latest` |
| `image.pullPolicy` | Container image pull policy | `IfNotPresent` |
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `42069` |
| `service.targetPort` | Container port | `42069` |
| `ingress.enabled` | Enable ingress | `true` |
| `ingress.annotations` | Ingress annotations | See values.yaml |
| `ingress.hosts` | Ingress hosts | See values.yaml |
| `certificate.issuerName` | Certificate issuer name | `letsencrypt-prod` |
| `certificate.issuerKind` | Certificate issuer kind | `ClusterIssuer` |
| `resources` | CPU/Memory resource requests/limits | See values.yaml |
| `secrets.rpcUrl` | RPC URL for blockchain access | `https://rpc-url-placeholder` |
| `secrets.databaseUrl` | Database connection URL | `postgresql://user:password@hostname:5432/subgraph` |

## Environment Variables

The following environment variables are set in the container:

| Name | Description |
| ---- | ----------- |
| `RIVER_ENV` | River environment (e.g., gamma) |
| `PONDER_PORT` | Port for the Ponder service |
| `PONDER_ENVIRONMENT` | Ponder environment |
| `PONDER_RPC_URL_1` | RPC URL for blockchain access |
| `DATABASE_URL` | Database connection URL |

## Health Checks

The deployment includes liveness and readiness probes that check the `/health` and `/ready` endpoints, respectively.

## Security Context

The pod runs as a non-root user (UID 1000) with a read-only root filesystem and dropped capabilities for enhanced security.

## Custom Configuration

To override the default configuration, create a YAML file with your customizations and pass it to the helm command:

```bash
$ helm install subgraph ./subgraph -f custom-values.yaml
``` 