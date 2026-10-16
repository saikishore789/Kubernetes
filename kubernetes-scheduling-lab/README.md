# Kubernetes Scheduling Lab

This lab focuses on Kubernetes pod scheduling features: nodeSelector, node affinity, pod affinity/anti-affinity, and taints & tolerations. Each example is self-contained and maps to a real YAML in this folder

---

## 1. nodeSelector
**Purpose:**
Assign a pod to nodes with specific labels.

**How it works:**
Pod will only schedule on a node if all `nodeSelector` key-value pairs match node labels.

**YAML Example:**
```yaml
spec:
  nodeSelector:
    disktype: ssd
```

See: [node-selector.yaml](./node-selector.yaml)

**Verification:**
```sh
kubectl get nodes --show-labels
kubectl apply -f node-selector.yaml
kubectl get pod selector-ssd -o wide
```

---

## 2. Node Affinity
**Purpose:**
Advanced node selection based on label rules. Has `requiredDuringSchedulingIgnoredDuringExecution` (hard) and `preferredDuringSchedulingIgnoredDuringExecution` (soft) options.

**How it works:**
- **Required**: Pod is scheduled only on nodes matching criteria.
- **Preferred**: Scheduler tries to place pod on nodes matching preferred criteria, but falls back if none found.

**YAML Example:**
```yaml
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
            - key: disktype
              operator: In
              values:
                - ssd
                - hdd
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 50
        preference:
          matchExpressions:
            - key: disktype
              operator: In
              values:
                - hdd
```
See: [node-affinity.yaml](./node-affinity.yaml)

**Verification:**
```sh
kubectl get nodes --show-labels
kubectl apply -f node-affinity.yaml
kubectl get pod affinity-required-preferred -o wide
```

---

## 3. Pod Affinity & Anti-affinity
**Purpose:**
Pod (anti)affinity constraints schedule pods near (or away from) other specific pods.

### Pod Affinity Example
```yaml
spec:
  affinity:
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchLabels:
            app: cache
        topologyKey: kubernetes.io/hostname
```
See: [pod-affinity.yaml](./pod-affinity.yaml)

### Pod Anti-Affinity Example
```yaml
spec:
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchLabels:
            app: spread-demo
        topologyKey: kubernetes.io/hostname
```
See: [pod-anti-affinity.yaml](./pod-anti-affinity.yaml)

**Verification:**
```sh
kubectl apply -f pod-affinity.yaml
kubectl get pods -o wide
kubectl apply -f pod-anti-affinity.yaml
kubectl get pods -o wide
```

---

## 4. Taints & Tolerations
**Purpose:**
Prevent pods from scheduling on specific nodes unless they tolerate the taint.

**How it works:**
- **Taint** is set on node: only pods with a matching `toleration` will be scheduled there.

**YAML Example:**
```yaml
spec:
  tolerations:
    - key: gpu
      operator: Equal
      value: "true"
      effect: NoSchedule
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: accelerator
                operator: In
                values:
                  - gpu
```
See: [gpu-toleration.yaml](./gpu-toleration.yaml)

**Add a taint to the node:**
```sh
kubectl taint nodes <node-name> gpu=true:NoSchedule
```

**Verification:**
```sh
kubectl describe node <node-name>
kubectl apply -f gpu-toleration.yaml
kubectl get pod gpu-tolerant -o wide
```

---

# Useful Commands & History
Common commands for scheduling features:
- `kubectl get nodes --show-labels`
- `kubectl label nodes <node> disktype=ssd`
- `kubectl taint nodes <node> gpu=true:NoSchedule`
- `kubectl apply -f <yaml>`
- `kubectl get pods -o wide`
- `kubectl describe pod <pod>`

