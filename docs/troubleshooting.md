# Troubleshooting and FAQ

This guide covers common issues encountered when running cdk-erigon and provides solutions for resolving them.

## Sync Issues

### SMT Rebuild Triggered

**Symptom**: The node logs show "Regeneration trie hashes started" and sync speed drops significantly.

**Cause**: When a node falls behind the network significantly, cdk-erigon triggers a full Sparse Merkle Tree (SMT) rebuild. This is computationally expensive and can take considerable time on longer chains.

**Solution**:

1. Allow the rebuild to complete. Progress is logged periodically:
   ```
   [stage] SMT regenerate progress: 50000/100000 (50.00%)
   ```

2. To prevent future rebuilds, ensure your node maintains stable connectivity to the data stream and has sufficient resources to keep up with the network.

3. For faster rebuilds, enable in-memory regeneration if you have sufficient RAM (64GB+ recommended):
   ```yaml
   zkevm.smt-regenerate-in-memory: true
   ```
   **Warning**: This can cause OOM kills on machines with insufficient RAM.

### Data Stream Disconnection

**Symptom**: Logs show repeated messages like:
```
[Datastream client] Error reading packet
[Datastream client] Last error detected, trying to reconnect
```

**Cause**: The connection to the sequencer's data stream was interrupted. This can occur due to network issues, sequencer restarts, or rate limiting.

**Solution**:

1. Verify the data stream URL is correct in your configuration:
   ```yaml
   zkevm.l2-datastreamer-url: "datastream.zkevm-rpc.com:6900"
   ```

2. Check network connectivity to the data stream endpoint:
   ```bash
   nc -zv datastream.zkevm-rpc.com 6900
   ```

3. The client will automatically attempt to reconnect. If disconnections are frequent, check if your IP is being rate-limited by the sequencer.

4. Consider running your own sequencer or using a dedicated data stream endpoint for high-availability setups.

### Node Falling Behind

**Symptom**: `eth_syncing` returns a growing gap between `currentBlock` and `highestBlock`, or the node cannot keep pace with new blocks.

**Cause**: Insufficient system resources (CPU, RAM, or disk I/O) or slow L1 RPC responses.

**Solution**:

1. Check system resource utilization:
   ```bash
   htop  # CPU and memory
   iostat -x 1  # Disk I/O
   ```

2. Ensure you meet minimum requirements: 4 cores, 32GB RAM, SSD storage.

3. For persistent issues, consider:
   - Upgrading to NVMe storage
   - Increasing RAM to 64GB
   - Using a faster L1 RPC provider
   - Enabling `zkevm.smt-regenerate-in-memory: true` if RAM permits

4. Monitor sync progress:
   ```bash
   curl -X POST http://localhost:8545 \
     -H "Content-Type: application/json" \
     -d '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}'
   ```

## Memory Issues

### OOM (Out of Memory) Prevention

**Symptom**: The cdk-erigon process is killed by the kernel OOM killer, or the system becomes unresponsive.

**Cause**: Memory consumption exceeds available system RAM, often during SMT operations or when processing large batches.

**Solution**:

1. Check current memory usage:
   ```bash
   free -h
   ps aux | grep cdk-erigon
   ```

2. If using `zkevm.smt-regenerate-in-memory: true`, disable it for machines with less than 64GB RAM:
   ```yaml
   zkevm.smt-regenerate-in-memory: false
   ```

3. Avoid running large batch RPC requests (e.g., `eth_getLogs` with wide block ranges) as these cannot use streaming and may cause large allocations.

4. Configure system swap space as a safety buffer (though not a performance solution):
   ```bash
   sudo swapon --show
   ```

5. Monitor memory usage over time and set appropriate container limits if using Docker.

### SMT In-Memory Regeneration

**Symptom**: Initial sync is very slow, taking days to complete.

**Cause**: By default, SMT regeneration uses disk storage which is slower than RAM.

**Solution**:

1. If your machine has sufficient RAM (64GB+), enable in-memory regeneration:
   ```yaml
   zkevm.smt-regenerate-in-memory: true
   ```

2. Before enabling, verify available memory:
   ```bash
   free -h
   ```

3. On x86 systems, ensure the optimized Poseidon libraries are installed:
   ```bash
   make build-libs
   ```
   Apple Silicon will automatically use the slower iden3 library.

4. Monitor memory during regeneration and be prepared to restart with the flag disabled if OOM occurs.

## L1 RPC Issues

### Rate Limiting

