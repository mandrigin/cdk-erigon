---
sidebar_position: 2
title: Cardona Testnet
description: Running cdk-erigon on zkEVM Cardona Testnet
---

# Cardona Testnet

Connect to Polygon zkEVM Cardona Testnet (Chain ID: 2442).

## Network Details

| Property | Value |
|----------|-------|
| Chain ID | 2442 |
| Network Name | zkEVM Cardona |
| L1 Network | Sepolia |

## Configuration

```bash
cdk-erigon --config hermezconfig-cardona.yaml
```

Or configure manually:

```yaml
chain: hermez-cardona

zkevm:
  l2-chain-id: 2442
  l1-chain-id: 11155111
  l1-rpc-url: https://sepolia.example.com
```

## L1 RPC Requirements

Cardona requires a Sepolia testnet RPC endpoint.

## Next Steps

- [Custom CDK](./custom-cdk) - Deploy your own chain
- [Configuration](../../configuration/network-presets) - Network presets
