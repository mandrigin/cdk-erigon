# Running a Node

This guide covers how to run cdk-erigon in various configurations: as an RPC node, as a sequencer, or on different networks.

## Table of Contents

- [RPC Node Setup](#rpc-node-setup)
- [Sequencer Setup](#sequencer-setup)
- [zkEVM Mainnet](#zkevm-mainnet)
- [zkEVM Cardona Testnet](#zkevm-cardona-testnet)
- [Custom CDK Chains](#custom-cdk-chains)
- [Mode Switching](#mode-switching)
- [L1 Recovery Mode](#l1-recovery-mode)

---

## RPC Node Setup

An RPC node synchronizes with a remote sequencer via the data stream and provides JSON-RPC endpoints for querying chain state.

### Data Stream Connection

The RPC node connects to a sequencer's data stream to receive new blocks and batches. Configure the data stream connection with:

```yaml
zkevm.l2-datastreamer-url: stream.zkevm-rpc.com:6900
```

Optional TLS and timeout settings:

```yaml
zkevm.l2-datastreamer-use-tls: true
zkevm.l2-datastreamer-timeout: 60s
```

### Sync Process

The sync process involves:
1. Connecting to the L2 data stream to receive block/batch data
2. Querying L1 for rollup verification data
3. Building the local state (Sparse Merkle Tree or Patricia Merkle Trie)

Key sync configuration:

```yaml
# L1 interaction
zkevm.l1-rpc-url: https://rpc.eth.gateway.fm
zkevm.l1-block-range: 20000
zkevm.l1-query-delay: 6000
zkevm.l1-highest-block-type: finalized  # Options: finalized, safe, latest

# L2 sequencer
zkevm.l2-sequencer-rpc-url: https://zkevm-rpc.com
```

### Minimal RPC Node Config

```yaml
datadir: /path/to/datadir
chain: hermez-mainnet
http: true
private.api.addr: localhost:9091

# L2 Configuration
zkevm.l2-chain-id: 1101
zkevm.l2-sequencer-rpc-url: https://zkevm-rpc.com
zkevm.l2-datastreamer-url: stream.zkevm-rpc.com:6900

# L1 Configuration
zkevm.l1-chain-id: 1
zkevm.l1-rpc-url: https://rpc.eth.gateway.fm
zkevm.l1-first-block: 16896700

# Contract Addresses
zkevm.address-sequencer: "0x148Ee7dAF16574cD020aFa34CC658f8F3fbd2800"
zkevm.address-zkevm: "0x519E42c24163192Dca44CD3fBDCEBF6be9130987"
zkevm.address-rollup: "0x5132A183E9F3CB7C848b0AAC5Ae0c4f0491B7aB2"
zkevm.address-ger-manager: "0x580bda1e7A0CFAe92Fa7F6c20A3794F169CE3CFb"

# RPC Settings
externalcl: true
http.api: [eth, debug, net, trace, web3, erigon, zkevm]
http.addr: 0.0.0.0
http.vhosts: any
http.corsdomain: any
ws: true
```

Run with:
```bash
./build/bin/cdk-erigon --config="./myconfig.yaml"
```

---

## Sequencer Setup

A sequencer produces new blocks by ordering transactions from the txpool and executing them against the zkEVM executor.

### Enabling Sequencer Mode

Set the environment variable before starting:

```bash
CDK_ERIGON_SEQUENCER=1 ./build/bin/cdk-erigon --config="./sequencer-config.yaml"
```

### Executor Configuration

The sequencer requires executor URLs for proof verification:

```yaml
zkevm.executor-urls: executor1.example.com:50071,executor2.example.com:50071
zkevm.executor-strict: true
zkevm.executor-request-timeout: 60s
zkevm.executor-max-concurrent-requests: 4
```

### Strict Mode

Strict mode (`zkevm.executor-strict: true`) ensures all batches are verified by the executor before being finalized. This is the default and recommended setting for production.

**When to disable strict mode:**
- Local development without an executor
- Testing scenarios where proof verification is not needed

**Warning:** Running with `executor-strict: false` in production can lead to invalid state transitions.

### Sequencer Configuration Examples

#### Example 1: Production Sequencer with Multiple Executors

```yaml
datadir: /data/sequencer
chain: hermez-mainnet

zkevm.executor-urls: executor1.prod.example.com:50071,executor2.prod.example.com:50071
zkevm.executor-strict: true
zkevm.data-stream-host: 0.0.0.0
zkevm.data-stream-port: 6900
zkevm.sequencer-block-seal-time: 2s
zkevm.sequencer-batch-seal-time: 10m
```

#### Example 2: Single Executor Setup

```yaml
datadir: /data/sequencer
chain: hermez-cardona

zkevm.executor-urls: executor.example.com:50071
zkevm.executor-strict: true
zkevm.data-stream-host: localhost
zkevm.data-stream-port: 6900
```

#### Example 3: Development Without Executor (Non-Strict)

```yaml
datadir: ./dev-datadir
chain: dynamic-devnet

zkevm.executor-strict: false
zkevm.disable-virtual-counters: true
zkevm.data-stream-host: localhost
zkevm.data-stream-port: 6900
```

#### Example 4: Sequencer with Custom Block Timing

```yaml
datadir: /data/sequencer
chain: hermez-mainnet

zkevm.executor-urls: executor.example.com:50071
zkevm.executor-strict: true
zkevm.sequencer-block-seal-time: 500ms
zkevm.sequencer-empty-block-seal-time: 2s
zkevm.sequencer-batch-seal-time: 5m
zkevm.sequencer-batch-verification-timeout: 30s
```

#### Example 5: Sequencer with Gas Price Configuration

```yaml
datadir: /data/sequencer
chain: hermez-mainnet

zkevm.executor-urls: executor.example.com:50071
zkevm.executor-strict: true
zkevm.default-gas-price: 1000000000
zkevm.max-gas-price: 0
zkevm.gas-price-factor: 0.0375
zkevm.effective-gas-price-eth-transfer: 0.34
zkevm.effective-gas-price-erc20-transfer: 0.44
zkevm.effective-gas-price-contract-invocation: 0.54
zkevm.effective-gas-price-contract-deployment: 0.74
```

#### Example 6: Sequencer with Full Witness Mode

```yaml
datadir: /data/sequencer
chain: hermez-mainnet

zkevm.executor-urls: executor.example.com:50071
zkevm.executor-strict: true
zkevm.witness-full: true
zkevm.data-stream-host: 0.0.0.0
zkevm.data-stream-port: 6900
```

#### Example 7: Sequencer Rejecting Contract Deployments

```yaml
datadir: /data/sequencer
chain: hermez-mainnet

zkevm.executor-urls: executor.example.com:50071
zkevm.executor-strict: true
zkevm.reject-smart-contract-deployments: true
```

#### Example 8: Shadow Sequencer for Testing

```yaml
datadir: ./shadow-datadir
chain: hermez-dev

zkevm.executor-urls: executor.example.com:50071
zkevm.executor-strict: true
zkevm.shadow-sequencer: true
zkevm.allow-free-transactions: true
zkevm.allow-pre-eip155-transactions: true
```

---

## zkEVM Mainnet

Polygon zkEVM Mainnet is the production L2 network secured by Ethereum Mainnet.

| Property | Value |
|----------|-------|
| Chain ID | 1101 |
| L1 Network | Ethereum Mainnet |
| L1 Chain ID | 1 |
| Fork ID | 9 |
| RPC URL | https://zkevm-rpc.com |
| Block Explorer | https://zkevm.polygonscan.com |

### L1 RPC Requirements

- Archive node access is **not** required for basic sync
- The L1 RPC should support `eth_getLogs` with reasonable rate limits
- For faster sync, use a dedicated or premium L1 RPC provider

### Mainnet Configuration

```yaml
datadir: /data/mainnet
chain: hermez-mainnet
http: true
private.api.addr: localhost:9091

zkevm.l2-chain-id: 1101
zkevm.l2-sequencer-rpc-url: https://zkevm-rpc.com
zkevm.l2-datastreamer-url: stream.zkevm-rpc.com:6900
zkevm.l1-chain-id: 1
zkevm.l1-rpc-url: https://rpc.eth.gateway.fm

zkevm.address-sequencer: "0x148Ee7dAF16574cD020aFa34CC658f8F3fbd2800"
zkevm.address-zkevm: "0x519E42c24163192Dca44CD3fBDCEBF6be9130987"
zkevm.address-rollup: "0x5132A183E9F3CB7C848b0AAC5Ae0c4f0491B7aB2"
zkevm.address-ger-manager: "0x580bda1e7A0CFAe92Fa7F6c20A3794F169CE3CFb"

zkevm.default-gas-price: 1000000000
zkevm.max-gas-price: 0
zkevm.gas-price-factor: 0.0375

zkevm.l1-rollup-id: 1
zkevm.l1-block-range: 20000
zkevm.l1-query-delay: 6000
zkevm.l1-first-block: 16896700

externalcl: true
http.api: [eth, debug, net, trace, web3, erigon, zkevm]
http.addr: 0.0.0.0
http.vhosts: any
http.corsdomain: any
ws: true
```

### Docker

```bash
docker run -d -p 8545:8545 \
  -v ./cdk-erigon-data:/home/erigon/.local/share/erigon \
  hermeznetwork/cdk-erigon \
  --config="./mainnet.yaml" \
  --zkevm.l1-rpc-url=https://rpc.eth.gateway.fm
```

---

## zkEVM Cardona Testnet

Cardona is the zkEVM testnet secured by Sepolia.

| Property | Value |
|----------|-------|
| Chain ID | 2442 |
| L1 Network | Sepolia |
| L1 Chain ID | 11155111 |
| Fork ID | 9 |
| RPC URL | https://rpc.cardona.zkevm-rpc.com |
| Block Explorer | https://cardona-zkevm.polygonscan.com |

### Cardona Configuration

```yaml
datadir: /data/cardona
chain: hermez-cardona
http: true
private.api.addr: localhost:9092

zkevm.l2-chain-id: 2442
zkevm.l2-sequencer-rpc-url: https://rpc.cardona.zkevm-rpc.com
zkevm.l2-datastreamer-url: datastream.cardona.zkevm-rpc.com:6900
zkevm.l1-chain-id: 11155111
zkevm.l1-rpc-url: https://rpc.sepolia.org

zkevm.address-sequencer: "0x761d53b47334bee6612c0bd1467fb881435375b2"
zkevm.address-zkevm: "0xA13Ddb14437A8F34897131367ad3ca78416d6bCa"
zkevm.address-rollup: "0x32d33d5137a7cffb54c5bf8371172bcec5f310ff"
zkevm.address-ger-manager: "0xAd1490c248c5d3CbAE399Fd529b79B42984277DF"

zkevm.default-gas-price: 1000000000
zkevm.max-gas-price: 0
zkevm.gas-price-factor: 0.12

zkevm.l1-rollup-id: 1
zkevm.l1-block-range: 20000
zkevm.l1-query-delay: 6000
zkevm.l1-first-block: 4789190
txpool.disable: true

externalcl: true
http.api: [eth, debug, net, trace, web3, erigon, zkevm]
http.addr: 0.0.0.0
http.vhosts: any
http.corsdomain: any
ws: true
```

### Docker

```bash
docker run -d -p 8545:8545 \
  -v ./cdk-erigon-data:/home/erigon/.local/share/erigon \
  hermeznetwork/cdk-erigon \
  --config="./cardona.yaml" \
  --zkevm.l1-rpc-url=https://rpc.sepolia.org
```

---

## Custom CDK Chains

For chains other than the built-in networks, use dynamic configuration files.

### Dynamic Config Structure

Dynamic configs require a chain name starting with `dynamic-` (e.g., `dynamic-mynetwork`).

#### Method 1: Separate Config Files

Create three configuration files:

1. **`dynamic-{network}-allocs.json`** - Genesis allocations
2. **`dynamic-{network}-chainspec.json`** - Chain specification
3. **`dynamic-{network}-conf.json`** - Additional configuration

**Example chainspec.json:**

```json
{
  "ChainName": "dynamic-mynetwork",
  "chainId": 12345,
  "consensus": "ethash",
  "homesteadBlock": 0,
  "daoForkBlock": 0,
  "eip150Block": 0,
  "eip155Block": 0,
  "byzantiumBlock": 0,
  "constantinopleBlock": 0,
  "petersburgBlock": 0,
  "istanbulBlock": 0,
  "muirGlacierBlock": 0,
  "berlinBlock": 0,
  "londonBlock": 9999999999999999999999999999999999999999999999999,
  "ethash": {}
}
```

**Example conf.json:**

```json
{
  "root": "0xd6dad0250a1b52d1d03b45e0fcc909444b6389463ae3ec7a5da75c3f53ae21c2",
  "timestamp": 123545,
  "gasLimit": 12345,
  "difficulty": 12345
}
```

**Example allocs.json:** Contains pre-funded accounts and deployed contracts at genesis.

#### Method 2: Union Config File

Create a single combined config file and reference it with:

```yaml
zkevm.genesis-config-path: /path/to/dynamic-mynetwork.json
```

### Finding Contract Addresses

When launching a new CDK network, contract addresses can be found in the deployment output files:

| Config Field | Source File | JSON Key |
|-------------|-------------|----------|
| `zkevm.address-sequencer` | `create_rollup_output.json` | `sequencer` |
| `zkevm.address-zkevm` | `create_rollup_output.json` | `rollupAddress` |
| `zkevm.address-rollup` | `deploy_output.json` | `polygonRollupManagerAddress` |
| `zkevm.address-ger-manager` | `deploy_output.json` | `polygonZkEVMGlobalExitRootAddress` |

### Converting Allocs Format

If you have allocs in Polygon's original format, convert them using:

```bash
go run cmd/hack/allocs/main.go your-allocs-file.json
```

### Running with Dynamic Config

```bash
./build/bin/cdk-erigon --cfg="/path/to/dynamic-mynetwork/dynamic-mynetwork.yaml"
```

For Docker, mount the config directory:

```bash
docker run -d -p 8545:8545 \
  -v ./dynamic-mynetwork:/dynamic-mynetwork \
  -v ./cdk-erigon-data:/home/erigon/.local/share/erigon \
  hermeznetwork/cdk-erigon \
  --cfg="/dynamic-mynetwork/dynamic-mynetwork.yaml"
```

---

## Mode Switching

cdk-erigon supports switching between RPC node and sequencer modes without data loss.

### RPC to Sequencer

1. Stop the RPC node
2. Add sequencer-specific flags to your config:
   ```yaml
   zkevm.executor-urls: executor.example.com:50071
   zkevm.executor-strict: true
   zkevm.data-stream-host: 0.0.0.0
   zkevm.data-stream-port: 6900
   ```
3. Start with sequencer mode enabled:
   ```bash
   CDK_ERIGON_SEQUENCER=1 ./build/bin/cdk-erigon --config="./config.yaml"
   ```

### Sequencer to RPC

1. Stop the sequencer
2. Ensure you have the RPC-specific flags:
   ```yaml
   zkevm.l2-sequencer-rpc-url: https://new-sequencer-rpc.example.com
   zkevm.l2-datastreamer-url: new-sequencer.example.com:6900
   ```
3. Start without the sequencer environment variable:
   ```bash
   ./build/bin/cdk-erigon --config="./config.yaml"
   ```

---

## L1 Recovery Mode

L1 recovery mode allows a sequencer to rebuild the chain using data from L1 when the original sequencer data is unavailable.

### When to Use

- Recovering from sequencer data loss
- Bootstrapping a new sequencer from L1 history
- Auditing chain history against L1 data

### Configuration

Enable L1 recovery with the `zkevm.l1-sync-start-block` flag:

```yaml
zkevm.l1-sync-start-block: 6032365  # First L1 block with sequenceBatches event
```

### Finding the Start Block

Locate the first L1 block containing a `sequenceBatches` event from the sequencer contract. This is the earliest point from which the chain can be recovered.

### Example Configuration

```yaml
datadir: ./recovery-datadir
chain: dynamic-mynetwork

zkevm.l1-sync-start-block: 6032365
zkevm.executor-strict: false
zkevm.disable-virtual-counters: true

zkevm.l1-chain-id: 11155111
zkevm.l1-rpc-url: https://rpc.sepolia.org
zkevm.l1-block-range: 20000
zkevm.l1-query-delay: 6000

zkevm.data-stream-host: 127.0.0.1
zkevm.data-stream-port: 6900

http: true
http.api: [eth, debug, net, trace, web3, erigon, txpool, zkevm]
http.addr: 0.0.0.0
```

### Using with Sync Limit

To speed up recovery when an RPC node is available:

1. Set `zkevm.sync-limit` to sync the node to a specific block first
2. Then enable L1 recovery to continue from that point

**Important:** When using `zkevm.sync-limit`, set it to the first block of the next batch. For example, if batch 41 ends at block 99, set sync limit to 100.

```yaml
zkevm.sync-limit: 100
zkevm.l1-sync-start-block: 6032365
```

### Limitations

- **Pre-ForkID 8 networks:** L1 recovery is not supported. Sync the node to ForkID 8 first, then enable recovery mode.
- **Resequencing:** When resequencing, additional flags may be needed:
  ```yaml
  zkevm.sequencer-resequence: true
  zkevm.sequencer-resequence-strict: true
  ```

### Process

When started in L1 recovery mode:
1. The node pulls batch data from L1 into the cdk-erigon database
2. Execution uses this L1 data instead of waiting for txpool transactions
3. The chain is rebuilt by replaying the L1-recorded sequence
