---
sidebar_position: 2
title: Debug Tools
description: Debugging tools and techniques for cdk-erigon development
---

# Debug Tools

This guide covers debugging tools and techniques for cdk-erigon.

## Debug Build

Build with debug symbols and MDBX debug mode:

```bash
make GO_DBG_BUILD
```

This compiles with:
- `-gcflags=all="-N -l"` - Disable optimizations for debugging
- `-DMDBX_DEBUG=1` - Enable MDBX assertions

## Delve Debugger

### Install Delve

```bash
go install github.com/go-delve/delve/cmd/dlv@latest
```

### Debug a Test

```bash
dlv test ./cmd/rpcdaemon/... -- -test.run TestFunctionName
```

### Debug the Binary

```bash
dlv exec ./build/bin/erigon -- --datadir=/path/to/data
```

### Attach to Running Process

```bash
dlv attach <pid>
```

## Log-Based Debugging

### Increase Log Verbosity

```yaml
log:
  console:
    level: debug
```

Or via flag:

```bash
./build/bin/erigon --log.console.verbosity=debug
```

### Stage Timing Analysis

Look for timing logs after sync cycles:

```
INFO Timings Headers=468ms Bodies=3.5s Execution=75ms HashState=56ms
```

## Database Inspection

### Check Database State

```bash
./build/bin/erigon snapshots verify --datadir=/path/to/data
```

### Historical Execution Check

Verify changesets from a specific block:

```bash
./build/bin/state checkChangeSets --datadir=/path/to/data --block=1000000
```

## RPC Debugging

### Test Individual RPC Methods

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'
```

### Debug Trace a Transaction

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"debug_traceTransaction","params":["0x..."],"id":1}'
```

## Common Issues

| Issue | Debug Approach |
|-------|----------------|
| Wrong trie root | Check `IntermediateHashes` stage logs |
| Sync stall | Inspect stage timings and peer count |
| RPC mismatch | Use rpctest comparative testing |
| Memory growth | Profile with `pprof` endpoints |

## Next Steps

- [Running Tests](./running-tests) - Test execution guide
- [Contributing](./contributing) - Contribution guidelines
