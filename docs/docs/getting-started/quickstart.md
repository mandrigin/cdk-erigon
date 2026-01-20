---
sidebar_position: 3
title: Quick Start
description: Get cdk-erigon running in 5 minutes
---

# Quick Start

Get a cdk-erigon RPC node running on zkEVM Mainnet in minutes.

## Using Docker (Recommended)

```bash
docker run -d \
  --name cdk-erigon \
  -v /data/cdk-erigon:/data \
  -p 8545:8545 \
  hermeznetwork/cdk-erigon:latest \
  --config=/etc/cdk-erigon/mainnet.yaml
```

## Verify Sync Status

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}'
```

## Check Batch Number

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"zkevm_batchNumber","params":[],"id":1}'
```

## Next Steps

- [Concepts](./concepts) - Understand zkEVM architecture
- [RPC Node Setup](../running/rpc-node) - Production configuration
- [Configuration Reference](../configuration/methods) - All options
