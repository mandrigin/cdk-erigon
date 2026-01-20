---
sidebar_position: 3
title: Prover Integration
description: Configure cdk-erigon for ZK prover integration
---

# Prover Integration

Configure cdk-erigon for ZK proof generation.

## Overview

The prover system requires:
- Executor for transaction validation
- Witness data for proof generation
- Counter estimation for resource planning

## Executor Configuration

Configure executor URLs for sequencer mode:

```yaml
zkevm:
  executor-urls: executor1:50071,executor2:50071
  executor-strict: true
  executor-enabled: true
  executor-request-timeout: 60s
  executor-max-concurrent-requests: 1
```

### Executor Options

| Option | Description | Default |
|--------|-------------|---------|
| `executor-urls` | Comma-separated gRPC executor URLs | Required |
| `executor-strict` | Reject transactions that fail verification | `true` |
| `executor-enabled` | Enable executor integration | `true` |
| `executor-request-timeout` | Timeout for executor requests | `60s` |
| `executor-max-concurrent-requests` | Max concurrent executor requests | `1` |
| `executor-payload-output` | Output path for serialized executor payloads | N/A |

### Strict Mode Verification

When `executor-strict: true` is enabled:

1. **Executor URLs Required**: The sequencer will panic at startup if no executor URLs are configured
2. **Virtual Counters Enforced**: Cannot disable virtual counters in strict mode
3. **Transaction Validation**: All transactions are verified by the executor before inclusion

```yaml
# Production configuration (strict mode)
zkevm:
  executor-urls: executor1:50071,executor2:50071
  executor-strict: true
  executor-enabled: true
```

```yaml
# Development/testing configuration (non-strict)
zkevm:
  executor-urls: ""
  executor-strict: false
  executor-enabled: false
  disable-virtual-counters: true
```

:::warning
Running with `executor-strict: false` in production is not recommended. This mode should only be used for testing or development purposes.
:::

## Witness Generation

Witness data is the cryptographic proof input that allows the ZK prover to verify state transitions without re-executing all transactions.

### Witness Modes

cdk-erigon supports two witness generation modes:

| Mode | Description | Use Case |
|------|-------------|----------|
| `trimmed` | Only includes necessary state data | Default, smaller size |
| `full` | Includes all accessed state data | Debugging, complete verification |

Configure the default mode:

```yaml
zkevm:
  witness-full: false  # Use trimmed mode (default)
```

### Witness-Full Mode

When `witness-full: true` is enabled:

- All SMT nodes accessed during execution are included in the witness
- Results in larger witness sizes but complete state representation
- Useful for debugging prover issues or when full state context is needed

```yaml
# Enable full witness mode
zkevm:
  witness-full: true
  witness-memdb-size: 4GB  # Increase for large batches
  witness-unwind-limit: 500000
```

### Witness Format

The witness is a binary-encoded data structure consisting of:

1. **Header**: Version byte (currently `0x01`)
2. **Operators**: Sequence of opcodes with encoded data

#### Operator Types

| Opcode | Name | Description |
|--------|------|-------------|
| `0x00` | LEAF | Key-value leaf node |
| `0x01` | EXTENSION | Extension node with key |
| `0x02` | BRANCH | Branch node with child mask |
| `0x03` | HASH | 32-byte hash reference |
| `0x04` | CODE | Contract bytecode |
| `0x05` | ACCOUNT_LEAF | Account data with optional storage/code |
| `0x06` | EMPTY_ROOT | Empty trie root marker |
| `0xBB` | NEW_TRIE | Trie separator (for forests) |

#### Encoding Details

- Keys use custom nibble encoding with flags for odd length and terminator
- Values and code use CBOR encoding
- Hashes are raw 32-byte values (no CBOR wrapper)

### Witness Cache

Enable caching to speed up repeated witness requests:

```yaml
zkevm:
  witness-cache-enable: true
  witness-cache-batch-ahead-offset: 100  # Cache 100 batches ahead
  witness-cache-batch-behind-offset: 10  # Keep 10 batches behind
```

The cache stores pre-generated witnesses for batches around the verified batch, reducing response time for `zkevm_getBatchWitness` calls.

## Prover Input Structure

The prover input is a JSON object containing all data needed for proof generation:

