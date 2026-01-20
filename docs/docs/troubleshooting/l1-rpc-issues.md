---
sidebar_position: 3
title: L1 RPC Issues
description: Troubleshoot L1 Ethereum RPC connectivity
---

# L1 RPC Issues

Diagnose and resolve L1 Ethereum RPC problems.

## Rate Limiting

### Symptoms

- HTTP 429 errors in logs
- Slow L1 sync progress
- Intermittent failures

### Solutions

#### Use Higher-Tier Provider

Upgrade to a provider plan with higher rate limits.

#### Multiple Providers

Future versions may support provider failover.

#### Block Type Selection

Use less frequent polling:

```yaml
zkevm:
  l1-highest-block-type: finalized
```

## Connection Failures

### Check Connectivity

```bash
curl -X POST https://your-l1-rpc.com \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'
```

### Verify URL

Ensure correct RPC URL in configuration:

```yaml
zkevm:
  l1-rpc-url: https://eth-mainnet.example.com
```

## Archive Access Required

Some operations require archive node access:

- Historical state queries
- L1 recovery mode
- Debug operations

### Symptoms

- "missing trie node" errors
- Failed historical queries

### Solution

Use an L1 archive RPC provider.

## Provider Recommendations

| Provider Type | Use Case |
|---------------|----------|
| Full node | Standard operations |
| Archive node | L1 recovery, historical |
| Load-balanced | High availability |

## Next Steps

- [Log Interpretation](./log-interpretation) - Understand logs
- [FAQ](./faq) - Common questions
