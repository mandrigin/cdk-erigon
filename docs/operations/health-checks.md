# Health Checks

cdk-erigon provides a built-in health check endpoint for monitoring node status. This is useful for load balancers, orchestration systems, and operational monitoring.

## Health Check Endpoint

The health check endpoint is available at `/health` on the HTTP RPC server.

### Basic Health Check

A simple GET request returns the node's health status:

```bash
curl http://localhost:8545/health
```

Response when healthy:
```json
{
  "healthcheck_query": "HEALTHY",
  "min_peer_count": "DISABLED",
  "check_block": "DISABLED",
  "tx_pool": "DISABLED",
  "last_block_time": "DISABLED"
}
```

## Header-Based Health Checks

Use the `X-ERIGON-HEALTHCHECK` header to enable specific health checks. Multiple checks can be combined.

### Available Checks

| Header Value | Description |
|--------------|-------------|
| `synced` | Check if the node is fully synced |
| `min_peer_count<N>` | Check minimum connected peers (e.g., `min_peer_count3`) |
| `check_block<N>` | Verify block N exists (e.g., `check_block1000000`) |
| `max_seconds_behind<N>` | Check latest block is within N seconds of current time |
| `tx_pool_enable` | Verify transaction pool is operational |
| `last_block_time` | Return timestamp of the latest block |

### Example 1: Sync Status Check

Check if the node is fully synchronized with the network:

```bash
curl -H "X-ERIGON-HEALTHCHECK: synced" http://localhost:8545/health
```

Response when synced:
```json
{
  "synced": "HEALTHY",
  "min_peer_count": "DISABLED",
  "check_block": "DISABLED",
  "max_seconds_behind": "DISABLED",
  "tx_pool_enable": "DISABLED",
  "last_block_time": "DISABLED"
}
```

Response when not synced (returns HTTP 500):
```json
{
  "synced": "ERROR: not synced",
  "min_peer_count": "DISABLED",
  "check_block": "DISABLED",
  "max_seconds_behind": "DISABLED",
  "tx_pool_enable": "DISABLED",
  "last_block_time": "DISABLED"
}
```

### Example 2: Multiple Health Checks

Combine multiple checks for comprehensive health verification:

```bash
curl -H "X-ERIGON-HEALTHCHECK: synced" \
     -H "X-ERIGON-HEALTHCHECK: min_peer_count3" \
     -H "X-ERIGON-HEALTHCHECK: max_seconds_behind60" \
     http://localhost:8545/health
```

Response:
```json
{
  "synced": "HEALTHY",
  "min_peer_count": "HEALTHY",
  "check_block": "DISABLED",
  "max_seconds_behind": "HEALTHY",
  "tx_pool_enable": "DISABLED",
  "last_block_time": "DISABLED"
}
```

## JSON Body Health Checks

Alternatively, send a POST request with a JSON body:

```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"min_peer_count": 3, "known_block": 1000000, "tx_pool_enable": true}' \
  http://localhost:8545/health
```

### Request Body Options

| Field | Type | Description |
|-------|------|-------------|
| `min_peer_count` | `number` | Minimum number of connected peers |
| `known_block` | `number` | Block number that must exist |
| `tx_pool_enable` | `boolean` | Check transaction pool status |
| `last_block_time` | `boolean` | Include latest block timestamp |

## RPC-Based Health Checks

Use standard JSON-RPC methods for additional health information.

### Example 3: Comprehensive Health Check Script

```bash
#!/bin/bash
# health-check.sh - Comprehensive cdk-erigon health check

NODE_URL="${1:-http://localhost:8545}"

echo "=== cdk-erigon Health Check ==="
echo "Node: $NODE_URL"
echo ""

# Check node version
echo "Node Version:"
curl -s -X POST \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"web3_clientVersion","params":[],"id":1}' \
  "$NODE_URL" | jq -r '.result'
echo ""

# Check sync status
echo "Sync Status:"
SYNC_STATUS=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' \
  "$NODE_URL")

if [ "$(echo $SYNC_STATUS | jq -r '.result')" == "false" ]; then
  echo "  Fully synced"
else
  echo "  Currently syncing:"
  echo "  Current Block: $(echo $SYNC_STATUS | jq -r '.result.currentBlock')"
  echo "  Highest Block: $(echo $SYNC_STATUS | jq -r '.result.highestBlock')"
fi
echo ""

# Check current batch
echo "Current Batch:"
curl -s -X POST \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"zkevm_batchNumber","params":[],"id":1}' \
  "$NODE_URL" | jq -r '.result'
echo ""

# Check verified batch
echo "Verified Batch:"
curl -s -X POST \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"zkevm_verifiedBatchNumber","params":[],"id":1}' \
  "$NODE_URL" | jq -r '.result'
echo ""

# Check health endpoint
echo "Health Endpoint:"
HEALTH=$(curl -s -w "%{http_code}" \
  -H "X-ERIGON-HEALTHCHECK: synced" \
  -H "X-ERIGON-HEALTHCHECK: min_peer_count1" \
  "$NODE_URL/health")

HTTP_CODE="${HEALTH: -3}"
BODY="${HEALTH:0:${#HEALTH}-3}"

echo "  HTTP Status: $HTTP_CODE"
echo "  Response: $BODY" | jq .
```

## Load Balancer Integration

### Kubernetes Liveness and Readiness Probes

```yaml
# kubernetes deployment snippet
containers:
  - name: cdk-erigon
    image: hermeznetwork/cdk-erigon:latest
    ports:
      - containerPort: 8545
    livenessProbe:
      httpGet:
        path: /health
        port: 8545
      initialDelaySeconds: 60
      periodSeconds: 30
      timeoutSeconds: 10
    readinessProbe:
      httpGet:
        path: /health
        port: 8545
        httpHeaders:
          - name: X-ERIGON-HEALTHCHECK
            value: "synced"
          - name: X-ERIGON-HEALTHCHECK
            value: "max_seconds_behind120"
      initialDelaySeconds: 120
      periodSeconds: 15
      timeoutSeconds: 10
```

### HAProxy Health Check

```haproxy
backend cdk-erigon-rpc
    mode http
    balance roundrobin
    option httpchk GET /health
    http-check expect status 200
    http-check send hdr X-ERIGON-HEALTHCHECK synced
    server node1 10.0.0.1:8545 check
    server node2 10.0.0.2:8545 check
    server node3 10.0.0.3:8545 check
```

### NGINX Health Check

```nginx
upstream cdk_erigon {
    server 10.0.0.1:8545;
    server 10.0.0.2:8545;
    server 10.0.0.3:8545;
}

server {
    location /health-check {
        internal;
        proxy_pass http://cdk_erigon/health;
        proxy_set_header X-ERIGON-HEALTHCHECK "synced";
    }
}
```

## Response Codes

| HTTP Code | Meaning |
|-----------|---------|
| 200 | All enabled health checks passed |
| 500 | One or more health checks failed |

## Related Topics

- [Monitoring Setup](./monitoring.md) - Prometheus and Grafana integration
- [Troubleshooting](../troubleshooting/sync-issues.md) - Diagnosing sync problems
