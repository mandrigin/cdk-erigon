# Backup and Recovery

This guide covers strategies for backing up your cdk-erigon node data and restoring from backups.

## Backup Strategies

### Cold Backup (Recommended)

The safest backup method involves stopping the node to ensure data consistency.

#### Example 1: Basic Cold Backup Script

```bash
#!/bin/bash
# backup-cold.sh - Cold backup of cdk-erigon data directory

set -e

DATADIR="${1:-/data/cdk-erigon}"
BACKUP_DIR="${2:-/backup/cdk-erigon}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="$BACKUP_DIR/backup_$TIMESTAMP"

echo "=== cdk-erigon Cold Backup ==="
echo "Source: $DATADIR"
echo "Destination: $BACKUP_PATH"
echo ""

# Check if node is running
if pgrep -f "cdk-erigon" > /dev/null; then
  echo "Stopping cdk-erigon..."
  systemctl stop cdk-erigon || pkill -f cdk-erigon
  sleep 10
  RESTART_AFTER=true
fi

# Create backup directory
mkdir -p "$BACKUP_PATH"

# Record current state
echo "Recording chain state..."
BLOCK_HEIGHT=$(cat "$DATADIR/chaindata/mdbx.dat" 2>/dev/null | head -c 1000 | strings | grep -oP 'block:\d+' | head -1 || echo "unknown")
echo "Approximate block height: $BLOCK_HEIGHT" > "$BACKUP_PATH/backup_info.txt"
echo "Backup timestamp: $TIMESTAMP" >> "$BACKUP_PATH/backup_info.txt"

# Backup using rsync (preserves permissions, handles large files)
echo "Backing up data directory..."
rsync -av --progress \
  --exclude='temp/*' \
  --exclude='*.lck' \
  "$DATADIR/" "$BACKUP_PATH/data/"

# Calculate checksum of main database
echo "Calculating checksum..."
md5sum "$BACKUP_PATH/data/chaindata/mdbx.dat" > "$BACKUP_PATH/checksums.md5"

# Record disk usage
du -sh "$BACKUP_PATH" >> "$BACKUP_PATH/backup_info.txt"

echo ""
echo "Backup completed: $BACKUP_PATH"
cat "$BACKUP_PATH/backup_info.txt"

# Restart if it was running
if [ "$RESTART_AFTER" = true ]; then
  echo "Restarting cdk-erigon..."
  systemctl start cdk-erigon || true
fi
```

### Hot Backup with MDBX

MDBX supports consistent reads during writes, allowing for hot backups using the `mdbx_copy` tool.

#### Example 2: Hot Backup with mdbx_copy

```bash
#!/bin/bash
# backup-hot.sh - Hot backup using mdbx_copy (no downtime)

set -e

DATADIR="${1:-/data/cdk-erigon}"
BACKUP_DIR="${2:-/backup/cdk-erigon}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="$BACKUP_DIR/backup_$TIMESTAMP"

echo "=== cdk-erigon Hot Backup ==="
echo "Source: $DATADIR"
echo "Destination: $BACKUP_PATH"
echo ""

# Create backup directory
mkdir -p "$BACKUP_PATH/chaindata"

# Get current block height via RPC
if command -v curl &> /dev/null; then
  BLOCK_HEIGHT=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
    http://localhost:8545 | jq -r '.result')
  echo "Current block: $BLOCK_HEIGHT"
  echo "Block at backup start: $BLOCK_HEIGHT" > "$BACKUP_PATH/backup_info.txt"
fi

# Hot copy of main database
echo "Copying chaindata (this may take a while)..."
if command -v mdbx_copy &> /dev/null; then
  mdbx_copy "$DATADIR/chaindata/mdbx.dat" "$BACKUP_PATH/chaindata/mdbx.dat"
else
  echo "WARNING: mdbx_copy not found, using cp (less safe)"
  cp "$DATADIR/chaindata/mdbx.dat" "$BACKUP_PATH/chaindata/"
fi

# Copy other directories (cold - stop writes if critical)
echo "Copying auxiliary data..."
cp -r "$DATADIR/nodes" "$BACKUP_PATH/" 2>/dev/null || true
cp -r "$DATADIR/txpool" "$BACKUP_PATH/" 2>/dev/null || true

# Record backup metadata
echo "Backup timestamp: $TIMESTAMP" >> "$BACKUP_PATH/backup_info.txt"
du -sh "$BACKUP_PATH" >> "$BACKUP_PATH/backup_info.txt"

echo ""
echo "Hot backup completed: $BACKUP_PATH"
```

