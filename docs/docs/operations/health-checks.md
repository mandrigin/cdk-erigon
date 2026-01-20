---
sidebar_position: 2
title: Health Checks
description: Verify cdk-erigon node health
---

# Health Checks

Verify your cdk-erigon node is healthy and syncing properly.

## Sync Status

Check if the node is syncing:

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}'
```

Returns `false` when fully synced.

## Block Number

Get current block:

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'
```

## Batch Number

Get current batch (zkEVM-specific):

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"zkevm_batchNumber","params":[],"id":1}'
```

## Peer Count

Check network connectivity:

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"net_peerCount","params":[],"id":1}'
```

## Health Check Script

```bash
#!/bin/bash
BLOCK=$(curl -s -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
  | jq -r '.result')
echo "Current block: $((BLOCK))"
```

## Next Steps

- [Database Management](./database-management) - Manage data
- [Troubleshooting](../troubleshooting/sync-issues) - Fix issues
