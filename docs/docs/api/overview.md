---
sidebar_position: 1
title: API Overview
description: Overview of cdk-erigon JSON-RPC API
---

# API Overview

cdk-erigon exposes a JSON-RPC API for interacting with the node.

## Enabling APIs

Configure which API namespaces to enable:

```yaml
http:
  api: [eth, net, web3, zkevm, txpool, debug, trace]
```

## Available Namespaces

| Namespace | Description |
|-----------|-------------|
| `eth` | Standard Ethereum methods |
| `net` | Network information |
| `web3` | Web3 utilities |
| `zkevm` | zkEVM-specific methods |
| `txpool` | Transaction pool |
| `debug` | Debug utilities |
| `trace` | Transaction tracing |

## Request Format

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "eth_blockNumber",
    "params": [],
    "id": 1
  }'
```

## Response Format

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": "0x1234"
}
```

## Next Steps

- [zkevm Namespace](./zkevm/batch-methods) - zkEVM-specific methods
- [Standard Namespaces](./standard-namespaces) - Ethereum standard APIs
