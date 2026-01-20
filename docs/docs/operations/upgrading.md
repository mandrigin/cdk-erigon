---
sidebar_position: 7
title: Upgrading
description: Upgrade cdk-erigon to new versions
---

# Upgrading

Upgrade your cdk-erigon node to new versions.

## Before Upgrading

1. Check [release notes](https://github.com/0xPolygon/cdk-erigon/releases)
2. Review breaking changes
3. Backup your data
4. Plan for downtime

## Upgrade Process

### Binary Upgrade

```bash
# Stop node
systemctl stop cdk-erigon

# Backup (optional but recommended)
cp /usr/local/bin/cdk-erigon /usr/local/bin/cdk-erigon.bak

# Download new version
curl -LO https://github.com/0xPolygonHermez/cdk-erigon/releases/download/v2.65.0/cdk-erigon-linux-amd64.tar.gz

# Install
tar -xzf cdk-erigon-linux-amd64.tar.gz
mv cdk-erigon /usr/local/bin/

# Start
systemctl start cdk-erigon
```

### Docker Upgrade

```bash
# Pull new image
docker pull hermeznetwork/cdk-erigon:v2.65.0

# Restart container with new image
docker-compose up -d
```

## Fork ID Upgrades

Network fork upgrades require running compatible versions before activation:

1. Monitor announcements for fork dates
2. Upgrade before fork activation block
3. Verify node continues syncing after fork

## Rollback

If issues occur:

```bash
# Stop node
systemctl stop cdk-erigon

# Restore backup binary
mv /usr/local/bin/cdk-erigon.bak /usr/local/bin/cdk-erigon

# Start
systemctl start cdk-erigon
```

## Next Steps

- [Monitoring](./monitoring) - Monitor after upgrade
- [Troubleshooting](../troubleshooting/sync-issues) - Fix issues
