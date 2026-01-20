---
sidebar_position: 6
title: Agglayer Integration
description: Connect cdk-erigon to Polygon's Agglayer for unified cross-chain liquidity
---

# Agglayer Integration

Configure cdk-erigon to connect with Polygon's Agglayer for unified cross-chain liquidity and pessimistic proof verification.

## Overview

Agglayer is Polygon's aggregation layer that provides:
- **Unified Liquidity**: Shared liquidity pool across connected chains
- **Pessimistic Proofs**: Cryptographic verification of cross-chain state transitions
- **Settlement Coordination**: Coordinated settlement to L1 Ethereum
- **Cross-chain Security**: Verification before finalization (no challenge periods)

### Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Agglayer                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │   Pessimistic   │  │    Unified      │  │   Settlement    │  │
│  │   Proof Verify  │  │    Bridge       │  │   to L1         │  │
│  └────────┬────────┘  └────────┬────────┘  └────────┬────────┘  │
└───────────┼────────────────────┼────────────────────┼───────────┘
            │                    │                    │
    ┌───────┴────────┐   ┌───────┴────────┐   ┌──────┴───────┐
    │  CDK Chain A   │   │  CDK Chain B   │   │  CDK Chain C │
    │  (cdk-erigon)  │   │  (cdk-erigon)  │   │  (cdk-erigon)│
    └────────────────┘   └────────────────┘   └──────────────┘
```

## Connection Setup

### Prerequisites

Before connecting to Agglayer:
1. cdk-erigon running in sequencer mode
2. Valid L1 contract addresses (rollup, GER manager)
3. Agglayer endpoint URL (provided by Polygon)
4. Bridge service configured

### Basic Configuration

**Example 1: Agglayer-Enabled cdk-erigon Configuration**

```yaml
datadir: /data/cdk-erigon
chain: cdk-chain

# Enable sequencer mode
# Set CDK_ERIGON_SEQUENCER=1 environment variable

# L1 Configuration (critical for Agglayer)
zkevm.l1-chain-id: 1
zkevm.l1-rpc-url: https://rpc.eth.gateway.fm
# IMPORTANT: For Agglayer networks, set to L1 block where GER Manager was deployed
zkevm.l1-first-block: 16896700
zkevm.l1-block-range: 20000
zkevm.l1-query-delay: 6000

# L2 Configuration
zkevm.l2-chain-id: 2442
zkevm.l2-sequencer-rpc-url: https://your-sequencer-rpc.com
zkevm.l2-datastreamer-url: your-datastreamer:6900

# Contract Addresses (must match Agglayer registration)
zkevm.address-sequencer: "0x148Ee7dAF16574cD020aFa34CC658f8F3fbd2800"
zkevm.address-zkevm: "0x519E42c24163192Dca44CD3fBDCEBF6be9130987"
zkevm.address-rollup: "0x5132A183E9F3CB7C848b0AAC5Ae0c4f0491B7aB2"
zkevm.address-ger-manager: "0x580bda1e7A0CFAe92Fa7F6c20A3794F169CE3CFb"

# L1 Rollup ID (assigned by Agglayer)
zkevm.l1-rollup-id: 1

# API Configuration
http: true
http.api: [eth, debug, net, trace, web3, erigon, zkevm]
http.addr: 0.0.0.0
http.port: 8545
```

## Configuration Options

### Key Parameters for Agglayer

| Parameter | Description | Required |
|-----------|-------------|----------|
| `zkevm.l1-first-block` | L1 block where GER Manager was deployed | Yes |
| `zkevm.address-ger-manager` | Global Exit Root Manager contract | Yes |
| `zkevm.address-rollup` | Rollup contract address on L1 | Yes |
| `zkevm.l1-rollup-id` | Unique ID assigned during Agglayer registration | Yes |

### Global Exit Root Manager

The GER Manager is central to Agglayer integration. It tracks exit roots that enable cross-chain verification.

**Example 2: GER Manager Configuration by Network**

```yaml
# zkEVM Mainnet
zkevm.address-ger-manager: "0x580bda1e7A0CFAe92Fa7F6c20A3794F169CE3CFb"
zkevm.l1-first-block: 16896700

# Cardona Testnet
zkevm.address-ger-manager: "0xAd1490c248c5d3CbAE399Fd529b79B42984277DF"
zkevm.l1-first-block: 4500000

# Custom CDK Chain (values provided during Agglayer onboarding)
zkevm.address-ger-manager: "0xYourGERManagerAddress"
zkevm.l1-first-block: <block-where-ger-manager-deployed>
```

## Pessimistic Proofs

Agglayer uses pessimistic proofs for cross-chain security. Unlike optimistic approaches that assume validity and allow challenges, pessimistic proofs require verification before finalization.

### How Pessimistic Proofs Work

1. **State Submission**: Chain submits state transition to Agglayer
2. **Proof Generation**: Agglayer generates pessimistic proof
3. **Verification**: Proof verified before cross-chain operations proceed
4. **Settlement**: Verified state settled to L1

### Enabling Pessimistic Proof Mode

**Example 3: Kurtosis Deployment with Pessimistic Proofs**

```bash
# Deploy CDK stack with pessimistic proofs (no ZK prover required)
kurtosis run --enclave cdk \
  --args-file "https://raw.githubusercontent.com/0xPolygon/kurtosis-cdk/refs/heads/main/.github/tests/fork12-pessimistic.yml" \
  github.com/0xPolygon/kurtosis-cdk
