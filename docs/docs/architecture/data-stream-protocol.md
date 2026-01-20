# Data Stream Protocol

This document specifies the data stream protocol used by cdk-erigon for synchronization between sequencers and RPC nodes.

## Overview

The data stream is a binary protocol over TCP that enables efficient synchronization of L2 blocks, batches, and state changes from sequencers to RPC nodes.

**Key Characteristics:**
- Binary protocol over TCP
- Optional TLS encryption
- Supports continuous streaming and on-demand queries
- Resumable via bookmarks and progress tracking
- Atomic batch operations for consistency

## Message Types

**Location:** `zk/datastream/types/entry_type.go`

| Type | Value | Description |
|------|-------|-------------|
| `EntryTypeUnspecified` | 0 | Unspecified entry |
| `EntryTypeBatchStart` | 1 | Start of a batch |
| `EntryTypeL2Block` | 2 | L2 block header |
| `EntryTypeL2Tx` | 3 | Transaction within block |
| `EntryTypeBatchEnd` | 4 | End of batch + state |
| `EntryTypeGerUpdate` | 5 | Global Exit Root update |
| `EntryTypeL2BlockEnd` | 6 | End of block marker |
| `BookmarkEntryType` | 176 | Positional bookmark |

## Message Formats

### Batch Start Entry

**Location:** `zk/datastream/types/batch_proto.go`

```
BatchStart {
  uint64    number       // Batch sequence number
  BatchType type         // Regular=1, Forced=2, Injected=3, Invalid=4
  uint64    fork_id      // Fork identifier
  uint64    chain_id     // Chain identifier
  Debug     debug        // Debug information
}
```

### L2 Block Entry

**Location:** `zk/datastream/types/l2block_proto.go`

```
L2Block {
  uint64  number              // Block number
  uint64  batch_number        // Parent batch
  uint64  timestamp           // Block timestamp
  uint32  delta_timestamp     // Time delta from previous block
  uint32  l1_infotree_index   // L1 info tree index
  bytes   l1_blockhash        // L1 block hash (32 bytes)
  bytes   hash                // Block hash (32 bytes)
  bytes   state_root          // State merkle root (32 bytes)
  bytes   global_exit_root    // GER from L1 (32 bytes)
  bytes   coinbase            // Block proposer address (20 bytes)
  uint64  block_gas_limit     // Gas limit
  bytes   block_info_root     // Block info merkle root (32 bytes)
  bytes   base_fee            // Base fee per gas (32 bytes)
  Debug   debug
}
```

### Transaction Entry

**Location:** `zk/datastream/types/tx_proto.go`

```
Transaction {
  uint64  l2block_number                   // Block containing transaction
  uint64  index                            // Position in block
  bool    is_valid                         // Validity flag
  bytes   encoded                          // RLP-encoded transaction
  uint32  effective_gas_price_percentage   // Gas price adjustment
  bytes   im_state_root                    // Intermediate state root (32 bytes)
  Debug   debug
}
```

### Batch End Entry

```
BatchEnd {
  uint64  number           // Batch number
  bytes   local_exit_root  // L2-to-L1 exit root (32 bytes)
  bytes   state_root       // Final state root (32 bytes)
  Debug   debug
}
```

### Global Exit Root Update Entry

**Location:** `zk/datastream/types/ger_update.go`

```
UpdateGER {
  uint64  batch_number      // Batch number
  uint64  timestamp         // Timestamp
  bytes   global_exit_root  // New GER value (32 bytes)
  bytes   coinbase          // Proposer (20 bytes)
  uint64  fork_id           // Fork ID
  uint64  chain_id          // Chain ID
  bytes   state_root        // State root (32 bytes)
  Debug   debug
}

Binary encoding: 106 bytes (or 102 pre-Etrog fork)
Layout: BatchNumber(8) + Timestamp(8) + GER(32) + Coinbase(20) +
        ForkId(2) + ChainId(4) + StateRoot(32)
```

