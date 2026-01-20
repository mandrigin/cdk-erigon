# Getting Started with cdk-erigon

## What is cdk-erigon?

cdk-erigon is a fork of [Erigon](https://github.com/erigontech/erigon), an efficiency-focused Ethereum client, optimized for syncing with the Polygon zkEVM network and CDK (Chain Development Kit) chains.

### Background

Erigon (formerly Turbo-Geth) was created as a performance-optimized Ethereum execution client, known for its efficient storage model and fast sync capabilities. cdk-erigon extends Erigon with zkEVM-specific functionality, enabling it to serve as an RPC node or sequencer for Polygon zkEVM networks.

### cdk-erigon vs zkNode

| Feature | cdk-erigon | zkNode |
|---------|------------|--------|
| Architecture | Single binary, staged sync | Multi-component (synchronizer, RPC, etc.) |
| Storage | Flat KV store (MDBX) | PostgreSQL + state manager |
| State commitment | SMT (Sparse Merkle Tree) or PMT | SMT only |
| Sync method | Data stream from sequencer | Data stream from sequencer |
| Resource usage | Lower memory footprint | Higher due to PostgreSQL |

cdk-erigon provides a simpler deployment model with a single binary while maintaining full compatibility with the zkEVM RPC API.

## System Requirements

### Hardware

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| CPU | 4 cores | 8+ cores |
| RAM | 32 GB | 64 GB |
| Storage | 500 GB SSD | 1 TB NVMe SSD |
| Network | 100 Mbps | 1 Gbps |

### Operating System

- **Linux**: Ubuntu 22.04 LTS or newer (required for g++ 12+)
- **macOS**: Supported on both Apple Silicon (ARM64) and Intel (AMD64)

### Dependencies

For building from source:

- **Go 1.24+** (required)
- **GCC 10+** or **Clang**
- **Linux kernel > v4**

For optimal Sparse Merkle Tree performance on x86:

```bash
# Ubuntu/Debian
sudo apt-get install libgtest-dev libomp-dev libgmp-dev

# macOS
brew install libomp gmp
```

Or use the Makefile target:

```bash
make build-libs
```

> **Note**: Apple Silicon will automatically fall back to the iden3 library for Poseidon hashing, which is slower than the vectorized x86 implementation.

## Quick Start

### Option 1: Docker (Recommended)

The fastest way to get started is using the official Docker image.

**Mainnet:**

```bash
docker run -d \
  -p 8545:8545 \
  -v ./cdk-erigon-data:/home/erigon/.local/share/erigon \
  hermeznetwork/cdk-erigon \
  --config="./mainnet.yaml" \
  --zkevm.l1-rpc-url=https://rpc.eth.gateway.fm
```

**Cardona Testnet:**

```bash
docker run -d \
  -p 8545:8545 \
  -v ./cdk-erigon-data:/home/erigon/.local/share/erigon \
  hermeznetwork/cdk-erigon \
  --config="./cardona.yaml" \
  --zkevm.l1-rpc-url=https://rpc.sepolia.org
```

**Using docker-compose:**

```bash
# Mainnet
NETWORK=mainnet L1_RPC_URL=https://rpc.eth.gateway.fm docker-compose -f docker-compose-example.yml up -d

# Cardona testnet
NETWORK=cardona L1_RPC_URL=https://rpc.sepolia.org docker-compose -f docker-compose-example.yml up -d
```

### Option 2: Build from Source

```bash
# Clone the repository
git clone https://github.com/0xPolygonHermez/cdk-erigon.git
cd cdk-erigon

# Build
make cdk-erigon

# Copy and edit a config file
cp hermezconfig-mainnet.yaml.example hermezconfig-mainnet.yaml
# Edit hermezconfig-mainnet.yaml with your settings

# Run
./build/bin/cdk-erigon --config="./hermezconfig-mainnet.yaml"
```

### Verify Sync Status

Check if your node is syncing:

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}'
```

Response when syncing:

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "currentBlock": "0x1234",
    "highestBlock": "0x5678"
  }
}
```

Response when fully synced:

```json
{"jsonrpc":"2.0","id":1,"result":false}
```

### Basic RPC Test

Get the current block number:

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'
```

Get the latest batch number (zkEVM-specific):

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"zkevm_batchNumber","params":[],"id":1}'
```

Check node version:

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"web3_clientVersion","params":[],"id":1}'
```

## Concepts Overview

### Batches vs Blocks

In zkEVM, the relationship between batches and blocks differs from standard Ethereum:

- **L2 Block**: A collection of transactions, similar to Ethereum blocks. Multiple L2 blocks can exist within a single batch.
- **Batch**: A group of L2 blocks that are sequenced together and submitted to L1 for verification. Batches are the unit of ZK proof generation.

```
Batch 1
├── L2 Block 1
│   ├── Transaction 1
│   └── Transaction 2
├── L2 Block 2
│   └── Transaction 3
└── L2 Block 3
    ├── Transaction 4
    └── Transaction 5
```

Batch lifecycle states:
- **Virtual**: Sequenced but not yet submitted to L1
- **Consolidated**: Submitted to L1 but not yet verified
- **Verified**: ZK proof verified on L1

### State Types: SMT vs PMT

cdk-erigon supports two state commitment schemes:

| Type | Full Name | Description |
|------|-----------|-------------|
| **SMT** | Sparse Merkle Tree | Default for zkEVM. Uses Poseidon hash function, optimized for ZK circuits. |
| **PMT** | Patricia Merkle Trie | Standard Ethereum state trie. Used for EVM-compatible chains. |

Configure via `zkevm.initial-commitment` (must be set from genesis):

```yaml
zkevm.initial-commitment: smt  # or "pmt"
```

### Operational Modes

cdk-erigon operates in two modes:

1. **RPC Node** (default): Syncs from a remote sequencer via data stream, serves RPC requests.

2. **Sequencer**: Produces new batches and blocks. Enable with:
   ```bash
   CDK_ERIGON_SEQUENCER=1 ./build/bin/cdk-erigon --config="./config.yaml"
   ```

You can migrate between modes by changing the environment variable and restarting.

### Fork IDs

Fork IDs represent protocol upgrades in zkEVM. Each fork may change execution semantics, data structures, or proof systems:

| Fork ID | Name | Notes |
|---------|------|-------|
| 4 | Blueberry | Early fork |
| 5 | Dragonfruit | Added EffectiveGasPricePercentage |
| 6 | Incaberry | Pre-L1InfoTree |
| 7 | Etrog | Introduced L1InfoTree, BlockInfoRoot |
| 8 | Elderberry | Current production fork |
| 9 | Elderberry 2 | Latest fork |

Current network support:
- **zkEVM Mainnet**: Fork ID 9
- **zkEVM Cardona**: Fork ID 9
- **CDK Chains**: Fork ID 9+ (beta support)

Query the current fork:

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"zkevm_getForkId","params":[],"id":1}'
```

## Next Steps

- [Configuration Reference](../README.md#config) - Full list of configuration options
- [zkEVM API Methods](../README.md#zkevm-specific-api-support) - zkEVM-specific RPC endpoints
- [Dynamic Chain Configuration](../README.md#dynamic-chain-configuration) - Running custom CDK chains
- [Troubleshooting and FAQ](troubleshooting.md) - Common issues and solutions
