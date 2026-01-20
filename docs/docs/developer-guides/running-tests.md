---
sidebar_position: 1
title: Running Tests
description: Guide to running tests in cdk-erigon
---

# Running Tests

This guide covers how to run tests in the cdk-erigon codebase.

## Quick Start

Run all tests:

```bash
make test
```

## Test Commands

### Unit Tests

Run the standard test suite:

```bash
make test
```

This executes:

```bash
go test -tags nosqlite,noboltdb,netgo -coverprofile=coverage.out ./... -p 2
```

### Erigon3 Tests

Run tests with Erigon3 tags:

```bash
make test3
```

### Library Tests

Test the erigon-lib module:

```bash
make test-erigon-lib
```

### Integration Tests

```bash
make test-integration
```

## Running Specific Tests

### Single Package

```bash
go test ./cmd/rpcdaemon/...
```

### Single Test Function

```bash
go test -run TestFunctionName ./path/to/package
```

### With Verbose Output

```bash
go test -v -run TestFunctionName ./path/to/package
```

## Test Coverage

Generate coverage report:

```bash
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out -o coverage.html
```

## RPC Testing

### Comparative Testing

Compare RPC responses between releases:

```bash
make rpctest
./build/bin/rpctest bench8 --erigonUrl http://localhost:8545 --gethUrl http://reference:8545 --needCompare --blockFrom 9000000 --blockTo 9000100
```

### Record and Replay

Record test queries:

```bash
./build/bin/rpctest bench8 --erigonUrl http://localhost:8545 --recordFile req.txt
```

Replay recorded queries:

```bash
./build/bin/rpctest replay --erigonUrl http://localhost:8545 --recordFile req.txt
```

## Next Steps

- [Debug Tools](./debug-tools) - Debugging techniques
- [Contributing](./contributing) - Contribution guidelines
