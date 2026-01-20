---
sidebar_position: 2
title: Core Flags
description: Essential cdk-erigon configuration flags
---

# Core Flags

Essential configuration options for cdk-erigon.

## Data Directory

| Format | Example |
|--------|---------|
| CLI | `--datadir=/data/cdk-erigon` |
| Env | `DATADIR=/data/cdk-erigon` |
| YAML | `datadir: /data/cdk-erigon` |

## HTTP RPC

| Flag | Description | Default |
|------|-------------|---------|
| `http` | Enable HTTP RPC | `false` |
| `http.addr` | HTTP listen address | `localhost` |
| `http.port` | HTTP port | `8545` |
| `http.api` | Enabled APIs | `eth,net,web3` |

### Example

```yaml
http:
  enabled: true
  addr: 0.0.0.0
  port: 8545
  api: [eth, net, web3, zkevm, txpool, debug]
```

## WebSocket RPC

| Flag | Description | Default |
|------|-------------|---------|
| `ws` | Enable WebSocket | `false` |
| `ws.addr` | WS listen address | `localhost` |
| `ws.port` | WS port | `8546` |

## Chain Selection

| Format | Example |
|--------|---------|
| CLI | `--chain=hermez-mainnet` |
| Env | `CHAIN=hermez-mainnet` |
| YAML | `chain: hermez-mainnet` |

Available chains: `hermez-mainnet`, `hermez-cardona`, `hermez-bali`

## Next Steps

- [zkevm Namespace](./zkevm-namespace) - zkEVM-specific options
- [Network Presets](./network-presets) - Pre-configured networks
