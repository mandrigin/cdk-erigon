---
sidebar_position: 5
title: Fork Methods
description: zkevm fork ID RPC methods
---

# Fork Methods

Methods for querying fork ID information.

## zkevm_getForkId

Get the current fork ID.

### Returns

`QUANTITY` - Current fork ID

### Example

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"zkevm_getForkId","params":[],"id":1}'
```

---

## zkevm_getForkById

Get fork details by ID.

### Parameters

1. `QUANTITY` - Fork ID

### Returns

Fork details object

### Example

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"zkevm_getForkById","params":["0x6"],"id":1}'
```

---

## zkevm_getForkIdByBatchNumber

Get fork ID for a specific batch.

### Parameters

1. `QUANTITY` - Batch number

### Returns

`QUANTITY` - Fork ID at that batch

---

## zkevm_getForks

Get all fork information.

### Returns

Array of fork objects

### Example

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"zkevm_getForks","params":[],"id":1}'
```

---

## zkevm_getVersionHistory

Get protocol version history.

### Returns

Array of version entries

## Next Steps

- [Counter Methods](./counter-methods) - ZK counter estimation
- [Deprecated Methods](./deprecated) - Deprecated APIs
