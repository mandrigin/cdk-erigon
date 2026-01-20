---
sidebar_position: 2
title: Type1 vs Type2 zkEVM Migration
description: Understanding zkEVM execution types and migrating from Type2 to Type1
---

# Type1 vs Type2 zkEVM Migration

This guide explains the differences between Type1 and Type2 zkEVM execution modes in cdk-erigon and how to migrate between them.

## Overview

cdk-erigon supports two execution types that differ in state commitment and EVM compatibility:

| Aspect | Type2 (zkEVM) | Type1 (Normalcy) |
|--------|---------------|------------------|
| State Trie | Sparse Merkle Tree (SMT) | Patricia Merkle Trie (PMT) |
| EVM Interpreter | zkEVM Interpreter | Standard EVM Interpreter |
| Virtual Counters | **Enabled** | **Disabled** |
| ZK Proof Generation | Full ZK proofs | Pessimistic proofs (PP) |
| Ethereum Compatibility | Modified opcodes | Full Ethereum compatibility |

## Type2: zkEVM Mode (Default)

Type2 is the traditional zkEVM execution mode:

- **Sparse Merkle Tree (SMT)**: Uses a zkEVM-specific state trie optimized for ZK proof generation
- **zkEVM Interpreter**: Modified EVM with zkEVM-specific opcode behavior
- **Virtual Counters**: Tracks computational resources for ZK circuit constraints
- **Full ZK Proofs**: Generates complete zero-knowledge proofs for every batch

```go
// From core/vm/evm.go - Type2 uses zkEVM interpreter
if !evm.ChainRules().IsNormalcy {
    evm.interpreter = NewZKEVMInterpreter(evm, NewZkConfig(vmConfig, nil))
}
```

### When to Use Type2

- Networks requiring full zkEVM proving
- Chains that need zkEVM-specific features
- Legacy CDK chains before Normalcy upgrade

## Type1: Normalcy Mode

Type1 enables full Ethereum compatibility through "Normalcy" mode:

- **Patricia Merkle Trie (PMT)**: Standard Ethereum state trie
- **Standard EVM Interpreter**: Unmodified Ethereum opcodes
- **No Virtual Counters**: ZK resource tracking is disabled
- **Pessimistic Proofs**: Uses PP mode for verification instead of full ZK proofs

```go
// From core/genesis_write.go - Type1 requires both PMT and Normalcy
type1 := usingPmt && normalcy
statedb.SetIsType1(type1)
```

### When to Use Type1

- Networks migrating to full Ethereum equivalence
- Chains using Pessimistic Proof (PP) mode
- New CDK deployments targeting Ethereum compatibility

## Virtual Counters Behavior

Virtual counters track zkEVM computational resources. They are automatically disabled in:

1. **Type1/Normalcy mode**: Full Ethereum compatibility means no ZK constraints
2. **L1 Recovery mode**: Counters unlimited during chain recovery
3. **Pessimistic Proof (PP) mode**: PP doesn't require ZK counter tracking

```go
// From eth/ethconfig/config_zkevm.go
func (c *Zk) ShouldCountersBeUnlimited(l1Recovery bool) bool {
    return l1Recovery || (c.DisableVirtualCounters && !c.ExecutorStrictMode && !c.HasExecutors())
}
```

### Manual Counter Disable

You can manually disable virtual counters on a sequencer without an external executor:

```yaml
# Disable virtual counters (sequencer only, no executor)
zkevm.disable-virtual-counters: true
zkevm.executor-strict: false
```

**Restrictions:**
- Cannot disable counters with `executor-strict: true`
- Cannot disable counters when using external executors
- Only effective on sequencer nodes

## Pessimistic Proof (PP) Mode

Pessimistic Proof mode is an alternative verification mechanism that doesn't require full ZK proof generation:

### Configuration

```yaml
# Enable PP mode by setting the fork number
zkevm.pessimistic-fork-number: 12

# PP mode works with these settings
zkevm.disable-virtual-counters: true
zkevm.executor-strict: false
zkevm.executor-enabled: false
```

### Key Characteristics

