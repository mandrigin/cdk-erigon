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

### ethers.js

```javascript
import { JsonRpcProvider } from 'ethers';

const provider = new JsonRpcProvider('http://localhost:8545');
const batchNumber = await provider.send('zkevm_batchNumber', []);
console.log('Current batch:', parseInt(batchNumber, 16));
```

### viem

```typescript
import { createPublicClient, http } from 'viem';
import { zkEvm } from 'viem/chains';

const client = createPublicClient({
  chain: zkEvm,
  transport: http('http://localhost:8545'),
});

const batchNumber = await client.request({
  method: 'zkevm_batchNumber',
  params: [],
});
console.log('Current batch:', parseInt(batchNumber, 16));
```

### Error Codes

| Code | Message | Description |
|------|---------|-------------|
| -32603 | Internal error | Node sync in progress or internal failure |

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

### ethers.js

```javascript
import { JsonRpcProvider } from 'ethers';

const provider = new JsonRpcProvider('http://localhost:8545');
const batchNumber = await provider.send('zkevm_batchNumberByBlockNumber', ['0x100']);
console.log('Batch number:', parseInt(batchNumber, 16));
```

### viem

```typescript
import { createPublicClient, http } from 'viem';
import { zkEvm } from 'viem/chains';

const client = createPublicClient({
  chain: zkEvm,
  transport: http('http://localhost:8545'),
});

const batchNumber = await client.request({
  method: 'zkevm_batchNumberByBlockNumber',
  params: ['0x100'],
});
console.log('Batch number:', parseInt(batchNumber, 16));
```

### Error Codes

| Code | Message | Description |
|------|---------|-------------|
| -32602 | Invalid params | Invalid block number format |
| -32603 | Internal error | Block not found or internal failure |

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

### ethers.js

```javascript
import { JsonRpcProvider } from 'ethers';

const provider = new JsonRpcProvider('http://localhost:8545');
const batch = await provider.send('zkevm_getBatchByNumber', ['0x100', true]);
console.log('Batch:', batch);
console.log('Transactions:', batch.transactions.length);
```

### viem

```typescript
import { createPublicClient, http } from 'viem';
import { zkEvm } from 'viem/chains';

const client = createPublicClient({
  chain: zkEvm,
  transport: http('http://localhost:8545'),
});

const batch = await client.request({
  method: 'zkevm_getBatchByNumber',
  params: ['0x100', true],
});
console.log('Batch:', batch);
```

### Error Codes

| Code | Message | Description |
|------|---------|-------------|
| -32602 | Invalid params | Invalid batch number or boolean format |
| -32603 | Internal error | Batch not found or internal failure |

---

## zkevm_virtualBatchNumber

Get the latest virtual (submitted to L1) batch number.

### Returns

`QUANTITY` - Virtual batch number

### Example

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"zkevm_virtualBatchNumber","params":[],"id":1}'
```

### ethers.js

```javascript
import { JsonRpcProvider } from 'ethers';

const provider = new JsonRpcProvider('http://localhost:8545');
const virtualBatch = await provider.send('zkevm_virtualBatchNumber', []);
console.log('Virtual batch:', parseInt(virtualBatch, 16));
```

### viem

```typescript
import { createPublicClient, http } from 'viem';
import { zkEvm } from 'viem/chains';

const client = createPublicClient({
  chain: zkEvm,
  transport: http('http://localhost:8545'),
});

const virtualBatch = await client.request({
  method: 'zkevm_virtualBatchNumber',
  params: [],
});
console.log('Virtual batch:', parseInt(virtualBatch, 16));
```

### Error Codes

| Code | Message | Description |
|------|---------|-------------|
| -32603 | Internal error | Node sync in progress or internal failure |

---

## zkevm_verifiedBatchNumber

Get the latest verified (ZK-proven) batch number.

### Returns

`QUANTITY` - Verified batch number

### Example

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"zkevm_verifiedBatchNumber","params":[],"id":1}'
```

### ethers.js

```javascript
import { JsonRpcProvider } from 'ethers';

const provider = new JsonRpcProvider('http://localhost:8545');
const verifiedBatch = await provider.send('zkevm_verifiedBatchNumber', []);
console.log('Verified batch:', parseInt(verifiedBatch, 16));
```

### viem

```typescript
import { createPublicClient, http } from 'viem';
import { zkEvm } from 'viem/chains';

const client = createPublicClient({
  chain: zkEvm,
  transport: http('http://localhost:8545'),
});

const verifiedBatch = await client.request({
  method: 'zkevm_verifiedBatchNumber',
  params: [],
});
console.log('Verified batch:', parseInt(verifiedBatch, 16));
```

### Error Codes

| Code | Message | Description |
|------|---------|-------------|
| -32603 | Internal error | Node sync in progress or internal failure |

---

## zkevm_consolidatedBlockNumber

Get the latest L1-confirmed block number.

### Returns

`QUANTITY` - Consolidated block number

### Example

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"zkevm_consolidatedBlockNumber","params":[],"id":1}'
```

### ethers.js

```javascript
import { JsonRpcProvider } from 'ethers';

const provider = new JsonRpcProvider('http://localhost:8545');
const consolidatedBlock = await provider.send('zkevm_consolidatedBlockNumber', []);
console.log('Consolidated block:', parseInt(consolidatedBlock, 16));
```

### viem

```typescript
import { createPublicClient, http } from 'viem';
import { zkEvm } from 'viem/chains';

const client = createPublicClient({
  chain: zkEvm,
  transport: http('http://localhost:8545'),
});

const consolidatedBlock = await client.request({
  method: 'zkevm_consolidatedBlockNumber',
  params: [],
});
console.log('Consolidated block:', parseInt(consolidatedBlock, 16));
```

### Error Codes

| Code | Message | Description |
|------|---------|-------------|
| -32603 | Internal error | Node sync in progress or internal failure |

## Next Steps

- [Block Methods](./block-methods) - Block-related methods
- [Witness Methods](./witness-methods) - Proof generation
