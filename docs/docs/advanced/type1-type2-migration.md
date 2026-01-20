---
sidebar_position: 2
title: zkEVM Execution Modes and Provers
description: Understanding Type1/Type2 zkEVM modes, provers, and verification mechanisms
---

# zkEVM Execution Modes and Provers

This guide explains the different execution modes, prover systems, and verification mechanisms in cdk-erigon.

## Architecture Overview

cdk-erigon supports multiple configurations across three dimensions:

```
┌─────────────────────────────────────────────────────────────────┐
│                     EXECUTION TYPE                              │
├─────────────────────────────────────────────────────────────────┤
│  Type2 (zkEVM)              │  Type1 (Normalcy)                 │
│  - SMT state trie           │  - PMT state trie                 │
│  - zkEVM interpreter        │  - Standard EVM interpreter       │
│  - Virtual counters ON      │  - Virtual counters OFF           │
│  - Hermez prover            │  - SP1 prover                     │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                   VERIFICATION MODE                             │
├─────────────────────────────────────────────────────────────────┤
│  FEP (Full Execution Proof) │  PP (Pessimistic Proof)           │
│  - Complete ZK proofs       │  - Optimistic verification        │
│  - Executor required        │  - No executor required           │
│  - Higher security          │  - Faster finality                │
│  - Counters enforced        │  - Counters disabled              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                   DATA AVAILABILITY                             │
├─────────────────────────────────────────────────────────────────┤
│  Rollup Mode                │  Sovereign/Validium Mode          │
│  - Data posted to L1        │  - Off-chain DA                   │
│  - Full L1 verification     │  - Independent operation          │
└─────────────────────────────────────────────────────────────────┘
```

## Execution Types Comparison

| Aspect | Type2 (zkEVM) | Type1 (Normalcy) |
|--------|---------------|------------------|
| State Trie | Sparse Merkle Tree (SMT) | Patricia Merkle Trie (PMT) |
| EVM Interpreter | zkEVM Interpreter | Standard EVM Interpreter |
| Virtual Counters | **Enabled** | **Disabled** |
| Prover | Hermez zkEVM prover | SP1 prover |
| Verification Modes | FEP or PP | FEP or PP |
| Ethereum Compatibility | Modified opcodes | Full Ethereum equivalence |

## Type2: zkEVM Mode

Type2 is the traditional zkEVM execution mode using the Hermez prover:

- **Sparse Merkle Tree (SMT)**: zkEVM-specific state trie optimized for ZK circuits
- **zkEVM Interpreter**: Modified EVM with zkEVM-specific opcode behavior
- **Virtual Counters**: Tracks computational resources for ZK circuit constraints
- **Hermez Prover**: Generates zkEVM-specific proofs

```go
// From core/vm/evm.go - Type2 uses zkEVM interpreter
if !evm.ChainRules().IsNormalcy {
    evm.interpreter = NewZKEVMInterpreter(evm, NewZkConfig(vmConfig, nil))
}
```

### Type2 with FEP Mode (Full Proving)

Full execution proofs with Hermez executor:

```yaml
# Type2 + FEP: Full zkEVM proving
zkevm.executor-urls: "executor:50071"
zkevm.executor-strict: true
zkevm.executor-enabled: true
zkevm.disable-virtual-counters: false
```

### Type2 with PP Mode (Pessimistic)

Pessimistic proofs without full ZK verification:

```yaml
# Type2 + PP: Pessimistic mode
zkevm.executor-strict: false
zkevm.executor-enabled: false
zkevm.disable-virtual-counters: true
zkevm.pessimistic-fork-number: 12
```

### When to Use Type2

- Networks requiring zkEVM-specific features
- Chains using Hermez prover infrastructure
- Legacy CDK chains before Normalcy upgrade

## Type1: Normalcy Mode

Type1 enables full Ethereum compatibility using the SP1 prover:

- **Patricia Merkle Trie (PMT)**: Standard Ethereum state trie
- **Standard EVM Interpreter**: Unmodified Ethereum opcodes
- **No Virtual Counters**: ZK resource tracking is disabled
- **SP1 Prover**: Generates Ethereum-compatible proofs

```go
// From core/genesis_write.go - Type1 requires both PMT and Normalcy
type1 := usingPmt && normalcy
statedb.SetIsType1(type1)
```

### Type1 with FEP Mode (Full Proving)

Full execution proofs with SP1:

```yaml
# Type1 + FEP: Full SP1 proving (future)
# Note: SP1 executor integration in development
zkevm.executor-strict: false
zkevm.executor-enabled: false
# SP1 prover configured externally
```

### Type1 with PP Mode (Pessimistic)

Pessimistic proofs for fastest finality:

