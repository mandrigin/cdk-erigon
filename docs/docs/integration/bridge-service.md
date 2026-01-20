---
sidebar_position: 4
title: Bridge Service
description: Configure cdk-erigon for bridge operations
---

# Bridge Service

Configure cdk-erigon for cross-chain bridge operations.

## Overview

The bridge enables asset transfers between L1 and L2 using:
- Global Exit Root (GER)
- Exit trees
- Bridge contracts

## GER Manager

Configure GER manager address:

```yaml
zkevm:
  address-ger-manager: 0x...
```

## RPC Methods

### Get Latest GER

```bash
curl -X POST http://localhost:8545 \
  -d '{"method":"zkevm_getLatestGlobalExitRoot","params":[]}'
```

### Get Exit Roots

```bash
curl -X POST http://localhost:8545 \
  -d '{"method":"zkevm_getExitRootTable","params":[]}'
```

### Query by GER

```bash
curl -X POST http://localhost:8545 \
  -d '{"method":"zkevm_getExitRootsByGER","params":["0x..."]}'
```

## Bridge Flow

```
L1 Ethereum
    │
    ├── Deposit ──► Bridge Contract
    │                    │
    │                    ▼
    │              GER Updated
    │                    │
    │                    ▼
    └── L2 ◄───── cdk-erigon (reads GER)
                       │
                       ▼
                 Claim on L2
```

## Next Steps

- [Kurtosis](./kurtosis) - Local development environment
- [Glossary](../glossary) - Bridge terminology
