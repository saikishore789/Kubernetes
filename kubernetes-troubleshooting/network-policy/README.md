What are Kubernetes Network Policies?
Network Policies are a mechanism for controlling network traffic flow in Kubernetes clusters. They allow you to define which of your Pods are allowed to exchange network traffic. You should use them in your clusters to prevent apps from reaching each other over the network, which will help limit the damage if one of your apps is compromised.

Each Network Policy you create targets a group of Pods and sets the Ingress (incoming) and Egress (outgoing) network endpoints those Pods can communicate with.

There are three different ways to identify target endpoints:

Specific Pods (Pods matching a label are allowed)
Specific Namespaces (all Pods in the namespace are allowed)
IP address blocks (endpoints with an IP address in the block are allowed)
How does Network Policy work?
Network Policies can set a different list of allowed targets for their Ingress and Egress rules. It’s also possible to use Network Policies to block all network communications for a Pod or restrict traffic to a specific port range.

Network Policies are additive, so you can have multiple policies targeting a particular Pod. The sum of the “allow” rules from all the policies will apply. Traffic from or to sources that don’t match any of the “allow” rules will be blocked if the target Pod is also covered by a “deny” policy.

In the OSI networking model, Network Policies represent layer 3/4 controls. They work with IP addresses and port numbers at the network transport level. This provides quite granular options to configure the network flows you require.

Nonetheless, Network Policies aren’t a fully complete solution. There are several limitations in the current version, such as the inability to log events when a network policy block occurs and lack of support for explicit deny policies. It’s also impossible to stop loopback or incoming host traffic using a Network Policy. If you need these features, then you should consider using a separate service mesh in addition to your network policies.

How are Network Policies implemented?
Responsibility for implementing the features provided by Network Policies falls to the CNI networking plugin you’re using in your cluster. Your plugin must support use of network policies for your rules to have any effect.

Managed Kubernetes services from cloud providers will automatically enable support. If you’re running your own cluster, you should ensure you’re using a compatible CNI plugin. The popular Flannel plugin doesn’t support network policies, while Calico does.

Kubernetes Network Policy use cases
Using Network Policies is a best practice for a secure Kubernetes configuration. They prevent Pod network access from being unnecessarily broad, such as in the following scenarios:

Ensuring a database can only be accessed by the app it’s part of: Databases running in Kubernetes are often intended to be solely accessed by other in-cluster Pods, such as the Pods that run your app’s backend. Network Policies allow you to enforce this constraint, preventing other apps from communicating with your database server.
Isolating Pods from your cluster’s network: Some sensitive Pods might not need to accept any inbound traffic from other Pods in your cluster. Using a Network Policy to block all Ingress traffic to them will tighten your workload’s security.
Allow specific apps or namespaces to communicate with each other: Kubernetes namespaces are the primary mechanism for separating objects associated with different apps, teams, and environments. You can use Network Policies to network-isolate these resources and achieve stronger multi-tenancy.
Now let’s see an example of creating and using a simple Network Policy.

How to create a Network Policy in Kubernetes
Before following this guide, you’ll need access to a Kubernetes cluster that’s using a CNI plugin with Network Policy support. If you need to create one, you can start a Minikube cluster and opt-in to using Calico:

$ minikube start --cni calico
Next, create a pair of Pods that will be used to test whether network communications are being blocked:

$ kubectl run pod1 --image nginx:latest -l app=pod1
pod/pod1 created

$ kubectl run pod2 --image nginx:latest -l app=pod2
pod/pod2 created
The -l flag sets a label that will let you reference the Pods within your Network Policies. Use Kubectl’s get pods command with the -o wide option to check your Pods are running and learn their IP addresses:

$ kubectl get pods
NAME   READY   STATUS    RESTARTS   AGE   IP              NODE       NOMINATED NODE   READINESS GATES
pod1   1/1     Running   0          59s   10.244.120.70   minikube   <none>           <none>
pod2   1/1     Running   0          57s   10.244.120.71   minikube   <none>           <none>
Your IP addresses will be different to those shown above. You should adjust the example commands in the rest of this tutorial to include your Pod IPs.

Now run a command inside pod1 to verify that it can communicate with pod2:

$ kubectl exec -it pod1 -- curl 10.244.120.71 --max-time 1
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
pod1 has successfully received a response from the NGINX server running in pod2. This is the expected result because the Kubernetes default settings allow all Pods to communicate.

Creating a Network Policy
Next, copy the following YAML manifest and save it to np.yaml in your working directory:

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: network-policy
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: pod2
  policyTypes:
    - Ingress
    - Egress
This is one of the simplest possible Network Policies. It selects the pod2 Pod by matching its labels using a podSelector. This is the Pod the Network Policy’s Ingress and Egress rules will apply to. Because the Ingress and Egress policy types are set but no further rules are added, the policy will block all network traffic to and from the Pod.

Use Kubectl to apply your Network Policy:

$ kubectl apply -f np.yaml
networkpolicy.networking.k8s.io/network-policy created
Now, repeat the earlier command to try to communicate with pod2 from pod1:

$ kubectl exec -it pod1 -- curl 10.244.120.71 --max-time 1
curl: (28) Connection timed out after 1001 milliseconds
command terminated with exit code 28
This time the connection does not succeed. The Network Policy targeting pod2 blocks all network traffic so pod1 cannot communicate.

Adding an Allow Rule
Next, modify your np.yaml manifest to include the following content:

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: network-policy
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: pod2
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
      - podSelector:
          matchLabels:
            app: pod1
  egress:
    - to:
      - podSelector:
          matchLabels:
            app: pod1
This Network Policy states that pod2 accepts Ingress and Egress traffic when the other end of the connection is a Pod that’s labeled app=pod1.

Apply the policy to your cluster:

$ kubectl apply -f np.yaml
networkpolicy.networking.k8s.io/network-policy created
Now repeat the test command:

$ kubectl exec -it pod1 -- curl 10.244.120.71 --max-time 1
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
Now pod1 can communicate with pod2 again because it matches the selectors in the Network Policy’s allow rules.

If you create another unlabeled Pod, it’ll be blocked from communicating because it won’t match the Network Policy’s selectors:

$ kubectl run pod3 --image nginx:latest

$ kubectl exec -it pod3 -- curl 10.244.120.71 --max-time 1
curl: (28) Connection timed out after 1001 milliseconds
command terminated with exit code 28
