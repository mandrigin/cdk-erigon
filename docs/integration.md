# Integration

This section covers how cdk-erigon integrates with other components in the Polygon CDK stack, including the cdk-node, provers, bridge service, and local development with Kurtosis.

## CDK Architecture Overview

cdk-erigon is a core component in the Polygon CDK (Chain Development Kit) stack, serving as the execution layer for zkEVM-based Layer 2 chains.

### Component Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              User Transactions                               │
└─────────────────────────────────────────────────────────────────────────────┘
                                       │
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           cdk-erigon RPC Node                                │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐              │
│  │   JSON-RPC API  │  │   Data Stream   │  │  State Storage  │              │
│  │  (eth_, zkevm_) │  │    Consumer     │  │   (MDBX + SMT)  │              │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘              │
└─────────────────────────────────────────────────────────────────────────────┘
                                       │
                    ┌──────────────────┴──────────────────┐
                    │                                      │
                    ▼                                      ▼
┌───────────────────────────────┐      ┌───────────────────────────────────────┐
│     cdk-erigon Sequencer      │      │              cdk-node                  │
│  ┌─────────────────────────┐  │      │  ┌─────────────────────────────────┐  │
│  │    Batch Production     │  │      │  │       Sequence Sender           │  │
│  │    Block Execution      │  │      │  │  - Reads batches from RPC       │  │
│  │    Data Stream Server   │  │      │  │  - Submits to L1 contracts      │  │
│  └─────────────────────────┘  │      │  │  - DAC coordination (validium)  │  │
│  ┌─────────────────────────┐  │      │  └─────────────────────────────────┘  │
│  │   Executor Integration  │──┼──────│  ┌─────────────────────────────────┐  │
│  │   (ZK Proof Support)    │  │      │  │         Aggregator              │  │
│  └─────────────────────────┘  │      │  │  - Batch proof coordination     │  │
└───────────────────────────────┘      │  │  - Prover communication         │  │
                                       │  │  - Proof aggregation            │  │
                    ┌──────────────────│  └─────────────────────────────────┘  │
                    │                  └───────────────────────────────────────┘
                    ▼                                      │
┌───────────────────────────────┐                          │
│        zkEVM Prover           │◄─────────────────────────┘
│  - Witness processing         │
│  - ZK-SNARK proof generation  │
│  - State root verification    │
└───────────────────────────────┘
                    │
                    ▼
┌───────────────────────────────┐      ┌───────────────────────────────────────┐
│          Agglayer             │      │          Bridge Service               │
│  - Cross-chain coordination   │      │  - L1 ↔ L2 asset bridging            │
│  - Pessimistic proof verify   │      │  - Global Exit Root management        │
│  - Settlement to L1           │      │  - Exit root synchronization          │
└───────────────────────────────┘      └───────────────────────────────────────┘
                    │                                      │
                    └──────────────────┬───────────────────┘
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                        Ethereum L1 (Settlement Layer)                        │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐              │
│  │  Rollup Contract│  │    GER Manager  │  │ Bridge Contract │              │
│  │  (PolygonZkEVM) │  │                 │  │                 │              │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Data Flow

The transaction lifecycle in a CDK chain follows these steps:

1. **Transaction Submission**: Users submit transactions to the cdk-erigon RPC node
2. **Sequencing**: The sequencer batches transactions into L2 blocks and batches
3. **Data Streaming**: Batch data is broadcast via the data stream protocol
4. **L1 Submission**: The sequence sender reads batches and submits them to L1 contracts
5. **Proof Generation**: The aggregator coordinates with provers to generate validity proofs
6. **Verification**: Proofs are submitted to L1 contracts for verification
7. **Finalization**: Once verified, the batch state becomes final

### Component Responsibilities

| Component | Responsibility |
|-----------|---------------|
| **cdk-erigon RPC** | Transaction handling, state queries, data stream consumption |
| **cdk-erigon Sequencer** | Block production, batch creation, data stream serving |
| **Sequence Sender** | L1 batch submission, data availability coordination |
| **Aggregator** | Proof aggregation, prover coordination |
| **Prover** | ZK proof generation from witness data |
| **Bridge Service** | Cross-chain messaging, exit root management |
| **Agglayer** | Multi-chain proof verification, settlement |

---

## cdk-node Integration

The cdk-node coordinates the sequence sender and aggregator components that work alongside cdk-erigon.

### Sequence Sender Configuration

The sequence sender reads batches from the cdk-erigon sequencer and submits them to L1 contracts.

**Example 1: Basic Sequence Sender Setup**

