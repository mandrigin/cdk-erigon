---
sidebar_position: 4
title: Kubernetes
description: Deploy cdk-erigon on Kubernetes
---

# Kubernetes Deployment

Deploy cdk-erigon in a Kubernetes cluster.

## Sample Deployment

See the [k8s/](https://github.com/0xPolygon/cdk-erigon/tree/zkevm/k8s) directory for example configurations.

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: cdk-erigon
spec:
  serviceName: cdk-erigon
  replicas: 1
  selector:
    matchLabels:
      app: cdk-erigon
  template:
    spec:
      containers:
      - name: cdk-erigon
        image: hermeznetwork/cdk-erigon:latest
        ports:
        - containerPort: 8545
        volumeMounts:
        - name: data
          mountPath: /data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 500Gi
```

## Scaling Considerations

- Use StatefulSets for data persistence
- Configure appropriate resource limits
- Consider separate deployments for RPC and archive nodes

## Next Steps

- [Hardware Recommendations](./hardware-recommendations) - Size your deployment
- [Operations](../operations/monitoring) - Monitor your cluster
