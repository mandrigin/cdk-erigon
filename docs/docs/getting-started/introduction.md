---
sidebar_position: 1
title: What is cdk-erigon
description: Introduction to cdk-erigon, the high-performance execution client for Polygon zkEVM
---

# What is cdk-erigon

cdk-erigon is a fork of [Erigon](https://github.com/erigontech/erigon), optimized for syncing with [Polygon zkEVM](https://docs.polygon.technology/zkEVM/) and [CDK-powered](https://docs.polygon.technology/cdk/) Layer 2 chains. For deeper Erigon internals, see the [Erigon documentation](https://erigon.gitbook.io/erigon).

## Key Features

- **High Performance**: Built on Erigon's efficient architecture
- **zkEVM Native**: Full support for Polygon zkEVM operations
- **CDK Compatible**: Run your own CDK-powered chain
- **Dual Modes**: Operate as RPC node or Sequencer
- **Flexible Proving**: Choose between FEP (Full Execution Proof) and PP (Pessimistic Proof) modes
- **Multiple Execution Types**: Support for Type1 (Ethereum-equivalent) and Type2 (zkEVM) execution

## Flexible Architecture

cdk-erigon supports multiple configuration dimensions, allowing you to choose the right balance of security, performance, and compatibility for your use case:

```
┌─────────────────────────────────────────────────────────────────────┐
│              cdk-erigon Configuration Flexibility                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   EXECUTION TYPE           VERIFICATION MODE      PROVER SYSTEM    │
│   ──────────────           ─────────────────      ─────────────    │
│   Type2 (zkEVM)      ───▶  FEP (Full Proof)  ───▶ Hermez Prover   │
│   • SMT state trie         • Executor required    • zkEVM circuits │
│   • zkEVM interpreter      • Full ZK proofs       • Virtual counters│
│                            • Max security                           │
│                                    │                                │
│                                    ├───▶ PP (Pessimistic)           │
│                                    │     • No executor needed       │
│                                    │     • Faster finality          │
│                                                                     │
│   Type1 (Normalcy)   ───▶  FEP (Full Proof)  ───▶ SP1 Prover      │
│   • PMT state trie         • Full ZK proofs       • Ethereum-equiv  │
│   • Standard EVM           • Highest security                       │
│                                    │                                │
│                                    ├───▶ PP (Pessimistic)           │
│                                         • Fastest finality          │
│                                         • Optimistic verification   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

| Configuration | Execution | Verification | Prover | Best For |
|---------------|-----------|--------------|--------|----------|
| Type2 + FEP | zkEVM | Full ZK | Hermez | Production zkEVM chains |
| Type2 + PP | zkEVM | Pessimistic | None | Fast zkEVM finality |
| Type1 + FEP | Standard EVM | Full ZK | SP1 | Ethereum-equivalent chains |
| Type1 + PP | Standard EVM | Pessimistic | None | Maximum throughput |

See [zkEVM Execution Modes](../advanced/type1-type2-migration.md) for detailed configuration.

## Supported Networks

| Network | Chain ID | Type |
|---------|----------|------|
| zkEVM Mainnet | 1101 | Production |
| zkEVM Cardona | 2442 | Testnet |
| Custom CDK | Variable | CDK Chains |

## Architecture Overview

cdk-erigon introduces several key modifications to support zkEVM (see [zkEVM architecture](https://docs.polygon.technology/zkEVM/architecture/high-level/smart-contracts/overview/) for L1 contract details):

- **zkevm_* RPC namespace**: 25+ methods for zkEVM operations — see [API Reference](../api/zkevm/batch-methods)
- **Dual State Tries**: SMT (Sparse Merkle Tree) for Type2, PMT (Patricia Merkle Trie) for Type1 — see [State Trie Configuration](../configuration/state-trie)
- **Data Stream Protocol**: Efficient sequencer synchronization — see [Data Stream Configuration](../configuration/data-stream)
- **L1 Recovery Mode**: Chain reconstruction from Ethereum mainnet — see [L1 Recovery](../operations/l1-recovery)
- **Flexible Verification**: FEP with executor/prover or PP without — see [Execution Modes](../advanced/type1-type2-migration.md)

## Next Steps

- [System Requirements](./system-requirements) - Check hardware requirements
- [Quick Start](./quickstart) - Get running in 5 minutes
- [Concepts](./concepts) - Understand key zkEVM concepts

## External Resources

- [Polygon zkEVM Documentation](https://docs.polygon.technology/zkEVM/) - Official zkEVM docs
- [Polygon CDK Documentation](https://docs.polygon.technology/cdk/) - CDK deployment guides
- [Erigon Documentation](https://erigon.gitbook.io/erigon) - Upstream Erigon docs
- [Gateway.fm Enterprise](https://docs.gateway.fm) - Enterprise deployment options
- [cdk-erigon Source](https://github.com/0xPolygonHermez/cdk-erigon) - GitHub repository
