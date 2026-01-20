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

### ethers.js

```javascript
import { JsonRpcProvider } from 'ethers';

const provider = new JsonRpcProvider('http://localhost:8545');
const counters = await provider.send('zkevm_estimateCounters', [{
  from: '0x1234567890123456789012345678901234567890',
  to: '0xabcdefabcdefabcdefabcdefabcdefabcdefabcd',
  data: '0x',
}]);
console.log('Estimated counters:', counters);
console.log('Gas used:', counters.gasUsed);
console.log('Steps:', counters.usedSteps);
```

### viem

```typescript
import { createPublicClient, http } from 'viem';
import { zkEvm } from 'viem/chains';

const client = createPublicClient({
  chain: zkEvm,
  transport: http('http://localhost:8545'),
});

const counters = await client.request({
  method: 'zkevm_estimateCounters',
  params: [{
    from: '0x1234567890123456789012345678901234567890',
    to: '0xabcdefabcdefabcdefabcdefabcdefabcdefabcd',
    data: '0x',
  }],
});
console.log('Estimated counters:', counters);
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

### Error Codes

| Code | Message | Description |
|------|---------|-------------|
| -32602 | Invalid params | Invalid transaction object format |
| -32603 | Internal error | Estimation failed or internal failure |
| -32000 | Execution reverted | Transaction would revert |

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

### ethers.js

```javascript
import { JsonRpcProvider } from 'ethers';

const provider = new JsonRpcProvider('http://localhost:8545');
const counters = await provider.send('zkevm_getBatchCountersByNumber', ['0x100']);
console.log('Batch counters:', counters);
```

### viem

```typescript
import { createPublicClient, http } from 'viem';
import { zkEvm } from 'viem/chains';

const client = createPublicClient({
  chain: zkEvm,
  transport: http('http://localhost:8545'),
});

const counters = await client.request({
  method: 'zkevm_getBatchCountersByNumber',
  params: ['0x100'],
});
console.log('Batch counters:', counters);
```

### Error Codes

| Code | Message | Description |
|------|---------|-------------|
| -32602 | Invalid params | Invalid batch number format |
| -32603 | Internal error | Batch not found or internal failure |

## Next Steps

- [Deprecated Methods](./deprecated) - Deprecated APIs
- [Standard Namespaces](../standard-namespaces) - Ethereum APIs
