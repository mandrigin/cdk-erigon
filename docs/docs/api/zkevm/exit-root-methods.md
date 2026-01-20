---
sidebar_position: 4
title: Exit Root Methods
description: zkevm exit root and bridge RPC methods
---

# Exit Root Methods

Methods for querying Global Exit Root (GER) and bridge data.

## zkevm_getLatestGlobalExitRoot

Get the latest Global Exit Root.

### Returns

`DATA` - Latest GER hash

### Example

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"zkevm_getLatestGlobalExitRoot","params":[],"id":1}'
```

---

## zkevm_getExitRootTable

Get the exit root table data.

### Returns

Array of exit root entries

### Example

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"zkevm_getExitRootTable","params":[],"id":1}'
```

---

## zkevm_getExitRootsByGER

Get exit roots by Global Exit Root hash.

### Parameters

1. `DATA` - GER hash

### Returns

Exit root data for the given GER

### Example

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"zkevm_getExitRootsByGER","params":["0x..."],"id":1}'
```

---

## zkevm_getL2BlockInfoTree

Get L2 block info tree data.

### Parameters

1. `QUANTITY` - Block number

### Returns

L2 block info tree data

## Next Steps

- [Fork Methods](./fork-methods) - Fork ID queries
- [Counter Methods](./counter-methods) - ZK counter estimation
