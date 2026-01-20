---
sidebar_position: 1
title: Sync Issues
description: Troubleshoot cdk-erigon synchronization problems
---

# Sync Issues

Diagnose and resolve synchronization problems.

## Node Not Syncing

### Check Data Stream Connection

Verify connection to the data stream:

```bash
# Check if port is reachable
nc -zv stream.zkevm-rpc.com 6900
```

### Verify Configuration

Ensure correct data stream URL:

```yaml
zkevm:
  l2-datastreamer-url: stream.zkevm-rpc.com:6900
```

## Sync Falling Behind

### Check Resources

- CPU utilization
- Memory usage
- Disk I/O

### Monitor Logs

```bash
tail -f /var/log/cdk-erigon.log | grep -E "(sync|block|batch)"
```

## SMT Rebuild Triggered

SMT rebuilds occur when state diverges. This is normal during:

- First sync
- Fork ID upgrades
- Recovery operations

### Speed Up Rebuild

Enable in-memory mode if you have sufficient RAM:

```yaml
zkevm:
  smt-regenerate-in-memory: true
```

## Data Stream Disconnects

### Symptoms

- Frequent reconnection messages
- Sync stalling periodically

### Solutions

1. Check network stability
2. Verify firewall rules
3. Try alternative data stream endpoint

## Common Error Messages

| Error | Cause | Solution |
|-------|-------|----------|
| `data stream disconnected` | Network issue | Check connectivity |
| `SMT rebuild required` | State divergence | Wait for rebuild |
| `batch not found` | Missing data | Check L1 sync |

## Next Steps

- [Memory Issues](./memory-issues) - Memory problems
- [L1 RPC Issues](./l1-rpc-issues) - L1 connectivity
