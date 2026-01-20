---
sidebar_position: 2
title: Memory Issues
description: Troubleshoot cdk-erigon memory problems
---

# Memory Issues

Diagnose and resolve memory-related problems.

## Out of Memory (OOM)

### Symptoms

- Node crashes with OOM killer
- System becomes unresponsive
- Logs show memory allocation failures

### Solutions

#### Disable In-Memory SMT

```yaml
zkevm:
  smt-regenerate-in-memory: false
```

#### Increase System Memory

Consider upgrading to 32GB+ RAM for production nodes.

#### Configure Swap

Add swap space as a safety net:

```bash
sudo fallocate -l 16G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

## High Memory Usage

### Monitor Usage

```bash
# Watch memory usage
watch -n 1 'ps aux | grep cdk-erigon'
```

### Profile Memory

Enable memory profiling:

```yaml
metrics:
  enabled: true
  addr: 0.0.0.0
  port: 6060
```

Access pprof at `http://localhost:6060/debug/pprof/heap`.

## Memory Leaks

If memory grows unbounded:

1. Check for latest version (may contain fixes)
2. Report issue with logs and memory profile

## Recommended Memory by Mode

| Mode | Minimum | Recommended |
|------|---------|-------------|
| RPC Node | 16 GB | 32 GB |
| Archive | 32 GB | 64 GB |
| Sequencer | 32 GB | 64 GB |

## Next Steps

- [L1 RPC Issues](./l1-rpc-issues) - L1 connectivity
- [Performance Tuning](../operations/performance-tuning) - Optimize usage
