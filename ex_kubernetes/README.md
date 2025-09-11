# Multi-Language Web App with Kubernetes

A simple Kubernetes manifest that creates two nginx pods serving different languages based on URL paths.

## What it does

- `/eng` → Displays "Hello World" (English)
- `/ita` → Displays "Ciao Mondo" (Italian)
- `/ita/` or `/eng/` → Returns 404 (exact path matching)

## Architecture

- **2 Deployments**: nginx containers with different HTML content
- **2 Services**: ClusterIP services to expose the pods
- **1 Ingress**: Path-based routing with regex support

## Prerequisites

```bash
# Install nginx ingress controller
helm install ingress-nginx ingress-nginx/ingress-nginx
```

## Usage

```bash
# Apply the manifest
kubectl apply -f hello_mondo.yaml

# Check resources
kubectl get pods,services,ingress

# Test with port forwarding
kubectl port-forward svc/ingress-nginx-controller 8080:80 -n ingress-nginx

# Test the endpoints
curl localhost:8080/eng  # Returns: Hello World
curl localhost:8080/ita  # Returns: Ciao Mondo
curl localhost:8080/ita/ # Returns: 404 (as expected)
```

## Key Features

- **Exact path matching**: Uses regex `$` to prevent matching `/ita/` or `/eng/`
- **URL rewriting**: Ingress rewrites paths to `/` before forwarding to pods
- **Minimal setup**: Single manifest file with all required resources

## Cleanup

```bash
kubectl delete -f hello_mondo.yaml
```
