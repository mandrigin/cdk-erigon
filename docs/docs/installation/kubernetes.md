# Kubernetes Deployment

cdk-erigon includes Kubernetes configurations for enterprise-scale deployments. The `k8s/` directory contains Kustomize-based manifests for deploying to various Kubernetes environments.

## Directory Structure

```
k8s/
├── base/                           # Base manifests
│   ├── kustomization.yaml
│   ├── statefulset.yaml           # Main StatefulSet definition
│   └── services/                   # Service definitions
│       ├── http.yaml              # HTTP JSON-RPC service
│       ├── metrics.yaml           # Prometheus metrics service
│       ├── eth66-peering-tcp.yaml # P2P TCP service
│       ├── eth66-peering-udp.yaml # P2P UDP service
│       ├── snap-sync-tcp.yaml     # Snapshot sync TCP
│       └── snap-sync-udp.yaml     # Snapshot sync UDP
│
└── google-kubernetes-engine/       # GKE-specific overlays
    ├── kustomization.yaml
    ├── statefulset-erigon-patch.yaml  # GKE patches
    ├── podmonitoring.yaml         # GKE Pod Monitoring
    └── tls/                       # TLS configurations
```

## Prerequisites

- Kubernetes cluster (1.24+)
- `kubectl` configured for your cluster
- `kustomize` (or kubectl with kustomize support)
- Persistent volume provisioner (for data storage)

## Base Deployment

The base configuration provides a minimal StatefulSet suitable for customization.

### Deploy Base

```bash
# Preview the manifests
kubectl kustomize k8s/base

# Apply to cluster
kubectl apply -k k8s/base
```

### Base StatefulSet Features

The base `statefulset.yaml` includes:

- Single replica StatefulSet
- Security context with dropped capabilities
- Read-only root filesystem
- Non-root user (UID 1000)
- Resource requests: 2.5 CPU, 16Gi memory
- Ports for all services (RPC, P2P, metrics, etc.)

### Customizing the Base

Create your own overlay:

```bash
mkdir -p k8s/my-deployment
```

Create `k8s/my-deployment/kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../base
  - ../base/services

patchesJson6902:
  - path: patches.yaml
    target:
      group: apps
      kind: StatefulSet
      name: erigon
      version: v1
```

Create `k8s/my-deployment/patches.yaml` with your customizations.

## Google Kubernetes Engine (GKE)

The `google-kubernetes-engine/` overlay provides GKE-optimized configurations.

### GKE Features

- **3 replicas** for high availability
- **Premium SSD storage** (premium-rwo StorageClass)
- **3TB persistent volume** per replica
- **High-memory nodes**: 9 CPU, 110Gi memory per pod
- **Pod Monitoring** for GKE-native Prometheus integration
- **Init container** for data directory permissions

### Deploy to GKE

```bash
# Preview
kubectl kustomize k8s/google-kubernetes-engine

# Apply
kubectl apply -k k8s/google-kubernetes-engine
```

### GKE Configuration Details

The patch configures the StatefulSet with production settings:

```yaml
# Command arguments
args:
  - '--chain=mainnet'
  - '--datadir=/home/erigon/.local/share/erigon'
  - '--db.pagesize=64KB'
  - '--healthcheck'
  - '--http'
  - '--http.addr=0.0.0.0'
  - '--http.api=eth,erigon,web3,net,debug,ots,trace,txpool'
  - '--http.corsdomain=*'
  - '--http.vhosts=any'
  - '--metrics'
  - '--metrics.addr=0.0.0.0'
  - '--ws'
```

## Custom Deployment Example

### zkEVM Mainnet on AWS EKS

Create `k8s/eks-mainnet/kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../base
  - ../base/services

namespace: cdk-erigon

patchesJson6902:
  - path: statefulset-patch.yaml
    target:
      group: apps
      kind: StatefulSet
      name: erigon
      version: v1

configMapGenerator:
  - name: erigon-config
    files:
      - mainnet.yaml
```

Create `k8s/eks-mainnet/statefulset-patch.yaml`:

