---
sidebar_position: 3
title: Contributing
description: Guidelines for contributing to cdk-erigon
---

# Contributing

Guidelines for contributing to cdk-erigon.

## Prerequisites

- Go 1.24 or later
- Git
- Linux dependencies: `libgtest-dev`, `libomp-dev`, `libgmp-dev`
- macOS dependencies: `brew install libomp gmp`

## Setup

### Clone and Build

```bash
git clone https://github.com/0xPolygonHermez/cdk-erigon.git
cd cdk-erigon
make build-libs
make erigon
```

### Verify Build

```bash
./build/bin/erigon --help
```

## Development Workflow

### Create a Branch

```bash
git checkout -b feature/my-feature
```

### Run Linting

```bash
make lint
```

This runs:
- golangci-lint on the codebase
- Module tidiness checks

### Run Tests

```bash
make test
```

### Build All Binaries

```bash
make all
```

## Code Style

### Format Code

```bash
gofmt -w .
```

### Import Organization

Use `goimports` for consistent import ordering:

```bash
goimports -w .
```

### Lint Checks

The project uses golangci-lint with custom configuration:

```bash
./erigon-lib/tools/golangci_lint.sh
```

## Pull Request Process

1. Ensure tests pass: `make test`
2. Run linting: `make lint`
3. Update documentation if needed
4. Create PR with clear description

## Project Structure

| Directory | Purpose |
|-----------|---------|
| `cmd/` | CLI entry points |
| `core/` | Core blockchain logic |
| `eth/` | Ethereum protocol |
| `erigon-lib/` | Shared libraries |
| `turbo/` | Performance optimizations |
| `zk/` | zkEVM-specific code |

## Build Tags

Common build tags used:

```bash
# Standard build
-tags nosqlite,noboltdb,netgo

# With Erigon3
-tags nosqlite,noboltdb,netgo,erigon3

# Debug build
-tags nosqlite,noboltdb,debug
```

## Next Steps

- [Running Tests](./running-tests) - Test execution guide
- [Debug Tools](./debug-tools) - Debugging techniques
