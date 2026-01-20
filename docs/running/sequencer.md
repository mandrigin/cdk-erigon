# Sequencer Setup

This guide covers setting up cdk-erigon as a sequencer node that produces blocks for a zkEVM network.

## Overview

A sequencer is responsible for:
- Receiving transactions from the mempool
- Ordering and executing transactions
- Producing blocks and batches
- Streaming data to RPC nodes
- Coordinating with ZK provers via executors

**Key characteristics:**
- Block producer: Creates new blocks and batches
- Higher resource requirements than RPC nodes
- Requires executor integration for ZK proof generation
- Critical infrastructure: downtime affects the entire network

## Enabling Sequencer Mode

Sequencer mode is enabled via the `CDK_ERIGON_SEQUENCER` environment variable:

```bash
CDK_ERIGON_SEQUENCER=1 ./build/bin/cdk-erigon --config="./config.yaml"
```

Or with Docker:

```bash
docker run -d \
  -e CDK_ERIGON_SEQUENCER=1 \
  -p 8545:8545 \
  -v ./data:/home/erigon/.local/share/erigon \
  hermeznetwork/cdk-erigon \
  --config="./sequencer.yaml"
```

## Executor Configuration

Sequencers require connection to one or more ZK executors for proof generation.

### Single Executor

```yaml
zkevm.executor-urls: "executor1.example.com:50071"
zkevm.executor-strict: true
```

### Multiple Executors (Round-Robin)

For high availability and load distribution, configure multiple executors as a comma-separated list:

```yaml
zkevm.executor-urls: "executor1.example.com:50071,executor2.example.com:50071,executor3.example.com:50071"
zkevm.executor-strict: true
```

The sequencer uses round-robin to distribute witness verification requests across executors.

### Executor Configuration Options

| Flag | Description | Default |
|------|-------------|---------|
| `zkevm.executor-urls` | Comma-separated list of executor gRPC endpoints | Required |
| `zkevm.executor-strict` | Verify all witnesses with executors | `true` |
| `zkevm.witness-full` | Use full witness mode | `false` |

## Strict Mode

Strict mode (`zkevm.executor-strict: true`) ensures all witnesses are verified by executors before batches are finalized. This is the recommended production setting.

### When to Disable Strict Mode

Disable strict mode **only** for:
- Local development without executors
- Testing sequencer logic in isolation
- Debugging witness generation issues

```yaml
# WARNING: Only for development/testing
zkevm.executor-strict: false
```

**Never disable strict mode in production.** Unverified batches may contain invalid state transitions.

## Configuration Examples

### Example 1: Production Sequencer with Multiple Executors

```yaml
datadir: /data/cdk-erigon-sequencer
chain: hermez-mainnet
http: true
http.addr: 0.0.0.0
http.api: [eth, debug, net, trace, web3, erigon, zkevm]
private.api.addr: localhost:9091

# L2 configuration
zkevm.l2-chain-id: 1101
zkevm.l2-sequencer-rpc-url: https://zkevm-rpc.com

# L1 configuration
zkevm.l1-chain-id: 1
zkevm.l1-rpc-url: https://your-l1-rpc.com
zkevm.l1-first-block: 16896700

# Contract addresses
zkevm.address-sequencer: "0x148Ee7dAF16574cD020aFa34CC658f8F3fbd2800"
zkevm.address-zkevm: "0x519E42c24163192Dca44CD3fBDCEBF6be9130987"
zkevm.address-rollup: "0x5132A183E9F3CB7C848b0AAC5Ae0c4f0491B7aB2"
zkevm.address-ger-manager: "0x580bda1e7A0CFAe92Fa7F6c20A3794F169CE3CFb"

# Executor configuration (production)
zkevm.executor-urls: "executor1.prod.com:50071,executor2.prod.com:50071,executor3.prod.com:50071"
zkevm.executor-strict: true
zkevm.witness-full: false

# Data stream server (for RPC nodes to connect)
zkevm.data-stream-host: "0.0.0.0"
zkevm.data-stream-port: 6900

externalcl: true
```

Start with:
```bash
CDK_ERIGON_SEQUENCER=1 ./build/bin/cdk-erigon --config="./sequencer-prod.yaml"
```

