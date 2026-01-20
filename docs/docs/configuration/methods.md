---
sidebar_position: 1
title: Configuration Methods
description: How to configure cdk-erigon using CLI, environment variables, or YAML
---

# Configuration Methods

cdk-erigon supports three configuration methods with the following priority (highest to lowest):

1. CLI flags
2. Environment variables
3. YAML configuration file

## CLI Flags

```bash
cdk-erigon --datadir=/data --http.addr=0.0.0.0 --zkevm.l2-chain-id=1101
```

## Environment Variables

```bash
export DATADIR=/data
export HTTP_ADDR=0.0.0.0
export ZKEVM_L2_CHAIN_ID=1101
cdk-erigon
```

## YAML Configuration

```yaml
datadir: /data
http:
  addr: 0.0.0.0
zkevm:
  l2-chain-id: 1101
```

Load with:

```bash
cdk-erigon --config config.yaml
```

## Format Comparison

| Option | CLI | Environment | YAML |
|--------|-----|-------------|------|
| Data directory | `--datadir=/data` | `DATADIR=/data` | `datadir: /data` |
| HTTP address | `--http.addr=0.0.0.0` | `HTTP_ADDR=0.0.0.0` | `http.addr: 0.0.0.0` |
| L2 Chain ID | `--zkevm.l2-chain-id=1101` | `ZKEVM_L2_CHAIN_ID=1101` | `zkevm.l2-chain-id: 1101` |

## Next Steps

- [Core Flags](./core-flags) - Essential configuration
- [zkevm Namespace](./zkevm-namespace) - zkEVM-specific options