```yaml
- op: replace
  path: /spec/replicas
  value: 2

- op: replace
  path: /spec/template/spec/containers/0/args
  value:
    - '--config=/config/mainnet.yaml'
    - '--zkevm.l1-rpc-url=$(L1_RPC_URL)'
    - '--datadir=/home/erigon/.local/share/erigon'
    - '--http'
    - '--http.addr=0.0.0.0'
    - '--http.api=eth,web3,net,zkevm'
    - '--metrics'
    - '--metrics.addr=0.0.0.0'

- op: add
  path: /spec/template/spec/containers/0/env
  value:
    - name: L1_RPC_URL
      valueFrom:
        secretKeyRef:
          name: erigon-secrets
          key: l1-rpc-url

- op: replace
  path: /spec/template/spec/containers/0/resources
  value:
    requests:
      cpu: '4'
      memory: 32Gi
    limits:
      cpu: '8'
      memory: 64Gi

- op: add
  path: /spec/volumeClaimTemplates/-
  value:
    metadata:
      name: data
    spec:
      accessModes:
        - ReadWriteOnce
      storageClassName: gp3
      resources:
        requests:
          storage: 2000Gi

- op: replace
  path: /spec/template/spec/containers/0/volumeMounts
  value:
    - mountPath: /home/erigon/.local/share/erigon
      name: data
    - mountPath: /config
      name: config

- op: add
  path: /spec/template/spec/volumes
  value:
    - name: config
      configMap:
        name: erigon-config
```

Create the secret for L1 RPC URL:

```bash
kubectl create secret generic erigon-secrets \
  --from-literal=l1-rpc-url='https://your-l1-rpc-endpoint.com'
```

Deploy:

```bash
kubectl apply -k k8s/eks-mainnet
```

## Services

### HTTP JSON-RPC Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: erigon-http
spec:
  selector:
    app: erigon
  ports:
    - port: 8545
      targetPort: http
      protocol: TCP
  type: ClusterIP
```

Expose externally with a LoadBalancer or Ingress:

```bash
# LoadBalancer
kubectl patch svc erigon-http -p '{"spec": {"type": "LoadBalancer"}}'

# Or use Ingress with TLS
```

### Metrics Service

The metrics service exposes Prometheus metrics on port 6060:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: erigon-metrics
spec:
  selector:
    app: erigon
  ports:
    - port: 6060
      targetPort: metrics
```

## Scaling Considerations

### Horizontal Scaling

cdk-erigon nodes can run independently. Scale by increasing replicas:

```yaml
- op: replace
  path: /spec/replicas
  value: 3
```

Each replica requires its own persistent volume.

### Load Balancing

For RPC load balancing:

1. Deploy multiple replicas
2. Use a Service with `type: LoadBalancer`
3. Or configure an Ingress controller

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: erigon-ingress
  annotations:
    nginx.ingress.kubernetes.io/proxy-body-size: "0"
spec:
  rules:
    - host: rpc.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: erigon-http
                port:
                  number: 8545
```

### Resource Recommendations

| Deployment Size | Replicas | CPU/Pod | Memory/Pod | Storage/Pod |
|-----------------|----------|---------|------------|-------------|
| Development | 1 | 2 | 16Gi | 500Gi |
| Production | 2-3 | 4-8 | 32-64Gi | 1-2Ti |
| High Availability | 3+ | 8+ | 64Gi+ | 2Ti+ |

## Monitoring

### Prometheus ServiceMonitor

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: erigon
spec:
  selector:
    matchLabels:
      app: erigon
  endpoints:
    - port: metrics
      interval: 15s
```

### GKE Pod Monitoring

The GKE overlay includes native Pod Monitoring:

```yaml
apiVersion: monitoring.googleapis.com/v1
kind: PodMonitoring
metadata:
  name: erigon
spec:
  selector:
    matchLabels:
      app: erigon
  endpoints:
    - port: metrics
      interval: 30s
```

## Troubleshooting

### Pod Not Starting

Check pod events:

```bash
kubectl describe pod erigon-0
kubectl logs erigon-0
```

### Storage Issues

Verify PVC binding:

```bash
kubectl get pvc
kubectl describe pvc data-erigon-0
```

### Permission Errors

The init container handles permission setup. If issues persist:

```bash
# Check init container logs
kubectl logs erigon-0 -c chown-datadir
```

## Next Steps

- [Configure your node](../configuration/index.md)
- [Set up monitoring](../operations/monitoring.md)
- [Performance tuning](../operations/performance.md)
