# zkEVM Configuration Flags

Complete reference for cdk-erigon zkEVM-specific configuration flags.

All zkEVM-specific flags use the `zkevm.` prefix. These flags configure the zkEVM-specific behavior of cdk-erigon.

## Configuration Methods

Each flag can be set via:

1. **CLI flag**: `--zkevm.flag-name=value`
2. **Environment variable**: `ZKEVM_FLAG_NAME=value` (replace dots and hyphens with underscores, uppercase)
3. **YAML config file**: `zkevm.flag-name: value`

### Multi-Format Examples

For the L2 chain ID flag:

```bash
# CLI
cdk-erigon --zkevm.l2-chain-id=1101

# YAML config
zkevm.l2-chain-id: 1101

# TOML config
[zkevm]
l2-chain-id = 1101
```

## Core Configuration

| Flag | Description | Default | Required |
|------|-------------|---------|----------|
| `--zkevm.l2-chain-id` | L2 network chain ID | N/A | Yes |
| `--zkevm.l2-sequencer-rpc-url` | Upstream L2 sequencer RPC endpoint | N/A | Yes (RPC mode) |
| `--zkevm.l2-datastreamer-url` | L2 data stream endpoint (host:port) | N/A | Yes (RPC mode) |
| `--zkevm.l2-datastreamer-max-entrychan` | Max entry channel size for data streamer | `1000000` | No |
| `--zkevm.l2-datastreamer-use-tls` | Use TLS for data stream connection | `false` | No |
| `--zkevm.l2-datastreamer-timeout` | Timeout for data stream operations (0s disables check) | `3s` | No |
| `--zkevm.l2-short-circuit-to-verified-batch` | Skip ahead to latest verified batch on sync | `true` | No |
| `--zkevm.genesis-config-path` | File path for the zk config containing allocs, chainspec, and other zk specific configurations | N/A | No |

## L1 Interaction

| Flag | Description | Default | Required |
|------|-------------|---------|----------|
| `--zkevm.l1-chain-id` | L1 network chain ID | N/A | Yes |
| `--zkevm.l1-rpc-url` | L1 Ethereum RPC URL | N/A | Yes |
| `--zkevm.l1-first-block` | First L1 block to sync from | `0` | Yes |
| `--zkevm.l1-block-range` | Number of L1 blocks to query per request | `20000` | No |
| `--zkevm.l1-query-delay` | Delay between L1 queries (milliseconds) | `6000` | No |
| `--zkevm.l1-highest-block-type` | L1 block finality type: `finalized`, `safe`, `latest` | `finalized` | No |
| `--zkevm.l1-no-activity-timeout` | Duration to wait without L1 activity before stopping the L1 sync stage | `3m` | No |
| `--zkevm.l1-finalized-block-requirement` | The given block must be finalized before sequencer L1 sync continues | `0` | No |
| `--zkevm.l1-sync-start-block` | L1 block to start recovery sync from (enables L1 recovery mode, disables datastream) | `0` | No |
| `--zkevm.l1-info-tree-updates-batch-size` | Size of the batch of L1 info tree updates to retrieve at a time from L2 RPC | `500` | No |
| `--zkevm.l1-info-tree-updates-l2-url` | L2 RPC node URL to initialize the info tree | N/A | No |

## Contract Addresses

| Flag | Description | Default | Required |
|------|-------------|---------|----------|
| `--zkevm.address-zkevm` | zkEVM contract address on L1 | N/A | Yes |
| `--zkevm.address-rollup` | Rollup contract address on L1 | N/A | Depends |
| `--zkevm.address-sequencer` | Sequencer contract address | N/A | Depends |
| `--zkevm.address-admin` | Admin contract address (Deprecated) | N/A | No |
| `--zkevm.address-ger-manager` | Global Exit Root manager contract | N/A | Depends |
| `--zkevm.l1-matic-contract-address` | MATIC/POL token contract address | `0x0` | Yes |
| `--zkevm.l1-rollup-id` | Rollup ID in the rollup manager | `1` | Depends |
| `--zkevm.l1-contract-address-check` | Verify L1 contract addresses | `true` | No |
| `--zkevm.l1-contract-address-retrieve` | Auto-retrieve contract addresses from L1 | `true` | No |

