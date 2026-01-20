# L1 Recovery Mode

L1 recovery mode allows a sequencer to rebuild the chain using data from the L1 (Ethereum mainnet or testnet). This is useful for disaster recovery, sequencer migration, or rebuilding state after data loss.

## Overview

In L1 recovery mode, the sequencer:
1. Pulls sequenced batch data from L1 contracts
2. Extracts transactions from `sequenceBatches` events
3. Re-executes transactions to rebuild the chain state
4. Continues from the recovered state once complete

**Use cases:**
- Disaster recovery after sequencer data loss
- Migrating to a new sequencer instance
- Auditing or verifying chain state against L1 data
- Resuming a paused sequencer

## Prerequisites

Before starting L1 recovery:

1. **Fork ID 8+**: L1 recovery mode is **not supported for pre-forkid8 networks**
   - For older networks: sync to forkid8 first, then enable recovery mode

2. **L1 block number**: Identify the first L1 block containing `sequenceBatches` events
   - This is set via `zkevm.l1-sync-start-block`

3. **L1 RPC access**: Reliable L1 RPC with historical event access

4. **Executor connectivity**: Working executor URLs for verification

## Configuration

### Basic L1 Recovery Configuration

```yaml
datadir: /data/cdk-erigon-recovery
chain: hermez-mainnet

# L1 Recovery configuration
zkevm.l1-sync-start-block: 16896700  # First L1 block with sequenceBatches events

# L1 configuration
zkevm.l1-chain-id: 1
zkevm.l1-rpc-url: https://your-l1-rpc.com
zkevm.l1-first-block: 16896700

# Contract addresses
zkevm.address-sequencer: "0x148Ee7dAF16574cD020aFa34CC658f8F3fbd2800"
zkevm.address-zkevm: "0x519E42c24163192Dca44CD3fBDCEBF6be9130987"
zkevm.address-rollup: "0x5132A183E9F3CB7C848b0AAC5Ae0c4f0491B7aB2"
zkevm.address-ger-manager: "0x580bda1e7A0CFAe92Fa7F6c20A3794F169CE3CFb"

# Executor configuration
zkevm.executor-urls: "executor1.example.com:50071,executor2.example.com:50071"
zkevm.executor-strict: true

externalcl: true
```

Start in sequencer mode:

```bash
CDK_ERIGON_SEQUENCER=1 ./build/bin/cdk-erigon --config="./recovery.yaml"
```

## Finding the L1 Sync Start Block

The `zkevm.l1-sync-start-block` must be the first L1 block containing `sequenceBatches` events from the sequencer contract.

### Using Etherscan

1. Go to the sequencer contract on Etherscan
2. Navigate to "Events" tab
3. Filter for `sequenceBatches` events
4. Find the earliest event and note the block number

### Using eth_getLogs

```bash
curl -X POST --data '{
  "jsonrpc":"2.0",
  "method":"eth_getLogs",
  "params":[{
    "fromBlock": "0x101F58C",
    "toBlock": "latest",
    "address": "0x5132A183E9F3CB7C848b0AAC5Ae0c4f0491B7aB2",
    "topics": ["0x303446e6a8cb73c83dff421c0b1d5e5c0b3f42e6a5fdccc0eeb27e6e913e1b3e"]
  }],
  "id":1
}' -H "Content-Type: application/json" https://your-l1-rpc.com
```

## Using sync-limit for Faster Recovery

For large chains, you can use an RPC node to sync most of the state, then switch to L1 recovery mode for the remaining blocks.

### Recovery with sync-limit

**Important:** When using `sync-limit`, you must set it to a batch boundary + 1 block.

Example: If batch 41 ends at block 99, set `sync-limit` to 100:

```yaml
# Step 1: Sync from RPC to a specific point
zkevm.sync-limit: 100  # Block after batch 41 ends
zkevm.l2-datastreamer-url: rpc-node.example.com:6900
```

Then switch to L1 recovery:

```yaml
# Step 2: Continue from L1 data
zkevm.l1-sync-start-block: 16900000  # L1 block corresponding to batch 42
# Remove sync-limit to continue
```

### Step-by-Step sync-limit Recovery

#### Step 1: Find Batch Boundary

Query the RPC node for batch information:

```bash
# Get batch 41 details
curl -X POST --data '{
  "jsonrpc":"2.0",
  "method":"zkevm_getBatchByNumber",
  "params":["0x29", true],
  "id":1
}' http://rpc-node:8545
```

Note the last block number in the batch.

#### Step 2: Sync from RPC

```yaml
datadir: /data/recovery
chain: hermez-mainnet

# Sync from RPC until batch 41
zkevm.sync-limit: 100  # batch 41 ends at block 99
zkevm.l2-datastreamer-url: rpc-node.example.com:6900
```

```bash
./build/bin/cdk-erigon --config="./sync-config.yaml"
```

Wait for sync to reach block 100, then stop the node.

#### Step 3: Switch to L1 Recovery

Update configuration:

```yaml
datadir: /data/recovery
chain: hermez-mainnet

# L1 recovery from batch 42 onwards
zkevm.l1-sync-start-block: 16900000
# Remove sync-limit

zkevm.executor-urls: "executor.example.com:50071"
zkevm.executor-strict: true
```

```bash
CDK_ERIGON_SEQUENCER=1 ./build/bin/cdk-erigon --config="./recovery-config.yaml"
```

## Unwinding Before Recovery

If you need to recover from a specific point after corruption or error, unwind the chain first:

### Using unwind Flag

```bash
# Unwind to block 1000
./build/bin/cdk-erigon --config="./config.yaml" --unwind=1000
```

Then start L1 recovery from the corresponding L1 block.

## Recovery Examples