```yaml
# Type1 + PP: Pessimistic Normalcy mode
zkevm.executor-strict: false
zkevm.executor-enabled: false
zkevm.disable-virtual-counters: true
zkevm.pessimistic-fork-number: 12
```

### When to Use Type1

- Networks targeting full Ethereum equivalence
- Chains using SP1 prover infrastructure
- New CDK deployments prioritizing compatibility

## Verification Modes: FEP vs PP

### FEP (Full Execution Proof)

FEP mode generates complete zero-knowledge proofs for every batch:

```
┌─────────────────────────────────────────────────────────────┐
│                    FEP Verification Flow                    │
├─────────────────────────────────────────────────────────────┤
│  Sequencer → Executor → Prover → L1 Verification           │
│                                                             │
│  1. Sequencer creates batch with transactions               │
│  2. Executor verifies execution and generates witness       │
│  3. Prover generates ZK proof (Hermez or SP1)              │
│  4. Proof submitted to L1 for verification                  │
└─────────────────────────────────────────────────────────────┘
```

**Characteristics:**
- Full ZK proof generation for each batch
- Virtual counters **required** (Type2) or disabled (Type1)
- Executor verification before proving
- Highest security guarantees

**Configuration:**
```yaml
# FEP mode with executor
zkevm.executor-urls: "executor:50071"
zkevm.executor-strict: true
zkevm.executor-enabled: true
```

### PP (Pessimistic Proof)

PP mode uses optimistic verification without full ZK proofs:

```
┌─────────────────────────────────────────────────────────────┐
│                    PP Verification Flow                     │
├─────────────────────────────────────────────────────────────┤
│  Sequencer → (No Executor) → L1 Submission                  │
│                                                             │
│  1. Sequencer creates batch with transactions               │
│  2. Batch submitted to L1 without ZK proof                  │
│  3. Challenge period for fraud proofs                       │
│  4. Finalization after challenge period                     │
└─────────────────────────────────────────────────────────────┘
```

**Characteristics:**
- No ZK proof generation
- Virtual counters **disabled**
- Faster batch finality
- Relies on challenge mechanism

**Configuration:**
```yaml
# PP mode - no executor needed
zkevm.executor-strict: false
zkevm.executor-enabled: false
zkevm.disable-virtual-counters: true
zkevm.pessimistic-fork-number: 12
```

### When PP Fork Number is Required

The `zkevm.pessimistic-fork-number` flag **must be set** when the network has never had an FEP rollup type assigned:

```go
// From zk/da/blob_da.go
if len(allForks) == 1 && allForks[0] == 0 {
    ppFork := zkCfg.PessimisticForkNumber
    if ppFork == 0 {
        return 0, nil, fmt.Errorf("zkevm.pessimistic-fork-number flag must be set...")
    }
}
```

## Prover Systems

### Hermez Prover (Type2)

The Hermez prover is used with Type2 zkEVM execution:

- Designed for zkEVM-specific circuits
- Requires virtual counters for resource tracking
- Communicates via gRPC with executor

**Executor Configuration:**
```yaml
# Hermez executor setup
zkevm.executor-urls: "executor1:50071,executor2:50071"
zkevm.executor-strict: true
zkevm.executor-enabled: true
zkevm.executor-request-timeout: 60s
zkevm.executor-max-concurrent-requests: 1
```

### SP1 Prover (Type1)

The SP1 prover is used with Type1 Normalcy execution:

- Ethereum-compatible proving system
- Works with standard PMT state trie
- No virtual counter requirements

**Note**: SP1 integration is configured externally to cdk-erigon.

## Virtual Counters

Virtual counters track zkEVM computational resources for ZK circuit constraints.

### When Counters Are Disabled

Counters are automatically unlimited in:

1. **Type1/Normalcy mode**: Full Ethereum compatibility
2. **L1 Recovery mode**: During chain recovery
3. **PP mode**: Pessimistic proofs don't need counters

```go
// From eth/ethconfig/config_zkevm.go
func (c *Zk) ShouldCountersBeUnlimited(l1Recovery bool) bool {
    return l1Recovery || (c.DisableVirtualCounters && !c.ExecutorStrictMode && !c.HasExecutors())
}
```

### Manual Counter Disable

Disable counters on a sequencer without external executor:

```yaml
zkevm.disable-virtual-counters: true
zkevm.executor-strict: false
```

**Restrictions:**
- Cannot disable with `executor-strict: true`
- Cannot disable when using external executors
- Only effective on sequencer nodes

## Sovereign Mode

Sovereign mode allows running a CDK chain independently without L1 verification:

### Characteristics

- **No L1 Dependency**: Chain operates independently
- **Off-chain DA**: Data availability handled externally
- **Self-Verification**: No external proof verification
- **Full Control**: Network operator manages all aspects

### Configuration

