## What is an Admission Controller in Kubernetes?

An **Admission Controller** is a component that sits between the Kubernetes API Server and etcd.

Whenever someone creates, updates, or deletes a Kubernetes resource, the request flows through admission controllers before the resource is stored.

### Request Flow

```text
User
  |
kubectl apply
  |
  v
Kubernetes API Server
  |
Authentication
  |
Authorization (RBAC)
  |
Admission Controllers
  |
etcd
```

Admission controllers can:

* Allow requests
* Deny requests
* Modify requests before they are stored

---

## Why Do We Need Admission Controllers?

Imagine a developer deploys:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx:latest
    securityContext:
      privileged: true
```

Without admission control:

✅ Pod gets created.

But this may violate security policies.

An admission controller can:

* Reject privileged containers
* Require resource limits
* Prevent deployments in the default namespace
* Add labels automatically
* Enforce approved container registries

---

## Types of Admission Controllers

### 1. Mutating Admission Controllers

Modify the object before it is stored.

Example:

User submits:

```yaml
metadata:
  name: app
```

Controller automatically adds:

```yaml
metadata:
  name: app
  labels:
    environment: prod
```

Result:

```text
Request → Modified → Stored
```

---

### 2. Validating Admission Controllers

Validate the object and either allow or deny it.

Example:

```yaml
image: docker.io/random/image
```

Policy:

```text
Only images from company registry allowed
```

Result:

```text
Request → Validation → Denied
```

---

## Built-in Admission Controllers

Kubernetes comes with many built-in controllers.

Examples:

| Admission Controller | Purpose                         |
| -------------------- | ------------------------------- |
| NamespaceLifecycle   | Validates namespaces            |
| LimitRanger          | Applies resource limits         |
| ResourceQuota        | Enforces quotas                 |
| PodSecurity          | Enforces pod security standards |
| DefaultStorageClass  | Assigns default storage class   |

You can see enabled admission plugins on the API server configuration (self-managed clusters).

---

## External Admission Controllers

Most organizations use external admission controllers for governance.

Popular tools:

* Kyverno
* OPA Gatekeeper
* Kubewarden

These use Kubernetes Admission Webhooks.

---

## How Admission Webhooks Work

```text
User
 |
kubectl apply
 |
API Server
 |
+-------------------+
| Admission Webhook |
+-------------------+
 |
Allow / Deny
 |
etcd
```

The API server sends the request to the webhook.

The webhook returns:

```json
{
  "allowed": true
}
```

or

```json
{
  "allowed": false,
  "message": "Default namespace not allowed"
}
```

---

## Example: Kyverno Admission Controller

Suppose you want to block Pods in the default namespace.

Policy:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-default
spec:
  validationFailureAction: Enforce
  rules:
  - name: block-default
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      message: "Default namespace is not allowed."
      deny:
        conditions:
          any:
          - key: "{{ request.namespace }}"
            operator: Equals
            value: default
```

When a user runs:

```bash
kubectl apply -f pod.yaml
```

Kyverno intercepts the request and denies it.

---

## Admission Controllers in AKS

In Azure Kubernetes Service, common admission controllers are used for:

### Security

* Prevent privileged containers
* Block root users
* Enforce Pod Security Standards

### Governance

* Require labels
* Enforce naming conventions
* Prevent use of default namespace

### Compliance

* PCI DSS
* HIPAA
* SOC2

### Cost Control

* Require CPU requests and limits

---

## Real-World Example

Suppose a company has 500 developers.

Without admission control:

```text
Developer A → Uses latest image
Developer B → Runs privileged pod
Developer C → No resource limits
```

Cluster becomes inconsistent.

With admission controllers:

```text
Every deployment checked
Every deployment follows standards
```

Policies are enforced automatically.

---

## How to See Admission Webhooks

Check mutating webhooks:

```bash
kubectl get mutatingwebhookconfigurations
```

Check validating webhooks:

```bash
kubectl get validatingwebhookconfigurations
```

Example output:

```text
kyverno-resource-validating-webhook-cfg
kyverno-policy-validating-webhook-cfg
```

Describe one:

```bash
kubectl describe validatingwebhookconfiguration <webhook-name>
```

---

## Admission Controller vs RBAC

| Feature                       | RBAC | Admission Controller |
| ----------------------------- | ---- | -------------------- |
| Controls who can do something | ✅    | ❌                    |
| Controls what can be created  | ❌    | ✅                    |
| Modifies resources            | ❌    | ✅                    |
| Validates configuration       | ❌    | ✅                    |

Example:

RBAC:

```text
Can Alice create Pods?
```

Admission Controller:

```text
Is Alice's Pod secure?
```

---

## Summary

Admission Controllers are Kubernetes gatekeepers that inspect requests after authentication and authorization but before resources are stored.

They are used to:

* Enforce security policies
* Validate configurations
* Automatically modify resources
* Ensure compliance and governance

Tools like Kyverno and OPA Gatekeeper extend admission control by allowing organizations to define custom policies that automatically approve, modify, or reject Kubernetes resources.
