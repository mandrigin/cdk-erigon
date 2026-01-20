---
sidebar_position: 2
title: cdk-node Integration
description: Integrate cdk-erigon with cdk-node
---

# cdk-node Integration

Configure cdk-erigon to work with cdk-node.

## Overview

cdk-node handles:
- Sequence submission to L1
- Aggregation coordination
- L1 contract interaction

cdk-erigon provides:
- Block production
- State execution
- Data streaming

## Sequencer Configuration

Configure cdk-erigon in sequencer mode:

```yaml
# cdk-erigon config
zkevm:
  data-stream-port: 6900
  data-stream-host: 0.0.0.0
```

## cdk-node Configuration

Point cdk-node to cdk-erigon:

```yaml
# cdk-node config
sequencer:
  rpc-url: http://cdk-erigon:8545
  data-stream-url: cdk-erigon:6900
```

## Communication Flow

```
cdk-erigon (Sequencer)
    │
    ├── RPC (8545) ──────────► cdk-node (sequence data)
    │
    └── Data Stream (6900) ──► cdk-node (block stream)
                                    │
                                    ▼
                              L1 Ethereum
```

## Health Monitoring

Verify integration:

```bash
# Check cdk-erigon
curl http://cdk-erigon:8545 -d '{"method":"eth_blockNumber"}'

# Verify data stream
nc -zv cdk-erigon 6900
```

## Next Steps

- [Prover Integration](./prover) - ZK proof generation
- [Bridge Service](./bridge-service) - Cross-chain operations
