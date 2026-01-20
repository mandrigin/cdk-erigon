# Monitoring Setup

This guide covers setting up monitoring for your cdk-erigon node using Prometheus and Grafana.

## Enabling Metrics

cdk-erigon exposes Prometheus-compatible metrics that can be scraped and visualized. Enable metrics collection by adding the following to your configuration.

### Configuration Options

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

<Tabs>
<TabItem value="yaml" label="YAML Config" default>

```yaml
metrics: true
metrics.addr: "0.0.0.0"
metrics.port: 6060
```

</TabItem>
<TabItem value="cli" label="CLI Flags">

```bash
cdk-erigon \
  --metrics \
  --metrics.addr="0.0.0.0" \
  --metrics.port=6060
```

</TabItem>
<TabItem value="env" label="Environment Variables">

```bash
export METRICS=true
export METRICS_ADDR="0.0.0.0"
export METRICS_PORT=6060
```

</TabItem>
</Tabs>

| Option | Default | Description |
|--------|---------|-------------|
| `metrics` | `false` | Enable metrics collection and reporting |
| `metrics.addr` | `"0.0.0.0"` | Address on which the metrics server listens |
| `metrics.port` | `6060` | Port on which the metrics server listens |

## Prometheus Configuration

Add cdk-erigon as a scrape target in your Prometheus configuration.

### Example 1: Basic Prometheus Scrape Config

```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'cdk-erigon'
    static_configs:
      - targets: ['localhost:6060']
    metrics_path: /debug/metrics/prometheus
```

### Example 2: Multiple Nodes with Labels

```yaml
# prometheus.yml
scrape_configs:
  - job_name: 'cdk-erigon-cluster'
    static_configs:
      - targets: ['node1:6060']
        labels:
          instance: 'mainnet-rpc-1'
          network: 'mainnet'
      - targets: ['node2:6060']
        labels:
          instance: 'mainnet-rpc-2'
          network: 'mainnet'
      - targets: ['node3:6060']
        labels:
          instance: 'cardona-rpc-1'
          network: 'cardona'
    metrics_path: /debug/metrics/prometheus
```

## Key Metrics

cdk-erigon exposes metrics for RPC performance, sync status, and resource utilization.

### RPC Metrics

| Metric | Type | Description |
|--------|------|-------------|
| `rpc_total` | Counter | Total number of RPC requests |
| `rpc_failure` | Counter | Number of failed RPC requests |
| `rpc_duration_seconds{method,success}` | Summary | RPC request duration by method |

### Sync Metrics

| Metric | Type | Description |
|--------|------|-------------|
| `chain_head_block` | Gauge | Current head block number |
| `chain_head_header` | Gauge | Current head header number |
| `p2p_peers` | Gauge | Number of connected peers |

## Grafana Dashboard Setup

### Example 3: Docker Compose with Grafana

```yaml
# docker-compose.monitoring.yml
version: '3.8'

services:
  cdk-erigon:
    image: hermeznetwork/cdk-erigon:latest
    ports:
      - "8545:8545"
      - "6060:6060"
    volumes:
      - ./data:/home/erigon/.local/share/erigon
      - ./mainnet.yaml:/mainnet.yaml
    command: --config=/mainnet.yaml --metrics --metrics.addr=0.0.0.0 --metrics.port=6060

  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus-data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    volumes:
      - grafana-data:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    depends_on:
      - prometheus

volumes:
  prometheus-data:
  grafana-data:
```

### Example 4: Basic Grafana Dashboard JSON

Create a dashboard to visualize RPC performance and sync status:

```json
{
  "title": "cdk-erigon Overview",
  "panels": [
    {
      "title": "RPC Requests/sec",
      "type": "graph",
      "targets": [
        {
          "expr": "rate(rpc_total[5m])",
          "legendFormat": "{{instance}}"
        }
      ]
    },
    {
      "title": "RPC Error Rate",
      "type": "graph",
      "targets": [
        {
          "expr": "rate(rpc_failure[5m]) / rate(rpc_total[5m]) * 100",
          "legendFormat": "{{instance}}"
        }
      ]
    },
    {
      "title": "Chain Head Block",
      "type": "stat",
      "targets": [
        {
          "expr": "chain_head_block",
          "legendFormat": "{{instance}}"
        }
      ]
    },
    {
      "title": "Connected Peers",
      "type": "gauge",
      "targets": [
        {
          "expr": "p2p_peers",
          "legendFormat": "{{instance}}"
        }
      ]
    }
  ]
}
```

## pprof Profiling

For debugging performance issues, cdk-erigon also supports pprof profiling.

### Example 5: Enabling pprof

<Tabs>
<TabItem value="yaml" label="YAML Config" default>

```yaml
pprof: true
pprof.addr: "127.0.0.1"
pprof.port: 6061
```

</TabItem>
<TabItem value="cli" label="CLI Flags">

```bash
cdk-erigon \
  --pprof \
  --pprof.addr="127.0.0.1" \
  --pprof.port=6061
```

</TabItem>
</Tabs>

Access profiling data:

```bash
# CPU profile (30 seconds)
go tool pprof http://localhost:6061/debug/pprof/profile?seconds=30

# Memory profile
go tool pprof http://localhost:6061/debug/pprof/heap

# Goroutine profile
go tool pprof http://localhost:6061/debug/pprof/goroutine
```

:::warning Security Note
The pprof endpoint exposes sensitive performance data. Only bind to `127.0.0.1` or use firewall rules to restrict access in production environments.
:::

## Alerting Rules

Configure Prometheus alerting rules to notify you of issues:

```yaml
# alerts.yml
groups:
  - name: cdk-erigon
    rules:
      - alert: HighRPCErrorRate
        expr: rate(rpc_failure[5m]) / rate(rpc_total[5m]) > 0.05
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High RPC error rate on {{ $labels.instance }}"

      - alert: NodeNotSyncing
        expr: increase(chain_head_block[10m]) == 0
        for: 15m
        labels:
          severity: critical
        annotations:
          summary: "Node {{ $labels.instance }} is not syncing"

      - alert: LowPeerCount
        expr: p2p_peers < 3
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "Low peer count on {{ $labels.instance }}"
```

## Related Topics

- [Health Checks](./health-checks.md) - Monitoring node health via HTTP endpoints
- [Performance Tuning](./performance-tuning.md) - Optimizing node performance
- [Troubleshooting](../troubleshooting/sync-issues.md) - Diagnosing common issues
