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
| `--zkevm.l2-datastreamer-max-entrychan` | Max entry channel size for data streamer | `1000` | No |
| `--zkevm.l2-datastreamer-use-tls` | Use TLS for data stream connection | `false` | No |
| `--zkevm.l2-datastreamer-timeout` | Timeout for data stream operations | `60s` | No |
| `--zkevm.l2-short-circuit-to-verified-batch` | Skip ahead to latest verified batch on sync | `false` | No |

## L1 Interaction

| Flag | Description | Default | Required |
|------|-------------|---------|----------|
| `--zkevm.l1-chain-id` | L1 network chain ID | N/A | Yes |
| `--zkevm.l1-rpc-url` | L1 Ethereum RPC URL | N/A | Yes |
| `--zkevm.l1-first-block` | First L1 block to sync from | N/A | Yes |
| `--zkevm.l1-block-range` | Number of L1 blocks to query per request | `10000` | No |
| `--zkevm.l1-query-delay` | Delay between L1 queries (milliseconds) | `500` | No |
| `--zkevm.l1-highest-block-type` | L1 block finality type: `finalized`, `safe`, `latest` | `finalized` | No |
| `--zkevm.l1-no-activity-timeout` | Timeout after which L1 inactivity triggers alert | `0s` (disabled) | No |
| `--zkevm.l1-finalized-block-requirement` | Required finalized blocks behind tip | `64` | No |
| `--zkevm.l1-sync-start-block` | L1 block to start recovery sync from | N/A | No |

## Contract Addresses

| Flag | Description | Default | Required |
|------|-------------|---------|----------|
| `--zkevm.address-zkevm` | zkEVM contract address on L1 | N/A | Yes |
| `--zkevm.address-rollup` | Rollup contract address on L1 | N/A | Depends |
| `--zkevm.address-sequencer` | Sequencer contract address | N/A | Depends |
| `--zkevm.address-admin` | Admin contract address | N/A | No |
| `--zkevm.address-ger-manager` | Global Exit Root manager contract | N/A | Depends |
| `--zkevm.l1-matic-contract-address` | MATIC/POL token contract address | N/A | Yes |
| `--zkevm.l1-rollup-id` | Rollup ID in the rollup manager | N/A | Depends |
| `--zkevm.l1-contract-address-check` | Verify L1 contract addresses | `true` | No |
| `--zkevm.l1-contract-address-retrieve` | Auto-retrieve contract addresses from L1 | `true` | No |

## Data Stream Server (Sequencer Mode)

| Flag | Description | Default |
|------|-------------|---------|
| `--zkevm.data-stream-port` | Data stream server port | `6900` |
| `--zkevm.data-stream-host` | Data stream server host | `0.0.0.0` |
| `--zkevm.data-stream-writeTimeout` | Write timeout for data stream | `5s` |
| `--zkevm.data-stream-inactivity-timeout` | Inactivity timeout | `120s` |
| `--zkevm.datastream-new-block-timeout` | Timeout for new block signal | `10s` |

## Sequencer Configuration

These flags are only relevant when running in sequencer mode (`CDK_ERIGON_SEQUENCER=1`).

| Flag | Description | Default |
|------|-------------|---------|
| `--zkevm.executor-urls` | Comma-separated list of executor gRPC URLs | N/A |
| `--zkevm.executor-enabled` | Enable executor integration | `true` |
| `--zkevm.executor-strict` | Enable strict verification mode | `true` |
| `--zkevm.executor-request-timeout` | Timeout for executor requests | `60s` |
| `--zkevm.executor-max-concurrent-requests` | Max concurrent executor requests | `10` |
| `--zkevm.sequencer-block-seal-time` | Time before sealing a block | `2s` |
| `--zkevm.sequencer-empty-block-seal-time` | Time before sealing an empty block | Same as block-seal-time |
| `--zkevm.sequencer-batch-seal-time` | Time before sealing a batch | `6s` |
| `--zkevm.sequencer-batch-verification-timeout` | Batch verification timeout | `30m` |
| `--zkevm.sequencer-batch-verification-retries` | Batch verification retry count | `3` |
| `--zkevm.sequencer-timeout-on-empty-tx-pool` | Timeout when tx pool is empty | `5s` |
| `--zkevm.sequencer-halt-on-batch-number` | Halt at specific batch number (debug) | `0` (disabled) |
| `--zkevm.sequencer-block-gas-limit` | Block gas limit for sequencing | `30000000` |

