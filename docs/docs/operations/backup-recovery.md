---
sidebar_position: 4
title: Backup and Recovery
description: Backup and restore cdk-erigon data
---

# Backup and Recovery

Backup and restore your cdk-erigon node data.

## Backup

### Stop Node First

Always stop cdk-erigon before backing up:

```bash
# Stop the node
systemctl stop cdk-erigon

# Create backup
tar -czf cdk-erigon-backup-$(date +%Y%m%d).tar.gz /data/cdk-erigon

# Restart
systemctl start cdk-erigon
```

### Hot Backup (Not Recommended)

Hot backups may result in inconsistent state. Only use if downtime is not acceptable.

## Restore

### From Backup

```bash
# Stop node
systemctl stop cdk-erigon

# Remove existing data
rm -rf /data/cdk-erigon

# Restore
tar -xzf cdk-erigon-backup-20240120.tar.gz -C /

# Start node
systemctl start cdk-erigon
```

## Snapshot Download

For faster initial sync, download snapshots if available:

```bash
# Download snapshot
wget https://snapshots.example.com/cdk-erigon-mainnet.tar.gz

# Extract
tar -xzf cdk-erigon-mainnet.tar.gz -C /data/cdk-erigon
```

## Next Steps

- [L1 Recovery](./l1-recovery) - Recover from L1
- [Upgrading](./upgrading) - Version upgrades
