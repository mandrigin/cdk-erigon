# ARM and Apple Silicon

cdk-erigon supports ARM64 architecture, including Apple Silicon (M1/M2/M3/M4) Macs. This page covers platform-specific considerations and performance notes.

## Platform Support

| Platform | Support Level | Notes |
|----------|---------------|-------|
| Linux x86_64 | Full | Optimized Poseidon hashing |
| Linux ARM64 | Full | iden3 Poseidon fallback |
| macOS Intel | Full | Optimized Poseidon hashing |
| macOS Apple Silicon | Full | iden3 Poseidon fallback |

## Poseidon Hashing Library

cdk-erigon uses Poseidon hashing for the Sparse Merkle Tree (SMT) state storage. The implementation varies by platform:

### x86_64 (Intel/AMD)

On x86_64 systems, cdk-erigon uses an optimized vectorized Poseidon implementation that leverages SIMD instructions for maximum performance.

**Required dependencies** (Linux):

```bash
sudo apt install libgtest-dev libomp-dev libgmp-dev
```

### ARM64 / Apple Silicon

On ARM64 systems (including Apple Silicon), cdk-erigon automatically falls back to the [iden3 Poseidon library](https://github.com/iden3/go-iden3-crypto), which is a pure Go implementation.

**No additional dependencies required** for the Poseidon library on ARM64.

## Installation on Apple Silicon

### Prerequisites

```bash
# Install Xcode command line tools
xcode-select --install

# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Go and dependencies
brew install go libomp gmp
```

### Building from Source

```bash
# Clone repository
git clone https://github.com/0xPolygonHermez/cdk-erigon.git
cd cdk-erigon
git checkout zkevm

# Install dependencies (macOS-specific)
make build-libs

# Build
make cdk-erigon

# Verify
./build/bin/cdk-erigon --version
```

### Docker on Apple Silicon

Docker Desktop for Mac supports ARM64 images. The cdk-erigon image will automatically use the appropriate architecture:

```bash
# Run on Apple Silicon (uses ARM64 image)
docker run -d \
  --name cdk-erigon \
  -p 8545:8545 \
  -v ./data:/home/erigon/.local/share/erigon \
  hermeznetwork/cdk-erigon \
  --config="./cardona.yaml" \
  --zkevm.l1-rpc-url=https://rpc.sepolia.org
```

## Performance Considerations

### SMT Hashing Performance

The vectorized Poseidon implementation on x86_64 is significantly faster than the iden3 fallback on ARM64. This primarily affects:

- **Initial sync**: SMT state construction from genesis
- **SMT rebuild**: When catching up after extended downtime
- **State root computation**: During block processing

**Expected performance difference**: ARM64/Apple Silicon may be 2-5x slower for SMT-intensive operations compared to x86_64.

### Mitigations

For developers on Apple Silicon experiencing slow sync:

1. **Use in-memory SMT regeneration** (if you have enough RAM):

   ```yaml
   zkevm.smt-regenerate-in-memory: true
   ```

   This uses RAM instead of disk for SMT rebuilds, improving performance at the cost of higher memory usage.

2. **Consider x86_64 for production**: For production workloads requiring maximum performance, deploy on x86_64 infrastructure.

3. **Use pre-synced snapshots**: Start with a pre-synced data directory to avoid initial SMT construction time.

### Memory Usage

ARM64 and x86_64 have similar memory requirements:

| Operation | Minimum RAM | Recommended RAM |
|-----------|-------------|-----------------|
| RPC node sync | 32 GB | 64 GB |
| SMT regeneration | 32 GB | 64 GB |
| In-memory SMT regen | 64 GB | 128 GB |

## Linux ARM64

### Ubuntu/Debian ARM64

```bash
# Install dependencies
sudo apt update
sudo apt install -y build-essential git make
sudo apt install -y libgtest-dev libomp-dev libgmp-dev

# Install Go for ARM64
wget https://go.dev/dl/go1.24.linux-arm64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.24.linux-arm64.tar.gz
export PATH=$PATH:/usr/local/go/bin

# Build cdk-erigon
git clone https://github.com/0xPolygonHermez/cdk-erigon.git
cd cdk-erigon
git checkout zkevm
make cdk-erigon
```

### Raspberry Pi

While cdk-erigon can technically run on ARM64 devices like Raspberry Pi 5, the hardware requirements (32GB+ RAM, fast NVMe storage) make this impractical for most use cases.

## Troubleshooting

### OpenMP on macOS

If you encounter OpenMP errors on macOS:

```bash
# Ensure libomp is installed
brew install libomp

# If still having issues, set the library path
export LIBRARY_PATH="/opt/homebrew/opt/libomp/lib:$LIBRARY_PATH"
```

### GMP Library Not Found

```bash
# macOS
brew install gmp
export LIBRARY_PATH="/opt/homebrew/opt/gmp/lib:$LIBRARY_PATH"
export CPATH="/opt/homebrew/opt/gmp/include:$CPATH"
```

### Rosetta 2 Warning

If you see Rosetta 2 translation warnings on Apple Silicon, ensure you're:
- Using the ARM64 Go binary (not the AMD64 version)
- Building natively without x86 emulation

Verify your Go installation:

```bash
go env GOARCH
# Should output: arm64
```

## Benchmarking

To compare performance on your system:

```bash
# Run tests with timing
go test -v -run=^$ -bench=. ./zk/...

# Monitor SMT performance during sync
# (enable debug timers in config)
debug.timers: true
```

## Next Steps

- [Build from source](./build-from-source.md)
- [Configure your node](../configuration/index.md)
- [Performance tuning](../operations/performance.md)