### Example 2: Testnet Sequencer (Cardona)

```yaml
datadir: /data/cdk-erigon-sequencer-cardona
chain: hermez-cardona
http: true
http.addr: 0.0.0.0
http.api: [eth, debug, net, trace, web3, erigon, zkevm]
private.api.addr: localhost:9092

zkevm.l2-chain-id: 2442
zkevm.l2-sequencer-rpc-url: https://rpc.cardona.zkevm-rpc.com/

zkevm.l1-chain-id: 11155111
zkevm.l1-rpc-url: https://rpc.sepolia.org
zkevm.l1-first-block: 4789190

zkevm.address-sequencer: "0x761d53b47334bee6612c0bd1467fb881435375b2"
zkevm.address-zkevm: "0xA13Ddb14437A8F34897131367ad3ca78416d6bCa"
zkevm.address-rollup: "0x32d33d5137a7cffb54c5bf8371172bcec5f310ff"
zkevm.address-ger-manager: "0xAd1490c248c5d3CbAE399Fd529b79B42984277DF"

zkevm.executor-urls: "executor-cardona.example.com:50071"
zkevm.executor-strict: true

zkevm.data-stream-host: "0.0.0.0"
zkevm.data-stream-port: 6900

externalcl: true
```

### Example 3: Development Sequencer (No Executor)

```yaml
datadir: ./dev-data
chain: dynamic-devnet
http: true
http.addr: 127.0.0.1
http.api: [eth, debug, net, trace, web3, erigon, zkevm]
private.api.addr: localhost:9091

zkevm.l2-chain-id: 1001
zkevm.l1-chain-id: 11155111
zkevm.l1-rpc-url: https://rpc.sepolia.org

# WARNING: Development only - no executor verification
zkevm.executor-strict: false

zkevm.data-stream-host: "127.0.0.1"
zkevm.data-stream-port: 6900

externalcl: true
```

### Example 4: High-Availability Sequencer with Load-Balanced Executors

```yaml
datadir: /data/cdk-erigon-ha
chain: hermez-mainnet
http: true
http.addr: 0.0.0.0
http.api: [eth, debug, net, trace, web3, erigon, zkevm]
private.api.addr: localhost:9091

zkevm.l2-chain-id: 1101
zkevm.l1-chain-id: 1
zkevm.l1-rpc-url: https://primary-l1.com,https://backup-l1.com

# 5 executors for high availability
zkevm.executor-urls: "exec1.ha.com:50071,exec2.ha.com:50071,exec3.ha.com:50071,exec4.ha.com:50071,exec5.ha.com:50071"
zkevm.executor-strict: true
zkevm.witness-full: false

zkevm.address-sequencer: "0x148Ee7dAF16574cD020aFa34CC658f8F3fbd2800"
zkevm.address-zkevm: "0x519E42c24163192Dca44CD3fBDCEBF6be9130987"
zkevm.address-rollup: "0x5132A183E9F3CB7C848b0AAC5Ae0c4f0491B7aB2"
zkevm.address-ger-manager: "0x580bda1e7A0CFAe92Fa7F6c20A3794F169CE3CFb"

zkevm.data-stream-host: "0.0.0.0"
zkevm.data-stream-port: 6900

externalcl: true
```

### Example 5: Sequencer with Full Witness Mode

Full witness mode sends complete witness data to executors, useful for debugging:

```yaml
datadir: /data/cdk-erigon-debug
chain: hermez-cardona

zkevm.l2-chain-id: 2442
zkevm.l1-chain-id: 11155111
zkevm.l1-rpc-url: https://rpc.sepolia.org

zkevm.executor-urls: "executor.debug.com:50071"
zkevm.executor-strict: true
zkevm.witness-full: true  # Full witness for debugging

http: true
http.api: [eth, debug, net, trace, web3, erigon, zkevm]
debug.timers: true  # Enable performance timers

externalcl: true
```

### Example 6: Sequencer Rejecting Contract Deployments

Some networks may want to restrict contract deployments:

