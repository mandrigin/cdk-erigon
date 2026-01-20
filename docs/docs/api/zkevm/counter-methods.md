---
sidebar_position: 6
title: Counter Methods
description: zkevm counter estimation RPC methods
---

# Counter Methods

Methods for estimating ZK counter usage.

## zkevm_estimateCounters

Estimate ZK counter usage for a transaction.

### Parameters

1. `Object` - Transaction call object

### Returns

Counter estimation object with various ZK resource metrics

### Example

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc":"2.0",
    "method":"zkevm_estimateCounters",
    "params":[{
      "from": "0x...",
      "to": "0x...",
      "data": "0x..."
    }],
    "id":1
  }'
```

### Response Fields

| Field | Description |
|-------|-------------|
| `gasUsed` | Estimated gas usage |
| `usedSteps` | ZK steps consumed |
| `usedMemory` | Memory consumption |
| `usedKeccakHashes` | Keccak operations |
| `usedPoseidonHashes` | Poseidon operations |
| `usedArithmetics` | Arithmetic operations |
| `usedBinaries` | Binary operations |

---

## zkevm_getBatchCountersByNumber

Get actual counter usage for a batch.

### Parameters

1. `QUANTITY` - Batch number

### Returns

Actual counter values for the batch

### Example

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"zkevm_getBatchCountersByNumber","params":["0x100"],"id":1}'
```

## Next Steps

- [Deprecated Methods](./deprecated) - Deprecated APIs
- [Standard Namespaces](../standard-namespaces) - Ethereum APIs
