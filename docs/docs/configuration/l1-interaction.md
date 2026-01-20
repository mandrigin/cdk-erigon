---
sidebar_position: 6
title: L1 Interaction
description: Configuring L1 Ethereum RPC interaction
---

# L1 Interaction

Configure how cdk-erigon interacts with L1 Ethereum.

## L1 RPC URL

```yaml
zkevm:
  l1-rpc-url: https://eth-mainnet.example.com
```

## Block Finality

Control which L1 block type to use for queries:

| Option | Description | Use Case |
|--------|-------------|----------|
| `finalized` | Finalized blocks only | Production (safest) |
| `safe` | Safe blocks | Faster, still safe |
| `latest` | Latest blocks | Development only |

```yaml
zkevm:
  l1-highest-block-type: finalized
```

## First Block

Specify the first L1 block for synchronization:

```yaml
zkevm:
  l1-first-block: 16000000
```

## L1 Sync Start Block

For L1 recovery mode:

```yaml
zkevm:
  l1-sync-start-block: 16000000
```

## Provider Recommendations

- Use a reliable L1 RPC provider
- Consider rate limits and quotas
- Archive access recommended for historical queries

## Next Steps

- [Data Stream](./data-stream) - Sequencer sync configuration
- [L1 Recovery](../operations/l1-recovery) - Recovery operations