cdk-node configuration (`config.toml`):

```toml
[SequenceSender]
WaitPeriodSendSequence = "5s"
LastBatchVirtualizationTimeMaxWaitPeriod = "5s"
MaxTxSizeForL1 = 131072
L2Coinbase = "0xfa3b44587990f97ba8b6ba7e230a5f0e95d14b3d"
PrivateKey = {Path = "/pk/sequencer.keystore", Password = "testonly"}

[SequenceSender.EthTxManager]
FrequencyToMonitorTxs = "1s"
WaitTxToBeMined = "2m"
```

**Example 2: Sequence Sender with cdk-erigon RPC**

The sequence sender connects to cdk-erigon's RPC to read batch data:

```toml
[SequenceSender]
# cdk-erigon RPC endpoint for reading batches
L2RPC = "http://cdk-erigon-rpc:8545"

# L1 RPC for submitting sequences
L1RPC = "http://l1-rpc:8545"

# Rollup contract address
RollupAddress = "0x5132A183E9F3CB7C848b0AAC5Ae0c4f0491B7aB2"

# GER Manager for exit root updates
GERManagerAddress = "0x580bda1e7A0CFAe92Fa7F6c20A3794F169CE3CFb"
```

**Example 3: Aggregator Configuration**

The aggregator coordinates proof generation and submission:

```toml
[Aggregator]
Host = "0.0.0.0"
Port = 50081
RetryTime = "5s"
VerifyProofInterval = "10s"
ProofStatePollingInterval = "5s"
TxProfitabilityCheckerType = "acceptall"

[Aggregator.EthTxManager]
FrequencyToMonitorTxs = "1s"
WaitTxToBeMined = "2m"
PrivateKeys = [{Path = "/pk/aggregator.keystore", Password = "testonly"}]
```

**Example 4: cdk-erigon Configuration for cdk-node Integration**

Ensure cdk-erigon exposes the necessary APIs:

```yaml
# cdk-erigon config
http: true
http.api: [eth, debug, net, trace, web3, erigon, zkevm]
http.addr: 0.0.0.0
http.port: 8545
http.vhosts: any
http.corsdomain: any

# Data stream server for sequence sender
zkevm.data-stream-host: 0.0.0.0
zkevm.data-stream-port: 6900

# Enable sequencer mode
# Set CDK_ERIGON_SEQUENCER=1 environment variable
```

**Example 5: Full CDK Stack Coordination**

Environment variables for coordinating cdk-erigon with cdk-node:

```bash
# cdk-erigon sequencer
export CDK_ERIGON_SEQUENCER=1

# cdk-node connections
export CDK_ERIGON_RPC_URL="http://localhost:8545"
export CDK_ERIGON_DATASTREAM_URL="localhost:6900"
export L1_RPC_URL="https://rpc.sepolia.org"

# Contract addresses (must match across all components)
export ROLLUP_ADDRESS="0x5132A183E9F3CB7C848b0AAC5Ae0c4f0491B7aB2"
export GER_MANAGER_ADDRESS="0x580bda1e7A0CFAe92Fa7F6c20A3794F169CE3CFb"
export BRIDGE_ADDRESS="0x2a3DD3EB832aF982ec71669E178424b10Dca2EDe"
```

---

## Prover Integration

cdk-erigon integrates with external ZK provers for batch verification and witness generation.

### Executor URLs Configuration

**Example 1: Single Executor Setup**

```yaml
# Single executor for development/testing
zkevm.executor-urls: "executor:50071"
zkevm.executor-strict: true
zkevm.executor-enabled: true
```

**Example 2: Multiple Executors for High Availability**

```yaml
# Multiple executors for production (comma-separated)
zkevm.executor-urls: "executor1:50071,executor2:50071,executor3:50071"
zkevm.executor-strict: true
zkevm.executor-enabled: true
zkevm.executor-max-concurrent-requests: 10
zkevm.executor-request-timeout: 60s
```

### Strict Mode

Strict mode ensures all batches are verified by the executor before finalization.

**Example 3: Strict Mode Configuration**

```yaml
# Production configuration with strict verification
zkevm.executor-strict: true     # Require executor verification (default: true)
zkevm.executor-enabled: true    # Enable executor integration (default: true)

# When strict mode is enabled, executor URLs are required
zkevm.executor-urls: "executor:50071"
```

To disable strict mode for testing (not recommended for production):

```yaml
# Development-only: disable strict verification
zkevm.executor-strict: false
zkevm.executor-enabled: false
```

### Witness Generation

Witnesses are generated for ZK proof creation. cdk-erigon provides RPC methods for witness retrieval.

