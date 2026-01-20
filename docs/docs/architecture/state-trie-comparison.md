# State Trie Comparison: SMT vs PMT

This document provides a detailed comparison of the two state commitment schemes supported by cdk-erigon: Sparse Merkle Tree (SMT) and Patricia Merkle Trie (PMT).

## Overview

cdk-erigon supports two fundamentally different approaches to state commitment:

| Feature | SMT (Sparse Merkle Tree) | PMT (Patricia Merkle Trie) |
|---------|--------------------------|----------------------------|
| Tree Structure | Binary (2 children per node) | Hexary (16 children per node) |
| Hash Function | Poseidon | Keccak-256 |
| Tree Depth | Fixed 256 levels | Variable (typically 20-30) |
| Primary Use Case | ZK proof generation | Ethereum compatibility |
| Configuration | `zkevm.initial-commitment: smt` | `zkevm.initial-commitment: pmt` |

## Architectural Differences

### Sparse Merkle Tree (SMT)

**Implementation:** `smt/pkg/smt/smt.go`

SMT is a binary tree where each node has exactly two children (left/right). Each bit of the 256-bit key determines the path through the tree:
- Bit `0` → left child
- Bit `1` → right child

**Node Types:**

```
NodeValue8 (8 uint64s)   - Stores leaf values (account/storage data)
NodeValue12 (12 uint64s) - Stores branch nodes (8 values + 4 capacity hashes)
NodeKey (4 uint64s)      - 256-bit keys stored as uint64 array
```

**Capacity Parameter:**

Each node includes a "capacity" field encoding node type metadata:
- `LeafCapacity = [4]uint64{1, 0, 0, 0}` for leaf nodes
- `BranchCapacity = [4]uint64{0, 0, 0, 0}` for branch nodes

**Key Operations:**

1. **Insert** - Traverses key bits to find insertion point, handles three cases:
   - UPDATE: Replace existing value
   - INSERT_FOUND: Split nodes when colliding with different key
   - INSERT_NOT_FOUND: Create new leaf

2. **Batch Operations** - `InsertBatch()` provides parallel processing with progress tracking

3. **Bulk Creation** - `GenerateFromKVBulk()` sorts keys and builds bottom-up with O(n log n) complexity

### Patricia Merkle Trie (PMT)

**Implementation:** `erigon-lib/commitment/hex_patricia_hashed.go`

PMT is a 16-ary (hexary) tree where each nibble (4-bit hex digit) of the key selects one of 16 children. Variable-depth with path compression via extension nodes.

**Node Types:**

- **Branch**: 16 children pointer array
- **Extension**: Key prefix compression node
- **Account Leaf**: Account data (balance, nonce, code, storage)
- **Storage Leaf**: Storage slot data
- **Hash Node**: Reference to pre-computed hash

**Grid-Based Processing:**

`HexPatriciaHashed` maintains a `grid[128][16]` structure:
- First 64 rows for account trie
- Second 64 rows for storage trie
- Each row has up to 16 columns (nibbles)

**Key Representation:**
- Keccak-256 pre-hashed keys (20 bytes for accounts, 32 bytes for storage)
- Nibbles extracted and processed sequentially
- Extension nodes compress common prefixes

## Hashing Mechanisms

### Poseidon Hash (SMT)

**Location:** `smt/pkg/utils/utils.go`

```go
import poseidon "github.com/okx/poseidongold/go"

func Hash(in [8]uint64, capacity [4]uint64) [4]uint64 {
    var result [4]uint64
    hashFunc(&in, &capacity, &result)
    return result
}
```

**Characteristics:**
- **Input**: Two uint64 arrays: 8 values + 4 capacity
- **Output**: 4 uint64s (256-bit hash)
- **ZK-Friendly**: Optimized for arithmetic circuits and finite field operations
- **Constant**: `PoseidonAllZeroes = 0xc71603f33a1144ca7953db0ab48808f4c4055e3364a246c33c18a9786cb0b359`

**Hash Patterns:**
```go
// Leaf hash: Key(4) + Value(4)
newLeafHash = Hash(ConcatArrays4(key, valueHash), LeafCapacity)

// Branch hash: LeftChild(4) + RightChild(4)
branchHash = Hash(ConcatArrays4(leftHash, rightHash), BranchCapacity)
```

### Keccak-256 Hash (PMT)

**Location:** `erigon-lib/commitment/hex_patricia_hashed.go`

```go
import "golang.org/x/crypto/sha3"

keccak := sha3.NewLegacyKeccak256()
```

**Characteristics:**
- **Input**: Variable-length byte data (RLP-encoded cell data)
- **Output**: 32-byte hash
- **CPU-Optimized**: Hardware acceleration support (SHA-3 extensions)
- **Ethereum-Native**: Compatible with all EVM tooling

**Hash Process:**
1. RLP-encode node data
2. If RLP < 32 bytes: store directly
3. If RLP >= 32 bytes: hash with Keccak256

## Performance Tradeoffs

### SMT Performance