```json
{
  "witness": "0x01...",
  "coinbase": "0x1234567890abcdef1234567890abcdef12345678",
  "oldAccInputHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "timestampLimit": 1699900000,
  "forcedBlockhashL1": ""
}
```

### Field Descriptions

| Field | Type | Description |
|-------|------|-------------|
| `witness` | hex string | SMT partial tree containing state data |
| `coinbase` | address | Sequencer address receiving fees |
| `oldAccInputHash` | hash | Previous batch's accumulated input hash |
| `timestampLimit` | uint64 | Maximum timestamp for transactions in batch |
| `forcedBlockhashL1` | hash | L1 block hash for forced batches (empty for regular) |

## Witness Retrieval Methods

### Get Witness for a Block

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "zkevm_getWitness",
    "params": ["0x100", "full"],
    "id": 1
  }'
```

### Get Witness for Block Range

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "zkevm_getBlockRangeWitness",
    "params": ["0x100", "0x110", "trimmed"],
    "id": 1
  }'
```

### Get Batch Witness

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "zkevm_getBatchWitness",
    "params": [256, "full"],
    "id": 1
  }'
```

### Get Prover Input (Sequencer Only)

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "zkevm_getProverInput",
    "params": [256, "full", true],
    "id": 1
  }'
```

## Code Examples

### Example 1: Basic Witness Retrieval with ethers.js

```javascript
import { JsonRpcProvider } from 'ethers';

const provider = new JsonRpcProvider('http://localhost:8545');

// Get witness for a specific block
async function getBlockWitness(blockNumber) {
  const witness = await provider.send('zkevm_getWitness', [
    `0x${blockNumber.toString(16)}`,
    'full'  // or 'trimmed'
  ]);
  console.log('Witness length:', witness.length);
  return witness;
}

// Get witness for a batch
async function getBatchWitness(batchNumber) {
  const witness = await provider.send('zkevm_getBatchWitness', [
    batchNumber,
    'full'
  ]);
  return witness;
}

// Usage
const witness = await getBlockWitness(256);
const batchWitness = await getBatchWitness(100);
```

### Example 2: Batch Witness Retrieval with viem

```typescript
import { createPublicClient, http, defineChain } from 'viem';

const cdkChain = defineChain({
  id: 1101,
  name: 'Polygon zkEVM',
  network: 'polygon-zkevm',
  nativeCurrency: { name: 'Ether', symbol: 'ETH', decimals: 18 },
  rpcUrls: {
    default: { http: ['http://localhost:8545'] },
  },
});

const client = createPublicClient({
  chain: cdkChain,
  transport: http(),
});

// Get batch witness with mode parameter
async function getBatchWitness(batchNumber: number, mode: 'full' | 'trimmed' = 'trimmed') {
  const witness = await client.request({
    method: 'zkevm_getBatchWitness',
    params: [batchNumber, mode],
  });
  return witness;
}

// Get witness for block range
async function getBlockRangeWitness(startBlock: number, endBlock: number) {
  const witness = await client.request({
    method: 'zkevm_getBlockRangeWitness',
    params: [
      `0x${startBlock.toString(16)}`,
      `0x${endBlock.toString(16)}`,
      'full'
    ],
  });
  return witness;
}

// Usage
const witness = await getBatchWitness(100, 'full');
console.log('Batch witness:', witness);
```

### Example 3: Complete Prover Integration Pipeline

