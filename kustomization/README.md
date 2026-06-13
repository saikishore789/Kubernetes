# What is Kustomize (Kustomization) in Kubernetes?

**Kustomize** is a built-in Kubernetes configuration management tool that lets you **customize Kubernetes YAML manifests without modifying the original files**.

It helps manage different environments such as:

* Development
* Testing
* UAT
* Production

using the same base Kubernetes manifests.

---

## Why Do We Need Kustomize?

Imagine you have an application deployment:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-app
spec:
  replicas: 2
```

For different environments, you may need:

| Environment | Replicas | Namespace |
| ----------- | -------- | --------- |
| Dev         | 1        | dev       |
| Test        | 2        | test      |
| Prod        | 5        | prod      |

Without Kustomize, you'd maintain multiple copies:

```text
deployment-dev.yaml
deployment-test.yaml
deployment-prod.yaml
```

This becomes difficult to maintain.

---

## How Kustomize Solves This

Create a common base:

```text
base/
 ├── deployment.yaml
 ├── service.yaml
 └── kustomization.yaml
```

Then create environment-specific overlays:

```text
overlays/
 ├── dev/
 ├── test/
 └── prod/
```

---

## Directory Structure Example

```text
k8s/
├── base
│   ├── deployment.yaml
│   ├── service.yaml
│   └── kustomization.yaml
│
└── overlays
    ├── dev
    │   ├── kustomization.yaml
    │   └── replica-patch.yaml
    │
    └── prod
        ├── kustomization.yaml
        └── replica-patch.yaml
```

---

## Base Configuration

### deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
```

### kustomization.yaml

```yaml
resources:
- deployment.yaml
```

---

## Dev Overlay

### replica-patch.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-app
spec:
  replicas: 1
```

### kustomization.yaml

```yaml
resources:
- ../../base

patches:
- path: replica-patch.yaml
```

---

## Production Overlay

### replica-patch.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-app
spec:
  replicas: 5
```

---

## Deploy Using Kustomize

```bash
kubectl apply -k overlays/dev
```

or

```bash
kubectl apply -k overlays/prod
```

The `-k` flag tells Kubernetes to process the Kustomization.

---

# Common Real-Time Use Cases

## 1. Environment-Specific Deployments

Same application:

```text
Dev
Test
UAT
Prod
```

Different values:

```yaml
replicas
namespace
resource limits
image tags
```

Kustomize manages all of them.

---

## 2. Namespace Management

Base:

```yaml
metadata:
  name: my-app
```

Overlay:

```yaml
namespace: production
```

Kustomize automatically applies the namespace.

---

## 3. Image Version Management

Base:

```yaml
image: nginx
```

Production:

```yaml
images:
- name: nginx
  newTag: 1.28
```

Dev:

```yaml
images:
- name: nginx
  newTag: latest
```

---

## 4. Adding Labels

Example:

```yaml
commonLabels:
  environment: production
  owner: devops
```

Automatically added to all resources.

---

## 5. Secrets and ConfigMaps

Generate ConfigMaps:

```yaml
configMapGenerator:
- name: app-config
  literals:
  - ENV=prod
```

Generate Secrets:

```yaml
secretGenerator:
- name: db-secret
  literals:
  - password=mysecret
```

---

# Example Real-World AKS Scenario

Suppose your team deploys to an Azure Kubernetes Service cluster.

### Dev

```yaml
replicas: 1
resources:
  requests:
    cpu: 100m
```

### Production

```yaml
replicas: 10
resources:
  requests:
    cpu: 1000m
```

Instead of maintaining separate YAML files, Kustomize applies only the differences.

---

# Kustomize vs Helm

| Feature              | Kustomize | Helm     |
| -------------------- | --------- | -------- |
| Uses Templates       | No        | Yes      |
| Uses YAML Only       | Yes       | No       |
| Learning Curve       | Easy      | Moderate |
| Package Management   | No        | Yes      |
| Environment Overlays | Excellent | Good     |
| Built into kubectl   | Yes       | No       |

---

## When to Use Kustomize

Use Kustomize when:

✅ You want simple YAML customization
✅ Multiple environments exist
✅ You don't need complex templating
✅ You want GitOps-friendly deployments

---

## When to Use Helm

Use Helm when:

✅ Deploying third-party applications
✅ Complex parameterization is needed
✅ You need versioned application packages (charts)

Examples:

* NGINX Ingress Controller
* Prometheus
* Grafana

are commonly installed via Helm.

---

# How Kustomize Works Internally

When you run:

```bash
kubectl apply -k overlays/prod
```

Kustomize:

1. Reads the base manifests
2. Applies patches
3. Updates images
4. Adds labels/annotations
5. Generates final YAML
6. Sends it to Kubernetes

You can preview the final YAML:

```bash
kubectl kustomize overlays/prod
```

or

```bash
kustomize build overlays/prod
```

---

# Real-Time DevOps/GitOps Usage

With tools like:

* Argo CD
* Flux

a typical repository looks like:

```text
apps/
├── base
├── dev
├── qa
└── prod
```

When changes are pushed to Git:

```text
Git
 ↓
ArgoCD
 ↓
Kustomize Build
 ↓
AKS Cluster
```

This is one of the most common enterprise Kubernetes deployment patterns today.

### Summary

Kustomize is a Kubernetes-native configuration management tool that allows you to reuse a common set of manifests and apply environment-specific customizations through overlays. It is widely used in AKS, GitOps, CI/CD pipelines, and multi-environment deployments because it eliminates duplicate YAML files while keeping configurations easy to understand and maintain.