## Data Stream Server (Sequencer Mode)

| Flag | Description | Default |
|------|-------------|---------|
| `--zkevm.data-stream-port` | Data stream server port | `0` |
| `--zkevm.data-stream-host` | Data stream server host | N/A |
| `--zkevm.data-stream-writeTimeout` | TCP write timeout when sending data to a datastream client | `20s` |
| `--zkevm.data-stream-inactivity-timeout` | Inactivity timeout when interacting with a data stream server | `10m` |
| `--zkevm.data-stream-inactivity-check-interval` | Inactivity check interval timeout when interacting with a data stream server | `5m` |
| `--zkevm.datastream-new-block-timeout` | Timeout for new block signal | `500ms` |

## Sequencer Configuration

These flags are only relevant when running in sequencer mode (`CDK_ERIGON_SEQUENCER=1`).

| Flag | Description | Default |
|------|-------------|---------|
| `--zkevm.executor-urls` | Comma-separated list of executor gRPC URLs | N/A |
| `--zkevm.executor-enabled` | Enable executor integration (set to false for limbo-only verification) | `true` |
| `--zkevm.executor-strict` | Require executor URLs to be set (bypass by setting to false) | `true` |
| `--zkevm.executor-request-timeout` | Timeout for executor requests | `60s` |
| `--zkevm.executor-max-concurrent-requests` | Max concurrent executor requests | `1` |
| `--zkevm.executor-payload-output` | Output path for executor payload (serialised requests stored to disk by batch number) | N/A |
| `--zkevm.sequencer-block-seal-time` | Time before sealing a block | `6s` |
| `--zkevm.sequencer-empty-block-seal-time` | Time before sealing an empty block (must be >= block-seal-time) | Same as block-seal-time |
| `--zkevm.sequencer-batch-seal-time` | Time before sealing a batch | `12s` |
| `--zkevm.sequencer-batch-verification-timeout` | Max time for batch verification including retries (0s = infinite) | `30m` |
| `--zkevm.sequencer-batch-verification-retries` | Max attempts to send a batch for verification (-1 = unlimited) | `3` |
| `--zkevm.sequencer-timeout-on-empty-tx-pool` | Timeout before requesting txs from txpool if none found | `5ms` |
| `--zkevm.sequencer-halt-on-batch-number` | Halt at specific batch number (debug) | `0` (disabled) |
| `--zkevm.sequencer-block-gas-limit` | Block gas limit for sequencing (0 = no limit) | `0` |
| `--zkevm.sequencer-resequence` | Automatically resequence unseen batches stored in data stream | `false` |
| `--zkevm.sequencer-resequence-strict` | Strictly resequence the rolledback batches | `true` |
| `--zkevm.sequencer-resequence-reuse-l1-info-index` | Reuse the L1 info index for resequencing | `true` |
| `--zkevm.sequencer-resequence-info-tree-offset` | Info tree offset for resequencing (format: `<index>:<offset>:<expected_ger_hash>`) | N/A |
| `--zkevm.sequencer-decoded-tx-cache-size` | Sequencer decoded transaction cache size | `4096` |
| `--zkevm.sequencer-decoded-tx-cache-ttl` | Sequencer decoded transaction cache TTL | `600s` |

## State Management