```typescript
import { JsonRpcProvider } from 'ethers';

interface ProverInput {
  witness: string;
  coinbase: string;
  oldAccInputHash: string;
  timestampLimit: number;
  forcedBlockhashL1: string;
}

class ProverClient {
  private provider: JsonRpcProvider;

  constructor(rpcUrl: string) {
    this.provider = new JsonRpcProvider(rpcUrl);
  }

  // Get prover input for a batch (sequencer node only)
  async getProverInput(batchNumber: number, mode: 'full' | 'trimmed' = 'full'): Promise<ProverInput> {
    const result = await this.provider.send('zkevm_getProverInput', [
      batchNumber,
      mode,
      false  // debug flag
    ]);
    return result;
  }

  // Get batch number for a block
  async getBatchByBlock(blockNumber: number): Promise<number> {
    const result = await this.provider.send('zkevm_batchNumberByBlockNumber', [
      `0x${blockNumber.toString(16)}`
    ]);
    return parseInt(result, 16);
  }

  // Get verified batch number
  async getVerifiedBatchNumber(): Promise<number> {
    const result = await this.provider.send('zkevm_verifiedBatchNumber', []);
    return parseInt(result, 16);
  }

  // Check if batch is verified
  async isBatchVerified(batchNumber: number): Promise<boolean> {
    const verifiedBatch = await this.getVerifiedBatchNumber();
    return batchNumber <= verifiedBatch;
  }

  // Get all unverified batches that need proving
  async getUnverifiedBatches(): Promise<number[]> {
    const [currentBatch, verifiedBatch] = await Promise.all([
      this.provider.send('zkevm_batchNumber', []),
      this.getVerifiedBatchNumber()
    ]);

    const current = parseInt(currentBatch, 16);
    const batches: number[] = [];

    for (let i = verifiedBatch + 1; i <= current; i++) {
      batches.push(i);
    }

    return batches;
  }
}

// Usage
const prover = new ProverClient('http://localhost:8545');

// Get prover input for batch 100
const proverInput = await prover.getProverInput(100, 'full');
console.log('Prover input:', {
  witnessLength: proverInput.witness.length,
  coinbase: proverInput.coinbase,
  timestampLimit: proverInput.timestampLimit
});

// Get all batches that need proving
const unverified = await prover.getUnverifiedBatches();
console.log('Unverified batches:', unverified);
```

### Example 4: Witness Parsing and Validation

```typescript
// Parse witness binary data
function parseWitness(witnessHex: string): WitnessData {
  const bytes = Buffer.from(witnessHex.slice(2), 'hex');

  // Check version (first byte should be 0x01)
  const version = bytes[0];
  if (version !== 0x01) {
    throw new Error(`Unsupported witness version: ${version}`);
  }

  const operators: WitnessOperator[] = [];
  let offset = 1;

  while (offset < bytes.length) {
    const opcode = bytes[offset];
    offset++;

    switch (opcode) {
      case 0x00: // LEAF
        // Parse CBOR-encoded key and value
        operators.push({ type: 'LEAF', offset });
        break;
      case 0x03: // HASH
        // Read 32 bytes
        const hash = bytes.slice(offset, offset + 32);
        operators.push({ type: 'HASH', hash: hash.toString('hex') });
        offset += 32;
        break;
      case 0x05: // ACCOUNT_LEAF
        operators.push({ type: 'ACCOUNT_LEAF', offset });
        break;
      case 0x06: // EMPTY_ROOT
        operators.push({ type: 'EMPTY_ROOT' });
        break;
      case 0xBB: // NEW_TRIE
        operators.push({ type: 'NEW_TRIE' });
        break;
      default:
        // Skip unknown operators for forward compatibility
        break;
    }
  }

  return { version, operators, totalSize: bytes.length };
}

interface WitnessOperator {
  type: string;
  hash?: string;
  offset?: number;
}

interface WitnessData {
  version: number;
  operators: WitnessOperator[];
  totalSize: number;
}

// Usage
const witness = await getBatchWitness(100);
const parsed = parseWitness(witness);
console.log(`Witness v${parsed.version}: ${parsed.operators.length} operators, ${parsed.totalSize} bytes`);
```

### Example 5: Automated Prover Batch Processing

