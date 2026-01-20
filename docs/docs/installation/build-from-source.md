# Build from Source

Building cdk-erigon from source gives you the latest features, allows customization, and is required for development work.

## Prerequisites

### Required Software

| Software | Version | Notes |
|----------|---------|-------|
| Go | 1.24+ | Required for building |
| GCC/g++ | 12+ | C/C++ compiler for CGO |
| Git | Any recent | For cloning repository |
| Make | Any | Build automation |

### System Libraries

**Linux (Ubuntu/Debian)**:

```bash
sudo apt update
sudo apt install -y build-essential git make
sudo apt install -y libgtest-dev libomp-dev libgmp-dev
```

**Linux (Fedora/RHEL)**:

```bash
sudo dnf install -y gcc gcc-c++ make git
sudo dnf install -y gtest-devel libomp-devel gmp-devel
```

**macOS**:

```bash
# Install Xcode command line tools
xcode-select --install

# Install dependencies via Homebrew
brew install go libomp gmp
```

### Go Installation

If Go is not installed:

```bash
# Download Go 1.24
wget https://go.dev/dl/go1.24.linux-amd64.tar.gz

# Extract to /usr/local
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.24.linux-amd64.tar.gz

# Add to PATH (add to ~/.bashrc for persistence)
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# Verify installation
go version
```

## Clone Repository

```bash
# Clone the repository
git clone https://github.com/0xPolygonHermez/cdk-erigon.git
cd cdk-erigon

# Checkout the stable branch
git checkout zkevm
```

## Install Dependencies

The Makefile provides a target to install required libraries:

```bash
make build-libs
```

This command installs platform-specific dependencies:
- **Linux**: `libgtest-dev`, `libomp-dev`, `libgmp-dev`
- **macOS**: `libomp`, `gmp` (via Homebrew)

## Build

### Standard Build

```bash
# Build cdk-erigon binary
make cdk-erigon

# Binary location
ls -la ./build/bin/cdk-erigon
```

### Build All Tools

To build cdk-erigon and all auxiliary tools:

```bash
make all
```

This builds:
- `cdk-erigon` - Main node binary
- `rpcdaemon` - Standalone RPC daemon
- `downloader` - Snapshot downloader
- `sentry` - P2P sentry service
- `txpool` - Transaction pool service
- `integration` - Integration testing tools
- And more...

### Debug Build

For development with debugging symbols and MDBX assertions:

```bash
make dbg
```

Debug builds allow viewing C stack traces when run with `GOTRACEBACK=crash`.

### Clean Build

To clean and rebuild:

```bash
make clean
make cdk-erigon
```

## Build Options

### Custom Go Flags

```bash
# Build with race detector (for debugging)
GO_FLAGS="-race" make cdk-erigon

# Build with custom tags
BUILD_TAGS="custom,tags" make cdk-erigon
```

### Cross-Compilation

Cross-compilation is limited due to CGO dependencies. For cross-platform builds, use Docker:

```bash
# Build using Docker (produces Linux binary regardless of host OS)
make docker
```

## Verify Installation

After building:

```bash
# Check version
./build/bin/cdk-erigon --version

# View help
./build/bin/cdk-erigon --help
```

Expected output:

```
cdk-erigon version 2.64.2-stable-abc1234
```

## Install Binaries

### Install to System PATH

```bash
# Install to /usr/local/bin
sudo cp ./build/bin/cdk-erigon /usr/local/bin/

# Or use the install target
DIST=/usr/local/bin make install
```

### Install to User Directory

```bash
mkdir -p ~/.local/bin
cp ./build/bin/cdk-erigon ~/.local/bin/

# Ensure ~/.local/bin is in PATH
export PATH="$HOME/.local/bin:$PATH"
```

## Running After Build

Download a configuration file and start the node:

```bash
# Copy example config
cp hermezconfig-cardona.yaml.example hermezconfig-cardona.yaml

# Edit configuration (set datadir, L1 RPC, etc.)
vim hermezconfig-cardona.yaml

# Run the node
./build/bin/cdk-erigon --config="./hermezconfig-cardona.yaml"
```

## Development Workflow

### Running Tests

```bash
# Run unit tests
make test

# Run integration tests
make test-integration

# Run specific test package
go test ./zk/...
```

### Code Generation

After modifying protobuf files or interfaces:

```bash
# Generate all auto-generated code
make gen

# Generate specific types
make mocks      # Test mocks
make abigen     # Contract bindings
make gencodec   # Marshalling code
```

### Linting

```bash
# Install linting tools
make lint-deps

# Run linters
make lint
```

## Troubleshooting

### Go Version Errors

```
minimum required Golang version is 1.24
```

Upgrade Go to version 1.24 or later.

### Missing Libraries

```
fatal error: gmp.h: No such file or directory
```

Install missing development libraries:

```bash
# Ubuntu/Debian
sudo apt install libgmp-dev

# Fedora/RHEL
sudo dnf install gmp-devel

# macOS
brew install gmp
```

### CGO Errors

```
cgo: C compiler "gcc" not found
```

Install GCC:

```bash
# Ubuntu/Debian
sudo apt install build-essential

# macOS
xcode-select --install
```

### OpenMP Errors

```
fatal error: omp.h: No such file or directory
```

Install OpenMP development package:

```bash
# Ubuntu/Debian
sudo apt install libomp-dev

# macOS
brew install libomp
```

### Silkworm Compatibility

If you see silkworm-related errors, the build will automatically disable silkworm with the `nosilkworm` tag. This is handled automatically by the Makefile.

## Updating

To update to the latest version:

```bash
# Pull latest changes
git fetch origin
git checkout zkevm
git pull origin zkevm

# Update dependencies
go mod download

# Rebuild
make clean
make cdk-erigon
```

## Next Steps

- [Configure your node](../configuration/index.md)
- [ARM and Apple Silicon notes](./arm-apple-silicon.md)
- [Run a node](../running/index.md)
