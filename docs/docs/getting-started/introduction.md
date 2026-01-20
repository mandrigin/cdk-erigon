---
sidebar_position: 1
title: What is cdk-erigon
description: Introduction to cdk-erigon, the high-performance execution client for Polygon zkEVM
---

# What is cdk-erigon

cdk-erigon is a fork of [Erigon](https://github.com/erigontech/erigon), optimized for syncing with Polygon zkEVM and CDK-powered Layer 2 chains.

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

cdk-erigon introduces several key modifications to support zkEVM:

- **zkevm_* RPC namespace**: 25+ methods for zkEVM operations
- **Sparse Merkle Tree (SMT)**: Alternative state storage with Poseidon hashing
- **Data Stream Protocol**: Efficient sequencer synchronization
- **L1 Recovery Mode**: Chain reconstruction from Ethereum mainnet

## Next Steps

- [System Requirements](./system-requirements) - Check hardware requirements
- [Quick Start](./quickstart) - Get running in 5 minutes
- [Concepts](./concepts) - Understand key zkEVM concepts