```yaml
# Sovereign mode - minimal L1 interaction
zkevm.l1-sync-start-block: 0  # No L1 sync
zkevm.executor-strict: false
zkevm.executor-enabled: false

# Optional: Use local DA
zkevm.da-url: "http://localhost:8080"
```

### Use Cases

- Private enterprise chains
- Development/testing environments
- Chains with custom DA solutions
- Networks transitioning to full rollup mode

## Limbo Recovery Mode

Limbo mode handles batches that fail executor verification:

```
┌─────────────────────────────────────────────────────────────┐
│                    Limbo Recovery Flow                      │
├─────────────────────────────────────────────────────────────┤
│  1. Batch fails executor verification                       │
│  2. Transactions moved to "limbo" pool                      │
│  3. System attempts re-execution with modifications         │
│  4. Valid transactions reprocessed in new batch             │
│  5. Invalid transactions discarded                          │
└─────────────────────────────────────────────────────────────┘
```

### Configuration

```yaml
# Enable limbo processing
zkevm.limbo: true
```

### Behavior

- **L1 Recovery Mode**: Limbo is bypassed (infinite loop on verification failure)
- **Default Mode + Limbo Disabled**: Also enters infinite loop
- **Default Mode + Limbo Enabled**: Transactions recovered and reprocessed

```go
// From zk/stages/stage_sequence_execute_batch.go
if batchState.isL1Recovery() || !batchContext.cfg.zk.Limbo {
    infiniteLoop(verifierBundle.Request.BatchNumber)
}
// Otherwise, handle limbo recovery
if err = handleLimbo(batchContext, batchState, verifierBundle); err != nil {
    return false, err
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

## Configuration Matrix

### Complete Mode Combinations

| Mode | Execution | Verification | Prover | Counters | Use Case |
|------|-----------|--------------|--------|----------|----------|
| Type2 + FEP | zkEVM/SMT | Full ZK | Hermez | Enabled | Production zkEVM |
| Type2 + PP | zkEVM/SMT | Pessimistic | None | Disabled | Fast Type2 finality |
| Type1 + FEP | EVM/PMT | Full ZK | SP1 | Disabled | Production Ethereum-equiv |
| Type1 + PP | EVM/PMT | Pessimistic | None | Disabled | Fast Ethereum-equiv |
| Sovereign | Either | None | None | Disabled | Independent chains |

### Configuration Reference

#### Type2 + FEP (Full zkEVM Proving)

```yaml
# Production zkEVM with Hermez executor
zkevm.executor-urls: "executor1:50071,executor2:50071"
zkevm.executor-strict: true
zkevm.executor-enabled: true
zkevm.disable-virtual-counters: false

# Witness generation for prover
zkevm.witness-full: true
zkevm.witness-memdb-size: 2GB
```

#### Type2 + PP (Pessimistic zkEVM)

```yaml
# zkEVM without full proving
zkevm.executor-strict: false
zkevm.executor-enabled: false
zkevm.disable-virtual-counters: true
zkevm.pessimistic-fork-number: 12
```

#### Type1 + FEP (Ethereum-Equivalent with SP1)

```yaml
# Full Ethereum equivalence with SP1 proving
# Note: SP1 prover configured externally
zkevm.executor-strict: false
zkevm.executor-enabled: false
zkevm.disable-virtual-counters: true  # Type1 doesn't use counters
# Chain config must have normalcyBlock set
```

#### Type1 + PP (Fast Ethereum-Equivalent)

```yaml
# Fastest Type1 configuration
zkevm.executor-strict: false
zkevm.executor-enabled: false
zkevm.disable-virtual-counters: true
zkevm.pessimistic-fork-number: 12
```

#### Sovereign Mode

```yaml
# Independent chain operation
zkevm.executor-strict: false
zkevm.executor-enabled: false
zkevm.disable-virtual-counters: true

# Minimal L1 configuration (or none)
zkevm.l1-rpc-url: ""  # No L1 if truly sovereign
zkevm.da-url: "http://custom-da:8080"  # Custom DA layer
```

#### Hybrid Configuration (Migration Period)

```yaml
# During Type2→Type1 migration
zkevm.executor-urls: "executor:50071"
zkevm.executor-strict: false  # Allow fallback
zkevm.executor-enabled: true
zkevm.pessimistic-fork-number: 12

# Pre-fork: Uses executor
# Post-fork: Falls back to PP
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

- [State Trie Configuration](../configuration/state-trie.md) - SMT vs PMT details
- [zkEVM Flags Reference](../../reference/zkevm-flags.md) - Complete flag documentation
- [L1 Recovery Mode](../operations/l1-recovery.md) - Chain recovery procedures
- [Prover Integration](../integration/prover.md) - Executor and prover setup
- [Architecture Overview](../integration/architecture-overview.md) - System components
- [Data Stream Protocol](../architecture/data-stream-protocol.md) - Sequencer communication
