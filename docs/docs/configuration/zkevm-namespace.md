---
sidebar_position: 3
title: zkevm.* Namespace
description: Complete reference for zkevm.* configuration flags
---

# zkevm.* Namespace

Complete reference for zkEVM-specific configuration options.

## Core Configuration

### zkevm.l2-chain-id

L2 network chain ID.

| Format | Example |
|--------|---------|
| CLI | `--zkevm.l2-chain-id=1101` |
| Env | `ZKEVM_L2_CHAIN_ID=1101` |
| YAML | `zkevm.l2-chain-id: 1101` |

### zkevm.l2-sequencer-rpc-url

L2 sequencer RPC endpoint.

| Format | Example |
|--------|---------|
| CLI | `--zkevm.l2-sequencer-rpc-url=https://rpc.example.com` |
| Env | `ZKEVM_L2_SEQUENCER_RPC_URL=https://rpc.example.com` |
| YAML | `zkevm.l2-sequencer-rpc-url: https://rpc.example.com` |

### zkevm.l2-datastreamer-url

Data stream endpoint for synchronization.

| Format | Example |
|--------|---------|
| CLI | `--zkevm.l2-datastreamer-url=stream.example.com:6900` |
| Env | `ZKEVM_L2_DATASTREAMER_URL=stream.example.com:6900` |
| YAML | `zkevm.l2-datastreamer-url: stream.example.com:6900` |

## L1 Interaction

### zkevm.l1-chain-id

L1 network chain ID.

| Format | Example |
|--------|---------|
| CLI | `--zkevm.l1-chain-id=1` |
| Env | `ZKEVM_L1_CHAIN_ID=1` |
| YAML | `zkevm.l1-chain-id: 1` |

### zkevm.l1-rpc-url

L1 Ethereum RPC URL.

| Format | Example |
|--------|---------|
| CLI | `--zkevm.l1-rpc-url=https://eth.example.com` |
| Env | `ZKEVM_L1_RPC_URL=https://eth.example.com` |
| YAML | `zkevm.l1-rpc-url: https://eth.example.com` |

### zkevm.l1-highest-block-type

Block finality type for L1 queries. Options: `finalized`, `safe`, `latest`.

| Format | Example |
|--------|---------|
| CLI | `--zkevm.l1-highest-block-type=finalized` |
| Env | `ZKEVM_L1_HIGHEST_BLOCK_TYPE=finalized` |
| YAML | `zkevm.l1-highest-block-type: finalized` |

## Sequencer Configuration

### zkevm.executor-urls

Comma-separated list of executor URLs.

| Format | Example |
|--------|---------|
| CLI | `--zkevm.executor-urls=exec1:50071,exec2:50071` |
| Env | `ZKEVM_EXECUTOR_URLS=exec1:50071,exec2:50071` |
| YAML | `zkevm.executor-urls: exec1:50071,exec2:50071` |

### zkevm.executor-strict

Strict verification mode (reject invalid transactions).

| Format | Example | Default |
|--------|---------|---------|
| CLI | `--zkevm.executor-strict=true` | `true` |
| Env | `ZKEVM_EXECUTOR_STRICT=true` | `true` |
| YAML | `zkevm.executor-strict: true` | `true` |

## State Management

### zkevm.initial-commitment

State trie type. Options: `smt` (Sparse Merkle Tree), `pmt` (Patricia Merkle Trie).

| Format | Example | Default |
|--------|---------|---------|
| CLI | `--zkevm.initial-commitment=smt` | `smt` |
| Env | `ZKEVM_INITIAL_COMMITMENT=smt` | `smt` |
| YAML | `zkevm.initial-commitment: smt` | `smt` |

### zkevm.smt-regenerate-in-memory

Use RAM for SMT regeneration (faster but memory-intensive).

| Format | Example | Default |
|--------|---------|---------|
| CLI | `--zkevm.smt-regenerate-in-memory=true` | `false` |
| Env | `ZKEVM_SMT_REGENERATE_IN_MEMORY=true` | `false` |
| YAML | `zkevm.smt-regenerate-in-memory: true` | `false` |

## Contract Addresses

### zkevm.address-sequencer

Sequencer contract address on L1.

### zkevm.address-zkevm

zkEVM contract address on L1.

### zkevm.address-rollup

Rollup contract address on L1.

### zkevm.address-ger-manager

Global Exit Root manager contract address.

## Data Stream

### zkevm.data-stream-port

Data stream server port (for sequencer mode).

| Format | Example | Default |
|--------|---------|---------|
| CLI | `--zkevm.data-stream-port=6900` | `6900` |
| Env | `ZKEVM_DATA_STREAM_PORT=6900` | `6900` |
| YAML | `zkevm.data-stream-port: 6900` | `6900` |

## Next Steps

- [Network Presets](./network-presets) - Pre-configured networks
- [State Trie](./state-trie) - SMT vs PMT details
