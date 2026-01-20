---
sidebar_position: 2
title: Sequencer Setup
description: Run cdk-erigon as a sequencer node
---

# Sequencer Setup

Run cdk-erigon as a sequencer for block production.

:::caution
Sequencer mode requires proper CDK infrastructure setup and should only be used by chain operators.
:::

## Enable Sequencer Mode

Set the environment variable:

```bash
export CDK_ERIGON_SEQUENCER=1
```

## Configuration

```yaml
datadir: /data/cdk-erigon-sequencer

zkevm:
  l2-chain-id: 1101
  executor-urls: executor1.local:50071,executor2.local:50071
  executor-strict: true
  witness-full: false
```

## Executor Integration

The sequencer requires connection to ZK executors for transaction validation:

- Configure `executor-urls` with your executor endpoints
- Set `executor-strict: true` for production (rejects invalid transactions)
- Multiple executors provide redundancy

## Next Steps

- [Operational Modes](./operational-modes) - Mode comparison
- [Configuration](../configuration/zkevm-namespace) - Full configuration reference
