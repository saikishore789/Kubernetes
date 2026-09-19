# KEDA

KEDA (Kubernetes Event-driven Autoscaling) is a Kubernetes add-on that scales workloads according to the amount of work waiting in an external event source. It connects event sources such as RabbitMQ, Kafka, Azure Service Bus, Prometheus, and cron schedules to Kubernetes autoscaling.

KEDA works with Kubernetes rather than replacing it. It uses a `ScaledObject` to describe the workload and event trigger, then exposes the trigger as a metric that Kubernetes can use to scale a Deployment. KEDA can also scale a workload down to zero when there is no work.

## Why We Use KEDA

CPU and memory are not always good indicators of work. A consumer may be idle while messages are waiting in a queue, or it may use little CPU while processing a large backlog. KEDA is useful when the desired capacity is directly related to an event source:

- Start consumers only when messages arrive.
- Scale out as the queue backlog grows.
- Scale back to zero when the queue is empty.
- Avoid running a fixed number of idle consumer pods.
- Keep autoscaling rules alongside the Kubernetes workload configuration.

## Main Components

### KEDA Operator

The operator watches KEDA custom resources such as `ScaledObject` and `TriggerAuthentication`. It manages the autoscaling relationship and makes sure the target workload is scaled according to the configured trigger.

### Scalers

Scalers are integrations with event sources. The RabbitMQ scaler reads a queue's message count. Other scalers can read Kafka lag, cloud queue depth, Prometheus metrics, cron schedules, and many other signals.

### KEDA Metrics Server

The metrics server exposes external event metrics to Kubernetes. For this example, it exposes the RabbitMQ `orders` queue length so Kubernetes can make scaling decisions.

### Custom Resources

- `ScaledObject`: connects a workload to one or more triggers and defines scaling limits and timing.
- `TriggerAuthentication`: tells KEDA how to obtain credentials or connection information for a scaler.
- `ScaledJob`: an alternative resource for scaling Kubernetes Jobs instead of a long-running Deployment.

### Kubernetes HPA

For a `ScaledObject` targeting a Deployment, KEDA creates or manages a Horizontal Pod Autoscaler (HPA). The HPA performs the replica-count changes, while KEDA supplies the event-driven metric and handles scale-to-zero behavior.

## HPA vs KEDA

| Area | Kubernetes HPA | KEDA |
| --- | --- | --- |
| Primary signal | CPU, memory, or metrics already available through Kubernetes metrics APIs | External events such as queue length, stream lag, or a schedule |
| Scale-to-zero | Not normally supported for standard HPA workloads | Supported when configured with `minReplicaCount: 0` |
| Event-source integration | Requires a separate metrics adapter or custom integration | Provides ready-made scalers for many event systems |
| Responsibility | Calculates and applies the desired replica count | Reads the event source and makes that signal available to Kubernetes; HPA applies normal scaling |
| Best fit | Keeping pods sized for resource utilization | Scaling consumers based on pending work |

KEDA and HPA can be used together. KEDA is the bridge from the event source to Kubernetes autoscaling; it is not a replacement for the Kubernetes scaling mechanism.

## RabbitMQ Demo

The `demo-rabbitq` folder demonstrates a RabbitMQ-backed order-processing consumer:

```text
publisher Job -> RabbitMQ orders queue -> order-consumer Deployment
                                      ^
                                      |
                         KEDA RabbitMQ scaler reads queue length
```

### Files in the demo

- `rabbitmq-deploy.yaml`: deploys RabbitMQ with the AMQP service on port `5672` and management service port `15672`.
- `consumer-deploy.yaml`: defines the `order-consumer` Deployment. It starts at `0` replicas and reads the `orders` queue.
- `publisher-job.yaml`: runs the publisher image as a Kubernetes Job. Its default argument publishes `50` messages.
- `scaled-object.yaml`: defines the RabbitMQ scaler, authentication, and scaling limits.
- `consumer.py`: consumes one message at a time, waits three seconds to simulate processing, and acknowledges the message.
- `publisher.py`: declares the queue and publishes durable `Order-1`, `Order-2`, and later messages.
- `dockerfile` and `dockerfile.publisher`: build the consumer and publisher images with the `pika` RabbitMQ client.

## How KEDA Is Implemented with RabbitMQ

### 1. Deploy RabbitMQ

`rabbitmq-deploy.yaml` creates a single RabbitMQ pod and a ClusterIP Service named `rabbitmq`. Inside the cluster, clients can connect to RabbitMQ using the service DNS name. The demo uses the default `guest` credentials and the `rabbitmq:3-management` image.

The service provides:

- `rabbitmq:5672` for AMQP client traffic.
- `rabbitmq:15672` for the RabbitMQ management interface.

### 2. Build the local application images

Build both images from the `demo-rabbitq` directory:

