# CDK Sync Stages

This document describes the sync stage pipeline architecture specific to cdk-erigon, including CDK-specific stages and how they differ from mainline Erigon.

## Overview

cdk-erigon uses a staged sync architecture where synchronization is broken into discrete stages. Each stage processes a specific aspect of blockchain synchronization and can be independently forwarded, unwound, or pruned.

The codebase defines **two distinct pipelines** based on node mode:
- **Default zkEVM Stages**: For RPC/synchronizer nodes
- **Sequencer zkEVM Stages**: For sequencer nodes

## CDK-Specific Stages

**Location:** `eth/stagedsync/stages/stages_zk.go`

| Stage | Description |
|-------|-------------|
| `L1Syncer` | Download L1 verifications |
| `L1SequencerSyncer` | L1 sequencer sync updates (waits for finalization) |
| `L1InfoTree` | L1 Info tree index updates sync |
| `SequenceExecutorVerify` | Verification for sequencer execution |
| `L1BlockSync` | L1 sequencer block sync (recovery mode) |
| `BlobRecovery` | Sequencer blob DA recovery |
| `Witness` | Generate witness caches for each block |

## Stage Pipelines

### Default zkEVM Stages (RPC/Synchronizer)

**Location:** `zk/stages/stages.go:287-581`, `turbo/stages/zk_stages.go:28-92`

Execution order for RPC nodes:

| # | Stage | Description |
|---|-------|-------------|
| 1 | L1Syncer | Download L1 block data from mainnet |
| 2 | L1InfoTree | Sync L1 Info Tree index updates |
| 3 | Batches | Download batches from data stream |
| 4 | BlockHashes | Write block hashes (standard Erigon) |
| 5 | Senders | Recover senders from signatures (standard) |
| 6 | Execution | Execute blocks without hash checks (zkEVM variant) |
| 7 | HashState | Hash keys in state (standard) |
| 8 | IntermediateHashes | Generate intermediate hashes/compute state root (zkEVM variant) |
| 9 | CallTraces | Generate call traces index (standard) |
| 10 | AccountHistoryIndex | Generate account history (standard) |
| 11 | StorageHistoryIndex | Generate storage history (standard) |
| 12 | LogIndex | Generate receipt logs index (standard) |
| 13 | TxLookup | Generate transaction lookup index (standard) |
| 14 | DataStream | Update data stream with missing details |
| 15 | Witness | Generate witness caches for verification |
| 16 | Finish | Final block update for RPC API |

### Sequencer zkEVM Stages

**Location:** `zk/stages/stages.go:23-259`, `turbo/stages/zk_stages.go:96-172`

Execution order for sequencer nodes:

| # | Stage | Description |
|---|-------|-------------|
| 1 | L1Syncer | Download L1 verifications |
| 2 | L1SequencerSyncer | L1 sequencer-specific sync (waits for finalization) |
| 3 | L1InfoTree | L1 Info tree index updates |
| 4 | L1BlockSync | L1 block sync for recovery (conditional) |
| 5 | BlobRecovery | Blob data availability recovery (conditional) |
| 6 | Execution | Sequence transactions (sequencer-specific) |
| 7 | IntermediateHashes | Sequencer-specific hashing (SMT before PMT migration) |
| 8 | HashState | Hash keys in state |
| 9 | CallTraces | Generate call traces |
| 10 | AccountHistoryIndex | Account history |
| 11 | StorageHistoryIndex | Storage history |
| 12 | LogIndex | Receipt logs index |
| 13 | TxLookup | Transaction lookup |
| 14 | Finish | Final update |

## Stage Dependencies

### Unwind Order

**Critical Constraint:** IntermediateHashes must be unwound before history/calltraces, while Execution must be unwound after history/calltraces.

#### Sequencer Unwind Order (ZkSequencerUnwindOrder)

```
1.  TxLookup
2.  LogIndex
3.  HashState
4.  SequenceExecutorVerify
5.  IntermediateHashes        ← Must unwind SMT before removing history
6.  StorageHistoryIndex
7.  AccountHistoryIndex
8.  CallTraces
9.  Execution                 ← After history and calltraces
10. L1Syncer
11. Finish
```

#### Synchronizer Unwind Order (ZkUnwindOrder)

```
1.  TxLookup
2.  LogIndex
3.  HashState
4.  IntermediateHashes        ← Must unwind SMT before removing history
5.  StorageHistoryIndex
6.  AccountHistoryIndex
7.  CallTraces
8.  Execution                 ← After history and calltraces
9.  Senders
10. BlockHashes
11. Batches
12. L1Syncer
13. Finish
```

## Stage Configuration

Each stage has a configuration struct. Key CDK-specific configurations:

### L1SyncerCfg

**Location:** `zk/stages/stage_l1_syncer.go:34-47`

Manages L1 block synchronization, including L1 contract addresses and verification tracking.

### L1SequencerSyncCfg

**Location:** `zk/stages/stage_l1_sequencer_sync.go:23-35`

- L1 finalization checking
- Configurable logs retrieval modes
- Sequencer-specific L1 state tracking

### L1InfoTreeCfg

**Location:** `zk/stages/stage_l1_info_tree.go:17-31`

Syncs L1 Info Tree updates from L1, used for cross-chain messaging.

### BatchesCfg

**Location:** `zk/stages/stage_batches.go:77-85`

- Manages data stream client connection
- Handles batch download from sequencer
- Progress tracking and resume

### SequencerL1BlockSyncCfg

**Location:** `zk/stages/stage_sequencer_l1_block_sync.go:24-36`

For L1 recovery mode - rebuilds batches as sent to L1.

### SequencerBlobRecoveryCfg

