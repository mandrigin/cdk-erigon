---
sidebar_position: 3
title: Quick Start
description: Get cdk-erigon running in 5 minutes
---

# Quick Start

Get a cdk-erigon RPC node running on [zkEVM Mainnet](../running/networks/mainnet) in minutes. For detailed setup, see [RPC Node Setup](../running/rpc-node).

## Using Docker (Recommended)

For detailed Docker options, see [Docker Installation](../installation/docker). For alternative installation methods, see [Pre-built Binaries](../installation/pre-built-binaries) or [Build from Source](../installation/build-from-source).

```bash
docker run -d \
  --name cdk-erigon \
  -v /data/cdk-erigon:/data \
  -p 8545:8545 \
  hermeznetwork/cdk-erigon:latest \
  --config=/etc/cdk-erigon/mainnet.yaml
```

## Verify Sync Status

Use the standard [eth_syncing](../api/standard-namespaces) method to check sync progress:

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}'
```

For more health checks, see [Health Checks](../operations/health-checks).

## Check Batch Number

Use the [`zkevm_batchNumber`](../api/zkevm/batch-methods#zkevm_batchnumber) method to check the latest batch:

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"zkevm_batchNumber","params":[],"id":1}'
```

For all zkEVM methods, see [zkEVM API Reference](../api/zkevm/batch-methods).

## Next Steps

- [Concepts](./concepts) - Understand zkEVM architecture
- [RPC Node Setup](../running/rpc-node) - Production configuration
- [Configuration Reference](../configuration/core-flags) - All options
- [Monitoring](../operations/monitoring) - Set up observability

## External Resources

- [zkEVM Explorer](https://zkevm.polygonscan.com/) - Block explorer
- [Polygon zkEVM Documentation](https://docs.polygon.technology/zkEVM/) - Official docs
- [Gateway.fm](https://docs.gateway.fm) - Managed node services