## Backup to Cloud Storage

### Example 3: Backup to S3 with Compression

```bash
#!/bin/bash
# backup-s3.sh - Backup to AWS S3 with compression

set -e

DATADIR="${1:-/data/cdk-erigon}"
S3_BUCKET="${2:-s3://my-bucket/cdk-erigon-backups}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
NETWORK="${3:-mainnet}"
TEMP_DIR="/tmp/cdk-erigon-backup"

echo "=== cdk-erigon S3 Backup ==="
echo "Source: $DATADIR"
echo "Destination: $S3_BUCKET/$NETWORK/"
echo ""

# Stop the node for consistent backup
echo "Stopping cdk-erigon..."
systemctl stop cdk-erigon
sleep 10

# Create temp directory
mkdir -p "$TEMP_DIR"

# Create compressed archive
echo "Creating compressed archive..."
tar -cvf - -C "$DATADIR" . \
  --exclude='temp/*' \
  --exclude='*.lck' \
  | pigz -p 4 > "$TEMP_DIR/backup_${TIMESTAMP}.tar.gz"

# Calculate size and checksum
BACKUP_SIZE=$(du -h "$TEMP_DIR/backup_${TIMESTAMP}.tar.gz" | cut -f1)
CHECKSUM=$(md5sum "$TEMP_DIR/backup_${TIMESTAMP}.tar.gz" | cut -d' ' -f1)
echo "Backup size: $BACKUP_SIZE"
echo "MD5: $CHECKSUM"

# Upload to S3
echo "Uploading to S3..."
aws s3 cp "$TEMP_DIR/backup_${TIMESTAMP}.tar.gz" \
  "$S3_BUCKET/$NETWORK/backup_${TIMESTAMP}.tar.gz" \
  --storage-class STANDARD_IA

# Upload metadata
echo "timestamp: $TIMESTAMP" > "$TEMP_DIR/backup_info.txt"
echo "size: $BACKUP_SIZE" >> "$TEMP_DIR/backup_info.txt"
echo "md5: $CHECKSUM" >> "$TEMP_DIR/backup_info.txt"
aws s3 cp "$TEMP_DIR/backup_info.txt" \
  "$S3_BUCKET/$NETWORK/backup_${TIMESTAMP}_info.txt"

# Cleanup
rm -rf "$TEMP_DIR"

# Restart the node
echo "Restarting cdk-erigon..."
systemctl start cdk-erigon

echo ""
echo "Backup uploaded to: $S3_BUCKET/$NETWORK/backup_${TIMESTAMP}.tar.gz"
```

## Restoring from Backup

### Example 4: Restore from Local Backup

