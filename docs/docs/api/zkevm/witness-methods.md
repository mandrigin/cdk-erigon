---
sidebar_position: 3
title: Witness Methods
description: zkevm witness generation RPC methods
---

# Witness Methods

Methods for generating witnesses for ZK proof generation.

## zkevm_getWitness

Get witness data for a specific block.

### Parameters

1. `QUANTITY` - Block number

### Returns

Witness data for proof generation

### Example

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"zkevm_getWitness","params":["0x100"],"id":1}'
```

---

## zkevm_getBlockRangeWitness

Get witness data for a range of blocks.

### Parameters

1. `QUANTITY` - Start block number
2. `QUANTITY` - End block number

### Returns

Combined witness data for the block range

### Example

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"zkevm_getBlockRangeWitness","params":["0x100","0x110"],"id":1}'
```

---

## zkevm_getBatchWitness

Get witness data for an entire batch.

### Parameters

1. `QUANTITY` - Batch number

### Returns

Witness data for the batch

---

## zkevm_getProverInput

Get full prover input data structure.

### Parameters

1. `QUANTITY` - Batch number

### Returns

Complete input data for ZK prover

### Example

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"zkevm_getProverInput","params":["0x100"],"id":1}'
```

## Next Steps

- [Exit Root Methods](./exit-root-methods) - Bridge data
- [Fork Methods](./fork-methods) - Fork ID queries
