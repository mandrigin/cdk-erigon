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

### ethers.js

```javascript
import { JsonRpcProvider } from 'ethers';

const provider = new JsonRpcProvider('http://localhost:8545');
const block = await provider.send('zkevm_getFullBlockByNumber', ['latest', true]);
console.log('Block:', block);
console.log('Block number:', parseInt(block.number, 16));
```

### viem

```typescript
import { createPublicClient, http } from 'viem';
import { zkEvm } from 'viem/chains';

const client = createPublicClient({
  chain: zkEvm,
  transport: http('http://localhost:8545'),
});

const block = await client.request({
  method: 'zkevm_getFullBlockByNumber',
  params: ['latest', true],
});
console.log('Block:', block);
```

### Error Codes

| Code | Message | Description |
|------|---------|-------------|
| -32602 | Invalid params | Invalid block number or tag format |
| -32603 | Internal error | Block not found or internal failure |

---

## zkevm_getFullBlockByHash

Get a block by hash with full zkEVM data.

### Parameters

1. `DATA` - Block hash
2. `Boolean` - Include full transactions

### Returns

Block object with zkEVM-specific fields

### Example

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"zkevm_getFullBlockByHash","params":["0x...",true],"id":1}'
```

### ethers.js

```javascript
import { JsonRpcProvider } from 'ethers';

const provider = new JsonRpcProvider('http://localhost:8545');
const blockHash = '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef';
const block = await provider.send('zkevm_getFullBlockByHash', [blockHash, true]);
console.log('Block:', block);
```

### viem

```typescript
import { createPublicClient, http } from 'viem';
import { zkEvm } from 'viem/chains';

const client = createPublicClient({
  chain: zkEvm,
  transport: http('http://localhost:8545'),
});

const blockHash = '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef';
const block = await client.request({
  method: 'zkevm_getFullBlockByHash',
  params: [blockHash, true],
});
console.log('Block:', block);
```

### Error Codes

| Code | Message | Description |
|------|---------|-------------|
| -32602 | Invalid params | Invalid block hash format |
| -32603 | Internal error | Block not found or internal failure |

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

### ethers.js

```javascript
import { JsonRpcProvider } from 'ethers';

const provider = new JsonRpcProvider('http://localhost:8545');
const isConsolidated = await provider.send('zkevm_isBlockConsolidated', ['0x100']);
console.log('Is consolidated:', isConsolidated);
```

### viem

```typescript
import { createPublicClient, http } from 'viem';
import { zkEvm } from 'viem/chains';

const client = createPublicClient({
  chain: zkEvm,
  transport: http('http://localhost:8545'),
});

const isConsolidated = await client.request({
  method: 'zkevm_isBlockConsolidated',
  params: ['0x100'],
});
console.log('Is consolidated:', isConsolidated);
```

### Error Codes

| Code | Message | Description |
|------|---------|-------------|
| -32602 | Invalid params | Invalid block number format |
| -32603 | Internal error | Block not found or internal failure |

---

## zkevm_isBlockVirtualized

Check if a block is submitted to L1.

### Parameters

1. `QUANTITY` - Block number

### Returns

`Boolean` - True if virtualized

### Example

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"zkevm_isBlockVirtualized","params":["0x100"],"id":1}'
```

### ethers.js

```javascript
import { JsonRpcProvider } from 'ethers';

const provider = new JsonRpcProvider('http://localhost:8545');
const isVirtualized = await provider.send('zkevm_isBlockVirtualized', ['0x100']);
console.log('Is virtualized:', isVirtualized);
```

### viem

```typescript
import { createPublicClient, http } from 'viem';
import { zkEvm } from 'viem/chains';

const client = createPublicClient({
  chain: zkEvm,
  transport: http('http://localhost:8545'),
});

const isVirtualized = await client.request({
  method: 'zkevm_isBlockVirtualized',
  params: ['0x100'],
});
console.log('Is virtualized:', isVirtualized);
```

### Error Codes

| Code | Message | Description |
|------|---------|-------------|
| -32602 | Invalid params | Invalid block number format |
| -32603 | Internal error | Block not found or internal failure |

---

## zkevm_getLatestDataStreamBlock

Get the latest block from the data stream.

### Returns

Block information from data stream

### Example

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"zkevm_getLatestDataStreamBlock","params":[],"id":1}'
```

### ethers.js

```javascript
import { JsonRpcProvider } from 'ethers';

const provider = new JsonRpcProvider('http://localhost:8545');
const dataStreamBlock = await provider.send('zkevm_getLatestDataStreamBlock', []);
console.log('Latest data stream block:', dataStreamBlock);
```

### viem

```typescript
import { createPublicClient, http } from 'viem';
import { zkEvm } from 'viem/chains';

const client = createPublicClient({
  chain: zkEvm,
  transport: http('http://localhost:8545'),
});

const dataStreamBlock = await client.request({
  method: 'zkevm_getLatestDataStreamBlock',
  params: [],
});
console.log('Latest data stream block:', dataStreamBlock);
```

### Error Codes

| Code | Message | Description |
|------|---------|-------------|
| -32603 | Internal error | Data stream unavailable or internal failure |

## Next Steps

- [Witness Methods](./witness-methods) - Proof generation
- [Exit Root Methods](./exit-root-methods) - Bridge data
