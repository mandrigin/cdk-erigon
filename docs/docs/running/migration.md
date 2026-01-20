---
sidebar_position: 5
title: Migration
description: Migrating between cdk-erigon modes and versions
---

# Migration

## Mode Switching

### RPC to Sequencer

1. Stop the RPC node
2. Set `CDK_ERIGON_SEQUENCER=1`
3. Configure executor URLs
4. Restart with sequencer configuration

:::caution
Mode switching may require data directory changes. Backup before switching.
:::

### Sequencer to RPC

1. Stop the sequencer
2. Unset `CDK_ERIGON_SEQUENCER`
3. Restart with RPC configuration

## Version Upgrades

1. Stop cdk-erigon
2. Backup data directory
3. Download new version
4. Review [changelog](https://github.com/0xPolygon/cdk-erigon/releases) for breaking changes
5. Start new version

## Fork ID Upgrades

Fork ID upgrades happen automatically during sync. Ensure you're running a compatible version before fork activation.

## Next Steps

- [Upgrading](../operations/upgrading) - Detailed upgrade guide
- [Backup](../operations/backup-recovery) - Backup procedures