| Flag | Description | Default |
|------|-------------|---------|
| `--zkevm.rebuild-tree-after` | Rebuild state tree after this many blocks behind | `10000` |
| `--zkevm.increment-tree-always` | Always increment tree (never rebuild) | `false` |
| `--zkevm.smt-regenerate-in-memory` | Regenerate the SMT in memory (requires a lot of RAM for most chains) | `false` |
| `--zkevm.witness-full` | Enable/disable full witness generation | `false` |
| `--zkevm.witness-memdb-size` | Size of memdb used for witness generation (may fail for older batches if not enough for unwind) | `2GB` |
| `--zkevm.witness-unwind-limit` | Maximum number of blocks the witness generation can unwind | `500000` |

## Sync Control

| Flag | Description | Default |
|------|-------------|---------|
| `--zkevm.sync-limit` | Limit sync to specific block height | `0` (unlimited) |
| `--zkevm.sync-limit-verified-enabled` | Enable sync limit based on verification | `false` |
| `--zkevm.sync-limit-unverified-count` | Max unverified batches ahead of verified | `0` |

## Transaction Pool

| Flag | Description | Default |
|------|-------------|---------|
| `--zkevm.pool-manager-url` | URL for external pool manager (if set, eth_sendRawTransaction redirects there) | N/A |
| `--zkevm.allow-free-transactions` | Allow transactions with zero gas price | `false` |
| `--zkevm.free-injected-batch` | Process the injected batch for free | `true` |
| `--zkevm.allow-pre-eip155-transactions` | Allow pre-EIP155 transactions | `false` |
| `--zkevm.reject-smart-contract-deployments` | Reject contract deployments | `false` |
| `--zkevm.reject-low-gas-price-transactions` | Reject low gas price transactions | `false` |
| `--zkevm.reject-low-gas-price-tolerance` | Tolerance for low gas price rejection (0-1, percentage removed from lowest price) | `0` |
| `--zkevm.bad-tx-allowance` | Max times a counter-exceeding transaction will be attempted before rejection | `2` |
| `--zkevm.bad-tx-store-value` | Max number of bad transactions to store in the database | `200` |
| `--zkevm.bad-tx-purge` | Purge bad transactions from the database on startup | `false` |

## Gas Pricing

| Flag | Description | Default |
|------|-------------|---------|
| `--zkevm.default-gas-price` | Default/minimum gas price (wei) | `10000000` (0.01 gwei) |
| `--zkevm.max-gas-price` | Maximum gas price (wei) | `0` (unlimited) |
| `--zkevm.gas-price-factor` | Factor to apply to L1 gas price for L2 gas price calculation | `1.0` |
| `--zkevm.gas-price-check-frequency` | Frequency to check L1 for latest gas price | `0` (disabled) |
| `--zkevm.gas-price-history-count` | Number of historical gas prices to keep | `1` |
| `--zkevm.effective-gas-price-eth-transfer` | Effective gas price percentage for ETH transfers (0-1) | `1.0` |
| `--zkevm.effective-gas-price-erc20-transfer` | Effective gas price percentage for ERC20 transfers (0-1) | `1.0` |
| `--zkevm.effective-gas-price-contract-invocation` | Effective gas price percentage for contract calls (0-1) | `1.0` |
| `--zkevm.effective-gas-price-contract-deployment` | Effective gas price percentage for deployments (0-1) | `1.0` |

## RPC Configuration

| Flag | Description | Default |
|------|-------------|---------|
| `--zkevm.rpc-get-batch-witness-concurrency-limit` | Max concurrent batch witness requests | `1` |
| `--zkevm.limbo` | Enable limbo processing on batches that failed verification | `false` |
| `--zkevm.disable-virtual-counters` | Disable virtual counters (only effective on sequencer without external executor) | `false` |
| `--zkevm.virtual-counters-smt-reduction` | Multiplier to reduce SMT depth when calculating virtual counters | `0.6` |
| `--zkevm.da-url` | URL of the data availability service | N/A |

## Recovery Options

