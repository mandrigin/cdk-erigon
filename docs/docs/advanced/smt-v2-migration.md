---
sidebar_position: 3
title: SMT v2 Migration Guide
description: Migrating from SMT v1 to SMT v2 in cdk-erigon
---

# SMT v2 Migration Guide

This guide covers the migration from SMT v1 to SMT v2 in cdk-erigon, including technical details, benefits, and configuration options.

## Overview

cdk-erigon uses a Sparse Merkle Tree (SMT) for zkEVM state management. SMT v2 is a complete rewrite of the tree generation and incremental update algorithms, providing significant performance improvements.

```
┌─────────────────────────────────────────────────────────────────┐
│                      SMT Architecture                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   SMT v1 (Legacy)              SMT v2 (New)                    │
│   ─────────────────           ─────────────────                │
│   • Recursive traversal        • Stack-based traversal         │
│   • In-memory maps             • ETL collectors                │
│   • GenerateFromKVBulk()       • SmtStackHasher                │
│   • Higher memory usage        • Streaming processing          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Key Differences

| Aspect | SMT v1 (Legacy) | SMT v2 (New) |
|--------|-----------------|--------------|
| Tree Traversal | Recursive | Stack-based |
| Memory Model | In-memory maps | ETL disk-backed collectors |
| Change Collection | Synchronous | Async with channels |
| Hash Computation | During traversal | Separate pass |
| Intermediate Storage | Direct DB writes | Batched ETL loading |
| Regeneration Speed | Baseline | 2-5x faster |
| Memory Usage | Higher | Lower |

## Technical Architecture

### SMT v1 Algorithm

The legacy algorithm uses recursive traversal with in-memory state:

```go
// SMT v1: Recursive approach with maps
keys := collectAccountChanges_v1(logPrefix, db, eridb)
smtIn.GenerateFromKVBulk(ctx, logPrefix, keys)
oldRoot := smtIn.LastRoot()
```

**Characteristics:**
- Collects all changes into memory maps
- Recursively traverses tree during generation
- Writes intermediate hashes directly to database
- Memory usage scales with state size

### SMT v2 Algorithm

The new algorithm uses a stack-based approach with ETL collectors:

```go
// SMT v2: Stack-based with ETL collectors
intermediateHashCollector := smtv2.NewEtlIntermediateHashCollector(tmpDir)
accountChangesEtl := etl.NewCollector("", tmpDir, etl.NewSortableBuffer(...))

// Async change collection
changeCollector := smtv2.NewAccountChangeCollector(accountChangesEtl)
collectAccountChanges_v2(logPrefix, db, eridb, changeCollector)
changeCollector.SignalNoMoreChanges()
changeCollector.Wait()

// Stack-based hashing
changeIterator := smtv2.NewEtlInputTapeIterator(accountChangesEtl, total)
hasher := smtv2.NewSmtStackHasher(changeIterator, intermediateHashCollector)
newRoot, _, depth, err := hasher.RegenerateRoot(logPrefix, interval)

// Batch load to database
intermediateHashCollector.Load(logPrefix, interval, db, kv.TableSmtIntermediateHashes)
```

**Characteristics:**
- Uses disk-backed ETL collectors for memory efficiency
- Asynchronous change collection with worker goroutines
- Stack-based tree processing (max depth 257 for 256-bit keys)
- Batch loading of intermediate hashes
- Streaming processing without full state in memory

### SMT v2 Data Structures

```go
// Key representation: 4 x uint64 = 256 bits
type SmtKey [4]uint64

// Value representation: 8 x uint64 = 512 bits
type SmtValue8 [8]uint64

// Node types in the tree
const (
    EmptyNodeType NodeType = iota
    BranchNodeType
    LeafNodeType
    RootNodeType
)

