---
sidebar_position: 1
title: zkEVM Mainnet
description: Running cdk-erigon on Polygon zkEVM Mainnet
---

# zkEVM Mainnet

Connect to Polygon zkEVM Mainnet (Chain ID: 1101).

## Network Details

| Property | Value |
|----------|-------|
| Chain ID | 1101 |
| Network Name | Polygon zkEVM |
| RPC URL | https://zkevm-rpc.com |
| Block Explorer | https://zkevm.polygonscan.com |

## Configuration

Use the provided mainnet configuration:

```bash
cdk-erigon --config hermezconfig-mainnet.yaml
```

Or configure manually:

```yaml
chain: hermez-mainnet

zkevm:
  l2-chain-id: 1101
  l1-chain-id: 1
  l1-rpc-url: https://eth-mainnet.example.com
```

## L1 RPC Requirements

Mainnet requires an Ethereum mainnet RPC endpoint for L1 synchronization.

## Next Steps

- [Cardona Testnet](./cardona) - Test network setup
- [Custom CDK](./custom-cdk) - Deploy your own chain