| Flag | Description | Default |
|------|-------------|---------|
| `--zkevm.blob-recovery` | Enable blob recovery mode | `false` |
| `--zkevm.blob-da-url` | Blob DA service URL | N/A |
| `--zkevm.blob-recovery-blob-limit` | Max blobs to recover | `0` (unlimited) |
| `--zkevm.recovery-stop-batch` | Stop recovery at specific batch | `0` (disabled) |

## Debug Options

Note: Debug flags use the `debug.*` prefix, not `zkevm.debug-*`.

| Flag | Description | Default |
|------|-------------|---------|
| `--debug.timers` | Enable debug timers | `false` |
| `--debug.no-sync` | Disable syncing | `false` |
| `--debug.limit` | Limit the number of blocks to sync | `0` |
| `--debug.step` | Number of blocks to process each run of the stage loop | `0` |
| `--debug.step-after` | Start incrementing by debug.step after this block | `0` |
| `--debug.disable-state-root-check` | Skip state root verification | `false` |
| `--zkevm.panic-on-reorg` | Crash on reorg instead of attempting to recover | `false` |
| `--zkevm.ignore-bad-batches-check` | Ignore bad batch checks (dangerous) | `false` |
| `--zkevm.bad-batches` | Comma-separated list of known bad batch numbers for L1 recovery | N/A |

## Witness Cache

| Flag | Description | Default |
|------|-------------|---------|
| `--zkevm.witness-cache-enable` | Enable witness caching | `false` |
| `--zkevm.witness-cache-purge` | Purge witness cache on startup | `false` |
| `--zkevm.witness-cache-batch-ahead-offset` | Batches ahead to pre-cache | `10` |
| `--zkevm.witness-cache-batch-behind-offset` | Batches behind to keep cached | `10` |
| `--zkevm.witness-contract-inclusion` | Contract addresses to include in witness | N/A |
| `--zkevm.mock-witness-generation` | Use mock witness generation | `false` |

## Advanced Options

| Flag | Description | Default |
|------|-------------|---------|
| `--zkevm.initial-batch-cfg-file` | Path to initial batch configuration | N/A |
| `--zkevm.acl-print-history` | Number of ACL history entries to print | `0` |
| `--zkevm.acl-json-location` | Path to ACL JSON file | N/A |
| `--zkevm.priority-senders-json-location` | Path to priority senders JSON | N/A |
| `--zkevm.info-tree-update-interval` | L1 info tree update interval | `30s` |
| `--zkevm.seal-batch-immediately-on-overflow` | Seal batch immediately on overflow | `false` |
| `--zkevm.always-generate-batch-l2-data` | Always generate batch L2 data | `false` |
| `--zkevm.shadow-sequencer` | Run as shadow sequencer | `false` |
| `--zkevm.honour-chainspec` | Honour chainspec values | `true` |
| `--zkevm.inject-gers` | Inject Global Exit Roots | `false` |
| `--zkevm.skip-smt` | Skip SMT operations | `false` |
| `--zkevm.only-smt-v2` | Use only SMT v2 | `false` |
| `--zkevm.simultaneous-pmt-and-smt` | Build PMT and SMT simultaneously | `false` |
| `--zkevm.force-pmt-interhashes-regen-on-restart` | Force PMT regeneration on restart | `false` |
| `--zkevm.pessimistic-fork-number` | Pessimistic proof fork number | `0` |

## Deprecated Flags

The following flags have been deprecated and should not be used:

| Deprecated Flag | Replacement | Notes |
|-----------------|-------------|-------|
| `--zkevm.gasless` | `--zkevm.allow-free-transactions` | Renamed |
| `--zkevm.rpc-ratelimit` | N/A | Removed |
| `--zkevm.datastream-version` | N/A | Removed |
| `--zkevm.l1-cache-port` | N/A | Removed |
| `--zkevm.l1-cache-enabled` | N/A | Removed |

## See Also

- [CLI Reference](./cli-reference.md) - Main CLI documentation
- [Configuration Reference](../configuration/) - Full configuration examples
- [Getting Started](../getting-started.md) - Quick start guide
