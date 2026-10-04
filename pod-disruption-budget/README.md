# Pod Disruption Budget and Topology Spread Lab

This lab demonstrates how Kubernetes can spread replicas across worker nodes
and protect an application during a voluntary node drain. It uses a Kind
cluster with one control-plane node and three workers, a six-replica NGINX
Deployment, and a PodDisruptionBudget (PDB).

## Files

- [`kind-cluster.yaml`](./kind-cluster.yaml) defines the Kind cluster: one
  control-plane node and three worker nodes.
- [`nginx-pdb.yaml`](./nginx-pdb.yaml) defines the NGINX Deployment and
  `nginx-pdb` PDB. The Deployment has six replicas, an HTTP readiness probe,
  and a topology spread constraint. The PDB selects the Deployment's
  `app: nginx` pods and sets `minAvailable: 4`.

## How the lab works

### PodDisruptionBudget (PDB)

A PDB sets the availability Kubernetes should preserve when handling
**voluntary** disruptions through the Eviction API, such as `kubectl drain`.
This manifest uses:

```yaml
minAvailable: 4
```

The selector matches pods labeled `app: nginx`. When all six replicas are
healthy, up to two may be voluntarily disrupted at a time (`6 - 4 = 2`).
This is not a guarantee that two evictions will always be allowed: if pods
are already unavailable, the number of allowed disruptions can be lower.
The readiness probe matters because unready pods do not count as available.

The PDB does not create replacement pods or control their placement. The
Deployment controller creates replacements, and the scheduler places them.
The PDB also does not prevent involuntary failures, such as a worker crashing.

Check the PDB's live status and allowed disruptions with:

```powershell
kubectl get pdb nginx-pdb
kubectl describe pdb nginx-pdb
```

### Topology spread constraint

The Deployment's `topologySpreadConstraints` entry uses:

```yaml
maxSkew: 1
topologyKey: node
whenUnsatisfiable: DoNotSchedule
labelSelector:
  matchLabels:
    app: nginx
```

The scheduler counts matching NGINX pods in topology domains. A domain is
identified by the value of the specified label key on a node. Here,
`topologyKey: node` means the value of each node's `node` label determines
its domain. The three distinct values `worker-1`, `worker-2`, and `worker-3`
therefore provide three domains.

`maxSkew: 1` asks the scheduler to keep the difference between the most- and
least-populated eligible domains at no more than one. With six pods over
three worker domains, the expected steady-state placement is two pods per
worker. `DoNotSchedule` means a pod remains Pending rather than being placed
if doing so would violate the constraint.

The PDB and topology spread constraint solve different problems: the PDB
limits voluntary evictions; topology spread influences pod scheduling. The
PDB does not cause even distribution, and topology spread does not keep pods
available during a drain.

## Create the cluster

Run from this directory. The config file in this directory is named
`kind-cluster.yaml`, so the command that works here is:

```powershell
kind create cluster --name pdb-lab --config kind-cluster.yaml
kubectl get nodes -o wide
```

If your local copy of the config is named `kind-config.yaml`, the equivalent
command is:

```powershell
kind create cluster --name pdb-lab --config kind-config.yaml
```

Kind normally names the nodes `pdb-lab-control-plane`, `pdb-lab-worker`,
`pdb-lab-worker2`, and `pdb-lab-worker3`. Check the names returned by
`kubectl get nodes` before labeling. The control-plane node is not labeled
for this workload; its control-plane taint normally keeps the NGINX pods on
the workers.

## Label the worker topology domains

Assign a unique value for the `node` label to each worker:

```powershell
kubectl label node pdb-lab-worker node=worker-1
kubectl label node pdb-lab-worker2 node=worker-2
kubectl label node pdb-lab-worker3 node=worker-3
kubectl get nodes -L node
```

The label values are intentionally different. If a node already has a
different `node` label, add `--overwrite`, for example:

```powershell
kubectl label node pdb-lab-worker node=worker-1 --overwrite
```

## Deploy the workload

The Deployment and PDB are both in `nginx-pdb.yaml`:

```powershell
kubectl apply -f nginx-pdb.yaml
kubectl rollout status deployment/nginx
kubectl get pods -l app=nginx -o wide
kubectl get pdb nginx-pdb
```

Once the six pods are Ready, check the `NODE` column. With the three labeled
topology domains, the expected even distribution is two pods on each worker.
The manifest's HTTP readiness probe requests `/` on port 80; image-pull time
and readiness can delay the steady state.

## Drain one worker

Choose a worker with two NGINX pods in the `NODE` column. The example drains
`pdb-lab-worker`; use the name of the worker you selected:

```powershell
kubectl drain pdb-lab-worker --ignore-daemonsets
kubectl get pdb nginx-pdb
kubectl get pods -l app=nginx -o wide
```

Draining cordons the node and requests eviction of its pods. With six healthy
replicas and `minAvailable: 4`, the PDB allows voluntary disruption while
maintaining at least four available pods. As pods are evicted, the Deployment
creates replacements; the cordoned worker is no longer a place for new
scheduled pods.

After the drain, the topology constraint schedules the six replicas across
the two remaining eligible worker domains. Once replacements are Ready, the
expected balanced placement is three pods per remaining worker. During
eviction and replacement, there may temporarily be fewer than six Ready
pods, so check again after the rollout settles:

```powershell
kubectl rollout status deployment/nginx
kubectl get pods -l app=nginx -o wide
kubectl get pdb nginx-pdb
```

If eviction is blocked, check `ALLOWED DISRUPTIONS`, pod readiness, and
events. If a replacement remains Pending, check its scheduling events and
verify that the topology label values and eligible workers are as expected.
The PDB permits safe voluntary eviction; it does not itself rebalance pods.

Restore the worker after the exercise:

```powershell
kubectl uncordon pdb-lab-worker
```

## Cleanup

Delete the lab cluster when finished:

```powershell
kind delete cluster --name pdb-lab
```
