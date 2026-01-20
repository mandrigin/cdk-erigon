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

### ethers.js

```javascript
import { JsonRpcProvider } from 'ethers';

const provider = new JsonRpcProvider('http://localhost:8545');
const ger = await provider.send('zkevm_getLatestGlobalExitRoot', []);
console.log('Latest GER:', ger);
```

### viem

```typescript
import { createPublicClient, http } from 'viem';
import { zkEvm } from 'viem/chains';

const client = createPublicClient({
  chain: zkEvm,
  transport: http('http://localhost:8545'),
});

const ger = await client.request({
  method: 'zkevm_getLatestGlobalExitRoot',
  params: [],
});
console.log('Latest GER:', ger);
```

### Error Codes

| Code | Message | Description |
|------|---------|-------------|
| -32603 | Internal error | Node sync in progress or internal failure |

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

### ethers.js

```javascript
import { JsonRpcProvider } from 'ethers';

const provider = new JsonRpcProvider('http://localhost:8545');
const exitRootTable = await provider.send('zkevm_getExitRootTable', []);
console.log('Exit root table:', exitRootTable);
console.log('Number of entries:', exitRootTable.length);
```

### viem

```typescript
import { createPublicClient, http } from 'viem';
import { zkEvm } from 'viem/chains';

const client = createPublicClient({
  chain: zkEvm,
  transport: http('http://localhost:8545'),
});

const exitRootTable = await client.request({
  method: 'zkevm_getExitRootTable',
  params: [],
});
console.log('Exit root table:', exitRootTable);
```

### Error Codes

| Code | Message | Description |
|------|---------|-------------|
| -32603 | Internal error | Node sync in progress or internal failure |

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

### ethers.js

```javascript
import { JsonRpcProvider } from 'ethers';

const provider = new JsonRpcProvider('http://localhost:8545');
const gerHash = '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef';
const exitRoots = await provider.send('zkevm_getExitRootsByGER', [gerHash]);
console.log('Exit roots:', exitRoots);
```

### viem

```typescript
import { createPublicClient, http } from 'viem';
import { zkEvm } from 'viem/chains';

const client = createPublicClient({
  chain: zkEvm,
  transport: http('http://localhost:8545'),
});

const gerHash = '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef';
const exitRoots = await client.request({
  method: 'zkevm_getExitRootsByGER',
  params: [gerHash],
});
console.log('Exit roots:', exitRoots);
```

### Error Codes

| Code | Message | Description |
|------|---------|-------------|
| -32602 | Invalid params | Invalid GER hash format |
| -32603 | Internal error | GER not found or internal failure |

---

## zkevm_getL2BlockInfoTree

Get L2 block info tree data.

### Parameters

1. `QUANTITY` - Block number

### Returns

L2 block info tree data

### Example

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"zkevm_getL2BlockInfoTree","params":["0x100"],"id":1}'
```

### ethers.js

```javascript
import { JsonRpcProvider } from 'ethers';

const provider = new JsonRpcProvider('http://localhost:8545');
const blockInfoTree = await provider.send('zkevm_getL2BlockInfoTree', ['0x100']);
console.log('L2 block info tree:', blockInfoTree);
```

### viem

```typescript
import { createPublicClient, http } from 'viem';
import { zkEvm } from 'viem/chains';

const client = createPublicClient({
  chain: zkEvm,
  transport: http('http://localhost:8545'),
});

const blockInfoTree = await client.request({
  method: 'zkevm_getL2BlockInfoTree',
  params: ['0x100'],
});
console.log('L2 block info tree:', blockInfoTree);
```

### Error Codes

| Code | Message | Description |
|------|---------|-------------|
| -32602 | Invalid params | Invalid block number format |
| -32603 | Internal error | Block not found or internal failure |

## Next Steps

- [Fork Methods](./fork-methods) - Fork ID queries
- [Counter Methods](./counter-methods) - ZK counter estimation
