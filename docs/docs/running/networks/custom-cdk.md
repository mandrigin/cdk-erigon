---
sidebar_position: 3
title: Custom CDK Chains
description: Running cdk-erigon on custom CDK-powered chains
---

# Custom CDK Chains

Deploy cdk-erigon on your own CDK-powered chain.

## Dynamic Configuration

Custom CDK chains use dynamic configuration files:

```bash
cdk-erigon \
  --zkevm.genesis-config-path=/path/to/genesis-config.json \
  --zkevm.allocs-path=/path/to/allocs.json
```

## Configuration Files

### genesis-config.json

Contains chain-specific parameters:

```json
{
  "l2ChainId": 10001,
  "l1ChainId": 11155111,
  "rollupCreationBlockNumber": 12345678,
  "rollupManagerCreationBlockNumber": 12345600
}
```

### allocs.json

Contains genesis allocations and contract deployments.

## Example

See [zk/examples/dynamic-configs/](https://github.com/0xPolygon/cdk-erigon/tree/zkevm/zk/examples/dynamic-configs) for examples.

## Next Steps

- [Integration](../../integration/cdk-node) - CDK stack integration
- [Kurtosis](../../integration/kurtosis) - Local development environment
