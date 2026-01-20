---
sidebar_position: 3
title: Database Management
description: Manage cdk-erigon data directory
---

# Database Management

Manage your cdk-erigon data directory.

## Data Directory Structure

```
datadir/
├── chaindata/       # Blockchain data
├── nodes/           # Node database
├── txpool/          # Transaction pool
└── snapshots/       # State snapshots
```

## Disk Usage

Monitor disk usage:

```bash
du -sh /data/cdk-erigon/*
```

## Pruning

cdk-erigon uses efficient storage but data grows over time.

### Check Size

```bash
du -sh /data/cdk-erigon/chaindata
```

### Full Resync

For a clean state, remove and resync:

```bash
# Stop cdk-erigon first
rm -rf /data/cdk-erigon/chaindata
# Restart to resync
```

## Database Tools

### Integrity Check

```bash
cdk-erigon db inspect --datadir=/data/cdk-erigon
```

## Next Steps

- [Backup and Recovery](./backup-recovery) - Backup procedures
- [Performance Tuning](./performance-tuning) - Optimize storage