### Bookmark Entry

**Location:** `zk/datastream/types/bookmark_proto.go`

```
BookMark {
  BookmarkType type   // BATCH=1, L2_BLOCK=2
  uint64       value  // Batch or block number
}
```

## File Format

### File Entry Structure

**Location:** `zk/datastream/types/file.go`

```
FileEntry {
  uint8   PacketType   // 0:Padding, 1:Header, 2:Data
  uint32  Length       // Total entry length in bytes
  uint32  EntryType    // Message type (see above)
  uint64  EntryNum     // Sequential entry number
  []byte  Data         // Variable-length payload
}

Minimum size: 17 bytes (header only)
Encoding: Big-endian
```

### Header Entry

**Location:** `zk/datastream/types/header.go`

```
HeaderEntry {
  uint8   PacketType    // Always 1 for header
  uint32  HeadLength    // 38 bytes (post-Etrog) or 29 (pre-Etrog)
  uint8   Version       // Protocol version (3 for current)
  uint64  SystemId      // System identifier
  uint64  StreamType    // 1 = Sequencer stream
  uint64  TotalLength   // Total file bytes
  uint64  TotalEntries  // Total data entries
}

Size: 38 bytes (current) or 29 bytes (legacy)
```

### Result Entry

**Location:** `zk/datastream/types/result.go`

```
ResultEntry {
  uint8   PacketType   // 0xff for result packet
  uint32  Length       // Entry length
  uint32  ErrorNum     // 0=success, else error code
  []byte  ErrorStr     // Error message
}

Error Codes:
  CmdErrOK              = 0   // Success
  CmdErrAlreadyStarted  = 1   // Command sent while streaming
  CmdErrAlreadyStopped  = 2   // Stop sent when not streaming
  CmdErrBadFromEntry    = 3   // Invalid entry number for resume
  CmdErrBadFromBookmark = 4   // Invalid bookmark
  CmdErrInvalidCommand  = 9   // Unknown command
```

## Connection Handling

**Location:** `zk/datastream/client/stream_client.go`

### Client Initialization

```go
client := NewClient(
    ctx,              // Context
    "host:port",      // Server address
    useTLS,           // Enable TLS encryption
    checkTimeout,     // Read/write timeout (min 500ms)
    latestForkId,     // Current fork ID
    maxEntryChanSize, // Entry channel buffer size
)
```

### Connection Lifecycle

1. **Start()** - Establishes TCP or TLS connection
2. **GetHeader()** - Fetches stream metadata and state
3. **ReadAllEntriesToChannel()** - Streams entries continuously
4. **Stop()** - Gracefully closes connection

### TCP Commands

**Location:** `zk/datastream/client/commands.go`

| Command | Value | Description |
|---------|-------|-------------|
| `CmdStart` | 1 | Begin streaming from entry number |
| `CmdStop` | 2 | Stop streaming |
| `CmdHeader` | 3 | Get stream header |
| `CmdStartBookmark` | 4 | Start from bookmark |
| `CmdEntry` | 5 | Get specific entry |
| `CmdBookmark` | 6 | Get bookmark position |

Command format:
```
uint64  Command ID
uint64  StreamType (always 1 for sequencer)
```

### Network I/O

**Location:** `zk/datastream/client/utils.go`

- `writeFullUint64ToConn()` - Send 8-byte values (big-endian)
- `writeFullUint32ToConn()` - Send 4-byte values (big-endian)
- `writeBytesToConn()` - Send raw bytes
- `readBuffer()` - Read exact number of bytes with timeout

All operations use non-blocking sockets with configurable deadlines.

### TLS Support

- Optional encryption via `tls.Dial()`
- Server name validation from host:port
- Configurable TLS settings

## Error Recovery

### Error Types