**Example 4: Witness Generation RPC Calls**

```bash
# Get witness for a specific batch
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "zkevm_getBatchWitness",
    "params": [123],
    "id": 1
  }'

# Get witness for a block range
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "zkevm_getBlockRangeWitness",
    "params": [100, 110, true],
    "id": 1
  }'

# Get full prover input for a batch
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "zkevm_getProverInput",
    "params": [123],
    "id": 1
  }'
```

**Example 5: Witness Configuration Options**

```yaml
# Witness generation settings
zkevm.witness-full: false              # Generate full witness (more data, slower)
zkevm.witness-memdb-size: 2GB          # Memory allocation for witness generation
zkevm.witness-unwind-limit: 10000      # Maximum blocks to unwind for witness

# Witness cache (optional, for performance)
zkevm.witness-cache-enable: true
zkevm.witness-cache-purge: false
zkevm.witness-cache-batch-ahead-offset: 10
zkevm.witness-cache-batch-behind-offset: 100

# Contract inclusion for witness (addresses to always include)
zkevm.witness-contract-inclusion: "0x1234...,0x5678..."

# Mock witness for testing (never use in production)
# zkevm.mock-witness-generation: true
```

---

## Bridge Service

The bridge service enables cross-chain asset transfers between L1 and L2 using Global Exit Roots (GER).

### GER Manager Configuration

The Global Exit Root Manager contract tracks exit roots for cross-chain verification.

**Example 1: GER Manager Address Configuration**

```yaml
# zkEVM Mainnet GER Manager
zkevm.address-ger-manager: "0x580bda1e7A0CFAe92Fa7F6c20A3794F169CE3CFb"

# Cardona Testnet GER Manager
zkevm.address-ger-manager: "0xAd1490c248c5d3CbAE399Fd529b79B42984277DF"
```

### Exit Root Queries

**Example 2: Querying Exit Roots via RPC**

```bash
# Get latest Global Exit Root
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "zkevm_getLatestGlobalExitRoot",
    "params": [],
    "id": 1
  }'

# Get exit root table
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "zkevm_getExitRootTable",
    "params": [],
    "id": 1
  }'

# Get exit roots by GER hash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "zkevm_getExitRootsByGER",
    "params": ["0x1234..."],
    "id": 1
  }'
```

### Bridge Contract Addresses

**Example 3: Bridge Contract Configuration**

```yaml
# Core contract addresses for bridge integration
# zkEVM Mainnet
zkevm.address-zkevm: "0x519E42c24163192Dca44CD3fBDCEBF6be9130987"
zkevm.address-rollup: "0x5132A183E9F3CB7C848b0AAC5Ae0c4f0491B7aB2"
zkevm.address-ger-manager: "0x580bda1e7A0CFAe92Fa7F6c20A3794F169CE3CFb"
zkevm.address-sequencer: "0x148Ee7dAF16574cD020aFa34CC658f8F3fbd2800"

# L2 GER Manager (hardcoded in protocol)
# Address: 0xa40D5f56745a118D0906a34E69aeC8C0Db1cB8fA
```

**Example 4: Complete Bridge-Enabled Configuration**

```yaml
datadir: /data/cdk-erigon
chain: hermez-mainnet
http: true

# L1 Configuration
zkevm.l1-chain-id: 1
zkevm.l1-rpc-url: https://rpc.eth.gateway.fm
zkevm.l1-first-block: 16896700
zkevm.l1-block-range: 20000
zkevm.l1-query-delay: 6000

# L2 Configuration
zkevm.l2-chain-id: 1101
zkevm.l2-sequencer-rpc-url: https://zkevm-rpc.com
zkevm.l2-datastreamer-url: stream.zkevm-rpc.com:6900

# Contract Addresses (required for bridge functionality)
zkevm.address-sequencer: "0x148Ee7dAF16574cD020aFa34CC658f8F3fbd2800"
zkevm.address-zkevm: "0x519E42c24163192Dca44CD3fBDCEBF6be9130987"
zkevm.address-rollup: "0x5132A183E9F3CB7C848b0AAC5Ae0c4f0491B7aB2"
zkevm.address-ger-manager: "0x580bda1e7A0CFAe92Fa7F6c20A3794F169CE3CFb"

# L1 Rollup ID (identifies this rollup on L1)
zkevm.l1-rollup-id: 1

# API configuration
http.api: [eth, debug, net, trace, web3, erigon, zkevm]
http.addr: 0.0.0.0
http.vhosts: any
http.corsdomain: any
ws: true
```

---