### Example 1: Full Recovery from Genesis

Recover the entire chain from L1 data:

```yaml
datadir: /data/full-recovery
chain: hermez-mainnet

zkevm.l1-sync-start-block: 16896700  # Genesis L1 block
zkevm.l1-chain-id: 1
zkevm.l1-rpc-url: https://archive-l1-rpc.com

zkevm.address-sequencer: "0x148Ee7dAF16574cD020aFa34CC658f8F3fbd2800"
zkevm.address-zkevm: "0x519E42c24163192Dca44CD3fBDCEBF6be9130987"
zkevm.address-rollup: "0x5132A183E9F3CB7C848b0AAC5Ae0c4f0491B7aB2"
zkevm.address-ger-manager: "0x580bda1e7A0CFAe92Fa7F6c20A3794F169CE3CFb"

zkevm.executor-urls: "executor.example.com:50071"
zkevm.executor-strict: true

externalcl: true
```

```bash
CDK_ERIGON_SEQUENCER=1 ./build/bin/cdk-erigon --config="./full-recovery.yaml"
```

### Example 2: Partial Recovery (from Block 1M)

Recover from a snapshot or partial state:

```yaml
datadir: /data/partial-recovery
chain: hermez-mainnet

# Sync from RPC first
zkevm.sync-limit: 1000001  # Stop after batch containing block 1M
zkevm.l2-datastreamer-url: rpc.example.com:6900
```

After RPC sync completes, update config:

```yaml
datadir: /data/partial-recovery
chain: hermez-mainnet

# Continue from L1
zkevm.l1-sync-start-block: 17500000  # L1 block after block 1M was sequenced
zkevm.l1-chain-id: 1
zkevm.l1-rpc-url: https://l1-rpc.com

zkevm.executor-urls: "executor.example.com:50071"
zkevm.executor-strict: true

externalcl: true
```

### Example 3: Cardona Testnet Recovery

```yaml
datadir: /data/cardona-recovery
chain: hermez-cardona

zkevm.l1-sync-start-block: 4789190
zkevm.l1-chain-id: 11155111
zkevm.l1-rpc-url: https://rpc.sepolia.org

zkevm.l2-chain-id: 2442

zkevm.address-sequencer: "0x761d53b47334bee6612c0bd1467fb881435375b2"
zkevm.address-zkevm: "0xA13Ddb14437A8F34897131367ad3ca78416d6bCa"
zkevm.address-rollup: "0x32d33d5137a7cffb54c5bf8371172bcec5f310ff"
zkevm.address-ger-manager: "0xAd1490c248c5d3CbAE399Fd529b79B42984277DF"

zkevm.executor-urls: "executor-cardona.example.com:50071"
zkevm.executor-strict: true

externalcl: true
```

### Example 4: Recovery with Performance Tuning

For faster recovery on machines with sufficient RAM:

```yaml
datadir: /data/fast-recovery
chain: hermez-mainnet

zkevm.l1-sync-start-block: 16896700
zkevm.l1-chain-id: 1
zkevm.l1-rpc-url: https://fast-l1-rpc.com
zkevm.l1-block-range: 50000  # Larger block range for faster L1 queries

# Use RAM for SMT rebuild
zkevm.smt-regenerate-in-memory: true

zkevm.executor-urls: "exec1.fast.com:50071,exec2.fast.com:50071,exec3.fast.com:50071"
zkevm.executor-strict: true

externalcl: true
```

### Example 5: Recovery After Corruption

If the data directory is corrupted:

```bash
# 1. Backup existing data (optional)
mv /data/cdk-erigon /data/cdk-erigon-backup

# 2. Create fresh directory
mkdir -p /data/cdk-erigon

# 3. Start recovery
CDK_ERIGON_SEQUENCER=1 ./build/bin/cdk-erigon --config="./recovery.yaml"
```

## Important Notes

### Fork ID 8 Requirement

L1 recovery mode requires fork ID 8 or higher. For networks that started before forkid8:

1. Sync using normal RPC mode until forkid8 is reached
2. Then switch to L1 recovery mode if needed

### sync-limit Batch Boundaries

When using `sync-limit`, always set it to exactly batch_end_block + 1:

- **Correct:** Batch 41 ends at block 99 → `sync-limit: 100`
- **Wrong:** Setting to middle of a batch will cause issues

### L1 RPC Requirements

L1 recovery requires substantial L1 RPC access:
- Historical event logs from the start block
- Large `eth_getLogs` queries
- Archive node recommended for full recovery

## Monitoring Recovery Progress

Monitor recovery via logs:

```bash
tail -f /data/cdk-erigon/cdk-erigon.log | grep -E "(L1|batch|recovery)"
```

Or via RPC:

```bash
# Current block
curl -X POST --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
  http://localhost:8545

# Current batch
curl -X POST --data '{"jsonrpc":"2.0","method":"zkevm_batchNumber","params":[],"id":1}' \
  http://localhost:8545
```

## Troubleshooting

### "L1 sync start block too low"

The `zkevm.l1-sync-start-block` is set before the first `sequenceBatches` event.

**Solution:** Find the correct block with the first event.

### Recovery Stuck

If recovery appears stuck:

1. Check L1 RPC connectivity
2. Check executor connectivity
3. Verify L1 block range contains expected events
4. Check logs for specific errors

### "Fork ID not supported"

Recovery mode requires forkid8+.

**Solution:** Sync normally until forkid8, then enable recovery mode.

## Next Steps

- [Mode Switching](./mode-switching.md) - Switching between RPC and sequencer
- [Sequencer Setup](./sequencer.md) - Full sequencer configuration
- [Troubleshooting](../troubleshooting/sync-issues.md) - Common sync issues
