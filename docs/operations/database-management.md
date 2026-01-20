# Database Management

This guide covers managing the cdk-erigon database, including data directory structure, disk usage monitoring, and pruning options.

## Data Directory Structure

cdk-erigon stores all chain data in a single data directory. The location is configured via the `datadir` option.

### Configuration

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

<Tabs>
<TabItem value="yaml" label="YAML Config" default>

```yaml
datadir: /data/cdk-erigon
```

</TabItem>
<TabItem value="cli" label="CLI Flags">

```bash
cdk-erigon --datadir=/data/cdk-erigon
```

</TabItem>
<TabItem value="env" label="Environment Variables">

```bash
export DATADIR=/data/cdk-erigon
```

</TabItem>
</Tabs>

### Directory Layout

```
<datadir>/
├── chaindata/           # Main chain database (MDBX)
│   ├── mdbx.dat         # Main database file
│   └── mdbx.lck         # Lock file
├── nodes/               # P2P node database
│   └── nodes.db         # Discovered nodes
├── txpool/              # Transaction pool database
│   └── acl/             # Access control list database
├── snapshots/           # Block snapshots (optional)
├── temp/                # Temporary files during sync
└── l1cache/             # L1 data cache (when enabled)
```

| Directory | Purpose | Typical Size |
|-----------|---------|--------------|
| `chaindata/` | Main blockchain state and history | 100-500+ GB |
| `nodes/` | P2P peer discovery data | < 100 MB |
| `txpool/` | Pending transactions and ACL | < 1 GB |
| `snapshots/` | Compressed historical data | Variable |
| `l1cache/` | Cached L1 RPC responses | Variable |

## Disk Usage Monitoring

### Example 1: Check Disk Usage

Monitor disk usage of your data directory:

```bash
#!/bin/bash
# disk-usage.sh - Monitor cdk-erigon disk usage

DATADIR="${1:-/data/cdk-erigon}"

echo "=== cdk-erigon Disk Usage ==="
echo "Data directory: $DATADIR"
echo ""

# Total usage
echo "Total usage:"
du -sh "$DATADIR"
echo ""

# Breakdown by subdirectory
echo "Breakdown by directory:"
du -sh "$DATADIR"/* 2>/dev/null | sort -rh
echo ""

# Main database file
if [ -f "$DATADIR/chaindata/mdbx.dat" ]; then
  echo "Main database (mdbx.dat):"
  ls -lh "$DATADIR/chaindata/mdbx.dat"
fi
echo ""

# Disk space available
echo "Disk space available:"
df -h "$DATADIR" | tail -1
```

### Example 2: Prometheus Disk Metrics

Add disk usage metrics to your monitoring stack:

```yaml
# prometheus disk monitoring via node_exporter
- job_name: 'node'
  static_configs:
    - targets: ['localhost:9100']

# Add alerting rule for low disk space
groups:
  - name: disk
    rules:
      - alert: LowDiskSpace
        expr: |
          (node_filesystem_avail_bytes{mountpoint="/data"}
           / node_filesystem_size_bytes{mountpoint="/data"}) * 100 < 10
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Low disk space on {{ $labels.instance }}"
          description: "Less than 10% disk space remaining"
```

## Database Maintenance

### MDBX Database

cdk-erigon uses MDBX (Memory-Mapped Database Extreme) for storing chain data. MDBX is designed for high performance and doesn't require routine maintenance like vacuuming.

### Example 3: Database Compaction

While MDBX handles space management automatically, you can reduce database size by stopping the node and performing a copy operation:

```bash
#!/bin/bash
# compact-db.sh - Compact cdk-erigon database

DATADIR="${1:-/data/cdk-erigon}"
BACKUP_DIR="${2:-/data/cdk-erigon-backup}"

echo "=== Database Compaction ==="
echo "WARNING: Stop cdk-erigon before running this script"
echo ""

# Check if node is running
if pgrep -f "cdk-erigon" > /dev/null; then
  echo "ERROR: cdk-erigon is still running. Stop it first."
  exit 1
fi

# Record original size
ORIGINAL_SIZE=$(du -sh "$DATADIR/chaindata" | cut -f1)
echo "Original chaindata size: $ORIGINAL_SIZE"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Copy database (this performs implicit compaction)
echo "Copying database (this may take a while)..."
mdbx_copy -c "$DATADIR/chaindata/mdbx.dat" "$BACKUP_DIR/mdbx.dat"

if [ $? -eq 0 ]; then
  # Record new size
  NEW_SIZE=$(du -sh "$BACKUP_DIR/mdbx.dat" | cut -f1)
  echo "Compacted database size: $NEW_SIZE"

  # Replace original
  echo "Replace original? (y/n)"
  read -r response
  if [ "$response" = "y" ]; then
    mv "$DATADIR/chaindata/mdbx.dat" "$DATADIR/chaindata/mdbx.dat.old"
    mv "$BACKUP_DIR/mdbx.dat" "$DATADIR/chaindata/mdbx.dat"
    echo "Database replaced. You can delete mdbx.dat.old after verifying."
  fi
else
  echo "ERROR: Compaction failed"
  exit 1
fi
```

:::note
The `mdbx_copy` tool is included with MDBX. If not available, you can use a simple file copy, but it won't provide compaction benefits.
:::

## Sparse Merkle Tree (SMT) Considerations

cdk-erigon maintains a Sparse Merkle Tree (SMT) for zkEVM state verification. The SMT may need to be rebuilt in certain situations:

### When SMT Rebuild Occurs

- After significant network lag (falling behind by many blocks)
- After database corruption recovery
- When changing commitment type configuration

### SMT Rebuild Options

<Tabs>
<TabItem value="yaml" label="YAML Config" default>

```yaml
# Use RAM for faster SMT rebuild (requires sufficient memory)
zkevm.smt-regenerate-in-memory: true

# Rebuild tree after N blocks (default: 0 = auto)
zkevm.rebuild-tree-after: 0
```

</TabItem>
<TabItem value="cli" label="CLI Flags">

```bash
cdk-erigon \
  --zkevm.smt-regenerate-in-memory=true \
  --zkevm.rebuild-tree-after=0
```

</TabItem>
</Tabs>

:::warning Memory Requirements
Setting `zkevm.smt-regenerate-in-memory=true` requires significant RAM (32GB+ recommended). Monitor memory usage to avoid OOM conditions.
:::

## Disk Space Planning

| Network | Estimated Size (Full) | Growth Rate |
|---------|----------------------|-------------|
| zkEVM Mainnet | 200-400 GB | ~10-20 GB/month |
| zkEVM Cardona | 50-100 GB | ~5-10 GB/month |
| Custom CDK | Varies | Depends on activity |

### Recommended Disk Setup

1. **Use SSD storage** - NVMe preferred for best performance
2. **Allocate 2x current chain size** - Room for growth
3. **Monitor disk usage** - Set alerts at 80% capacity
4. **Separate data volume** - Keep chain data on dedicated mount

## Cleaning Up

### Remove Temporary Files

```bash
# Remove temp files (safe when node is stopped)
rm -rf "$DATADIR/temp"/*
```

### Clear L1 Cache

```bash
# Remove L1 cache to free space (will be rebuilt)
rm -rf "$DATADIR/l1cache"/*
```

:::caution
Only delete cache directories when the node is stopped. Deleting while running may cause errors or data corruption.
:::

## Related Topics

- [Backup and Recovery](./backup-recovery.md) - Backing up your node data
- [Performance Tuning](./performance-tuning.md) - Optimizing disk I/O
- [L1 Recovery](./l1-recovery.md) - Rebuilding from L1 data
