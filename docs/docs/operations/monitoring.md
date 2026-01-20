---
sidebar_position: 1
title: Monitoring
description: Monitor your cdk-erigon node with Prometheus and Grafana
---

# Monitoring

Set up monitoring for your cdk-erigon node.

## Prometheus Metrics

cdk-erigon exposes Prometheus metrics by default.

### Enable Metrics

```yaml
metrics:
  enabled: true
  addr: 0.0.0.0
  port: 6060
```

### Scrape Configuration

Add to your Prometheus configuration:

```yaml
scrape_configs:
  - job_name: 'cdk-erigon'
    static_configs:
      - targets: ['localhost:6060']
```

## Key Metrics

| Metric | Description |
|--------|-------------|
| `chain_head_block` | Current block number |
| `chain_head_batch` | Current batch number |
| `p2p_peers` | Connected peers |
| `rpc_requests_total` | Total RPC requests |
| `sync_stage_*` | Sync stage progress |

## Grafana Dashboards

Import community dashboards or create custom ones for:

- Sync progress
- RPC performance
- Resource utilization
- Network connectivity

## Alerting

Configure alerts for:

- Sync falling behind
- High RPC latency
- Low peer count
- Memory/CPU thresholds

## Next Steps

- [Health Checks](./health-checks) - Verify node health
- [Performance Tuning](./performance-tuning) - Optimize performance