## Kurtosis Deployment

Kurtosis provides a reproducible environment for deploying a complete CDK stack locally.

### Prerequisites

- Docker Engine 4.27+ (macOS) or Docker on Linux
- Minimum 8GB RAM, 2-core CPU
- Kurtosis CLI installed

Install Kurtosis:

```bash
# macOS
brew install kurtosis-tech/tap/kurtosis-cli

# Linux
echo "deb [trusted=yes] https://apt.fury.io/kurtosis-tech/ /" | \
  sudo tee /etc/apt/sources.list.d/kurtosis.list
sudo apt update
sudo apt install kurtosis-cli
```

### Quick Start

**Example 1: Default Full Execution Proofs Deployment**

```bash
# Deploy the default CDK stack with cdk-erigon
kurtosis run --enclave cdk github.com/0xPolygon/kurtosis-cdk
```

This deploys:
- Local L1 Ethereum node
- cdk-erigon sequencer
- cdk-node (sequence sender + aggregator)
- Mock prover
- Bridge service
- Agglayer

**Example 2: Pessimistic Proof Deployment**

```bash
# Deploy with pessimistic proofs (faster, no ZK prover required)
kurtosis run --enclave cdk \
  --args-file "https://raw.githubusercontent.com/0xPolygon/kurtosis-cdk/refs/heads/main/.github/tests/fork12-pessimistic.yml" \
  github.com/0xPolygon/kurtosis-cdk
```

**Example 3: Custom Configuration File**

Create a `params.yml`:

```yaml
args:
  consensus_contract_type: pessimistic
  sequencer_type: erigon
  erigon_strict_mode: false
  additional_services:
    - blockscout
    - prometheus_grafana
```

Deploy with custom config:

```bash
kurtosis clean --all
kurtosis run --enclave cdk --args-file ./params.yml github.com/0xPolygon/kurtosis-cdk
```

**Example 4: Accessing the Deployed Services**

```bash
# Inspect the deployed enclave
kurtosis enclave inspect cdk

# Export the L2 RPC URL
export ETH_RPC_URL="$(kurtosis port print cdk cdk-erigon-node-001 rpc)"

# Verify the deployment
cast block-number
cast chain-id

# Check a funded test account (pre-funded in test mode)
cast balance --ether 0xE34aaF64b29273B7D567FCFc40544c014EEe9970
```

**Example 5: Monitoring Batch Progression**

```bash
# Latest L2 batch number
cast rpc zkevm_batchNumber

# Latest batch received on L1 (virtualized)
cast rpc zkevm_virtualBatchNumber

# Latest verified batch on L1
cast rpc zkevm_verifiedBatchNumber

# Check consolidated block
cast rpc zkevm_consolidatedBlockNumber
```

**Example 6: Full Development Workflow**

```bash
# 1. Clean any existing deployment
kurtosis clean --all

# 2. Deploy the stack
kurtosis run --enclave cdk github.com/0xPolygon/kurtosis-cdk

# 3. Export RPC URL
export ETH_RPC_URL="$(kurtosis port print cdk cdk-erigon-node-001 rpc)"

# 4. Send a test transaction
cast send --private-key 0x12d7de8621a77640c9241b2595ba78ce443d05e94090365ab3bb5e19df82c625 \
  0x0000000000000000000000000000000000000000 \
  --value 0.001ether

# 5. Verify the transaction was included
cast block-number

# 6. Check batch status
cast rpc zkevm_batchNumber

# 7. View logs
kurtosis service logs cdk cdk-erigon-node-001

# 8. Cleanup when done
kurtosis clean --all
```

### Troubleshooting Kurtosis Deployments

**Resource Issues:**

```bash
# If deployment fails due to resources, increase Docker memory
# Docker Desktop: Settings > Resources > Memory: 16GB recommended

# Clean and retry
kurtosis clean --all
kurtosis run --enclave cdk github.com/0xPolygon/kurtosis-cdk
```

**Service Inspection:**

```bash
# List all services
kurtosis enclave inspect cdk

# Get service logs
kurtosis service logs cdk cdk-erigon-node-001 --follow

# Execute commands in a service
kurtosis service shell cdk cdk-erigon-node-001
```

> **Note:** The Kurtosis deployment uses a mock prover suitable only for local testing. Never use this configuration for production environments.

---

## Next Steps

- [Configuration Reference](../README.md#config) - Full list of configuration options
- [JSON-RPC API](../README.md#zkevm-specific-api-support) - Complete zkevm_* method reference
- [Operations Guide](./operations.md) - Monitoring and troubleshooting
