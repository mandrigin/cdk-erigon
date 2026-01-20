# Fork ID Management

This document describes the fork ID system used in cdk-erigon for managing protocol upgrades and network compatibility.

## Overview

Fork IDs are version identifiers representing protocol upgrades in zkEVM. Each fork may change execution semantics, data structures, or proof systems. Fork IDs are sequential integers indicating which protocol rules apply to a given batch.

## Fork ID Enumeration

**Location:** `erigon-lib/chain/zk_constants.go`

```go
type ForkId uint64

const (
    ForkID4            ForkId = 4   // Blueberry
    ForkID5Dragonfruit ForkId = 5   // Added EffectiveGasPricePercentage
    ForkID6IncaBerry   ForkId = 6   // Pre-L1InfoTree
    ForkID7Etrog       ForkId = 7   // Introduced L1InfoTree, BlockInfoRoot
    ForkID8Elderberry  ForkId = 8   // Production fork
    ForkID9Elderberry2 ForkId = 9   // Latest stable
    ForkID10           ForkId = 10
    ForkID11           ForkId = 11
    ForkID12Banana     ForkId = 12
    ForkId13Durian     ForkId = 13
)
```

| Fork ID | Name | Key Features |
|---------|------|--------------|
| 4 | Blueberry | Early fork |
| 5 | Dragonfruit | Added EffectiveGasPricePercentage |
| 6 | IncaBerry | Pre-L1InfoTree |
| 7 | Etrog | Introduced L1InfoTree, BlockInfoRoot |
| 8 | Elderberry | Production fork |
| 9 | Elderberry 2 | Latest stable |
| 10-13 | ForkID10-Durian | Subsequent upgrades |

## Network Upgrade Implementation

### Chain Configuration

**Location:** `erigon-lib/chain/chain_config.go`

Fork activation blocks are configured in the chain config:

```go
type Config struct {
    ForkID4Block            *big.Int
    ForkID5DragonfruitBlock *big.Int
    ForkID6IncaBerryBlock   *big.Int
    ForkID7EtrogBlock       *big.Int
    ForkID8ElderberryBlock  *big.Int
    ForkID9Elderberry2Block *big.Int
    ForkID10                *big.Int
    ForkID11                *big.Int
    ForkID12BananaBlock     *big.Int
    ForkId13Durian          *big.Int
}
```

### Fork Check Methods

Each fork has a check method:

```go
func (c *Config) IsForkID7Etrog(num uint64) bool {
    return isForked(c.ForkID7EtrogBlock, num)
}
```

### Database Storage

**Location:** `zk/hermez_db/db.go`

| Table | Key | Value | Purpose |
|-------|-----|-------|---------|
| `hermez_forkIds` | batchNo | forkId | Maps batches to fork IDs |
| `hermez_forkIdBlock` | forkId | blockNumber | First block of each fork |
| `fork_history` | index | forkId + lastVerifiedBatch | Historical tracking |

## Compatibility Matrix (EIP-2124)

**Location:** `core/forkid/forkid.go`

Fork compatibility uses EIP-2124 for peer-to-peer validation:

```go
type ID struct {
    Hash [4]byte  // CRC32 checksum of genesis + fork blocks
    Next uint64   // Next upcoming fork block
}
```

### Validation Rules

1. If local and remote FORK_CSUM match, compare local head to FORK_NEXT
2. If remote is subset of local forks, validate against announced next fork
3. If remote is superset of local forks, accept (node is out of sync)
4. Reject in all other cases

## Fork ID in Execution

### EVM Instruction Selection

**Location:** `core/vm/evm_zkevm.go`

```go
switch {
case evm.chainRules.IsForkID13Durian:
    return durian_jump_table
case evm.chainRules.IsForkID8Elderberry:
    return elderberry_jump_table
case evm.chainRules.IsForkID7Etrog:
    return etrog_jump_table
}
```

### State Transitions

**Location:** `core/state_processor_zkevm.go`

```go
if evm.ChainRules().IsForkID5Dragonfruit {
    // Dragonfruit-specific execution logic
}
```

## RPC Methods

**Location:** `turbo/jsonrpc/zkevm_api.go`

| Method | Description |
|--------|-------------|
| `zkevm_getForkId` | Returns current fork ID |
| `zkevm_getForkById` | Returns fork details by ID |
| `zkevm_getForkIdByBatchNumber` | Returns fork ID for a batch |
| `zkevm_getForks` | Returns all fork intervals |

### ForkInterval Response

```go
type ForkInterval struct {
    ForkId          hexutil.Uint64
    FromBatchNumber hexutil.Uint64
    ToBatchNumber   hexutil.Uint64
    Version         string
    BlockNumber     hexutil.Uint64
}
```

## Supported Networks

**Location:** `erigon-lib/chain/zk_chain_config.go`

| Chain ID | Network |
|----------|---------|
| 195 | xlayer-testnet |
| 196 | xlayer-mainnet |
| 1101 | Polygon zkEVM mainnet |
| 2440 | Cardona internal |
| 2442 | Cardona testnet |
| 10010 | Etrog testnet |
| 999999 | Local devnet |

## Key Source Files

- `erigon-lib/chain/zk_constants.go` - Fork ID constants
- `erigon-lib/chain/chain_config.go` - Chain configuration
- `zk/hermez_db/db.go` - Database storage
- `core/forkid/forkid.go` - EIP-2124 implementation
- `turbo/jsonrpc/zkevm_api.go` - RPC methods
- `core/vm/evm_zkevm.go` - EVM integration

## Related Documentation

- [Sync Stages](sync-stages.md)
- [Data Stream Protocol](data-stream-protocol.md)
