# Installation

This section covers all the ways to install and deploy cdk-erigon for syncing with Polygon zkEVM and CDK-powered Layer 2 chains.

## Installation Methods

| Method | Best For | Difficulty |
|--------|----------|------------|
| [Pre-built Binaries](./pre-built-binaries.md) | Quick setup, testing | Easy |
| [Docker](./docker.md) | Production deployments, reproducible environments | Easy |
| [Build from Source](./build-from-source.md) | Development, custom builds | Intermediate |
| [Kubernetes](./kubernetes.md) | Enterprise/scaled deployments | Advanced |

## System Requirements

Before installing, ensure your system meets these requirements:

### Hardware

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| CPU | 4 cores | 8+ cores |
| RAM | 32 GB | 64 GB |
| Storage | 500 GB SSD | 1 TB+ NVMe SSD |
| Network | 100 Mbps | 1 Gbps |

### Software

- **Operating System**: Linux (Ubuntu 22.04 LTS or later recommended), macOS
- **Architecture**: AMD64 (x86_64) or ARM64 (Apple Silicon supported)
- **Compiler**: g++ 12+ (for building from source)
- **Go**: 1.24+ (for building from source)

### Platform-Specific Notes

- **Linux x86_64**: Full performance with optimized Poseidon hashing
- **Apple Silicon (M1/M2/M3)**: Supported with iden3 library fallback for Poseidon hashing (see [ARM and Apple Silicon](./arm-apple-silicon.md))
- **Windows**: Not officially supported; use WSL2 with Ubuntu or Docker

## Quick Start

For the fastest path to a running node:

```bash
# Option 1: Docker (recommended for most users)
docker run -d -p 8545:8545 \
  -v ./cdk-erigon-data:/home/erigon/.local/share/erigon \
  hermeznetwork/cdk-erigon \
  --config="./cardona.yaml" \
  --zkevm.l1-rpc-url=https://rpc.sepolia.org

# Option 2: Pre-built binary
curl -LO https://github.com/0xPolygonHermez/cdk-erigon/releases/latest/download/cdk-erigon-linux-amd64
chmod +x cdk-erigon-linux-amd64
./cdk-erigon-linux-amd64 --config="./hermezconfig-cardona.yaml"
```

## Next Steps

After installation, proceed to [Running a Node](../running/index.md) to configure and start your node.
