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

### ethers.js

```javascript
import { JsonRpcProvider } from 'ethers';

const provider = new JsonRpcProvider('http://localhost:8545');
const witness = await provider.send('zkevm_getWitness', ['0x100']);
console.log('Witness data:', witness);
```

### viem

```typescript
import { createPublicClient, http } from 'viem';
import { zkEvm } from 'viem/chains';

const client = createPublicClient({
  chain: zkEvm,
  transport: http('http://localhost:8545'),
});

const witness = await client.request({
  method: 'zkevm_getWitness',
  params: ['0x100'],
});
console.log('Witness data:', witness);
```

### Error Codes

| Code | Message | Description |
|------|---------|-------------|
| -32602 | Invalid params | Invalid block number format |
| -32603 | Internal error | Block not found or internal failure |

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

### ethers.js

```javascript
import { JsonRpcProvider } from 'ethers';

const provider = new JsonRpcProvider('http://localhost:8545');
const witness = await provider.send('zkevm_getBlockRangeWitness', ['0x100', '0x110']);
console.log('Block range witness:', witness);
```

### viem

```typescript
import { createPublicClient, http } from 'viem';
import { zkEvm } from 'viem/chains';

const client = createPublicClient({
  chain: zkEvm,
  transport: http('http://localhost:8545'),
});

const witness = await client.request({
  method: 'zkevm_getBlockRangeWitness',
  params: ['0x100', '0x110'],
});
console.log('Block range witness:', witness);
```

### Error Codes

| Code | Message | Description |
|------|---------|-------------|
| -32602 | Invalid params | Invalid block number format or invalid range |
| -32603 | Internal error | Blocks not found or internal failure |

---

## zkevm_getBatchWitness

Get witness data for an entire batch.

### Parameters

1. `QUANTITY` - Batch number

### Returns

Witness data for the batch

### Example

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"zkevm_getBatchWitness","params":["0x100"],"id":1}'
```

### ethers.js

```javascript
import { JsonRpcProvider } from 'ethers';

const provider = new JsonRpcProvider('http://localhost:8545');
const witness = await provider.send('zkevm_getBatchWitness', ['0x100']);
console.log('Batch witness:', witness);
```

### viem

```typescript
import { createPublicClient, http } from 'viem';
import { zkEvm } from 'viem/chains';

const client = createPublicClient({
  chain: zkEvm,
  transport: http('http://localhost:8545'),
});

const witness = await client.request({
  method: 'zkevm_getBatchWitness',
  params: ['0x100'],
});
console.log('Batch witness:', witness);
```

### Error Codes

| Code | Message | Description |
|------|---------|-------------|
| -32602 | Invalid params | Invalid batch number format |
| -32603 | Internal error | Batch not found or internal failure |

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

### ethers.js

```javascript
import { JsonRpcProvider } from 'ethers';

const provider = new JsonRpcProvider('http://localhost:8545');
const proverInput = await provider.send('zkevm_getProverInput', ['0x100']);
console.log('Prover input:', proverInput);
```

### viem

```typescript
import { createPublicClient, http } from 'viem';
import { zkEvm } from 'viem/chains';

const client = createPublicClient({
  chain: zkEvm,
  transport: http('http://localhost:8545'),
});

const proverInput = await client.request({
  method: 'zkevm_getProverInput',
  params: ['0x100'],
});
console.log('Prover input:', proverInput);
```

### Error Codes

| Code | Message | Description |
|------|---------|-------------|
| -32602 | Invalid params | Invalid batch number format |
| -32603 | Internal error | Batch not found or internal failure |

## Next Steps

- [Exit Root Methods](./exit-root-methods) - Bridge data
- [Fork Methods](./fork-methods) - Fork ID queries
