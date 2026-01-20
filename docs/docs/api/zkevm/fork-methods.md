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

### ethers.js

```javascript
import { JsonRpcProvider } from 'ethers';

const provider = new JsonRpcProvider('http://localhost:8545');
const forkId = await provider.send('zkevm_getForkId', []);
console.log('Current fork ID:', parseInt(forkId, 16));
```

### viem

```typescript
import { createPublicClient, http } from 'viem';
import { zkEvm } from 'viem/chains';

const client = createPublicClient({
  chain: zkEvm,
  transport: http('http://localhost:8545'),
});

const forkId = await client.request({
  method: 'zkevm_getForkId',
  params: [],
});
console.log('Current fork ID:', parseInt(forkId, 16));
```

### Error Codes

| Code | Message | Description |
|------|---------|-------------|
| -32603 | Internal error | Node sync in progress or internal failure |

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

### ethers.js

```javascript
import { JsonRpcProvider } from 'ethers';

const provider = new JsonRpcProvider('http://localhost:8545');
const fork = await provider.send('zkevm_getForkById', ['0x6']);
console.log('Fork details:', fork);
```

### viem

```typescript
import { createPublicClient, http } from 'viem';
import { zkEvm } from 'viem/chains';

const client = createPublicClient({
  chain: zkEvm,
  transport: http('http://localhost:8545'),
});

const fork = await client.request({
  method: 'zkevm_getForkById',
  params: ['0x6'],
});
console.log('Fork details:', fork);
```

### Error Codes

| Code | Message | Description |
|------|---------|-------------|
| -32602 | Invalid params | Invalid fork ID format |
| -32603 | Internal error | Fork not found or internal failure |

---

## zkevm_getForkIdByBatchNumber

Get fork ID for a specific batch.

### Parameters

1. `QUANTITY` - Batch number

### Returns

`QUANTITY` - Fork ID at that batch

### Example

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"zkevm_getForkIdByBatchNumber","params":["0x100"],"id":1}'
```

### ethers.js

```javascript
import { JsonRpcProvider } from 'ethers';

const provider = new JsonRpcProvider('http://localhost:8545');
const forkId = await provider.send('zkevm_getForkIdByBatchNumber', ['0x100']);
console.log('Fork ID at batch:', parseInt(forkId, 16));
```

### viem

```typescript
import { createPublicClient, http } from 'viem';
import { zkEvm } from 'viem/chains';

const client = createPublicClient({
  chain: zkEvm,
  transport: http('http://localhost:8545'),
});

const forkId = await client.request({
  method: 'zkevm_getForkIdByBatchNumber',
  params: ['0x100'],
});
console.log('Fork ID at batch:', parseInt(forkId, 16));
```

### Error Codes

| Code | Message | Description |
|------|---------|-------------|
| -32602 | Invalid params | Invalid batch number format |
| -32603 | Internal error | Batch not found or internal failure |

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

### ethers.js

```javascript
import { JsonRpcProvider } from 'ethers';

const provider = new JsonRpcProvider('http://localhost:8545');
const forks = await provider.send('zkevm_getForks', []);
console.log('All forks:', forks);
console.log('Number of forks:', forks.length);
```

### viem

```typescript
import { createPublicClient, http } from 'viem';
import { zkEvm } from 'viem/chains';

const client = createPublicClient({
  chain: zkEvm,
  transport: http('http://localhost:8545'),
});

const forks = await client.request({
  method: 'zkevm_getForks',
  params: [],
});
console.log('All forks:', forks);
```

### Error Codes

| Code | Message | Description |
|------|---------|-------------|
| -32603 | Internal error | Node sync in progress or internal failure |

---

## zkevm_getVersionHistory

Get protocol version history.

### Returns

Array of version entries

### Example

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"zkevm_getVersionHistory","params":[],"id":1}'
```

### ethers.js

```javascript
import { JsonRpcProvider } from 'ethers';

const provider = new JsonRpcProvider('http://localhost:8545');
const versionHistory = await provider.send('zkevm_getVersionHistory', []);
console.log('Version history:', versionHistory);
```

### viem

```typescript
import { createPublicClient, http } from 'viem';
import { zkEvm } from 'viem/chains';

const client = createPublicClient({
  chain: zkEvm,
  transport: http('http://localhost:8545'),
});

const versionHistory = await client.request({
  method: 'zkevm_getVersionHistory',
  params: [],
});
console.log('Version history:', versionHistory);
```

### Error Codes

| Code | Message | Description |
|------|---------|-------------|
| -32603 | Internal error | Node sync in progress or internal failure |

## Next Steps

- [Counter Methods](./counter-methods) - ZK counter estimation
- [Deprecated Methods](./deprecated) - Deprecated APIs
