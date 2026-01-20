---
sidebar_position: 1
title: Pre-built Binaries
description: Install cdk-erigon using pre-built binaries
---

# Pre-built Binaries

Download and install cdk-erigon from GitHub releases.

## Download

Get the latest release from [GitHub Releases](https://github.com/0xPolygonHermez/cdk-erigon/releases).

```bash
# Linux AMD64
curl -LO https://github.com/0xPolygonHermez/cdk-erigon/releases/download/v2.65.0/cdk-erigon-linux-amd64.tar.gz
tar -xzf cdk-erigon-linux-amd64.tar.gz

# Verify
./cdk-erigon --version
```

## Add to PATH

```bash
sudo mv cdk-erigon /usr/local/bin/
```

## Verify Installation

```bash
cdk-erigon --help
```

## Next Steps

- [Docker Installation](./docker) - Container deployment
- [Quick Start](../getting-started/quickstart) - Start your node
