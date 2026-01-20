---
sidebar_position: 1
title: Batch Methods
description: zkevm batch-related RPC methods
---

# Batch Methods

Methods for querying batch information.

## zkevm_batchNumber

Get the current batch number.

### Parameters

None

### Returns

`QUANTITY` - Current batch number

### Example

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"zkevm_batchNumber","params":[],"id":1}'
```

```json
{"jsonrpc":"2.0","id":1,"result":"0x1234"}
```

---

## zkevm_batchNumberByBlockNumber

Get the batch number for a given block.

### Parameters

1. `QUANTITY|TAG` - Block number or tag

### Returns

`QUANTITY` - Batch number containing the block

### Example

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"zkevm_batchNumberByBlockNumber","params":["0x100"],"id":1}'
```

---

## zkevm_getBatchByNumber

Get batch details by number.

### Parameters

1. `QUANTITY` - Batch number
2. `Boolean` - Include transactions

### Returns

Batch object with transactions

### Example

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"zkevm_getBatchByNumber","params":["0x100",true],"id":1}'
```

---

## zkevm_virtualBatchNumber

Get the latest virtual (submitted to L1) batch number.

### Returns

`QUANTITY` - Virtual batch number

---

## zkevm_verifiedBatchNumber

Get the latest verified (ZK-proven) batch number.

### Returns

`QUANTITY` - Verified batch number

---

## zkevm_consolidatedBlockNumber

Get the latest L1-confirmed block number.

### Returns

`QUANTITY` - Consolidated block number

## Next Steps

- [Block Methods](./block-methods) - Block-related methods
- [Witness Methods](./witness-methods) - Proof generation
