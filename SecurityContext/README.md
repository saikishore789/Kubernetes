# Kubernetes SecurityContext and Related Concepts

This document provides an overview and practical examples related to Kubernetes `SecurityContext`, admission controllers, and user namespaces. These are important concepts for securing containerized applications in Kubernetes.

---

## SecurityContext

A `SecurityContext` in Kubernetes defines privilege and access control settings for a Pod or Container. These settings help control the security features available to the containerized process.

### Key features explained:
- `runAsNonRoot`: Ensures the container runs as a non-root user.
- `runAsUser`: Specifies the UID to run the container process as.
- `runAsGroup`: Specifies the GID to run the container process as.

### Practical examples:
- `container-security-pod.yaml`: Defines container-level security context with specific user and group IDs, enforcing non-root execution.
- `normal-pod.yaml`: Shows pod-level security context applied to all containers and individual container overrides.
- `secure-pod-level.yaml`: Pod-level security context ensuring all containers within the pod follow specified user and group IDs.

Using these settings enhances security by limiting container privileges.

---

## Admission Controllers

Admission controllers are plugins that govern and enforce how the cluster is used. They intercept API requests post-authentication/authorization but before persistence, and can modify or reject requests.

### Example policy:
- `require-nonroot-containers.yaml`: A Kyverno validating policy that denies pods where containers run as root user or without explicit `runAsNonRoot` set to true.

This policy helps ensure containers comply with security best practices before they are created or updated.

---

## User Namespaces

User namespaces separate the user and group IDs between the host and the container, increasing security by isolating container privileges.

### Practical exercise:
- Created a kind cluster with user namespace support.
- Practiced deploying pods with user namespace awareness using `usernamespce-pod.yaml`.

This practice helps understand how user namespaces restrict container privileges and prevent privilege escalations.

---

## How to Practice

1. Create a kind cluster.
2. Apply the YAML files for security contexts to see the effect on container privileges.
3. Use Kyverno (or similar tools) to enforce admission controller policies on pod creation.
4. Deploy pods with user namespaces enabled to experience isolation benefits.