```bash
#!/bin/bash
# restore.sh - Restore cdk-erigon from backup

set -e

BACKUP_PATH="${1}"
DATADIR="${2:-/data/cdk-erigon}"

if [ -z "$BACKUP_PATH" ]; then
  echo "Usage: $0 <backup_path> [datadir]"
  echo "Example: $0 /backup/cdk-erigon/backup_20240115_120000 /data/cdk-erigon"
  exit 1
fi

echo "=== cdk-erigon Restore ==="
echo "Backup: $BACKUP_PATH"
echo "Target: $DATADIR"
echo ""

# Confirm restoration
echo "WARNING: This will overwrite existing data in $DATADIR"
echo "Continue? (yes/no)"
read -r response
if [ "$response" != "yes" ]; then
  echo "Aborted."
  exit 0
fi

# Stop node if running
if pgrep -f "cdk-erigon" > /dev/null; then
  echo "Stopping cdk-erigon..."
  systemctl stop cdk-erigon || pkill -f cdk-erigon
  sleep 10
fi

# Backup existing data (optional safety measure)
if [ -d "$DATADIR/chaindata" ]; then
  echo "Moving existing data to $DATADIR.old..."
  mv "$DATADIR" "${DATADIR}.old"
fi

# Create data directory
mkdir -p "$DATADIR"

# Check if backup is compressed
if [ -f "$BACKUP_PATH" ] && [[ "$BACKUP_PATH" == *.tar.gz ]]; then
  echo "Extracting compressed backup..."
  tar -xzf "$BACKUP_PATH" -C "$DATADIR"
elif [ -d "$BACKUP_PATH/data" ]; then
  echo "Restoring from directory backup..."
  rsync -av --progress "$BACKUP_PATH/data/" "$DATADIR/"
else
  echo "ERROR: Unrecognized backup format"
  exit 1
fi

# Verify checksum if available
if [ -f "$BACKUP_PATH/checksums.md5" ]; then
  echo "Verifying checksum..."
  cd "$DATADIR/chaindata"
  if md5sum -c "$BACKUP_PATH/checksums.md5"; then
    echo "Checksum verified successfully"
  else
    echo "WARNING: Checksum verification failed!"
    exit 1
  fi
fi

# Remove lock files
rm -f "$DATADIR/chaindata/"*.lck

# Set permissions
chown -R erigon:erigon "$DATADIR" 2>/dev/null || true

echo ""
echo "Restore completed successfully!"
echo ""
echo "Next steps:"
echo "1. Review your configuration file"
echo "2. Start cdk-erigon: systemctl start cdk-erigon"
echo "3. Monitor logs: journalctl -u cdk-erigon -f"
```

## Restore from S3

```bash
#!/bin/bash
# restore-s3.sh - Restore from S3 backup

S3_BACKUP_PATH="${1}"
DATADIR="${2:-/data/cdk-erigon}"

if [ -z "$S3_BACKUP_PATH" ]; then
  echo "Usage: $0 <s3_backup_path> [datadir]"
  echo "Example: $0 s3://my-bucket/cdk-erigon-backups/mainnet/backup_20240115.tar.gz"
  exit 1
fi

echo "Downloading backup from S3..."
aws s3 cp "$S3_BACKUP_PATH" /tmp/cdk-erigon-restore.tar.gz

echo "Extracting backup..."
mkdir -p "$DATADIR"
tar -xzf /tmp/cdk-erigon-restore.tar.gz -C "$DATADIR"

rm /tmp/cdk-erigon-restore.tar.gz
echo "Restore completed."
```

## Backup Best Practices

### Backup Schedule

| Backup Type | Frequency | Retention |
|-------------|-----------|-----------|
| Full cold backup | Weekly | 4 weeks |
| Hot backup | Daily | 7 days |
| Cloud archive | Monthly | 6 months |

### What to Include

| Data | Priority | Notes |
|------|----------|-------|
| `chaindata/` | Critical | Main database - required |
| Configuration files | Critical | Your YAML config |
| `nodes/` | Low | Can be rebuilt from network |
| `txpool/` | Medium | Pending transactions |
| `l1cache/` | Low | Will be rebuilt from L1 |

### Verification Checklist

1. **Test restores regularly** - Verify backups work before you need them
2. **Monitor backup jobs** - Alert on failures
3. **Check disk space** - Ensure backup destination has capacity
4. **Document procedures** - Keep runbooks updated
5. **Encrypt sensitive data** - Use encryption for cloud backups

## Related Topics

- [Database Management](./database-management.md) - Understanding the data directory
- [L1 Recovery](./l1-recovery.md) - Alternative recovery from L1 data
- [Health Checks](./health-checks.md) - Verifying node health after restore