```go
ErrSocket                    // Base socket error
ErrNilConnection             // Connection is nil
ErrFileEntryNotFound         // Entry missing in stream
ErrReachedEntryNumberLimit   // Stream boundary reached
ErrAlreadyStarted            // Command sent while streaming
ErrAlreadyStopped            // Stop sent when not streaming
ErrBadFromEntry              // Invalid entry number for resume
ErrBadFromBookmark           // Invalid bookmark
ErrInvalidCommand            // Unknown command
```

### Reconnection Strategy

```go
HandleStart() {
    if !c.started {
        c.Start()        // Cold start
        c.started = true
    }

    if c.lastError != nil {
        c.tryReConnect() // Error recovery
        c.lastError = nil
    }
}

tryReConnect() {
    c.conn.Close()
    c.Start()  // Retry connection
}
```

### Timeout Handling

- **Minimum timeout:** 500ms
- **Read timeout:** Applied before each socket read
- **Write timeout:** Applied before each socket write
- **Configurable:** Via `checkTimeout` parameter

### Resume from Checkpoint

```go
readAllEntriesToChannel() {
    progress := c.progress.Load()

    if progress == 0 {
        // Start from beginning
        bookmark = NewBookmarkProto(0, BOOKMARK_TYPE_BATCH)
    } else {
        // Resume from last processed block
        bookmark = NewBookmarkProto(progress+1, BOOKMARK_TYPE_L2_BLOCK)
    }

    c.initiateDownloadBookmark(bookmark)
}
```

The `progress` atomic variable tracks the last successfully processed L2 block number.

## Sequencer to RPC Sync Flow

### Sequencer-Side: Writing to Stream

**Location:** `zk/datastream/server/datastream_populate.go`

#### Genesis Initialization

```go
WriteGenesisToStream(genesis, reader, tx)
// Writes block 0 to initialize stream
```

#### Block Writing (Sequential)

```go
WriteBlocksToStreamConsecutively(ctx, logPrefix, tx, reader, from, to)
```

Process:
1. Load blocks from database (from block `from` to `to`)
2. For each block:
   - Check if batch changes → write BATCH_START + GER updates
   - Write BLOCK_BOOKMARK
   - Write L2_BLOCK entry
   - Write TRANSACTION entries (one per tx)
   - Write BLOCK_END entry
   - When batch completes → write BATCH_END
3. Uses atomic operations: `StartAtomicOp()` → write entries → `CommitAtomicOp()`
4. Batches commits every 80,000 entries or when complete

#### Batch Writing (Whole)

```go
WriteWholeBatchToStream(logPrefix, tx, reader, prevBatchNum, batchNum)
```

Writes entire batch atomically:
1. BATCH_BOOKMARK
2. BATCH_START
3. All blocks in batch (with bookmarks and transactions)
4. GER updates for batch gap
5. BATCH_END

### RPC Node-Side: Reading from Stream

**Location:** `zk/stages/stage_batches.go`

#### Initialization

```go
dsClient := NewClient(ctx, "sequencer:6900", useTLS, 5*time.Second, forkId, 100000)
dsClient.Start()
```

#### Continuous Synchronization

```go
ReadAllEntriesToChannel() {
    // 1. Get header to know stream bounds
    header := GetHeader()

    // 2. Resume from checkpoint or start at batch 0
    progress := GetProgressAtomic().Load()
    if progress == 0 {
        bookmark = Batch(0)
    } else {
        bookmark = Block(progress+1)
    }

    // 3. Stream entries to channel
    for entry := range stream {
        switch entry.(type) {
        case BookmarkProto:
            // Position marker for resume points
        case BatchStart:
            currentFork = entry.ForkId
        case FullL2Block:
            entry.ForkId = currentFork
            entryChan <- entry
        case BatchEnd:
            // Batch finalized
        case GerUpdate:
            // Process L1 state update
        }
    }
}
```

#### Per-Block Processing

