---
sidebar_position: 6
title: Performance Tuning
description: Optimize cdk-erigon performance
---

# Performance Tuning

Optimize your cdk-erigon node for better performance.

## Memory Configuration

### SMT Regeneration

For faster SMT rebuilds with sufficient RAM:

```yaml
zkevm:
  smt-regenerate-in-memory: true
```

:::caution
Requires significant memory (16GB+). Only enable if you have adequate RAM.
:::

## RPC Optimization

### Rate Limiting

Configure RPC rate limits:

```yaml
http:
  rpc-rate-limit: 1000
```

### Connection Limits

```yaml
http:
  max-connections: 100
```

## Storage Optimization

### NVMe Recommended

- Use NVMe SSDs for best performance
- Avoid network-attached storage for chaindata
- Consider RAID 0 for maximum IOPS

### Filesystem

- ext4 or xfs recommended
- Disable access time updates: `noatime` mount option

## CPU Optimization

- cdk-erigon benefits from multiple cores
- Pin to specific CPUs for consistent performance
- Consider disabling hyperthreading for some workloads

## Debug Timers

Enable performance timing:

```yaml
debug:
  timers: true
```

## Next Steps

- [Upgrading](./upgrading) - Keep your node updated
- [Monitoring](./monitoring) - Track performance
