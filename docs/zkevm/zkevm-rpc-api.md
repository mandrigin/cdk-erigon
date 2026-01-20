# zkEVM JSON-RPC API Reference

The `zkevm` namespace provides zkEVM-specific RPC methods for interacting with batch processing, witness generation, fork management, and L2 block operations on the Polygon zkEVM network.

## Table of Contents

- [Batch Methods](#batch-methods)
  - [zkevm_batchNumber](#zkevm_batchnumber)
  - [zkevm_batchNumberByBlockNumber](#zkevm_batchnumberbyblocknumber)
  - [zkevm_virtualBatchNumber](#zkevm_virtualbatchnumber)
  - [zkevm_verifiedBatchNumber](#zkevm_verifiedbatchnumber)
  - [zkevm_getBatchByNumber](#zkevm_getbatchbynumber)
  - [zkevm_getBatchCountersByNumber](#zkevm_getbatchcountersbynumber)
- [Block Consolidation Methods](#block-consolidation-methods)
  - [zkevm_consolidatedBlockNumber](#zkevm_consolidatedblocknumber)
  - [zkevm_isBlockConsolidated](#zkevm_isblockconsolidated)
  - [zkevm_isBlockVirtualized](#zkevm_isblockvirtualized)
- [Block Retrieval Methods](#block-retrieval-methods)
  - [zkevm_getFullBlockByNumber](#zkevm_getfullblockbynumber)
  - [zkevm_getFullBlockByHash](#zkevm_getfullblockbyhash)
  - [zkevm_getL2BlockInfoTree](#zkevm_getl2blockinfotree)
- [Exit Root Methods](#exit-root-methods)
  - [zkevm_getLatestGlobalExitRoot](#zkevm_getlatestglobalexitroot)
  - [zkevm_getExitRootsByGER](#zkevm_getexitrootsbyger)
  - [zkevm_getExitRootTable](#zkevm_getexitroottable)
- [Witness Methods](#witness-methods)
  - [zkevm_getWitness](#zkevm_getwitness)
  - [zkevm_getBlockRangeWitness](#zkevm_getblockrangewitness)
  - [zkevm_getBatchWitness](#zkevm_getbatchwitness)
  - [zkevm_getProverInput](#zkevm_getproverinput)
- [Counter Methods](#counter-methods)
  - [zkevm_estimateCounters](#zkevm_estimatecounters)
- [Fork Methods](#fork-methods)
  - [zkevm_getForkId](#zkevm_getforkid)
  - [zkevm_getForkById](#zkevm_getforkbyid)
  - [zkevm_getForkIdByBatchNumber](#zkevm_getforkidbybatchnumber)
  - [zkevm_getForks](#zkevm_getforks)
- [Configuration Methods](#configuration-methods)
  - [zkevm_getVersionHistory](#zkevm_getversionhistory)
  - [zkevm_getRollupAddress](#zkevm_getrollupaddress)
  - [zkevm_getRollupManagerAddress](#zkevm_getrollupmanageraddress)
- [Data Stream Methods](#data-stream-methods)
  - [zkevm_getLatestDataStreamBlock](#zkevm_getlatestdatastreamblock)
- [Deprecated Methods](#deprecated-methods)
  - [zkevm_getBroadcastURI](#zkevm_getbroadcasturi-deprecated)

---

## Batch Methods

### zkevm_batchNumber

Returns the latest batch number.

**Parameters**

None

**Returns**

`hexutil.Uint64` - The latest batch number as a hex-encoded integer.

**Example**

```bash
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"zkevm_batchNumber","params":[],"id":1}' \
  http://localhost:8545
```

**Response**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": "0x1a4"
}
```

---

### zkevm_batchNumberByBlockNumber

Returns the batch number that contains a specific L2 block.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `blockNumber` | `rpc.BlockNumber` | The L2 block number (integer, "latest", "earliest", or "pending") |

**Returns**

`hexutil.Uint64` - The batch number containing the specified block.

**Example**

```bash
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"zkevm_batchNumberByBlockNumber","params":["0x100"],"id":1}' \
  http://localhost:8545
```

**Response**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": "0x50"
}
```

---

### zkevm_virtualBatchNumber

Returns the latest virtual batch number. A virtual batch is a batch that has been sequenced on L1 but not yet verified with a ZK proof.

**Parameters**

None

**Returns**

`hexutil.Uint64` - The latest virtual batch number.

**Example**

```bash
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"zkevm_virtualBatchNumber","params":[],"id":1}' \
  http://localhost:8545
```

**Response**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": "0x1a8"
}
```

---

### zkevm_verifiedBatchNumber

Returns the latest verified batch number. A batch is verified once its ZK proof has been validated and accepted by the network.

**Parameters**

None

**Returns**

`hexutil.Uint64` - The latest verified batch number.

**Example**

```bash
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"zkevm_verifiedBatchNumber","params":[],"id":1}' \
  http://localhost:8545
```

**Response**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": "0x1a0"
}
```

---

### zkevm_getBatchByNumber

Returns detailed information about a batch by its number.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `batchNumber` | `rpc.BlockNumber` | The batch number (integer, "latest", "earliest") |
| `fullTx` | `*bool` | If `true`, returns full transaction and block objects; if `false` or omitted, returns only hashes |

**Returns**

`json.RawMessage` - A batch object with the following fields:

| Field | Type | Description |
|-------|------|-------------|
| `number` | `uint64` | Batch number |
| `coinbase` | `address` | Sequencer address |
| `stateRoot` | `hash` | State root after batch execution |
| `timestamp` | `uint64` | Batch timestamp |
| `blocks` | `array` | Array of block hashes (or full blocks if `fullTx=true`) |
| `transactions` | `array` | Array of transaction hashes (or full txs if `fullTx=true`) |
| `globalExitRoot` | `hash` | Global exit root |
| `mainnetExitRoot` | `hash` | Mainnet exit root |
| `rollupExitRoot` | `hash` | Rollup exit root |
| `localExitRoot` | `hash` | Local exit root |
| `sendSequencesTxHash` | `hash` | L1 transaction hash for the sequence |
| `verifyBatchTxHash` | `hash` | L1 transaction hash for verification |
| `accInputHash` | `hash` | Accumulated input hash |
| `closed` | `bool` | Whether the batch is closed |
| `batchL2Data` | `bytes` | Encoded batch L2 data |

**Example**

```bash
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"zkevm_getBatchByNumber","params":["0x100", false],"id":1}' \
  http://localhost:8545
```

**Response**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "number": "0x100",
    "coinbase": "0x148Ee7dAF16574cD020aFa34CC658f8F3fbd2800",
    "stateRoot": "0x1234...abcd",
    "timestamp": "0x6579a800",
    "blocks": ["0xabc...123", "0xdef...456"],
    "transactions": ["0x111...222", "0x333...444"],
    "globalExitRoot": "0x5678...efgh",
    "closed": true,
    "batchL2Data": "0x..."
  }
}
```

---

### zkevm_getBatchCountersByNumber

Returns the execution counters for a batch. This is useful for analyzing resource consumption.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `batchNumber` | `rpc.BlockNumber` | The batch number |

**Returns**

`json.RawMessage` - Counter data with the following fields:

| Field | Type | Description |
|-------|------|-------------|
| `smtDepth` | `int` | SMT (Sparse Merkle Tree) depth |
| `batchNumber` | `uint64` | Batch number |
| `blockFrom` | `uint64` | First block in batch |
| `blockTo` | `uint64` | Last block in batch |
| `countersUsed` | `object` | Counters used by the batch |
| `countersLimits` | `object` | Counter limits |

Counter objects contain:
- `gas` - Gas used
- `keccakHashes` - Keccak hash operations
- `poseidonHashes` - Poseidon hash operations
- `poseidonPaddings` - Poseidon padding operations
- `memAligns` - Memory alignment operations
- `arithmetics` - Arithmetic operations
- `binaries` - Binary operations
- `steps` - Execution steps
- `SHA256Hashes` - SHA256 hash operations

**Example**

```bash
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"zkevm_getBatchCountersByNumber","params":["0x100"],"id":1}' \
  http://localhost:8545
```

**Response**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "smtDepth": 256,
    "batchNumber": 256,
    "blockFrom": 1000,
    "blockTo": 1050,
    "countersUsed": {
      "gas": 5000000,
      "keccakHashes": 150,
      "poseidonHashes": 300,
      "poseidonPaddings": 50,
      "memAligns": 100,
      "arithmetics": 2000,
      "binaries": 500,
      "steps": 100000,
      "SHA256Hashes": 10
    },
    "countersLimits": {
      "gas": 30000000,
      "keccakHashes": 2145,
      "poseidonHashes": 252357,
      "poseidonPaddings": 135191,
      "memAligns": 236585,
      "arithmetics": 236585,
      "binaries": 473170,
      "steps": 8388608,
      "SHA256Hashes": 1596
    }
  }
}
```

---

## Block Consolidation Methods

### zkevm_consolidatedBlockNumber

Returns the latest consolidated block number. A block is consolidated when the batch containing it has been verified on L1.

**Parameters**

None

**Returns**

`hexutil.Uint64` - The latest consolidated block number.

**Example**

```bash
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"zkevm_consolidatedBlockNumber","params":[],"id":1}' \
  http://localhost:8545
```

**Response**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": "0x5dc"
}
```

---

### zkevm_isBlockConsolidated

Checks if a block is consolidated (included in a verified batch).

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `blockNumber` | `rpc.BlockNumber` | The block number to check |

**Returns**

`bool` - `true` if the block is consolidated, `false` otherwise.

**Example**

```bash
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"zkevm_isBlockConsolidated","params":["0x100"],"id":1}' \
  http://localhost:8545
```

**Response**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": true
}
```

---

### zkevm_isBlockVirtualized

Checks if a block is virtualized (included in a sequenced batch on L1, but not yet verified).

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `blockNumber` | `rpc.BlockNumber` | The block number to check |

**Returns**

`bool` - `true` if the block is virtualized, `false` otherwise.

**Example**

```bash
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"zkevm_isBlockVirtualized","params":["0x200"],"id":1}' \
  http://localhost:8545
```

**Response**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": true
}
```

---

## Block Retrieval Methods

### zkevm_getFullBlockByNumber

Returns full block details including zkEVM-specific fields.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `blockNumber` | `rpc.BlockNumber` | The block number |
| `fullTx` | `bool` | If `true`, returns full transaction objects |

**Returns**

`types.Block` - A block object with extended zkEVM fields including L2 transaction hashes and receipts.

**Example**

```bash
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"zkevm_getFullBlockByNumber","params":["0x100", true],"id":1}' \
  http://localhost:8545
```

**Response**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "parentHash": "0x...",
    "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347",
    "miner": "0x...",
    "stateRoot": "0x...",
    "transactionsRoot": "0x...",
    "receiptsRoot": "0x...",
    "logsBloom": "0x...",
    "difficulty": "0x0",
    "number": "0x100",
    "gasLimit": "0x1c9c380",
    "gasUsed": "0x5208",
    "timestamp": "0x6579a800",
    "extraData": "0x",
    "mixHash": "0x...",
    "nonce": "0x0000000000000000",
    "hash": "0x...",
    "transactions": [...]
  }
}
```

---

### zkevm_getFullBlockByHash

Returns full block details by block hash including zkEVM-specific fields.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `hash` | `common.Hash` | The block hash |
| `fullTx` | `bool` | If `true`, returns full transaction objects |

**Returns**

`types.Block` - A block object with extended zkEVM fields.

**Example**

```bash
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"zkevm_getFullBlockByHash","params":["0xabc123...", true],"id":1}' \
  http://localhost:8545
```

---

### zkevm_getL2BlockInfoTree

Returns L2 block information tree data including transaction details and execution results.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `blockNum` | `rpc.BlockNumberOrHash` | Block number or hash |

**Returns**

`json.RawMessage` - Block info tree data with the following fields:

| Field | Type | Description |
|-------|------|-------------|
| `blockNumber` | `uint64` | Block number |
| `coinbase` | `address` | Block coinbase |
| `blockTime` | `uint64` | Block timestamp |
| `blockGasLimit` | `uint64` | Block gas limit |
| `blockGasUsed` | `uint64` | Gas used in block |
| `ger` | `hash` | Global exit root (if set) |
| `l1BlockHash` | `hash` | L1 block hash (if set) |
| `previousStateRoot` | `hash` | Previous state root |
| `txInfos` | `array` | Array of transaction info objects |

**Example**

```bash
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"zkevm_getL2BlockInfoTree","params":["0x100"],"id":1}' \
  http://localhost:8545
```

**Error Codes**

| Code | Message |
|------|---------|
| -32602 | Block 0 doesn't have block info tree |
| -32602 | Block not found |

---

## Exit Root Methods

### zkevm_getLatestGlobalExitRoot

Returns the latest global exit root used on L2.

**Parameters**

None

**Returns**

`common.Hash` - The latest global exit root hash.

**Example**

```bash
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"zkevm_getLatestGlobalExitRoot","params":[],"id":1}' \
  http://localhost:8545
```

**Response**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
}
```

---

### zkevm_getExitRootsByGER

Returns the exit roots (mainnet and rollup) for a given global exit root.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `globalExitRoot` | `common.Hash` | The global exit root hash |

**Returns**

`ZkExitRoots` - Exit root data:

| Field | Type | Description |
|-------|------|-------------|
| `blockNumber` | `uint64` | L1 block number |
| `timestamp` | `uint64` | Timestamp |
| `mainnetExitRoot` | `hash` | Mainnet exit root |
| `rollupExitRoot` | `hash` | Rollup exit root |

**Example**

```bash
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"zkevm_getExitRootsByGER","params":["0x1234..."],"id":1}' \
  http://localhost:8545
```

**Response**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "blockNumber": "0x100",
    "timestamp": "0x6579a800",
    "mainnetExitRoot": "0xabc...",
    "rollupExitRoot": "0xdef..."
  }
}
```

---

### zkevm_getExitRootTable

Returns entries from the L1 info tree with optional filtering.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `args` | `object` | Optional filtering arguments |
| `args.from` | `uint64` | Start index (optional) |
| `args.to` | `uint64` | End index (optional) |

**Returns**

`[]l1InfoTreeData` - Array of L1 info tree entries:

| Field | Type | Description |
|-------|------|-------------|
| `index` | `uint64` | L1 info tree index |
| `ger` | `hash` | Global exit root |
| `info_root` | `hash` | Info root |
| `mainnet_exit_root` | `hash` | Mainnet exit root |
| `rollup_exit_root` | `hash` | Rollup exit root |
| `parent_hash` | `hash` | Parent hash |
| `min_timestamp` | `uint64` | Minimum timestamp |
| `block_number` | `uint64` | Block number |

**Example**

```bash
# Get all entries
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"zkevm_getExitRootTable","params":[null],"id":1}' \
  http://localhost:8545

# Get entries from index 1 to 10
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"zkevm_getExitRootTable","params":[{"from": 1, "to": 10}],"id":1}' \
  http://localhost:8545
```

---

## Witness Methods

### zkevm_getWitness

Returns the witness for a single block. The witness is the cryptographic proof data needed for ZK proving.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `blockNrOrHash` | `rpc.BlockNumberOrHash` | Block number or hash |
| `mode` | `*WitnessMode` | Witness mode (optional): `"full"` or `"trimmed"` |
| `debug` | `*bool` | Enable debug output (optional) |

**Witness Modes**

- `"full"` - Returns full witness data
- `"trimmed"` - Returns trimmed/optimized witness data
- `null` - Uses node default mode

**Returns**

`hexutility.Bytes` - The witness data as hex-encoded bytes.

**Example**

```bash
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"zkevm_getWitness","params":["0x100", "full", false],"id":1}' \
  http://localhost:8545
```

**Error Codes**

| Code | Message |
|------|---------|
| -32000 | invalid mode, must be full or trimmed |
| -32000 | state trie does not support witness |
| -32000 | not supported by Erigon3 |

---

### zkevm_getBlockRangeWitness

Returns the witness for a range of blocks (inclusive).

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `startBlockNrOrHash` | `rpc.BlockNumberOrHash` | Start block number or hash |
| `endBlockNrOrHash` | `rpc.BlockNumberOrHash` | End block number or hash |
| `mode` | `*WitnessMode` | Witness mode (optional): `"full"` or `"trimmed"` |
| `debug` | `*bool` | Enable debug output (optional) |

**Returns**

`hexutility.Bytes` - The combined witness data for the block range.

**Example**

```bash
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"zkevm_getBlockRangeWitness","params":["0x100", "0x110", "trimmed", false],"id":1}' \
  http://localhost:8545
```

**Error Codes**

| Code | Message |
|------|---------|
| -32000 | start block number must be less than or equal to end block number |

---

### zkevm_getBatchWitness

Returns the witness for an entire batch. This method has concurrency limiting to prevent resource exhaustion.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `batchNumber` | `uint64` | The batch number |
| `mode` | `*WitnessMode` | Witness mode (optional): `"full"` or `"trimmed"` |

**Returns**

`interface{}` - The witness data (hex string) or error.

**Example**

```bash
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"zkevm_getBatchWitness","params":[256, "full"],"id":1}' \
  http://localhost:8545
```

**Response**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": "0x..."
}
```

**Error Codes**

| Code | Message |
|------|---------|
| -32000 | busy (concurrency limit reached) |
| -32000 | no blocks found for batch N |

---

### zkevm_getProverInput

Returns the prover input payload containing witness and metadata. **Only available on sequencer nodes.**

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `batchNumber` | `uint64` | The batch number |
| `mode` | `*WitnessMode` | Witness mode (optional) |
| `debug` | `*bool` | Enable debug output (optional) |

**Returns**

`RpcPayload` - Prover input data:

| Field | Type | Description |
|-------|------|-------------|
| `witness` | `string` | Hex-encoded witness |
| `coinbase` | `string` | Sequencer address |
| `oldAccInputHash` | `string` | Previous accumulated input hash |
| `timestampLimit` | `uint64` | Timestamp limit |
| `forcedBlockhashL1` | `string` | Forced L1 blockhash (if applicable) |

**Example**

```bash
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"zkevm_getProverInput","params":[256, "full", false],"id":1}' \
  http://localhost:8545
```

**Error Codes**

| Code | Message |
|------|---------|
| -32000 | method only supported from a sequencer node |

---

## Counter Methods

### zkevm_estimateCounters

Estimates the execution counters for a transaction without adding it to the blockchain. Useful for determining if a transaction will fit within batch limits.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `transaction` | `object` | Transaction object |
| `transaction.from` | `address` | Sender address (optional, defaults to 0x111...111) |
| `transaction.to` | `address` | Recipient address (required for calls, omit for contract creation) |
| `transaction.gas` | `uint64` | Gas limit |
| `transaction.gasPrice` | `uint256` | Gas price (optional, defaults to 1) |
| `transaction.value` | `uint256` | Value to send (optional) |
| `transaction.data` | `bytes` | Transaction data |
| `transaction.input` | `bytes` | Alternative to `data` |
| `transaction.nonce` | `uint64` | Nonce (optional, uses account nonce) |

**Returns**

`json.RawMessage` - Counter estimation:

| Field | Type | Description |
|-------|------|-------------|
| `countersUsed` | `object` | Estimated counters used |
| `countersLimits` | `object` | Counter limits |
| `revertInfo` | `object` | Revert information if transaction fails |
| `oocError` | `string` | Out-of-counters error message (if applicable) |

**Example**

```bash
curl -X POST -H "Content-Type: application/json" \
  --data '{
    "jsonrpc":"2.0",
    "method":"zkevm_estimateCounters",
    "params":[{
      "from": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb7",
      "to": "0x1234567890123456789012345678901234567890",
      "gas": "0x76c0",
      "gasPrice": "0x9184e72a000",
      "value": "0x9184e72a",
      "data": "0x"
    }],
    "id":1
  }' \
  http://localhost:8545
```

**Response**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "countersUsed": {
      "gas": 21000,
      "keccakHashes": 2,
      "poseidonHashes": 50,
      "poseidonPaddings": 10,
      "memAligns": 5,
      "arithmetics": 100,
      "binaries": 20,
      "steps": 500,
      "SHA256Hashes": 0
    },
    "countersLimits": {
      "gas": 30000,
      "keccakHashes": 2145,
      "poseidonHashes": 252357,
      "poseidonPaddings": 135191,
      "memAligns": 236585,
      "arithmetics": 236585,
      "binaries": 473170,
      "steps": 8388608,
      "SHA256Hashes": 1596
    },
    "revertInfo": {
      "message": "",
      "data": null
    },
    "oocError": ""
  }
}
```

---

## Fork Methods

### zkevm_getForkId

Returns the current fork ID of the network.

**Parameters**

None

**Returns**

`hexutil.Uint64` - The current fork ID.

**Example**

```bash
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"zkevm_getForkId","params":[],"id":1}' \
  http://localhost:8545
```

**Response**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": "0xc"
}
```

---

### zkevm_getForkById

Returns the fork interval for a specific fork ID.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `forkId` | `hexutil.Uint64` | The fork ID |

**Returns**

`json.RawMessage` - Fork interval data:

| Field | Type | Description |
|-------|------|-------------|
| `forkId` | `uint64` | Fork ID |
| `fromBatchNumber` | `uint64` | Starting batch number |
| `toBatchNumber` | `uint64` | Ending batch number (0 if current) |
| `version` | `string` | Version string |
| `blockNumber` | `uint64` | L1 block number of fork activation |

**Example**

```bash
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"zkevm_getForkById","params":["0xc"],"id":1}' \
  http://localhost:8545
```

**Response**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "forkId": "0xc",
    "fromBatchNumber": "0x1000",
    "toBatchNumber": "0x0",
    "version": "",
    "blockNumber": "0x5dc"
  }
}
```

---

### zkevm_getForkIdByBatchNumber

Returns the fork ID for a specific batch number.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `batchNumber` | `rpc.BlockNumber` | The batch number |

**Returns**

`hexutil.Uint64` - The fork ID active at that batch.

**Example**

```bash
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"zkevm_getForkIdByBatchNumber","params":["0x100"],"id":1}' \
  http://localhost:8545
```

---

### zkevm_getForks

Returns all fork intervals configured in the network.

**Parameters**

None

**Returns**

`json.RawMessage` - Array of fork intervals.

**Example**

```bash
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"zkevm_getForks","params":[],"id":1}' \
  http://localhost:8545
```

**Response**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": [
    {
      "forkId": "0x1",
      "fromBatchNumber": "0x0",
      "toBatchNumber": "0x100",
      "version": "",
      "blockNumber": "0x0"
    },
    {
      "forkId": "0x7",
      "fromBatchNumber": "0x101",
      "toBatchNumber": "0x500",
      "version": "",
      "blockNumber": "0x1000"
    },
    {
      "forkId": "0xc",
      "fromBatchNumber": "0x501",
      "toBatchNumber": "0x0",
      "version": "",
      "blockNumber": "0x2000"
    }
  ]
}
```

---

## Configuration Methods

### zkevm_getVersionHistory

Returns the version history of the node software.

**Parameters**

None

**Returns**

`json.RawMessage` - Array of version history entries.

**Example**

```bash
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"zkevm_getVersionHistory","params":[],"id":1}' \
  http://localhost:8545
```

---

### zkevm_getRollupAddress

Returns the rollup smart contract address.

**Parameters**

None

**Returns**

`json.RawMessage` - The rollup contract address.

**Example**

```bash
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"zkevm_getRollupAddress","params":[],"id":1}' \
  http://localhost:8545
```

**Response**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": "0x5132A183E9F3CB7C848b0AAC5Ae0c4f0491B7aB2"
}
```

---

### zkevm_getRollupManagerAddress

Returns the rollup manager smart contract address.

**Parameters**

None

**Returns**

`json.RawMessage` - The rollup manager contract address.

**Example**

```bash
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"zkevm_getRollupManagerAddress","params":[],"id":1}' \
  http://localhost:8545
```

---

## Data Stream Methods

### zkevm_getLatestDataStreamBlock

Returns the latest block number available in the data stream.

**Parameters**

None

**Returns**

`hexutil.Uint64` - The latest data stream block number.

**Example**

```bash
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"zkevm_getLatestDataStreamBlock","params":[],"id":1}' \
  http://localhost:8545
```

**Response**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": "0x7d0"
}
```

---

## Deprecated Methods

### zkevm_getBroadcastURI (Deprecated)

**Status:** Commented out in the codebase and not currently exposed.

This method was intended to return the URI of the trusted sequencer broadcaster.

---

## Common Error Codes

| Code | Message | Description |
|------|---------|-------------|
| -32600 | Invalid Request | The JSON sent is not a valid Request object |
| -32601 | Method not found | The method does not exist / is not available |
| -32602 | Invalid params | Invalid method parameter(s) |
| -32603 | Internal error | Internal JSON-RPC error |
| -32000 | Server error | Generic server-side error |

## Notes

- All block and batch numbers can be specified as hex integers or special values like `"latest"`, `"earliest"`, `"pending"`.
- Hash values should be 32-byte hex strings prefixed with `0x`.
- Address values should be 20-byte hex strings prefixed with `0x`.
- The witness methods require the node to be running with SMT (Sparse Merkle Tree) support, not PMT (Partitioned Merkle Tree).
- Some methods like `zkevm_getProverInput` are only available on sequencer nodes.
- The `zkevm_getBatchWitness` method has concurrency limiting - callers may receive a "busy" error if too many concurrent requests are made.
