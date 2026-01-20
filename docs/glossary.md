# Glossary

This glossary defines key terms used throughout the cdk-erigon documentation. Terms are organized alphabetically for easy reference.

---

## Batch

A group of L2 blocks that are sequenced together and submitted to L1 for verification. Batches are the fundamental unit of ZK proof generation in zkEVM.

**Relationship to blocks:**
```
Batch 1
├── L2 Block 1
│   ├── Transaction 1
│   └── Transaction 2
├── L2 Block 2
│   └── Transaction 3
└── L2 Block 3
    └── Transaction 4
```

Batches progress through three lifecycle states: [Virtual](#virtual-state), [Trusted](#trusted-state), and [Verified](#verified-state).

**Related:** [Running a Node - Concepts Overview](getting-started.md#concepts-overview)

---

## Fork ID

A version identifier representing protocol upgrades in zkEVM. Each fork may change execution semantics, data structures, or proof systems. Fork IDs are sequential integers that indicate which protocol rules apply to a given batch.

| Fork ID | Name | Notes |
|---------|------|-------|
| 4 | Blueberry | Early fork |
| 5 | Dragonfruit | Added EffectiveGasPricePercentage |
| 6 | Incaberry | Pre-L1InfoTree |
| 7 | Etrog | Introduced L1InfoTree, BlockInfoRoot |
| 8 | Elderberry | Production fork |
| 9 | Elderberry 2 | Latest fork |

Query the current fork using `zkevm_getForkId` RPC method.

**Related:** [Getting Started - Fork IDs](getting-started.md#fork-ids)

---

## Global Exit Root (GER)

A cryptographic commitment that enables cross-chain asset transfers via the Unified Bridge. The GER is computed from both the L1 and L2 exit trees and is stored on both chains to verify bridge operations.

The GER Manager contract on L1 tracks GER updates and makes them available to L2 via the [L1 Info Tree](#l1-info-tree).

**Related:** [L1 Info Tree](zkevm/l1-info-tree.md), [Unified Bridge](#unified-bridge)

---

## L1 Info Tree

A data structure maintained in smart contracts that provides L2 with granular access to L1 information during batch processing. The L1 Info Tree is a 32-level incremental Merkle tree containing:

- Global Exit Root
- L1 block hash
- Minimum timestamp (minTimestamp)

New leaves are added whenever a new GER is computed. Index 0 is reserved as a special index indicating "no change" to reduce gas costs.

**Related:** [L1 Info Tree Documentation](zkevm/l1-info-tree.md)

---

## Local Exit Tree

A Merkle tree on L2 that records exit transactions (withdrawals from L2 to L1). When a user initiates a withdrawal, a leaf is added to the Local Exit Tree. The root of this tree is combined with the L1 exit root to form the [Global Exit Root](#global-exit-root-ger).

**Related:** [Global Exit Root (GER)](#global-exit-root-ger), [Unified Bridge](#unified-bridge)

---

## Patricia Merkle Trie (PMT)

The standard Ethereum state commitment structure, also known as a Modified Merkle Patricia Trie. PMT uses Keccak-256 hashing and is the default state representation in Ethereum.

In cdk-erigon, PMT can be used for EVM-compatible chains that don't require ZK proofs. Configure via:
```yaml
zkevm.initial-commitment: pmt
```

**Comparison with SMT:**

| Aspect | PMT | SMT |
|--------|-----|-----|
| Hash function | Keccak-256 | Poseidon |
| ZK-friendly | No | Yes |
| Use case | Standard EVM chains | zkEVM chains |

**Related:** [Sparse Merkle Tree (SMT)](#sparse-merkle-tree-smt), [Getting Started - State Types](getting-started.md#state-types-smt-vs-pmt)

---

## Pessimistic Proof

A proof mechanism used by Agglayer that assumes the worst-case scenario for cross-chain state transitions. Unlike optimistic approaches that assume validity and allow challenges, pessimistic proofs require verification before finalization.

This approach provides stronger security guarantees for cross-chain operations at the cost of higher latency compared to optimistic mechanisms.

**Related:** [Unified Bridge](#unified-bridge)

---

## Poseidon Hash

A cryptographic hash function designed specifically for efficient computation inside ZK circuits. Poseidon is used by the [Sparse Merkle Tree](#sparse-merkle-tree-smt) in zkEVM because it requires significantly fewer constraints than Keccak-256 when generating ZK proofs.

On x86 systems, cdk-erigon uses a vectorized Poseidon implementation for optimal performance. Apple Silicon falls back to the iden3 library implementation.

**Related:** [Sparse Merkle Tree (SMT)](#sparse-merkle-tree-smt)

---

## Sequencer

The component responsible for ordering transactions and producing new batches and blocks. In cdk-erigon, sequencer mode is enabled via environment variable:

```bash
CDK_ERIGON_SEQUENCER=1 ./build/bin/cdk-erigon --config="./config.yaml"
```

The sequencer:
- Receives transactions from the transaction pool
- Orders transactions into blocks
- Groups blocks into batches
- Publishes batch data to L1
- Manages the [L1 Info Tree](#l1-info-tree) indexes during block creation

cdk-erigon can run as either a Sequencer (block production) or RPC Node (read-only sync), and supports migration between modes.

**Related:** [Getting Started - Operational Modes](getting-started.md#operational-modes)

---

## Sparse Merkle Tree (SMT)

A ZK-optimized state commitment structure that uses [Poseidon hashing](#poseidon-hash). SMT is the default state representation for zkEVM chains because it can be efficiently verified inside ZK circuits.

Configure via:
```yaml
zkevm.initial-commitment: smt  # Default for zkEVM
```

SMT rebuilds may occur if a node falls significantly behind the network. Performance can be improved with:
```yaml
zkevm.smt-regenerate-in-memory: true  # Uses RAM instead of disk (requires sufficient memory)
```

**Related:** [Patricia Merkle Trie (PMT)](#patricia-merkle-trie-pmt), [Getting Started - State Types](getting-started.md#state-types-smt-vs-pmt)

---

## Trusted State

The state of batches that have been sequenced and are available via the data stream but have not yet been submitted to L1. Trusted state relies on the sequencer's integrity.

**Finality progression:** Trusted → [Virtual](#virtual-state) → [Verified](#verified-state)

**Related:** [Virtual State](#virtual-state), [Verified State](#verified-state)

---

## Unified Bridge

A cross-chain bridge infrastructure that enables asset transfers between L1, L2, and other chains in the Polygon ecosystem. The Unified Bridge uses [Global Exit Roots](#global-exit-root-ger) to cryptographically prove the validity of cross-chain transfers.

Key components:
- **L1 Exit Tree**: Records deposits from L1 to L2
- **[Local Exit Tree](#local-exit-tree)**: Records withdrawals from L2 to L1
- **GER Manager**: Coordinates exit roots across chains

**Related:** [Global Exit Root (GER)](#global-exit-root-ger), [Local Exit Tree](#local-exit-tree)

---

## Validium

A scaling architecture where transaction data is stored off-chain (unlike zkRollups which post data on-chain). Validiums use ZK proofs to verify state transitions but rely on a Data Availability Committee (DAC) to ensure data is accessible.

**Trade-offs:**

| Aspect | Validium | zkRollup |
|--------|----------|----------|
| Data availability | Off-chain (DAC) | On-chain (L1) |
| Cost | Lower | Higher |
| Security model | Requires trust in DAC | Full L1 security |

CDK chains can be configured as either Validium or zkRollup architectures.

**Related:** [zkRollup](#zkrollup)

---

## Verified State

The final state of batches whose ZK proofs have been verified on L1. Verified batches have the highest finality guarantee, as their correctness is cryptographically proven and recorded on Ethereum.

Query the latest verified batch using `zkevm_verifiedBatchNumber` RPC method.

**Finality progression:** [Trusted](#trusted-state) → [Virtual](#virtual-state) → Verified

**Related:** [Trusted State](#trusted-state), [Virtual State](#virtual-state)

---

## Virtual State

The state of batches that have been submitted to L1 but whose ZK proofs have not yet been verified. Virtual batches have data availability on L1 but lack cryptographic proof verification.

Query the latest virtual batch using `zkevm_virtualBatchNumber` RPC method.

**Finality progression:** [Trusted](#trusted-state) → Virtual → [Verified](#verified-state)

**Related:** [Trusted State](#trusted-state), [Verified State](#verified-state)

---

## Witness

A data structure containing all the state data required to re-execute a batch and generate a ZK proof. The witness includes account states, storage values, and Merkle proofs needed by the prover to verify state transitions without access to the full state database.

In cdk-erigon, witnesses can be retrieved via:
- `zkevm_getWitness` - Witness for a specific block
- `zkevm_getBlockRangeWitness` - Witness for a range of blocks
- `zkevm_getBatchWitness` - Witness for a batch

**Related:** [Programmers Guide - Witness Format](programmers_guide/witness_format.md)

---

## zkCounters

Resource metrics that track computational costs specific to ZK proof generation. Unlike Ethereum gas which measures EVM execution cost, zkCounters measure the number of constraints required in the ZK circuit.

Key counter types include:
- Arithmetic operations
- Binary operations
- Memory operations
- Keccak hashes
- Poseidon hashes
- Storage operations

Estimate counters for a transaction using `zkevm_estimateCounters` RPC method. Transactions exceeding counter limits cannot be included in batches.

**Related:** [JSON-RPC API - zkevm_estimateCounters](../README.md#zkevm-specific-api-support)

---

## zkEVM

Zero-Knowledge Ethereum Virtual Machine - a Layer 2 scaling solution that executes Ethereum transactions and generates ZK proofs of correct execution. zkEVM maintains EVM compatibility while achieving scalability through validity proofs verified on L1.

cdk-erigon is an execution client optimized for zkEVM networks, supporting both RPC node and sequencer operations.

**Related:** [Getting Started - What is cdk-erigon](getting-started.md#what-is-cdk-erigon)

---

## zkRollup

A Layer 2 scaling architecture that posts transaction data on-chain (L1) and uses ZK proofs to verify state transitions. zkRollups inherit Ethereum's security guarantees because all data needed to reconstruct the state is available on L1.

**Comparison with Validium:**

| Aspect | zkRollup | Validium |
|--------|----------|----------|
| Data availability | On-chain (L1) | Off-chain (DAC) |
| Cost | Higher | Lower |
| Security | Full L1 security | Requires trust in DAC |

Polygon zkEVM mainnet operates as a zkRollup.

**Related:** [Validium](#validium), [zkEVM](#zkevm)
