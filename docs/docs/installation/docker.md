---
sidebar_position: 2
title: Docker
description: Deploy cdk-erigon using Docker
---

# Docker Deployment

Run cdk-erigon in a Docker container.

## Quick Start

```bash
docker run -d \
  --name cdk-erigon \
  -v /data/cdk-erigon:/data \
  -p 8545:8545 \
  hermeznetwork/cdk-erigon:latest
```

## Docker Compose

```yaml
version: '3.8'
services:
  cdk-erigon:
    image: hermeznetwork/cdk-erigon:latest
    container_name: cdk-erigon
    volumes:
      - ./data:/data
      - ./config:/etc/cdk-erigon
    ports:
      - "8545:8545"
      - "8546:8546"
    command: --config=/etc/cdk-erigon/config.yaml
    restart: unless-stopped
```

## Volume Mounts

| Path | Purpose |
|------|---------|
| `/data` | Chain data directory |
| `/etc/cdk-erigon` | Configuration files |

## Next Steps

- [Build from Source](./build-from-source) - Custom builds
- [Configuration](../configuration/methods) - Configure your node