**Advantages:**
- **ZK-Efficient**: Poseidon is 100-1000x faster in arithmetic circuits (FRI proofs)
- **Binary Structure**: 256 fixed levels allow predictable memory layout
- **Parallelizable**: Batch operations with go-parallel workers
- **Deterministic Depth**: Always 256 levels regardless of data distribution

**Disadvantages:**
- **Larger Tree**: 256 levels vs ~64 for account + storage in PMT
- **More Hashes**: Binary tree requires more hash computations
- **EVM Incompatibility**: Poseidon hashes not compatible with Ethereum tooling
- **CPU Operations**: Slower on traditional CPUs (no hardware acceleration)

### PMT Performance

**Advantages:**
- **CPU-Optimized**: Keccak has hardware support
- **Compressed Keys**: Extension nodes reduce tree depth
- **Ethereum-Native**: Compatible with all EVM tools
- **Shallower Trees**: Typically 20-30 levels for accounts
- **Hash Memoization**: Path extension allows skipping multiple levels

**Disadvantages:**
- **ZK-Unfriendly**: Keccak has prohibitive circuit cost
- **Variable Depth**: Different keys have different depths
- **Complex Witnesses**: More complex witness format for variable paths
- **Memory Overhead**: Variable-depth nodes require more complex bookkeeping

### Benchmark Comparison

| Operation | SMT | PMT |
|-----------|-----|-----|
| Insert single | ~256 Poseidon hashes | ~20 Keccak hashes |
| CPU time (insert) | ~10-50ms | ~1-5ms |
| ZK proof generation | ~100ms | ~10s (prohibitive) |
| Memory (full state) | ~256 GB typical | ~64 GB typical |

## When to Use Each

### Use SMT When:

1. **ZK Proof Required**: zkEVM mainnet, prover integration
2. **Cross-Chain Bridges**: Polygon CDK, ZK rollups
3. **Sequencer Nodes**: Primary chain operators
4. **High-Value Chains**: Where proof generation time/cost matters

**Configuration:**
```yaml
zkevm:
  initial-commitment: smt
  smt-regenerate-in-memory: true   # Faster, more RAM
  smt-regenerate-in-memory: false  # Slower, less RAM
```

### Use PMT When:

1. **No ZK Proofs**: Standard EVM chains, local testing
2. **Ethereum Compatibility**: Tools expecting Keccak hashes
3. **Memory-Constrained**: Limited RAM environments
4. **Development/Testing**: Faster iteration cycles
5. **RPC Nodes**: Non-sequencer read-only nodes

**Configuration:**
```yaml
zkevm:
  initial-commitment: pmt
```

## Migration Between SMT and PMT

### Critical Limitation

The `zkevm.initial-commitment` setting must be set from genesis and **cannot be changed** after the node has started syncing.

**Why?**

State root calculation differs fundamentally:
- SMT: `root = Poseidon(leftChild, rightChild, capacity)`
- PMT: `root = Keccak(RLP(cellData))`

The root hashes will differ for identical state, making cross-verification impossible.

### Migration Strategies

**For Operators Switching to ZK:**
1. Maintain both nodes in parallel
2. New SMT node syncs from genesis (or trusted checkpoint)
3. Old PMT node deprecated
4. Client traffic gradually switched

**For RPC Node Deployment:**
1. Primary: SMT sequencer (ZK-enabled)
2. Secondary: PMT archival node (Ethereum tooling compatibility)
3. API router: Serve appropriate responses from each

**For Testing/Staging:**
1. Use PMT with snapshot data
2. Shadow-sync with SMT for validation
3. Compare root hashes periodically

## Key Source Files

### SMT Implementation
- `smt/pkg/smt/smt.go` - Main SMT logic
- `smt/pkg/smt/smt_batch.go` - Batch operations
- `smt/pkg/smt/smt_create.go` - Bulk creation
- `smt/pkg/utils/utils.go` - Poseidon hashing utilities

### SMT v2 (Alternative)
- `smtv2/smt_v2_types.go` - Types and data structures
- `smtv2/smt_v2_stack.go` - Stack-based SMT operations

### PMT Implementation
- `erigon-lib/commitment/hex_patricia_hashed.go` - Hexary PMT
- `erigon-lib/commitment/bin_patricia_hashed.go` - Binary PMT variant
- `erigon-lib/commitment/commitment.go` - Interface definition

### Hashing
- `turbo/trie/hasher.go` - Keccak-based hasher for PMT
- `smt/pkg/utils/utils.go` - Poseidon hash implementation

## Configuration Reference

| Setting | Values | Default | Description |
|---------|--------|---------|-------------|
| `zkevm.initial-commitment` | `smt`, `pmt` | `smt` | State commitment algorithm |
| `zkevm.smt-regenerate-in-memory` | `true`, `false` | `true` | Regenerate SMT in memory (faster, more RAM) |

## Related Documentation

- [State Trie Configuration](../configuration/state-trie.md)
- [Getting Started Concepts](../getting-started/concepts.md)
- [Glossary](../glossary.md)
