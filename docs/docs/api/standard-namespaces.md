---
sidebar_position: 3
title: Standard Namespaces
description: Standard Ethereum JSON-RPC namespaces
---

# Standard Namespaces

cdk-erigon supports standard Ethereum JSON-RPC namespaces.

## eth Namespace

Standard Ethereum methods for blocks, transactions, and state.

### Common Methods

| Method | Description |
|--------|-------------|
| `eth_blockNumber` | Get current block number |
| `eth_getBlockByNumber` | Get block by number |
| `eth_getBlockByHash` | Get block by hash |
| `eth_getTransactionByHash` | Get transaction |
| `eth_getBalance` | Get account balance |
| `eth_call` | Execute call |
| `eth_estimateGas` | Estimate gas |
| `eth_sendRawTransaction` | Send transaction |

See [Ethereum JSON-RPC Specification](https://ethereum.org/en/developers/docs/apis/json-rpc/) for complete reference.

## net Namespace

Network information methods.

| Method | Description |
|--------|-------------|
| `net_version` | Get network ID |
| `net_listening` | Check if listening |
| `net_peerCount` | Get peer count |

## web3 Namespace

Web3 utility methods.

| Method | Description |
|--------|-------------|
| `web3_clientVersion` | Get client version |
| `web3_sha3` | Compute Keccak-256 |

## debug Namespace

Debug and diagnostic methods.

| Method | Description |
|--------|-------------|
| `debug_traceTransaction` | Trace transaction execution |
| `debug_traceBlockByNumber` | Trace all transactions in block |

## trace Namespace

Transaction tracing methods.

| Method | Description |
|--------|-------------|
| `trace_transaction` | Get transaction trace |
| `trace_block` | Get block traces |

## txpool Namespace

Transaction pool methods.

| Method | Description |
|--------|-------------|
| `txpool_status` | Get pool status |
| `txpool_content` | Get pool contents |

## Next Steps

- [zkevm Namespace](./zkevm/batch-methods) - zkEVM-specific APIs
- [Configuration](../configuration/methods) - Enable namespaces
