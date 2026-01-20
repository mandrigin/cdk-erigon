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

## Supported Networks

| Network | Chain ID | Type |
|---------|----------|------|
| zkEVM Mainnet | 1101 | Production |
| zkEVM Cardona | 2442 | Testnet |
| Custom CDK | Variable | CDK Chains |

## Architecture Overview

cdk-erigon introduces several key modifications to support zkEVM (see [zkEVM architecture](https://docs.polygon.technology/zkEVM/architecture/high-level/smart-contracts/overview/) for L1 contract details):

- **zkevm_* RPC namespace**: 25+ methods for zkEVM operations — see [API Reference](../api/zkevm/batch-methods)
- **Sparse Merkle Tree (SMT)**: Alternative state storage with [Poseidon hashing](https://docs.polygon.technology/zkEVM/concepts/sparse-merkle-trees/sparse-merkle-tree/) — see [State Trie Configuration](../configuration/state-trie)
- **Data Stream Protocol**: Efficient sequencer synchronization — see [Data Stream Configuration](../configuration/data-stream)
- **L1 Recovery Mode**: Chain reconstruction from Ethereum mainnet — see [L1 Recovery](../operations/l1-recovery)

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
