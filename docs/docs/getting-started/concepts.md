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

## Execution Types: Type1 vs Type2

cdk-erigon supports two execution types, giving you flexibility in how your chain operates:

### Type2: zkEVM Execution

Type2 is the traditional zkEVM mode using Hermez prover:

- **Sparse Merkle Tree (SMT)** for state storage
- **zkEVM interpreter** with modified opcodes
- **Virtual counters** for ZK circuit resource tracking
- **Hermez prover** for proof generation
- Best for: Chains requiring zkEVM-specific features

### Type1: Normalcy Execution

Type1 enables full Ethereum equivalence using SP1 prover:

- **Patricia Merkle Trie (PMT)** for state storage
- **Standard EVM interpreter** with unmodified opcodes
- **No virtual counters** (disabled)
- **SP1 prover** for Ethereum-compatible proving
- Best for: Chains targeting full Ethereum compatibility

See [Type1/Type2 Migration](../advanced/type1-type2-migration.md) for detailed configuration.

## Verification Modes: FEP vs PP

cdk-erigon supports two verification mechanisms:

### FEP: Full Execution Proof

Full ZK proving with executor verification:

- **Executor required** to verify batch execution
- **Complete ZK proofs** generated for each batch
- **Highest security** with cryptographic guarantees
- **Virtual counters enforced** (Type2) or disabled (Type1)
- Best for: Production chains requiring maximum security

```yaml
# FEP mode configuration
zkevm.executor-urls: "executor:50071"
zkevm.executor-strict: true
zkevm.executor-enabled: true
```

### PP: Pessimistic Proof

Optimistic verification without full ZK proofs:

- **No executor required** for verification
- **Faster finality** without proof generation overhead
- **Challenge-based security** with fraud proofs
- **Virtual counters disabled** in all cases
- Best for: Chains prioritizing throughput over proof latency

```yaml
# PP mode configuration
zkevm.executor-strict: false
zkevm.executor-enabled: false
zkevm.disable-virtual-counters: true
zkevm.pessimistic-fork-number: 12
```

### Choosing Your Configuration

| Use Case | Recommended Mode |
|----------|------------------|
| Production zkEVM | Type2 + FEP |
| Fast zkEVM finality | Type2 + PP |
| Ethereum equivalence | Type1 + FEP |
| Maximum throughput | Type1 + PP |
| Development/Testing | Type1 + PP |

See [zkEVM Execution Modes](../advanced/type1-type2-migration.md) for complete configuration options.

## State Tries

cdk-erigon supports two state trie implementations, corresponding to execution types:

### Sparse Merkle Tree (SMT) — Type2

The SMT is zkEVM's native state representation. See [Polygon's SMT documentation](https://docs.polygon.technology/zkEVM/concepts/sparse-merkle-trees/sparse-merkle-tree/) for technical details.

- Uses [Poseidon hashing](https://docs.polygon.technology/zkEVM/concepts/sparse-merkle-trees/detailed-smt/) (ZK-friendly)
- Required for Type2 zkEVM execution
- Supports SMT v2 with improved performance — see [SMT v2 Migration](../advanced/smt-v2-migration.md)
- Configure with [`--zkevm.only-smt-v2`](../configuration/state-trie#sparse-merkle-tree)

### Patricia Merkle Trie (PMT) — Type1

The PMT is Erigon's standard state representation. See [Erigon's state documentation](https://erigon.gitbook.io/erigon) for details.

- Standard Ethereum Keccak-based trie
- Required for Type1 Normalcy execution
- Full compatibility with Ethereum tooling
- Configure via chain config `normalcyBlock`

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
