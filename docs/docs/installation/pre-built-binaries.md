# Pre-built Binaries

Pre-built binaries are the fastest way to get cdk-erigon running. Binaries are available for Linux (AMD64) and are published with each release.

## Download

### From GitHub Releases

Visit the [cdk-erigon releases page](https://github.com/0xPolygonHermez/cdk-erigon/releases) to download the latest version.

**Example: Download latest release (Linux AMD64)**

```bash
# Download the latest release
curl -LO https://github.com/0xPolygonHermez/cdk-erigon/releases/latest/download/cdk-erigon-linux-amd64

# Make executable
chmod +x cdk-erigon-linux-amd64

# Verify it runs
./cdk-erigon-linux-amd64 --help
```

### Specific Version

To download a specific version:

```bash
# Example: Download v2.64.2
VERSION="v2.64.2"
curl -LO "https://github.com/0xPolygonHermez/cdk-erigon/releases/download/${VERSION}/cdk-erigon-linux-amd64"
chmod +x cdk-erigon-linux-amd64
```

## Verification

Always verify downloaded binaries before running them in production.

### Checksum Verification

Each release includes SHA256 checksums:

```bash
# Download checksums file
curl -LO https://github.com/0xPolygonHermez/cdk-erigon/releases/latest/download/checksums.txt

# Verify the binary
sha256sum -c checksums.txt 2>/dev/null | grep cdk-erigon-linux-amd64
```

Expected output:
```
cdk-erigon-linux-amd64: OK
```

## Adding to PATH

For convenient access, add the binary to your system PATH.

### Option 1: Move to /usr/local/bin (system-wide)

```bash
sudo mv cdk-erigon-linux-amd64 /usr/local/bin/cdk-erigon
```

### Option 2: Add to user's PATH

```bash
# Create a local bin directory
mkdir -p ~/.local/bin

# Move the binary
mv cdk-erigon-linux-amd64 ~/.local/bin/cdk-erigon

# Add to PATH (add to ~/.bashrc or ~/.zshrc for persistence)
export PATH="$HOME/.local/bin:$PATH"
```

### Verify Installation

```bash
cdk-erigon --version
```

## Running

After installation, create a configuration file and start the node:

```bash
# Download example config for Cardona testnet
curl -LO https://raw.githubusercontent.com/0xPolygonHermez/cdk-erigon/zkevm/hermezconfig-cardona.yaml.example
mv hermezconfig-cardona.yaml.example hermezconfig-cardona.yaml

# Edit the config file to set your datadir and L1 RPC URL
# vim hermezconfig-cardona.yaml

# Start the node
cdk-erigon --config="./hermezconfig-cardona.yaml" --zkevm.l1-rpc-url=https://rpc.sepolia.org
```

## Available Binaries

Each release includes binaries for:

| Binary | Description |
|--------|-------------|
| `cdk-erigon` | Main node binary |
| `rpcdaemon` | Standalone RPC daemon (optional) |
| `downloader` | Snapshot downloader (optional) |
| `sentry` | P2P sentry service (optional) |
| `txpool` | Transaction pool service (optional) |

For most use cases, only the `cdk-erigon` binary is needed as it runs all services in a single process.

## Upgrading

To upgrade to a new version:

```bash
# Stop the running node
# (use your process manager or Ctrl+C)

# Download new version
VERSION="v2.65.0"
curl -LO "https://github.com/0xPolygonHermez/cdk-erigon/releases/download/${VERSION}/cdk-erigon-linux-amd64"

# Replace the binary
chmod +x cdk-erigon-linux-amd64
sudo mv cdk-erigon-linux-amd64 /usr/local/bin/cdk-erigon

# Restart the node
cdk-erigon --config="./hermezconfig-cardona.yaml"
```

## Troubleshooting

### Binary not found after adding to PATH

Ensure you've reloaded your shell configuration:

```bash
source ~/.bashrc  # or ~/.zshrc
```

### Permission denied

Ensure the binary has execute permissions:

```bash
chmod +x /path/to/cdk-erigon
```

### glibc version errors

Pre-built binaries require glibc 2.31+. If you see glibc errors, either:
- Upgrade your Linux distribution
- [Build from source](./build-from-source.md) for older systems

## Next Steps

- [Configure your node](../configuration/index.md)
- [Run a node](../running/index.md)