```typescript
import { JsonRpcProvider } from 'ethers';

interface BatchJob {
  batchNumber: number;
  witness: string;
  status: 'pending' | 'proving' | 'verified' | 'failed';
}

class BatchProverService {
  private provider: JsonRpcProvider;
  private jobs: Map<number, BatchJob> = new Map();
  private pollingInterval: number;

  constructor(rpcUrl: string, pollingIntervalMs: number = 10000) {
    this.provider = new JsonRpcProvider(rpcUrl);
    this.pollingInterval = pollingIntervalMs;
  }

  // Fetch witness for a batch with retry logic
  async fetchBatchWitness(batchNumber: number, retries: number = 3): Promise<string> {
    for (let attempt = 1; attempt <= retries; attempt++) {
      try {
        const witness = await this.provider.send('zkevm_getBatchWitness', [
          batchNumber,
          'full'
        ]);
        return witness;
      } catch (error) {
        if (attempt === retries) throw error;
        await this.delay(1000 * attempt);  // Exponential backoff
      }
    }
    throw new Error('Failed to fetch witness');
  }

  // Process unverified batches
  async processUnverifiedBatches(): Promise<void> {
    const [currentBatch, verifiedBatch] = await Promise.all([
      this.provider.send('zkevm_batchNumber', []).then(r => parseInt(r, 16)),
      this.provider.send('zkevm_verifiedBatchNumber', []).then(r => parseInt(r, 16))
    ]);

    console.log(`Current: ${currentBatch}, Verified: ${verifiedBatch}`);

    for (let batch = verifiedBatch + 1; batch <= currentBatch; batch++) {
      if (!this.jobs.has(batch)) {
        try {
          const witness = await this.fetchBatchWitness(batch);
          this.jobs.set(batch, {
            batchNumber: batch,
            witness,
            status: 'pending'
          });
          console.log(`Queued batch ${batch} for proving (witness: ${witness.length} chars)`);
        } catch (error) {
          console.error(`Failed to fetch witness for batch ${batch}:`, error);
        }
      }
    }
  }

  // Start continuous monitoring
  async startMonitoring(): Promise<void> {
    console.log('Starting batch prover monitoring...');

    while (true) {
      await this.processUnverifiedBatches();
      await this.delay(this.pollingInterval);
    }
  }

  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}

// Usage
const service = new BatchProverService('http://localhost:8545', 5000);
await service.startMonitoring();
```

### Example 6: Counter Estimation Before Transaction

```typescript
import { JsonRpcProvider } from 'ethers';

interface CounterEstimate {
  gasUsed: number;
  countersUsed: {
    steps: number;
    arithmetic: number;
    binary: number;
    memAlign: number;
    keccaks: number;
    poseidon: number;
    padding: number;
    sha256: number;
  };
  countersLimit: {
    steps: number;
    arithmetic: number;
    binary: number;
    memAlign: number;
    keccaks: number;
    poseidon: number;
    padding: number;
    sha256: number;
  };
}

async function estimateCounters(
  provider: JsonRpcProvider,
  to: string,
  data: string,
  value: string = '0x0'
): Promise<CounterEstimate> {
  const result = await provider.send('zkevm_estimateCounters', [{
    to,
    data,
    value,
    from: '0x0000000000000000000000000000000000000000'
  }]);

  return result;
}

// Check if transaction will fit in a batch
function willFitInBatch(estimate: CounterEstimate): boolean {
  const { countersUsed, countersLimit } = estimate;

  return Object.entries(countersUsed).every(([key, value]) => {
    const limit = countersLimit[key as keyof typeof countersLimit];
    return value <= limit;
  });
}

// Usage
const provider = new JsonRpcProvider('http://localhost:8545');

const estimate = await estimateCounters(
  provider,
  '0x1234567890abcdef1234567890abcdef12345678',
  '0xa9059cbb...', // ERC20 transfer data
  '0x0'
);

console.log('Counter estimate:', estimate);
console.log('Will fit in batch:', willFitInBatch(estimate));
```

## Troubleshooting

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| "witness too old" | Block outside unwind limit | Increase `witness-unwind-limit` |
| "executor timeout" | Slow executor response | Increase `executor-request-timeout` |
| "out of memory" | Large batch witness | Increase `witness-memdb-size` |
| "method only supported from sequencer" | Non-sequencer node | Use `zkevm_getBatchWitness` instead |

### Performance Tuning

For high-throughput prover integration:

```yaml
zkevm:
  witness-cache-enable: true
  witness-cache-batch-ahead-offset: 200
  witness-cache-batch-behind-offset: 20
  witness-memdb-size: 8GB
  witness-unwind-limit: 1000000
  executor-max-concurrent-requests: 4
  rpc-get-batch-witness-concurrency-limit: 4
```

## Next Steps

- [Bridge Service](./bridge-service) - Cross-chain operations
- [Kurtosis](./kurtosis) - Local development
- [Witness Methods API](../api/zkevm/witness-methods) - Full API reference
