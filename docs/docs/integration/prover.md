---
sidebar_position: 3
title: Prover Integration
description: Configure cdk-erigon for ZK prover integration
---

# Prover Integration

Configure cdk-erigon for ZK proof generation.

## Overview

The prover system requires:
- Executor for transaction validation
- Witness data for proof generation
- Counter estimation for resource planning

## Executor Configuration

Configure executor URLs for sequencer mode:

```yaml
zkevm:
  executor-urls: executor1:50071,executor2:50071
  executor-strict: true
```

### Executor Options

| Option | Description | Default |
|--------|-------------|---------|
| `executor-urls` | Comma-separated URLs | Required |
| `executor-strict` | Reject invalid txs | `true` |
| `witness-full` | Full witness mode | `false` |

## Witness Generation

RPC methods for proof generation:

```bash
# Get witness for block
curl -X POST http://localhost:8545 \
  -d '{"method":"zkevm_getWitness","params":["0x100"]}'

# Get prover input
curl -X POST http://localhost:8545 \
  -d '{"method":"zkevm_getProverInput","params":["0x100"]}'
```

## Counter Estimation

Estimate ZK resource usage:

```bash
curl -X POST http://localhost:8545 \
  -d '{"method":"zkevm_estimateCounters","params":[{"to":"0x...","data":"0x..."}]}'
```

## Next Steps

- [Bridge Service](./bridge-service) - Cross-chain operations
- [Kurtosis](./kurtosis) - Local development
