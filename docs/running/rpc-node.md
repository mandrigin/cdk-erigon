# RPC Node Setup

This guide covers setting up cdk-erigon as an RPC node that syncs with a remote sequencer via the data stream protocol.

## Overview

An RPC node connects to a sequencer's data stream to receive new blocks and batches. It maintains a local copy of the chain state and serves JSON-RPC requests to clients.

**Key characteristics:**
- Read-only: Does not produce blocks
- Syncs via data stream protocol from a sequencer
- Serves JSON-RPC requests (eth, zkevm, debug, trace namespaces)
- Lower resource requirements than a sequencer

## Prerequisites

- cdk-erigon binary (built or downloaded)
- Data stream URL from your network's sequencer
- L1 RPC endpoint (Ethereum mainnet or Sepolia for testnets)
- Sufficient disk space (500GB+ recommended for mainnet)

## Configuration

### Minimal Configuration

Create a YAML configuration file (e.g., `config.yaml`):

```yaml
# Data directory for chain state
datadir: /data/cdk-erigon

# Network identifier
chain: hermez-mainnet

# Enable HTTP RPC server
http: true
http.addr: 0.0.0.0
http.api: [eth, debug, net, trace, web3, erigon, zkevm]
http.vhosts: any
http.corsdomain: any

# Enable WebSocket
ws: true

# L2 configuration
zkevm.l2-chain-id: 1101
zkevm.l2-sequencer-rpc-url: https://zkevm-rpc.com
zkevm.l2-datastreamer-url: stream.zkevm-rpc.com:6900

# L1 configuration
zkevm.l1-chain-id: 1
zkevm.l1-rpc-url: https://your-l1-rpc.com
zkevm.l1-first-block: 16896700

# Contract addresses (mainnet)
zkevm.address-sequencer: "0x148Ee7dAF16574cD020aFa34CC658f8F3fbd2800"
zkevm.address-zkevm: "0x519E42c24163192Dca44CD3fBDCEBF6be9130987"
zkevm.address-rollup: "0x5132A183E9F3CB7C848b0AAC5Ae0c4f0491B7aB2"
zkevm.address-ger-manager: "0x580bda1e7A0CFAe92Fa7F6c20A3794F169CE3CFb"

# Internal API (change port if running multiple instances)
private.api.addr: localhost:9091

# Required for zkEVM
externalcl: true
```

### Starting the Node

```bash
./build/bin/cdk-erigon --config="./config.yaml"
```

Or using Docker:

```bash
docker run -d \
  -p 8545:8545 \
  -v ./data:/home/erigon/.local/share/erigon \
  hermeznetwork/cdk-erigon \
  --config="./mainnet.yaml" \
  --zkevm.l1-rpc-url=https://your-l1-rpc.com
```

## Data Stream Connection

The data stream is the primary mechanism for syncing an RPC node with the sequencer.

### Configuration Options

| Flag | Description | Example |
|------|-------------|---------|
| `zkevm.l2-datastreamer-url` | Sequencer's data stream endpoint | `stream.zkevm-rpc.com:6900` |
| `zkevm.l2-sequencer-rpc-url` | Sequencer's RPC endpoint (fallback) | `https://zkevm-rpc.com` |

### Connection Flow

1. Node connects to the data stream URL on startup
2. Receives block and batch data in real-time
3. Verifies data against L1 contract state
4. Updates local state and serves RPC requests

### Troubleshooting Connection Issues

If the data stream connection fails:

```bash
# Check connectivity to data stream port
nc -zv stream.zkevm-rpc.com 6900

# Verify your config
grep datastreamer config.yaml
```

## Sync Process

### Initial Sync

On first start, the node performs an initial sync:

1. **L1 sync**: Fetches batch data from L1 contracts starting from `zkevm.l1-first-block`
2. **Data stream sync**: Connects to sequencer and downloads blocks
3. **State rebuild**: Builds the Sparse Merkle Tree (SMT) from block data

Monitor sync progress via RPC:

```bash
curl -X POST --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' \
  -H "Content-Type: application/json" \
  http://localhost:8545
```

### Sync Performance Options

For faster initial sync on machines with sufficient RAM:

```yaml
# Use RAM for SMT rebuild (faster but requires more memory)
zkevm.smt-regenerate-in-memory: true
```

### Sync Limiting

To sync to a specific block height (useful for testing):

```yaml
zkevm.sync-limit: 1000000
```

## Serving Data Stream to Other Nodes

Your RPC node can serve as a data stream source for other nodes:

```yaml
# Enable data stream server
zkevm.data-stream-host: "0.0.0.0"
zkevm.data-stream-port: 6900
```

Other nodes can then connect to your node's data stream:

```yaml
zkevm.l2-datastreamer-url: your-rpc-node.com:6900
```

## Health Checks

### Node Version

```bash
curl -X POST --data '{"jsonrpc":"2.0","method":"web3_clientVersion","params":[],"id":1}' \
  http://localhost:8545
```

### Sync Status

```bash
curl -X POST --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' \
  http://localhost:8545
```

### Health Endpoint

```bash
curl -H "X-ERIGON-HEALTHCHECK: synced" http://localhost:8545
```

Returns HTTP 200 if the node is synced.

## Next Steps

- [Network Configurations](./networks.md) - Specific configurations for mainnet, Cardona, and custom chains
- [Configuration Reference](../configuration/reference.md) - Complete list of configuration options
- [Troubleshooting](../troubleshooting/sync-issues.md) - Common sync issues and solutions
