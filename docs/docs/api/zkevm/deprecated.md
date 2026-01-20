---
sidebar_position: 7
title: Deprecated Methods
description: Deprecated zkevm RPC methods
---

# Deprecated Methods

These methods are deprecated and may be removed in future versions.

## zkevm_getBroadcastURI

:::warning Deprecated
This method is deprecated and will be removed in a future version.
:::

Previously used for broadcast URI retrieval.

### Example

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"zkevm_getBroadcastURI","params":[],"id":1}'
```

### ethers.js

```javascript
import { JsonRpcProvider } from 'ethers';

// DEPRECATED: This method will be removed in a future version
const provider = new JsonRpcProvider('http://localhost:8545');
const uri = await provider.send('zkevm_getBroadcastURI', []);
```

### viem

```typescript
import { createPublicClient, http } from 'viem';
import { zkEvm } from 'viem/chains';

// DEPRECATED: This method will be removed in a future version
const client = createPublicClient({
  chain: zkEvm,
  transport: http('http://localhost:8545'),
});

const uri = await client.request({
  method: 'zkevm_getBroadcastURI',
  params: [],
});
```

### Error Codes

| Code | Message | Description |
|------|---------|-------------|
| -32601 | Method not found | Method may be disabled or removed |
| -32603 | Internal error | Internal failure |

---

## zkevm_virtualCounters

:::warning Deprecated
This method is deprecated. Use `zkevm_estimateCounters` instead.
:::

Legacy counter estimation method.

### Example

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"zkevm_virtualCounters","params":[{"from":"0x...","to":"0x..."}],"id":1}'
```

### ethers.js

```javascript
import { JsonRpcProvider } from 'ethers';

// DEPRECATED: Use zkevm_estimateCounters instead
const provider = new JsonRpcProvider('http://localhost:8545');
const counters = await provider.send('zkevm_virtualCounters', [{
  from: '0x1234567890123456789012345678901234567890',
  to: '0xabcdefabcdefabcdefabcdefabcdefabcdefabcd',
}]);
```

### viem

```typescript
import { createPublicClient, http } from 'viem';
import { zkEvm } from 'viem/chains';

// DEPRECATED: Use zkevm_estimateCounters instead
const client = createPublicClient({
  chain: zkEvm,
  transport: http('http://localhost:8545'),
});

const counters = await client.request({
  method: 'zkevm_virtualCounters',
  params: [{
    from: '0x1234567890123456789012345678901234567890',
    to: '0xabcdefabcdefabcdefabcdefabcdefabcdefabcd',
  }],
});
```

### Error Codes

| Code | Message | Description |
|------|---------|-------------|
| -32601 | Method not found | Method may be disabled or removed |
| -32602 | Invalid params | Invalid transaction object format |
| -32603 | Internal error | Internal failure |

---

## zkevm_traceTransactionCounters

:::warning Deprecated
This method is deprecated. Use `zkevm_getBatchCountersByNumber` instead.
:::

Legacy transaction counter tracing.

### Example

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"zkevm_traceTransactionCounters","params":["0x..."],"id":1}'
```

### ethers.js

```javascript
import { JsonRpcProvider } from 'ethers';

// DEPRECATED: Use zkevm_getBatchCountersByNumber instead
const provider = new JsonRpcProvider('http://localhost:8545');
const txHash = '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef';
const counters = await provider.send('zkevm_traceTransactionCounters', [txHash]);
```

### viem

```typescript
import { createPublicClient, http } from 'viem';
import { zkEvm } from 'viem/chains';

// DEPRECATED: Use zkevm_getBatchCountersByNumber instead
const client = createPublicClient({
  chain: zkEvm,
  transport: http('http://localhost:8545'),
});

const txHash = '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef';
const counters = await client.request({
  method: 'zkevm_traceTransactionCounters',
  params: [txHash],
});
```

### Error Codes

| Code | Message | Description |
|------|---------|-------------|
| -32601 | Method not found | Method may be disabled or removed |
| -32602 | Invalid params | Invalid transaction hash format |
| -32603 | Internal error | Transaction not found or internal failure |

## Migration Guide

| Deprecated Method | Replacement |
|-------------------|-------------|
| `zkevm_virtualCounters` | `zkevm_estimateCounters` |
| `zkevm_traceTransactionCounters` | `zkevm_getBatchCountersByNumber` |
| `zkevm_getBroadcastURI` | None (removed functionality) |

## Next Steps

- [Counter Methods](./counter-methods) - Current counter APIs
- [API Overview](../overview) - All available APIs
