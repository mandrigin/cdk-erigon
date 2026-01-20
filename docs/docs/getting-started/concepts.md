---
sidebar_position: 4
title: Concepts
description: Key concepts for understanding cdk-erigon and zkEVM
---

# Concepts

## Batches vs Blocks

In zkEVM, transactions are organized into **batches** for proof generation. See [Polygon's batch documentation](https://docs.polygon.technology/zkEVM/architecture/high-level/smart-contracts/sequencing-batches/) for L1 contract details.

- **Block**: Standard Ethereum block containing transactions
- **Batch**: Collection of blocks submitted together for ZK proof generation — query with [`zkevm_batchNumber`](../api/zkevm/batch-methods#zkevm_batchnumber)
- **Sequence**: Multiple batches submitted to L1 in a single transaction

### Block Organization Within Batches

L2 blocks are organized into batches for ZK proof generation. A single batch can contain one or more L2 blocks, and each block belongs to exactly one batch.

```
Batch N
├── L2 Block 100
│   ├── Transaction 1
│   └── Transaction 2
├── L2 Block 101
│   └── Transaction 3
└── L2 Block 102
    ├── Transaction 4
    └── Transaction 5
```

**Key relationships:**
- Use [`zkevm_batchNumberByBlockNumber`](../api/zkevm/batch-methods#zkevm_batchnumberbyblocknumber) to find which batch contains a block
- Use [`zkevm_getBatchByNumber`](../api/zkevm/batch-methods#zkevm_getbatchbynumber) to get all transactions in a batch
- Batch 0 is a special genesis batch containing no blocks

### Batch Numbering

Batches are numbered sequentially starting from 0:

| Batch | Description |
|-------|-------------|
| 0 | Genesis batch (special case, no blocks) |
| 1+ | Sequential batches containing L2 blocks |

The sequencer assigns blocks to batches based on:
- ZK circuit constraints (proof complexity limits)
- Timing thresholds (batches close after time limits)
- Transaction count limits

### Batch Data Structure

Each batch contains:

| Field | Description |
|-------|-------------|
| `number` | Sequential batch identifier |
| `coinbase` | Sequencer address (fee recipient) |
| `stateRoot` | State root after batch execution |
| `globalExitRoot` | GER used for bridge operations |
| `localExitRoot` | L2 exit tree root |
| `accInputHash` | Accumulated input hash for verification |
| `timestamp` | Batch creation timestamp |
| `transactions` | All transactions in the batch |

### Batch Lifecycle

```
Sequencer creates batch
        │
        ▼
   [L2 Blocks added]
        │
        ▼
   Batch closed
        │
        ▼
  Submitted to L1 (Virtual)
        │
        ▼
  ZK Proof generated
        │
        ▼
  Proof verified on L1 (Verified)
```

## State Types

cdk-erigon supports two state trie implementations:

### Sparse Merkle Tree (SMT)

The SMT is zkEVM's native state representation. See [Polygon's SMT documentation](https://docs.polygon.technology/zkEVM/concepts/sparse-merkle-trees/sparse-merkle-tree/) for technical details.

- Uses [Poseidon hashing](https://docs.polygon.technology/zkEVM/concepts/sparse-merkle-trees/detailed-smt/) (ZK-friendly)
- Required for proof generation
- Default for zkEVM networks
- Configure with [`--zkevm.smt`](../configuration/state-trie#sparse-merkle-tree)

### Patricia Merkle Trie (PMT)

The PMT is Erigon's standard state representation. See [Erigon's state documentation](https://erigon.gitbook.io/erigon) for details.

- Standard Ethereum trie
- Compatible with existing tooling
- Used for non-ZK operations

## Finality States

zkEVM uses a multi-stage finality model. See [Polygon's finality documentation](https://docs.polygon.technology/zkEVM/architecture/high-level/smart-contracts/verification/) for verification details.

| State | Description | API Method |
|-------|-------------|------------|
| **Trusted** | Sequencer has processed, not yet on L1 | [`zkevm_batchNumber`](../api/zkevm/batch-methods#zkevm_batchnumber) |
| **Virtual** | Submitted to L1, not yet proven | [`zkevm_virtualBatchNumber`](../api/zkevm/batch-methods#zkevm_virtualbatchnumber) |
| **Verified** | ZK proof verified on L1 | [`zkevm_verifiedBatchNumber`](../api/zkevm/batch-methods#zkevm_verifiedbatchnumber) |

### Finality Progression

Batches progress through finality states in order:

```
Trusted ──► Virtual ──► Verified
  │            │            │
  │            │            └── L1 ZK proof verified (strongest guarantee)
  │            └── Sequenced to L1 (data available)
  └── Processed by sequencer (soft confirmation)
```

**Important considerations:**
- **Trusted state** relies on sequencer honesty; reorganizations possible
- **Virtual state** ensures data availability on L1; proof pending
- **Verified state** provides cryptographic finality via ZK proof

### Querying Finality

Check current finality levels:

```bash
# Highest trusted batch (sequencer processed)
curl -X POST http://localhost:8545 \
  -d '{"method":"zkevm_batchNumber","params":[]}'

# Highest virtual batch (on L1, unproven)
curl -X POST http://localhost:8545 \
  -d '{"method":"zkevm_virtualBatchNumber","params":[]}'

# Highest verified batch (ZK proven)
curl -X POST http://localhost:8545 \
  -d '{"method":"zkevm_verifiedBatchNumber","params":[]}'
```

For block-level finality, use [`zkevm_consolidatedBlockNumber`](../api/zkevm/batch-methods#zkevm_consolidatedblocknumber) to get the latest L1-confirmed block.

## Operational Modes

See [Operational Modes](../running/operational-modes) for detailed setup instructions.

### RPC Node

- Read-only synchronization — see [RPC Node Setup](../running/rpc-node)
- Connects to sequencer via [data stream](../configuration/data-stream)
- Serves JSON-RPC requests — see [API Overview](../api/overview)

### Sequencer

- Produces new blocks — see [Sequencer Setup](../running/sequencer)
- Manages transaction pool
- Requires [executor connection](../integration/prover) for proof generation

## Fork IDs

Fork IDs track protocol upgrades. See [Polygon's upgrade documentation](https://docs.polygon.technology/zkEVM/architecture/high-level/smart-contracts/api/upgradability/) for upgrade mechanics.

| Fork ID | Description | API |
|---------|-------------|-----|
| 4 | Initial Mainnet | [`zkevm_getForkId`](../api/zkevm/fork-methods#zkevm_getforkid) |
| 5 | First upgrade | [`zkevm_getForkIdByBatchNumber`](../api/zkevm/fork-methods#zkevm_getforkidbybatchnumber) |
| 6+ | Subsequent upgrades | See [Upgrading](../operations/upgrading) |

## Next Steps

- [Installation](../installation/index) - Install cdk-erigon
- [Configuration](../configuration/zkevm-namespace) - zkEVM-specific options
- [Glossary](../glossary) - Term definitions

## External Resources

- [zkEVM State Management](https://docs.polygon.technology/zkEVM/architecture/high-level/smart-contracts/state-management/) - L1 state roots
- [zkEVM Transaction Flow](https://docs.polygon.technology/zkEVM/architecture/high-level/smart-contracts/sequencing-batches/) - Batch lifecycle
- [CDK Components](https://docs.polygon.technology/cdk/architecture/cdk-zkevm/) - Full stack overview
