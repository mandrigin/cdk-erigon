---
sidebar_position: 1
title: RPC Node Setup
description: Run cdk-erigon as an RPC node
---

# RPC Node Setup

Run cdk-erigon as a read-only RPC node syncing from a sequencer.

## Configuration

Create a configuration file:

```yaml
datadir: /data/cdk-erigon
chain: hermez-mainnet

http:
  enabled: true
  addr: 0.0.0.0
  port: 8545
  api: [eth, net, web3, zkevm, txpool]

zkevm:
  l2-chain-id: 1101
  l2-datastreamer-url: stream.zkevm-rpc.com:6900
```

## Start Node

```bash
cdk-erigon --config config.yaml
```

## Verify Sync

```bash
# Check sync status
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}'

# Check current batch
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"zkevm_batchNumber","params":[],"id":1}'
```

## Next Steps

- [Sequencer Setup](./sequencer) - Run as sequencer
- [Network Configurations](./networks/mainnet) - Network-specific guides