## State Management

| Flag | Description | Default |
|------|-------------|---------|
| `--zkevm.rebuild-tree-after` | Rebuild state tree after N blocks | `50000` |
| `--zkevm.increment-tree-always` | Always increment tree (disable rebuild) | `false` |
| `--zkevm.smt-regenerate-in-memory` | Use RAM for SMT regeneration | `false` |
| `--zkevm.witness-full` | Generate full witness data | `false` |
| `--zkevm.witness-memdb-size` | Memory size for witness DB | `4GB` |
| `--zkevm.witness-unwind-limit` | Witness unwind block limit | `100` |

## Sync Control

| Flag | Description | Default |
|------|-------------|---------|
| `--zkevm.sync-limit` | Limit sync to specific block height | `0` (unlimited) |
| `--zkevm.sync-limit-verified-enabled` | Enable sync limit based on verification | `false` |
| `--zkevm.sync-limit-unverified-count` | Max unverified batches ahead of verified | `0` |

## Transaction Pool

| Flag | Description | Default |
|------|-------------|---------|
| `--zkevm.pool-manager-url` | URL for external pool manager | N/A |
| `--zkevm.allow-free-transactions` | Allow transactions with zero gas price | `false` |
| `--zkevm.free-injected-batch` | Free injected batch | `false` |
| `--zkevm.allow-pre-eip155-transactions` | Allow pre-EIP155 transactions | `false` |
| `--zkevm.reject-smart-contract-deployments` | Reject contract deployments | `false` |
| `--zkevm.reject-low-gas-price-transactions` | Reject low gas price transactions | `false` |
| `--zkevm.reject-low-gas-price-tolerance` | Tolerance for low gas price rejection | `0.05` |

## Gas Pricing

| Flag | Description | Default |
|------|-------------|---------|
| `--zkevm.default-gas-price` | Default gas price (wei) | `1000000000` |
| `--zkevm.max-gas-price` | Maximum gas price (wei) | `0` (unlimited) |
| `--zkevm.gas-price-factor` | Gas price multiplier | `1.0` |
| `--zkevm.gas-price-check-frequency` | Frequency of gas price updates | `12s` |
| `--zkevm.gas-price-history-count` | Number of historical gas prices to track | `100` |
| `--zkevm.effective-gas-price-eth-transfer` | Effective gas price ratio for ETH transfers | `1.0` |
| `--zkevm.effective-gas-price-erc20-transfer` | Effective gas price ratio for ERC20 transfers | `1.0` |
| `--zkevm.effective-gas-price-contract-invocation` | Effective gas price ratio for contract calls | `1.0` |
| `--zkevm.effective-gas-price-contract-deployment` | Effective gas price ratio for deployments | `1.0` |

## RPC Configuration

| Flag | Description | Default |
|------|-------------|---------|
| `--zkevm.rpc-get-batch-witness-concurrency-limit` | Max concurrent batch witness requests | `10` |
| `--zkevm.limbo` | Enable limbo mode for pending transactions | `false` |
| `--zkevm.disable-virtual-counters` | Disable virtual counter tracking | `false` |
| `--zkevm.virtual-counters-smt-reduction` | SMT reduction factor for virtual counters | `0.0` |

## Recovery Options

| Flag | Description | Default |
|------|-------------|---------|
| `--zkevm.blob-recovery` | Enable blob recovery mode | `false` |
| `--zkevm.blob-da-url` | Blob DA service URL | N/A |
| `--zkevm.blob-recovery-blob-limit` | Max blobs to recover | `0` (unlimited) |
| `--zkevm.recovery-stop-batch` | Stop recovery at specific batch | `0` (disabled) |

## Debug Options

| Flag | Description | Default |
|------|-------------|---------|
| `--zkevm.debug-timers` | Enable performance timing | `false` |
| `--zkevm.debug-no-sync` | Disable sync (debug only) | `false` |
| `--zkevm.debug-limit` | Debug block limit | `0` |
| `--zkevm.debug-step` | Debug step size | `0` |
| `--zkevm.debug-step-after` | Start debug step after block | `0` |
| `--zkevm.debug-disable-state-root-check` | Skip state root verification | `false` |
| `--zkevm.panic-on-reorg` | Panic on chain reorganization | `false` |
| `--zkevm.ignore-bad-batches-check` | Ignore bad batch checks (dangerous) | `false` |
| `--zkevm.bad-batches` | Comma-separated list of known bad batches | N/A |

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
