---
sidebar_position: 3
title: Build from Source
description: Build cdk-erigon from source code
---

# Build from Source

Compile cdk-erigon from the source repository.

## Prerequisites

- Go 1.19+
- GCC/G++ 12+
- Make
- Git

## Clone Repository

```bash
git clone https://github.com/0xPolygon/cdk-erigon.git
cd cdk-erigon
git checkout zkevm
```

## Build

```bash
# Build native libraries
make build-libs

# Build cdk-erigon binary
make cdk-erigon
```

## Verify

```bash
./build/bin/cdk-erigon --version
```

## Apple Silicon Notes

On ARM64/Apple Silicon, the Poseidon library may fall back to a slower implementation. For production use on ARM, consider using x86_64 builds or Docker with Rosetta.

## Next Steps

- [Kubernetes](./kubernetes) - K8s deployment
- [Configuration](../configuration/methods) - Configure your build