```yaml
datadir: /data/cdk-erigon-restricted
chain: dynamic-restricted

zkevm.l2-chain-id: 2001

zkevm.executor-urls: "executor.restricted.com:50071"
zkevm.executor-strict: true

# Reject contract deployment transactions
zkevm.reject-smart-contract-deployments: true

http: true
http.api: [eth, net, web3, zkevm]

externalcl: true
```

### Example 7: Sequencer with Custom Gas Pricing

```yaml
datadir: /data/cdk-erigon-custom-gas
chain: dynamic-custom

zkevm.l2-chain-id: 3001

zkevm.executor-urls: "executor.custom.com:50071"
zkevm.executor-strict: true

# Custom gas price configuration
zkevm.default-gas-price: 2000000000    # 2 gwei default
zkevm.max-gas-price: 100000000000      # 100 gwei max
zkevm.gas-price-factor: 0.05           # 5% adjustment factor

http: true
http.api: [eth, debug, net, trace, web3, erigon, zkevm]

externalcl: true
```

### Example 8: Docker Compose Production Sequencer

```yaml
# docker-compose.yml
version: '3.8'

services:
  sequencer:
    image: hermeznetwork/cdk-erigon:latest
    environment:
      - CDK_ERIGON_SEQUENCER=1
    ports:
      - "8545:8545"
      - "8546:8546"  # WebSocket
      - "6900:6900"  # Data stream
    volumes:
      - ./data:/home/erigon/.local/share/erigon
      - ./config:/config
    command: --config="/config/sequencer.yaml"
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 64G
        reservations:
          memory: 32G
```

With sequencer.yaml mounted at `/config/sequencer.yaml`:

```yaml
datadir: /home/erigon/.local/share/erigon
chain: hermez-mainnet
http: true
http.addr: 0.0.0.0
http.api: [eth, debug, net, trace, web3, erigon, zkevm]
ws: true

zkevm.l2-chain-id: 1101
zkevm.l1-chain-id: 1
zkevm.l1-rpc-url: ${L1_RPC_URL}

zkevm.executor-urls: ${EXECUTOR_URLS}
zkevm.executor-strict: true

zkevm.address-sequencer: "0x148Ee7dAF16574cD020aFa34CC658f8F3fbd2800"
zkevm.address-zkevm: "0x519E42c24163192Dca44CD3fBDCEBF6be9130987"
zkevm.address-rollup: "0x5132A183E9F3CB7C848b0AAC5Ae0c4f0491B7aB2"
zkevm.address-ger-manager: "0x580bda1e7A0CFAe92Fa7F6c20A3794F169CE3CFb"

zkevm.data-stream-host: "0.0.0.0"
zkevm.data-stream-port: 6900

externalcl: true
```

Start with:
```bash
L1_RPC_URL=https://your-l1.com EXECUTOR_URLS=exec1:50071,exec2:50071 docker-compose up -d
```

## Sequencer-Specific Flags Reference

| Flag | Type | Default | Description |
|------|------|---------|-------------|
| `zkevm.executor-urls` | string | - | CSV list of executor gRPC endpoints |
| `zkevm.executor-strict` | bool | `true` | Verify witnesses with executors |
| `zkevm.witness-full` | bool | `false` | Use full witness mode |
| `zkevm.reject-smart-contract-deployments` | bool | `false` | Reject contract deployment txs |
| `zkevm.ignore-bad-batches-check` | bool | `false` | **DANGEROUS**: Skip bad batch checks |
| `zkevm.default-gas-price` | int | `1000000000` | Default gas price (wei) |
| `zkevm.max-gas-price` | int | `0` | Max gas price (0 = unlimited) |
| `zkevm.gas-price-factor` | float | varies | Gas price adjustment factor |

## Monitoring

Enable metrics for monitoring sequencer performance:

```yaml
metrics: true
metrics.addr: "0.0.0.0"
metrics.port: 6060

pprof: true
pprof.addr: "0.0.0.0"
pprof.port: 6061
```

## Next Steps

- [Mode Switching](./mode-switching.md) - Switching between RPC and sequencer modes
- [L1 Recovery Mode](./l1-recovery.md) - Recovering a sequencer from L1 data
- [Troubleshooting](../troubleshooting/sequencer-issues.md) - Common sequencer issues