**Symptom**: L1 sync stalls or logs show errors when fetching L1 data. Responses may include HTTP 429 errors.

**Cause**: Public L1 RPC endpoints often have rate limits that can be exceeded during initial sync or high-activity periods.

**Solution**:

1. Use a dedicated L1 RPC provider with higher rate limits:
   ```yaml
   zkevm.l1-rpc-url: "https://your-dedicated-eth-rpc.com"
   ```

2. Consider running your own L1 execution client (Geth, Erigon, etc.) for unlimited access.

3. Use the L1 cache feature to reduce redundant requests (enabled by default):
   ```yaml
   zkevm.l1-cache-enabled: true
   zkevm.l1-cache-port: 6969
   ```

4. For initial sync, temporarily use multiple L1 RPC endpoints by leveraging another cdk-erigon node's L1 cache:
   ```yaml
   zkevm.l1-rpc-url: "http://myerigonnode:6969?endpoint=http%3A%2F%2Feth-rpc.com&chainid=2440"
   ```

### Provider Selection

**Symptom**: Inconsistent sync behavior, timeouts, or data availability issues with L1.

**Cause**: Not all L1 RPC providers support the same features or have the same reliability.

**Solution**:

1. Recommended providers for L1 connectivity:
   - **Mainnet**: Infura, Alchemy, QuickNode, or self-hosted Ethereum clients
   - **Sepolia** (for Cardona testnet): Public Sepolia RPCs or dedicated providers

2. Verify provider connectivity:
   ```bash
   curl -X POST https://your-l1-rpc.com \
     -H "Content-Type: application/json" \
     -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'
   ```

3. Ensure the provider supports the `eth_getLogs` method with historical data access for the required block ranges.

4. For AggLayer networks, ensure `zkevm.l1-first-block` is set to the L1 block where the GER Manager contract was deployed.

### L1 Highest Block Type

**Symptom**: Sync issues related to L1 block finality, especially on testnets or during network instability.

**Cause**: The default `finalized` block type may not be available or may lag significantly on some L1 networks.

**Solution**:

1. Configure the L1 block type based on your requirements:
   ```yaml
   # Default - most secure, waits for L1 finality
   zkevm.l1-highest-block-type: "finalized"

   # Alternative - uses safe blocks, slightly faster
   zkevm.l1-highest-block-type: "safe"

   # Fastest but least secure - uses latest blocks
   zkevm.l1-highest-block-type: "latest"
   ```

2. For testnets where finality may be slow or inconsistent, `safe` or `latest` may provide better sync performance.

3. For production mainnet nodes, `finalized` is recommended for maximum security.

4. Check L1 finality status:
   ```bash
   curl -X POST https://your-l1-rpc.com \
     -H "Content-Type: application/json" \
     -d '{"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["finalized", false],"id":1}'
   ```

## Log Interpretation

### SMT Regeneration Progress

**Log examples**:
```
INFO [stage] Regeneration trie hashes started
INFO [stage] SMT regenerate progress: 25000/100000 (25.00%)
INFO [stage] SMT2 starting new
INFO [stage] SMT2 finished new time=5m30s
INFO [stage] Regeneration ended
```

**Interpretation**:
- `Regeneration trie hashes started`: Full SMT rebuild has been triggered
- `SMT regenerate progress`: Shows current progress (processed/total entries and percentage)
- `SMT2 starting/finished`: Indicates the optimized SMT v2 algorithm is processing
- `time=` values show how long each phase took

**Action**: These are informational messages. Allow the process to complete. Long times are normal for large chains.

### Data Stream Client Messages

**Log examples**:
```
INFO [Datastream client] Error reading packet err="connection reset"
INFO [Datastream client] Last error detected, trying to reconnect
INFO [Datastream client] Error reading result entry err="EOF"
```

**Interpretation**:
- `Error reading packet`: Connection to data stream was interrupted
- `trying to reconnect`: Client is automatically attempting reconnection
- `EOF`: The stream ended unexpectedly, often due to sequencer restart

**Action**: These indicate network issues with the data stream. The client handles reconnection automatically. If frequent, check your network connectivity and data stream URL.

### Debug Timers

**Log examples** (when `debug.timers: true`):
```
INFO [stage] Witness generation time=2.5s batch=1234
INFO [stage] Block execution time=150ms block=5678
```

**Interpretation**: Debug timers show performance metrics for various operations:
- Witness generation time per batch
- Block execution time
- SMT operation timing

**Action**: Use these to identify performance bottlenecks. High times may indicate resource constraints or complex transactions.

