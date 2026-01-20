---
sidebar_position: 4
title: Network Presets
description: Pre-configured network settings
---

# Network Presets

cdk-erigon includes configuration presets for common networks.

## Available Presets

| Network | Config File | Chain ID |
|---------|-------------|----------|
| zkEVM Mainnet | `hermezconfig-mainnet.yaml` | 1101 |
| zkEVM Cardona | `hermezconfig-cardona.yaml` | 2442 |
| zkEVM Bali | `hermezconfig-bali.yaml` | - |
| XLayer Mainnet | `xlayerconfig-mainnet.yaml` | - |
| XLayer Testnet | `xlayerconfig-testnet.yaml` | - |

## Using Presets

```bash
cdk-erigon --config hermezconfig-mainnet.yaml
```

## Customizing Presets

Copy and modify the preset for your needs:

```bash
cp hermezconfig-mainnet.yaml my-config.yaml
# Edit my-config.yaml
cdk-erigon --config my-config.yaml
```

## Next Steps

- [State Trie](./state-trie) - Configure state storage
- [L1 Interaction](./l1-interaction) - L1 RPC settings