```powershell
docker build -f dockerfile -t order-consumer:latest .
docker build -f dockerfile.publisher -t order-publisher:latest .
```

The manifests use `imagePullPolicy: Never`, so the images must be available to the Kubernetes node. With Minikube, build them inside Minikube's Docker environment or load them into Minikube:

```powershell
minikube image load order-consumer:latest
minikube image load order-publisher:latest
```

If the images were built directly inside Minikube, the `image load` commands are unnecessary.

### 3. Deploy the consumer

Apply `consumer-deploy.yaml`. The Deployment intentionally starts with `replicas: 0`. KEDA will increase this value when it detects messages in RabbitMQ.

The container receives:

- `RABBITMQ_HOST=rabbitmq`, which resolves to the RabbitMQ Service.
- `QUEUE_NAME=orders`, which is the queue consumed by the application.

The consumer uses `prefetch_count=1`, waits three seconds per message, and acknowledges a message only after processing finishes. This makes the effect of scaling easy to observe.

### 4. Store the RabbitMQ connection information

The first resource in `scaled-object.yaml` is a Secret named `rabbitmq-secret`. Its `host` value is:

```text
amqp://guest:guest@rabbitmq.default.svc.cluster.local:5672/
```

This is the fully qualified Kubernetes Service DNS name for RabbitMQ. In a production cluster, credentials should be replaced with strong, separately managed credentials rather than the demo `guest` account.

### 5. Connect the secret to KEDA

The `TriggerAuthentication` named `rabbitmq-trigger-auth` maps the Secret key `host` to the scaler parameter also named `host`:

```yaml
secretTargetRef:
  - parameter: host
    name: rabbitmq-secret
    key: host
```

The RabbitMQ scaler can therefore authenticate without putting the connection string directly in the `ScaledObject`.

### 6. Configure the RabbitMQ `ScaledObject`

The `ScaledObject` named `order-consumer-scaled-object` targets the `order-consumer` Deployment:

```yaml
scaleTargetRef:
  name: order-consumer
minReplicaCount: 0
maxReplicaCount: 10
pollingInterval: 5
cooldownPeriod: 30
triggers:
  - type: rabbitmq
    metadata:
      queueName: orders
      mode: QueueLength
      value: "5"
```

The important behavior is:

- KEDA checks RabbitMQ every 5 seconds.
- The trigger watches the `orders` queue.
- A queue length of `5` is the target value used for scaling decisions.
- Replicas may grow from `0` to `10`.
- After the queue becomes inactive, KEDA waits 30 seconds before scaling down according to the configured cooldown.

### 7. Publish work and observe scaling

From the repository root, apply the resources in dependency order:

```powershell
kubectl apply -f KEDA/demo-rabbitq/rabbitmq-deploy.yaml
kubectl apply -f KEDA/demo-rabbitq/consumer-deploy.yaml
kubectl apply -f KEDA/demo-rabbitq/scaled-object.yaml
kubectl apply -f KEDA/demo-rabbitq/publisher-job.yaml
```

The publisher Job sends `50` messages by default. Watch the Deployment, pods, and queue-processing logs:

```powershell
kubectl get scaledobject,hpa,deploy,pods -w
kubectl logs -l app=order-consumer -f
kubectl get jobs,pods
```

Because each consumer takes about three seconds per message and RabbitMQ receives 50 messages, the queue backlog gives KEDA a reason to start more consumer replicas. As messages are acknowledged and the queue drains, KEDA reduces the Deployment toward zero after the cooldown period.

To publish a different number of messages, edit the Job argument or create a new Job with a different argument, for example `args: ["100"]`.

## End-to-End Verification

Check the resources and KEDA events:

```powershell
kubectl get pods
kubectl get deploy order-consumer
kubectl get hpa
kubectl describe scaledobject order-consumer-scaled-object
kubectl describe hpa
```

Expected results during a run:

1. RabbitMQ is Ready and its Service is available.
2. `order-consumer` begins at zero replicas.
3. The publisher Job completes after sending its messages.
4. KEDA reports the RabbitMQ trigger as active and the consumer Deployment scales above zero.
5. Consumer logs show orders being processed and acknowledged.
6. After the queue drains and the cooldown expires, the consumer scales back toward zero.

## Prerequisites and Notes

- A Kubernetes cluster with KEDA installed and its CRDs available.
- `kubectl`, Docker, and access to the cluster's image runtime.
- The demo resources use the `default` namespace. Keep the Secret, `TriggerAuthentication`, `ScaledObject`, Deployment, Job, and RabbitMQ Service in the same namespace unless the manifests are updated consistently.
- The RabbitMQ Deployment has no persistent volume, so its queue data is intended for a lab and can be lost when the pod is recreated.
- The RabbitMQ credentials and images are deliberately simple for local learning and should be hardened for production.