- **No ZK Counters**: Virtual counters are disabled in PP mode
- **Faster Verification**: PP verification is faster than full ZK proving
- **Fork-Based Activation**: Activates at specified fork number

### When PP Fork Number is Required

The `zkevm.pessimistic-fork-number` flag **must be set** when:

```go
// From zk/da/blob_da.go
if len(allForks) == 1 && allForks[0] == 0 {
    // Network never had FEP rollup type assigned
    ppFork := zkCfg.PessimisticForkNumber
    if ppFork == 0 {
        return 0, nil, fmt.Errorf("zkevm.pessimistic-fork-number flag must be set...")
    }
}
```

## Migration: Type2 to Type1

### Prerequisites

1. Network must support Normalcy upgrade (fork activation)
2. PMT must be enabled at the correct block
3. All nodes must be upgraded before fork activation

### Migration Steps

#### Step 1: Verify Network Support

Check your chain's configuration supports Normalcy:

```bash
# Verify genesis config includes Normalcy block
cat genesis.json | jq '.config.normalcyBlock'
```

#### Step 2: Update Configuration

```yaml
# Before: Type2 configuration
zkevm.executor-urls: "executor:50071"
zkevm.executor-strict: true
zkevm.executor-enabled: true

# After: Type1 configuration (PP mode)
zkevm.executor-strict: false
zkevm.executor-enabled: false
zkevm.disable-virtual-counters: true
zkevm.pessimistic-fork-number: 12  # Set to your network's PP fork
```

#### Step 3: Coordinate Fork Activation

The network must undergo a coordinated upgrade:

1. **Pre-fork**: All nodes running Type2 with zkEVM
2. **Fork activation**: Normalcy block reached
3. **Post-fork**: All nodes running Type1 with PMT

```yaml
# Chain config requirements
config:
  pmtEnabledBlock: 1000000    # PMT activation block
  normalcyBlock: 1000000       # Normalcy activation (must equal PMT)
```

**Important**: PMT and Normalcy must activate at the same block:

```go
// From core/genesis_write.go
if usingPmt && !normalcy {
    panic("PMT is enabled, but normalcy is not set")
}
```

### Post-Migration Verification

After migration, verify Type1 is active:

```bash
# Check current fork ID
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"zkevm_getForkId","params":[],"id":1}'

# Verify counters are disabled (no counter errors in logs)
grep -i "counter" /path/to/erigon.log
```

## Configuration Reference

### Type2 (zkEVM) Configuration

```yaml
# Full zkEVM with executor
zkevm.executor-urls: "executor1:50071,executor2:50071"
zkevm.executor-strict: true
zkevm.executor-enabled: true
zkevm.disable-virtual-counters: false
```

### Type1 (Normalcy/PP) Configuration

```yaml
# Normalcy mode with PP
zkevm.executor-strict: false
zkevm.executor-enabled: false
zkevm.disable-virtual-counters: true
zkevm.pessimistic-fork-number: 12
```

### Hybrid Configuration (Migration Period)

```yaml
# During migration - keep executor for pre-fork batches
zkevm.executor-urls: "executor:50071"
zkevm.executor-strict: false  # Allow fallback
zkevm.executor-enabled: true
zkevm.pessimistic-fork-number: 12
```

## Troubleshooting

### "PMT is enabled, but normalcy is not set"

This panic occurs when PMT is activated without Normalcy:

**Solution**: Ensure both `pmtEnabledBlock` and `normalcyBlock` are set to the same value in your chain config.

### "zkevm.pessimistic-fork-number flag must be set"

This error occurs on networks without FEP rollup type history:

**Solution**: Set `zkevm.pessimistic-fork-number` to your network's PP activation fork.

### "Cannot disable virtual counters when running in strict mode"

Strict mode requires counters for executor verification:

**Solution**: Set `zkevm.executor-strict: false` when disabling virtual counters.

### "Cannot disable virtual counters when running with executors"

External executors require counter tracking:

**Solution**: Either remove executor URLs or keep counters enabled.

## See Also

- [State Trie Configuration](../configuration/state-trie.md)
- [zkEVM Flags Reference](../../reference/zkevm-flags.md)
- [L1 Recovery Mode](../operations/l1-recovery.md)