```go
SpawnStageBatches(StageState, Unwinder, ctx, tx, cfg) {
    // 1. Get latest L2 block from stream
    fullBlock := dsClient.GetLatestL2Block()

    // 2. Process block transactions
    for tx := range fullBlock.L2Txs {
        // Execute transaction, update state
    }

    // 3. Save progress
    SaveStageProgress(tx, stages.Batches, blockNumber)
    GetProgressAtomic().Store(blockNumber)
}
```

#### On-Demand Block Retrieval

```go
block := dsClient.GetL2BlockByNumber(blockNum)

// Process:
// 1. Send CmdStartBookmark with block bookmark
// 2. Stream entries until BLOCK_END
// 3. Close connection
```

### Data Stream Catch-Up Stage

**Location:** `zk/stages/stage_data_stream_catch_up.go`

```go
CatchupDatastream(ctx, logPrefix, tx, srv) {
    // Determine target block
    if isSequencer {
        finalBlock = GetStageProgress(tx, stages.DataStream)
    } else {
        finalBlock = GetStageProgress(tx, stages.Execution)
    }

    // Write genesis if needed
    if previousProgress == 0 && stream.TotalEntries == 0 {
        WriteGenesisToStream(genesis)
    }

    // Sync all blocks up to target
    WriteBlocksToStreamConsecutively(ctx, logPrefix, tx, reader,
                                     previousProgress+1, finalBlock)

    SaveStageProgress(tx, stages.DataStream, finalBlock)
}
```

## Synchronization States

### Sequencer State Machine

1. **Execute** → Validate and execute batches
2. **Data Stream Write** → Write blocks to stream
3. **Sequence Execute** → Handle batch lifecycle
4. **Check Alignment** → Ensure execution ≤ datastream

### RPC Node State Machine

1. **Data Stream Catch-Up** → Initial sync to sequencer
2. **Batches** → Process blocks from stream
3. **Execution** → Apply state changes
4. **Continuous** → Monitor stream for new blocks

## Entry Parsing

**Location:** `zk/datastream/client/stream_client.go`

```go
ReadParsedProto(iterator FileEntryIterator) {
    file := iterator.NextFileEntry()

    switch file.EntryType {
    case BookmarkEntryType:
        // Parse bookmark
    case EntryTypeBatchStart:
        // Parse batch header
    case EntryTypeL2Block:
        // Parse block + read following transactions
        for {
            tx := iterator.NextFileEntry()
            if tx.IsL2Tx() {
                block.L2Txs = append(block.L2Txs, parseTx(tx))
            } else if tx.IsL2BlockEnd() {
                break
            }
        }
    case EntryTypeBatchEnd:
        // Parse batch finalization
    case EntryTypeGerUpdate:
        // Parse L1 state update
    }
}
```

## Atomic Operations

Server-side atomicity ensures consistency:

```go
streamServer.StartAtomicOp()
defer streamServer.RollbackAtomicOp()

// Write multiple entries
commitEntriesToStreamProto(entries)

// Commit atomically
commitAtomicOp(&latestBlock, &latestBatch, &latestClosedBatch)
```

All entries between `StartAtomicOp()` and `CommitAtomicOp()` are written as a single transaction.

## Configuration

| Setting | Default | Description |
|---------|---------|-------------|
| `zkevm.datastream-host` | - | Data stream server host |
| `zkevm.datastream-port` | 6900 | Data stream server port |
| `zkevm.datastream-tls` | false | Enable TLS encryption |

## Key Source Files

- `zk/datastream/client/stream_client.go` - Client implementation
- `zk/datastream/client/commands.go` - TCP command definitions
- `zk/datastream/client/utils.go` - Network utilities
- `zk/datastream/server/datastream_populate.go` - Server-side writing
- `zk/datastream/types/*.go` - Message type definitions
- `zk/stages/stage_batches.go` - Batch processing stage
- `zk/stages/stage_data_stream_catch_up.go` - Catch-up stage
- `zk/stages/stage_sequence_execute_data_stream.go` - Sequencer integration

## Related Documentation

- [Sync Stages](sync-stages.md)
- [Fork ID Management](fork-id-management.md)