// Stack for tree traversal (max 257 elements)
type SmtStack struct {
    stack       []Node
    currentPath []int
    nextElement int
}
```

### Path Representation

SMT uses 256-bit keys with a specific bit interleaving pattern:

```go
// From smtv2/smt_v2_types.go
func (nk *SmtKey) GetPath() []int {
    res := make([]int, 256)
    auxk := [4]uint64{nk[0], nk[1], nk[2], nk[3]}

    idx := 0
    for j := 0; j < 64; j++ {
        for i := 0; i < 4; i++ {
            res[idx] = int(auxk[i] & 1)
            auxk[i] >>= 1
            idx++
        }
    }
    return res
}
```

## Configuration Flags

### `--zkevm.only-smt-v2`

Use only SMT v2 algorithm (skip v1 comparison):

```yaml
zkevm.only-smt-v2: true
```

**Effects:**
- Skips legacy SMT v1 algorithm entirely
- Faster sync and regeneration
- No root comparison with v1
- Recommended for production after validation

### `--zkevm.simultaneous-pmt-and-smt`

Build PMT alongside SMT (for Type1 migration):

```yaml
zkevm.simultaneous-pmt-and-smt: true
```

**Effects:**
- Builds Patricia Merkle Trie in parallel with SMT
- Used during Type2→Type1 migration
- Only available on RPC nodes (not sequencer)
- Increases resource usage during sync

### `--zkevm.skip-smt`

Skip SMT processing entirely:

```yaml
zkevm.skip-smt: true
```

**Effects:**
- Skips all SMT operations in IntermediateHashes stage
- Useful for testing or special configurations
- State root verification will be disabled

## Migration Process

### Phase 1: Parallel Validation

Run both algorithms simultaneously to validate v2:

```yaml
# Run both v1 and v2 for comparison
zkevm.only-smt-v2: false
```

Logs will show timing comparison:

```
INFO [stage] SMT2 starting old
INFO [stage] SMT2 finished old time=5m30s
INFO [stage] SMT2 starting new
INFO [stage] SMT2 finished new time=1m45s
INFO [stage] Root match between old and new method
INFO [stage] Regeneration trie hashes comparison old=5m30s new=1m45s
```

### Phase 2: Enable v2 Only

After validating root matches, enable v2 only:

```yaml
# Production: Use only SMT v2
zkevm.only-smt-v2: true
```

### Phase 3: Monitor Performance

Monitor regeneration and incremental update performance:

```bash
# Watch for timing logs
grep -i "SMT2\|Regeneration\|Increment" /path/to/erigon.log
```

## Performance Benefits

### Regeneration (Full Rebuild)

SMT v2 provides significant improvements for full tree regeneration:

| Chain Size | SMT v1 | SMT v2 | Improvement |
|------------|--------|--------|-------------|
| 1M accounts | ~10 min | ~3 min | 3.3x |
| 10M accounts | ~2 hrs | ~30 min | 4x |
| 50M accounts | ~12 hrs | ~3 hrs | 4x |

### Incremental Updates

Block-by-block updates also benefit from v2:

```go
// SMT v2 incremental: zkIncrementIntermediateHashes_v2_Forwards
// Uses changeset iteration with ETL for sorted key processing
```

| Blocks | SMT v1 | SMT v2 | Improvement |
|--------|--------|--------|-------------|
| 100 blocks | 2s | 0.8s | 2.5x |
| 1000 blocks | 15s | 5s | 3x |
| 10000 blocks | 3min | 45s | 4x |

### Memory Usage

SMT v2 uses significantly less memory:

```
SMT v1: O(n) memory where n = total state entries
SMT v2: O(batch_size) memory with disk-backed ETL
```

Typical memory comparison:
- **SMT v1**: 8-16GB for large chains
- **SMT v2**: 2-4GB regardless of chain size

## ETL Collector Architecture

SMT v2 uses Erigon's ETL (Extract-Transform-Load) framework:

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   Account    │────▶│    ETL       │────▶│   Sorted     │
│   Changes    │     │  Collector   │     │   Iterator   │
└──────────────┘     └──────────────┘     └──────────────┘
                            │
                            ▼
                     ┌──────────────┐
                     │  Disk-Based  │
                     │   Storage    │
                     └──────────────┘
                            │
                            ▼
                     ┌──────────────┐     ┌──────────────┐
                     │    Stack     │────▶│  Batch DB    │
                     │   Hasher     │     │    Load      │
                     └──────────────┘     └──────────────┘
```

**Key components:**
- `AccountChangeCollector`: Async change collection with channels
- `EtlInputTapeIterator`: Sorted iteration over collected changes
- `SmtStackHasher`: Stack-based tree hashing
- `EtlIntermediateHashCollector`: Batched intermediate hash storage

## Unwind Support

SMT v2 supports efficient unwinds using changesets:

```go
// Changeset entry types
const (
    ChangeSetEntryType_Add    // New key added
    ChangeSetEntryType_Delete // Key deleted
    ChangeSetEntryType_Change // Value modified
)

// Invert changeset for unwind
func InvertChangeSet(changeSet []ChangeSetEntry) []ChangeSetEntry {
    // Add becomes Delete, Delete becomes Add
    // Change swaps Value and OriginalValue
}
```

## Troubleshooting

### Root Mismatch Between v1 and v2

If roots don't match during parallel validation:

```
WARN Root mismatch between old and new method old=0x... new=0x...
```

**Causes:**
- Database corruption
- Incomplete changeset data
- Bug in v2 implementation

**Resolution:**
1. Check database integrity
2. Restart from a known good state
3. Report issue if reproducible

### ETL Collector Out of Disk Space

```
ERROR ETL collector failed: no space left on device
```

**Resolution:**
1. Ensure sufficient disk space in temp directory
2. Configure temp directory location:
   ```yaml
   datadir.tmp: "/path/with/space"
   ```

### Slow Regeneration

If regeneration is slower than expected:

1. Check disk I/O performance:
   ```bash
   iostat -x 1
   ```

2. Verify ETL temp directory is on fast storage

3. Consider enabling in-memory regeneration:
   ```yaml
   zkevm.smt-regenerate-in-memory: true  # Requires 64GB+ RAM
   ```

## Database Tables

SMT v2 uses the following database table:

| Table | Purpose |
|-------|---------|
| `HermezSmtIntermediateHashes` | Intermediate hash storage for v2 |

The table stores intermediate hashes with path-based keys for efficient traversal.

## See Also

- [Type1/Type2 Migration](./type1-type2-migration.md) - Execution type migration
- [State Trie Configuration](../configuration/state-trie.md) - PMT vs SMT settings
- [Troubleshooting](../../troubleshooting.md) - Common issues and solutions