To enable:
```yaml
debug.timers: true
```

### Stage Progress Messages

**Log examples**:
```
INFO [1/15 Headers] Processed headers=1000 blk/sec=500
INFO [5/15 Execution] Executed blocks=500 txs=2500 gas=125000000
INFO [8/15 IntermediateHashes] Computing intermediate hashes from=1000 to=1500
```

**Interpretation**: cdk-erigon uses staged sync with 15 stages. Each stage logs its progress:
- `Headers`: Downloading and validating block headers
- `Execution`: Executing transactions and updating state
- `IntermediateHashes`: Computing SMT hashes

**Action**: Monitor stage progress to understand sync status. Slow stages may indicate specific bottlenecks (e.g., slow IntermediateHashes suggests SMT performance issues).

## Frequently Asked Questions

### General

**Q: What is the difference between cdk-erigon and zkNode?**

A: cdk-erigon is a single-binary solution using a flat KV store (MDBX), while zkNode is a multi-component architecture using PostgreSQL. cdk-erigon typically has lower resource usage and simpler deployment.

**Q: Which networks does cdk-erigon support?**

A: Full support for zkEVM Cardona testnet, beta support for zkEVM mainnet, and beta support for CDK chains (forkid.9 and above).

**Q: Can I run cdk-erigon on Apple Silicon?**

A: Yes, both Apple Silicon (ARM64) and AMD64 are supported. Note that Apple Silicon will use a slower Poseidon library, resulting in reduced SMT performance.

### Configuration

**Q: What are the minimum hardware requirements?**

A: At minimum: 4-core CPU, 32GB RAM, 500GB SSD. Recommended: 8+ cores, 64GB RAM, 1TB NVMe SSD.

**Q: How do I enable the zkevm API namespace?**

A: Add 'zkevm' to the http.api configuration:
```yaml
http.api: ["eth", "net", "web3", "zkevm"]
```

**Q: Can I change the state commitment type after syncing?**

A: No. The `zkevm.initial-commitment` setting (SMT or PMT) must be set from genesis and cannot be changed after the node has started syncing.

### Sync and Performance

**Q: How long does initial sync take?**

A: Initial sync time varies significantly based on chain length, hardware, and L1 RPC speed. Enable `debug.timers: true` to monitor progress.

**Q: Why does my node keep triggering SMT rebuilds?**

A: SMT rebuilds occur when the node falls significantly behind the network. Ensure adequate resources and stable connectivity to prevent this.

**Q: How can I speed up initial sync?**

A:
1. Use fast NVMe storage
2. Enable `zkevm.smt-regenerate-in-memory: true` if RAM permits (64GB+)
3. Use a dedicated L1 RPC with high rate limits
4. Ensure optimal network connectivity to the data stream

### Operations

**Q: How do I check if my node is synced?**

A: Query the sync status:
```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}'
```
Returns `false` when fully synced.

**Q: How do I switch from RPC mode to sequencer mode?**

A: Stop the node, set the environment variable `CDK_ERIGON_SEQUENCER=1`, and restart. Ensure sequencer-specific flags are configured.

**Q: How do I check the current fork ID?**

A:
```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"zkevm_getForkId","params":[],"id":1}'
```

**Q: What is the difference between virtual, consolidated, and verified batches?**

A:
- **Virtual**: Sequenced but not yet submitted to L1
- **Consolidated**: Submitted to L1 but not yet verified
- **Verified**: ZK proof verified on L1

Query batch status:
```bash
# Latest batch (includes virtual)
curl -X POST http://localhost:8545 -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"zkevm_batchNumber","params":[],"id":1}'

# Latest verified batch
curl -X POST http://localhost:8545 -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"zkevm_verifiedBatchNumber","params":[],"id":1}'
```

**Q: How do I run a custom CDK chain?**

A: Use dynamic configuration by:
1. Naming your chain starting with `dynamic-` (e.g., `dynamic-mynetwork`)
2. Creating config files: `dynamic-{network}-allocs.json`, `dynamic-{network}-chainspec.json`, `dynamic-{network}-conf.json`
3. Running with `--config="/path/to/dynamic-mynetwork.yaml"`

See the [Dynamic Chain Configuration](../README.md#dynamic-chain-configuration) section for details.

**Q: Where can I find more detailed documentation?**

A: Visit [https://docs.gateway.fm/cdk-erigon/](https://docs.gateway.fm/cdk-erigon/) for comprehensive documentation.
