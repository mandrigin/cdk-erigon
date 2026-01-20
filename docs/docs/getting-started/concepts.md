---
sidebar_position: 4
title: Concepts
description: Key concepts for understanding cdk-erigon and zkEVM
---

# Concepts

## Batches vs Blocks

In zkEVM, transactions are organized into **batches** for proof generation:

- **Block**: Standard Ethereum block containing transactions
- **Batch**: Collection of blocks submitted together for ZK proof generation
- **Sequence**: Multiple batches submitted to L1 in a single transaction

## State Types

cdk-erigon supports two state trie implementations:

### Sparse Merkle Tree (SMT)

- Uses Poseidon hashing (ZK-friendly)
- Required for proof generation
- Default for zkEVM networks

### Patricia Merkle Trie (PMT)

- Standard Ethereum trie
- Compatible with existing tooling
- Used for non-ZK operations

## Finality States

| State | Description |
|-------|-------------|
| **Trusted** | Sequencer has processed, not yet on L1 |
| **Virtual** | Submitted to L1, not yet proven |
| **Verified** | ZK proof verified on L1 |

## Operational Modes

### RPC Node

- Read-only synchronization
- Connects to sequencer via data stream
- Serves JSON-RPC requests

### Sequencer

- Produces new blocks
- Manages transaction pool
- Requires executor connection

## Fork IDs

Fork IDs track protocol upgrades:

| Fork ID | Description |
|---------|-------------|
| 4 | Initial Mainnet |
| 5 | First upgrade |
| 6+ | Subsequent upgrades |

## Next Steps

- [Installation](../installation/binaries) - Install cdk-erigon
- [Configuration](../configuration/zkevm-namespace) - zkEVM-specific options