**Location:** `zk/stages/stage_sequence_blob_recovery.go:18-32`

For blob data availability recovery from L1.

### ZkInterHashesCfg

**Location:** `zk/stages/stage_interhashes.go:44-56`

- Supports both PMT and SMT
- Configurable root checking
- Memory optimization options

### WitnessCfg

**Location:** `zk/stages/stage_witness.go:26-37`

Generates witness caches for block verification. Skipped when:
- `WitnessCacheEnabled` is false
- Node is sequencer
- Using PMT (Probabilistic Merkle Tree)

### DataStreamCatchupCfg

**Location:** `zk/stages/stage_data_stream_catch_up.go:17-27`

Updates data stream with missing block details.

## Conditional Stages

Some stages are conditionally enabled:

### L1BlockSync

Enabled only in L1 recovery mode:
```go
Disabled: !sequencerL1BlockSyncCfg.zkCfg.IsL1Recovery()
```

### BlobRecovery

Enabled only in blob recovery mode:
```go
Disabled: !sequencerBlobRecoveryCfg.zkCfg.IsBlobRecovery()
```

### Witness

Skipped when:
- `WitnessCacheEnabled` is false
- Node is sequencer
- Using PMT

## Differences from Mainline Erigon

| Aspect | Mainline Erigon | CDK/zkEVM |
|--------|-----------------|-----------|
| **L1 Interaction** | None | L1Syncer, L1SequencerSyncer, L1InfoTree |
| **Batch Processing** | Sequential blocks | Batch-based (from data stream) |
| **Data Source** | P2P network | Data stream server |
| **Execution Model** | Standard EVM | Sequencer creates blocks; RPC receives batches |
| **State Root** | Full verification | SMT/PMT with optional root checks |
| **Recovery Modes** | Limited | L1Recovery, BlobRecovery, L1BlockSync |
| **Witness Generation** | None | Full witness caching for verification |
| **Sequencing** | Mining stages | Sequencing stage (sequencer only) |
| **Intermediate Hashes** | Single algorithm | Dual algorithm support (SMT vs PMT) |

### Mainline vs CDK Pipeline Comparison

**Mainline Execution Order:**
```
Snapshots → Headers → BorHeimdall → BlockHashes → Bodies → Senders
→ Execution → HashState → IntermediateHashes → AccountHistory
→ StorageHistory → LogIndex → CallTraces → TxLookup → Finish
```

**CDK RPC Execution Order:**
```
L1Syncer → L1InfoTree → Batches → BlockHashes → Senders
→ Execution → HashState → IntermediateHashes → CallTraces
→ AccountHistory → StorageHistory → LogIndex → TxLookup
→ DataStream → Witness → Finish
```

**CDK Sequencer Execution Order:**
```
L1Syncer → L1SequencerSyncer → L1InfoTree → L1BlockSync → BlobRecovery
→ SequenceExecution → IntermediateHashes → HashState → CallTraces
→ AccountHistory → StorageHistory → LogIndex → TxLookup → Finish
```

## Stage Lifecycle Functions

Each stage implements three functions:

### Forward

Executes stage progress - moves the stage forward to a target block.

```go
Forward: func(firstCycle, badBlockUnwind bool, s *StageState, u Unwinder,
              txc wrap.TxContainer, logger log.Logger) error {
    return SpawnStageL1Syncer(s, u, cfg, ctx, txc.Tx, logger)
}
```

### Unwind

Rolls back stage progress - used for chain reorganizations.

```go
Unwind: func(firstCycle bool, u *UnwindState, s *StageState,
             txc wrap.TxContainer, logger log.Logger) error {
    return UnwindL1SyncerStage(u, txc.Tx, cfg, ctx)
}
```

### Prune

Cleans up historical data according to pruning mode.

```go
Prune: func(firstCycle bool, p *PruneState, txc wrap.TxContainer,
            logger log.Logger) error {
    return PruneL1SyncerStage(p, txc.Tx, cfg, ctx)
}
```

## Stage Orchestration

**Location:** `turbo/stages/zk_stages.go`

Entry points that create and configure stages:

- `NewDefaultZkStages()` - Creates RPC/synchronizer node stages
- `NewSequencerZkStages()` - Creates sequencer node stages

These call the stage builder functions in `zk/stages/stages.go`:

- `DefaultZkStages()` - Builds RPC pipeline
- `SequencerZkStages()` - Builds sequencer pipeline

## Key Source Files

### Stage Definitions
- `eth/stagedsync/stages/stages_zk.go` - CDK stage constants
- `zk/stages/stages.go` - Main pipeline definitions
- `turbo/stages/zk_stages.go` - Stage factory functions

### Stage Implementations
- `zk/stages/stage_l1_syncer.go` - L1 synchronization
- `zk/stages/stage_l1_sequencer_sync.go` - Sequencer L1 sync
- `zk/stages/stage_l1_info_tree.go` - L1 Info Tree updates
- `zk/stages/stage_batches.go` - Batch downloading
- `zk/stages/stage_sequence_execute.go` - Sequencer execution
- `zk/stages/stage_interhashes.go` - Merkle tree hashing
- `zk/stages/stage_witness.go` - Witness generation
- `zk/stages/stage_data_stream_catch_up.go` - Data stream updates
- `zk/stages/stage_sequencer_l1_block_sync.go` - L1 recovery
- `zk/stages/stage_sequence_blob_recovery.go` - Blob recovery

### Execution Support
- `zk/stages/stage_sequence_execute_*.go` - Various execution helpers

## Related Documentation

- [Data Stream Protocol](data-stream-protocol.md)
- [Fork ID Management](fork-id-management.md)
- [State Trie Comparison](state-trie-comparison.md)
