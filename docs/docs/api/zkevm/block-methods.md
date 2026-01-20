---
sidebar_position: 2
title: Block Methods
description: zkevm block-related RPC methods
---

# Block Methods

Methods for querying block information with zkEVM extensions.

## zkevm_getFullBlockByNumber

Get a block with full zkEVM data.

### Parameters

1. `QUANTITY|TAG` - Block number or tag
2. `Boolean` - Include full transactions

### Returns

Block object with zkEVM-specific fields

### Example

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"zkevm_getFullBlockByNumber","params":["latest",true],"id":1}'
```

---

## zkevm_getFullBlockByHash

Get a block by hash with full zkEVM data.

### Parameters

1. `DATA` - Block hash
2. `Boolean` - Include full transactions

### Returns

Block object with zkEVM-specific fields

---

## zkevm_isBlockConsolidated

Check if a block is confirmed on L1.

### Parameters

1. `QUANTITY` - Block number

### Returns

`Boolean` - True if consolidated

### Example

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"zkevm_isBlockConsolidated","params":["0x100"],"id":1}'
```

---

## zkevm_isBlockVirtualized

Check if a block is submitted to L1.

### Parameters

1. `QUANTITY` - Block number

### Returns

`Boolean` - True if virtualized

---

## zkevm_getLatestDataStreamBlock

Get the latest block from the data stream.

### Returns

Block information from data stream

## Next Steps

- [Witness Methods](./witness-methods) - Proof generation
- [Exit Root Methods](./exit-root-methods) - Bridge data