```

Custom parameters file for pessimistic proof deployment:

```yaml
# params-pessimistic.yml
args:
  consensus_contract_type: pessimistic
  sequencer_type: erigon
  erigon_strict_mode: false
  agglayer_prover_primary_prover: mock-prover  # Use 'sp1-prover' for production
  pp_vkey_hash: "0x00d6e4bdab9cac75a50d58262bb4e60b3107a6b61576c624b6fb7"
```

### Pessimistic vs Full Execution Proofs

| Aspect | Pessimistic Proofs | Full Execution Proofs |
|--------|-------------------|----------------------|
| Prover Required | No (lighter weight) | Yes (ZK prover) |
| Security Model | Verification before finalization | Full ZK validity proof |
| Latency | Lower | Higher |
| Use Case | Cross-chain operations | L2 state verification |

## Cross-Chain Liquidity

Agglayer enables unified liquidity across all connected CDK chains through the Unified Bridge.

### Bridge Integration

The bridge service works with Agglayer to enable:
- Deposits from L1 to any connected L2
- Withdrawals from any L2 to L1
- Cross-L2 transfers via shared liquidity pool

**Example 4: Querying Cross-Chain State via RPC**

```bash
# Get latest Global Exit Root (shared across Agglayer)
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "zkevm_getLatestGlobalExitRoot",
    "params": [],
    "id": 1
  }'

# Get exit root table (all roots for cross-chain verification)
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "zkevm_getExitRootTable",
    "params": [],
    "id": 1
  }'

# Query exit roots by specific GER hash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "zkevm_getExitRootsByGER",
    "params": ["0x1234567890abcdef..."],
    "id": 1
  }'

# Check batch verification status
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "zkevm_verifiedBatchNumber",
    "params": [],
    "id": 1
  }'
```

### Monitoring Cross-Chain Operations

```bash
# Track batch progression through Agglayer
# Latest L2 batch (local)
cast rpc zkevm_batchNumber

# Batches submitted to L1 (virtualized)
cast rpc zkevm_virtualBatchNumber

# Batches verified on L1 (final)
cast rpc zkevm_verifiedBatchNumber

# Consolidated block number
cast rpc zkevm_consolidatedBlockNumber
```

## Sequencer Mode Integration

When running cdk-erigon as a sequencer connected to Agglayer, additional configuration ensures proper coordination.

**Example 5: Full Sequencer Configuration for Agglayer**

```yaml
# cdk-erigon sequencer config for Agglayer integration
datadir: /data/cdk-erigon-sequencer
chain: cdk-chain

# Sequencer mode (set via environment)
# CDK_ERIGON_SEQUENCER=1

# Data stream server (required for Agglayer coordination)
zkevm.data-stream-host: 0.0.0.0
zkevm.data-stream-port: 6900

# L1 Configuration
zkevm.l1-chain-id: 1
zkevm.l1-rpc-url: https://rpc.eth.gateway.fm
zkevm.l1-first-block: 16896700  # GER Manager deployment block
zkevm.l1-block-range: 20000
zkevm.l1-query-delay: 6000
zkevm.l1-highest-block-type: finalized

# L2 Configuration
zkevm.l2-chain-id: 2442

# Contract Addresses (must match Agglayer registration)
zkevm.address-sequencer: "0x148Ee7dAF16574cD020aFa34CC658f8F3fbd2800"
zkevm.address-zkevm: "0x519E42c24163192Dca44CD3fBDCEBF6be9130987"
zkevm.address-rollup: "0x5132A183E9F3CB7C848b0AAC5Ae0c4f0491B7aB2"
zkevm.address-ger-manager: "0x580bda1e7A0CFAe92Fa7F6c20A3794F169CE3CFb"

# Rollup ID (assigned by Agglayer)
zkevm.l1-rollup-id: 1

# Executor configuration (for batch validation)
zkevm.executor-urls: "executor:50071"
zkevm.executor-strict: true
zkevm.executor-enabled: true

# Witness generation (for proof coordination)
zkevm.witness-full: false
zkevm.witness-memdb-size: 2GB

# API Configuration
http: true
http.api: [eth, debug, net, trace, web3, erigon, zkevm]
http.addr: 0.0.0.0
http.port: 8545
http.vhosts: any
http.corsdomain: any
ws: true
```

Environment variables for sequencer operation:

```bash
# Enable sequencer mode
export CDK_ERIGON_SEQUENCER=1

# Start cdk-erigon with Agglayer-ready config
./build/bin/cdk-erigon --config="./sequencer-config.yaml"
```

## Troubleshooting

### Common Issues

**GER Manager Sync Errors**

If you see errors related to Global Exit Root synchronization:

1. Verify `zkevm.l1-first-block` is set to the correct L1 block where the GER Manager was deployed
2. Check L1 RPC connectivity and ensure historical data access
3. Confirm `zkevm.address-ger-manager` matches the deployed contract

**Cross-Chain Verification Failures**

1. Ensure all contract addresses match across cdk-erigon, cdk-node, and Agglayer registration
2. Verify `zkevm.l1-rollup-id` matches the ID assigned during Agglayer onboarding
3. Check that the bridge service is properly configured and running

**Pessimistic Proof Delays**

1. Verify Agglayer prover is operational
2. Check network connectivity to Agglayer endpoints
3. Monitor batch submission timing

## Next Steps

- [Architecture Overview](./architecture-overview) - Full CDK stack architecture
- [Bridge Service](./bridge-service) - Cross-chain asset transfers
- [cdk-node Integration](./cdk-node) - Sequencer coordination
- [Kurtosis](./kurtosis) - Local development with Agglayer
