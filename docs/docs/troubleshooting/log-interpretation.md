---
sidebar_position: 4
title: Log Interpretation
description: Understand cdk-erigon log messages
---

# Log Interpretation

Understanding cdk-erigon log messages.

## Log Levels

| Level | Description |
|-------|-------------|
| `TRACE` | Detailed debugging |
| `DEBUG` | Debug information |
| `INFO` | Normal operations |
| `WARN` | Potential issues |
| `ERROR` | Errors requiring attention |

## Common Messages

### Sync Progress

```
INFO [01-20|12:00:00] Syncing block=1234567 batch=5678
```

Normal sync progress message.

### Data Stream

```
INFO [01-20|12:00:00] Connected to data stream url=stream:6900
```

Successful data stream connection.

```
WARN [01-20|12:00:00] Data stream disconnected, reconnecting...
```

Temporary disconnection, will auto-reconnect.

### L1 Sync

```
INFO [01-20|12:00:00] L1 sync progress block=18000000
```

L1 synchronization progress.

### SMT Operations

```
INFO [01-20|12:00:00] SMT rebuild started
```

SMT regeneration beginning (may take time).

```
INFO [01-20|12:00:00] SMT rebuild completed duration=10m
```

SMT regeneration complete.

## Error Messages

### Connection Errors

```
ERROR [01-20|12:00:00] Failed to connect to L1 RPC err="connection refused"
```

Check L1 RPC URL and network connectivity.

### State Errors

```
ERROR [01-20|12:00:00] State mismatch, triggering rebuild
```

State divergence detected, will rebuild automatically.

## Enable Debug Logging

```yaml
log:
  level: debug
```

## Next Steps

- [FAQ](./faq) - Common questions
- [Sync Issues](./sync-issues) - Sync problems
