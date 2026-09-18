# Horizontal Pod Autoscaler (HPA)

## What is HPA?

Horizontal Pod Autoscaler (HPA) is a Kubernetes feature that automatically adjusts the number of pod replicas for a Deployment, ReplicaSet, or StatefulSet based on observed CPU, memory, or custom metrics.

Instead of manually scaling an application up or down, HPA continuously monitors workload usage and modifies the replica count to keep the application responsive and efficient.

## Why do we need HPA?

Applications often face changing demand:

- Traffic may rise during business hours or marketing campaigns.
- Background jobs or batch workloads may create bursts of CPU usage.
- Idle workloads should scale down to save costs.

HPA helps by:

- Improving application availability during spikes.
- Reducing wasted resources when traffic is low.
- Avoiding manual intervention for routine scaling.
- Supporting better cost optimization in cloud and on-prem Kubernetes clusters.

In simple terms, HPA keeps your application healthy without over-provisioning or under-provisioning resources.

## How HPA works

HPA works through the Kubernetes control plane and a controller called the Horizontal Pod Autoscaler controller.

The basic workflow is:

1. HPA checks the current metric values for the target workload.
2. It compares the current value to the target value configured in the HPA manifest.
3. If the current usage is above the target, it increases the replica count.
4. If the current usage is below the target, it decreases the replica count.
5. Kubernetes creates or removes pods to reach the desired replica count.

Example:

- CPU target is 50% average utilization.
- Current average CPU usage is 80%.
- HPA decides to scale out by increasing replicas.
- When CPU usage falls below 50%, HPA reduces replicas.

HPA can use metrics such as:

- CPU utilization
- Memory utilization
- Custom metrics from Prometheus, Datadog, or other monitoring systems
- External metrics from external APIs or monitoring services

## Common HPA configuration values

A typical HPA definition includes:

- `minReplicas`: minimum number of pods allowed
- `maxReplicas`: maximum number of pods allowed
- `target`: desired metric threshold
- `metrics`: defines the metrics used for scaling

For example, a CPU-based HPA may target 50% utilization, meaning the system tries to keep average pod CPU usage around half of the requested CPU limit.

## Prerequisites for HPA

To use HPA successfully, the following prerequisites are needed:

### 1. Kubernetes cluster

You must have a working Kubernetes cluster with a functioning control plane and nodes.

### 2. Metrics Server

For CPU and memory-based autoscaling, the cluster must have Metrics Server installed and working.

Metrics Server collects resource usage data from pods and nodes and exposes it to the HPA controller.

Without Metrics Server, HPA cannot read CPU or memory usage information.

### 3. Resource requests configured

The workload should define CPU or memory requests in its pod specification. For example:

```yaml
resources:
  requests:
    cpu: 200m
```

HPA relies on requested values to calculate utilization.

### 4. Suitable workload type

HPA works with scalable workloads such as:

- Deployments
- ReplicaSets
- StatefulSets

It does not directly scale DaemonSets or Jobs in the same way.

### 5. Monitoring support for custom metrics

If you plan to scale based on custom metrics, you need additional monitoring tooling such as:

- Prometheus
- Prometheus Adapter
- Datadog or another metrics provider

### 6. Proper RBAC and permissions

The cluster must allow the HPA controller to read metrics and modify the deployment replica count. This is usually handled by default Kubernetes RBAC when set up correctly.

### 7. Reasonable min/max values

You should set sensible minimum and maximum replica counts to prevent:

- too few replicas during a spike
- too many replicas causing unnecessary cost

## Example HPA manifest

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: php-apache-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: php-apache
  minReplicas: 1
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 50
```

This HPA will keep the average CPU utilization around 50% by adjusting the number of replicas between 1 and 10.

## Summary

HPA is a Kubernetes autoscaling feature that helps applications scale horizontally based on real-time resource demand. It is needed to handle traffic variability, improve performance, and optimize cost. It works by collecting metrics, comparing them to target values, and adjusting the replica count automatically.

For CPU and memory-based HPA, the key prerequisites are a working Kubernetes cluster, Metrics Server, and properly configured resource requests. For advanced scaling, custom metrics and monitoring integrations may also be required.
