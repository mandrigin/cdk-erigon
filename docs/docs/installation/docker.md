# Docker Deployment

Docker is the recommended deployment method for production environments. The official cdk-erigon Docker image includes pre-configured network settings and all required dependencies.

## Docker Image

The official image is available on Docker Hub:

```
hermeznetwork/cdk-erigon
```

### Available Tags

| Tag | Description |
|-----|-------------|
| `latest` | Latest stable release |
| `v2.64.2` | Specific version |
| `zkevm` | Latest from zkevm branch |

## Quick Start

### zkEVM Mainnet

```bash
docker run -d \
  --name cdk-erigon-mainnet \
  -p 8545:8545 \
  -v ./cdk-erigon-data:/home/erigon/.local/share/erigon \
  hermeznetwork/cdk-erigon \
  --config="./mainnet.yaml" \
  --zkevm.l1-rpc-url=https://rpc.eth.gateway.fm
```

### zkEVM Cardona Testnet

```bash
docker run -d \
  --name cdk-erigon-cardona \
  -p 8545:8545 \
  -v ./cdk-erigon-data:/home/erigon/.local/share/erigon \
  hermeznetwork/cdk-erigon \
  --config="./cardona.yaml" \
  --zkevm.l1-rpc-url=https://rpc.sepolia.org
```

## Volume Mounts

Persistent storage is critical for blockchain data. Always mount a volume for the data directory.

### Data Directory

The default data directory inside the container is `/home/erigon/.local/share/erigon`.

```bash
# Mount local directory
-v /path/to/your/data:/home/erigon/.local/share/erigon

# Mount named volume (Docker manages the location)
-v cdk-erigon-data:/home/erigon/.local/share/erigon
```

### Custom Configuration File

To use a custom configuration file:

```bash
docker run -d \
  --name cdk-erigon \
  -p 8545:8545 \
  -v ./cdk-erigon-data:/home/erigon/.local/share/erigon \
  -v ./my-config.yaml:/config/my-config.yaml \
  hermeznetwork/cdk-erigon \
  --config="/config/my-config.yaml" \
  --zkevm.l1-rpc-url=https://your-l1-rpc.com
```

### JWT Secret for Engine API

For Engine API authentication (required for sequencer setups):

```bash
# Generate JWT secret
openssl rand -hex 32 > jwt.hex

# Mount and use the JWT file
docker run -d \
  --name cdk-erigon \
  -p 8545:8545 \
  -p 8551:8551 \
  -v ./cdk-erigon-data:/home/erigon/.local/share/erigon \
  -v ./jwt.hex:/jwt.hex:ro \
  hermeznetwork/cdk-erigon \
  --config="./mainnet.yaml" \
  --authrpc.jwtsecret=/jwt.hex \
  --zkevm.l1-rpc-url=https://rpc.eth.gateway.fm
```

## Docker Compose

For production deployments, use docker-compose for easier management.

### Basic Setup

Create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  cdk-erigon:
    image: hermeznetwork/cdk-erigon:latest
    container_name: cdk-erigon
    restart: unless-stopped
    ports:
      - "8545:8545"    # JSON-RPC
      - "8551:8551"    # Engine API
      - "30303:30303"  # P2P (optional)
    volumes:
      - ./cdk-erigon-data:/home/erigon/.local/share/erigon
    command: >
      --config=${NETWORK:-cardona}.yaml
      --zkevm.l1-rpc-url=${L1_RPC_URL:-https://rpc.sepolia.org}
    mem_swappiness: 0
```

Start with:

```bash
# Cardona testnet
L1_RPC_URL=https://rpc.sepolia.org docker-compose up -d

# Mainnet
NETWORK=mainnet L1_RPC_URL=https://rpc.eth.gateway.fm docker-compose up -d
```

### With Monitoring

For production with Prometheus and Grafana:

```yaml
version: '3.8'

services:
  cdk-erigon:
    image: hermeznetwork/cdk-erigon:latest
    container_name: cdk-erigon
    restart: unless-stopped
    ports:
      - "8545:8545"
      - "6060:6060"  # Metrics
    volumes:
      - cdk-erigon-data:/home/erigon/.local/share/erigon
    command: >
      --config=${NETWORK:-mainnet}.yaml
      --zkevm.l1-rpc-url=${L1_RPC_URL}
      --metrics
      --metrics.addr=0.0.0.0
      --metrics.port=6060
    mem_swappiness: 0

  prometheus:
    image: prom/prometheus:v2.51.2
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus-data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
    restart: unless-stopped

  grafana:
    image: grafana/grafana:10.4.2
    container_name: grafana
    ports:
      - "3000:3000"
    volumes:
      - grafana-data:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    restart: unless-stopped

volumes:
  cdk-erigon-data:
  prometheus-data:
  grafana-data:
```

Create `prometheus.yml`:

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'cdk-erigon'
    static_configs:
      - targets: ['cdk-erigon:6060']
```

### Multi-Service Architecture

For advanced setups separating RPC, TxPool, and other services:

```yaml
version: '2.2'

x-erigon-service: &default-erigon-service
  image: hermeznetwork/cdk-erigon:latest
  volumes_from: [erigon]
  restart: unless-stopped
  mem_swappiness: 0
  user: ${DOCKER_UID:-1000}:${DOCKER_GID:-1000}

services:
  erigon:
    image: hermeznetwork/cdk-erigon:latest
    command: >
      --config=${NETWORK:-mainnet}.yaml
      --private.api.addr=0.0.0.0:9090
      --txpool.disable
      --zkevm.l1-rpc-url=${L1_RPC_URL}
    ports:
      - "8551:8551"
    volumes:
      - ./cdk-erigon-data:/home/erigon/.local/share/erigon
    restart: unless-stopped
    mem_swappiness: 0

  rpcdaemon:
    <<: *default-erigon-service
    entrypoint: rpcdaemon
    command: >
      --http.addr=0.0.0.0
      --http.vhosts=any
      --http.corsdomain=*
      --ws
      --private.api.addr=erigon:9090
      --txpool.api.addr=txpool:9094
    ports:
      - "8545:8545"

  txpool:
    <<: *default-erigon-service
    entrypoint: txpool
    command: >
      --private.api.addr=erigon:9090
      --txpool.api.addr=0.0.0.0:9094
```

## Port Reference

| Port | Protocol | Service | Description |
|------|----------|---------|-------------|
| 8545 | TCP | HTTP JSON-RPC | Main RPC endpoint |
| 8551 | TCP | Engine API | Consensus client communication |
| 9090 | TCP | Private API | Internal service communication |
| 30303 | TCP/UDP | P2P | Ethereum P2P networking |
| 42069 | TCP/UDP | BitTorrent | Snapshot sync |
| 6060 | TCP | Metrics | Prometheus metrics |
| 6061 | TCP | pprof | Go profiling |
| 6900 | TCP | Data Stream | Sequencer data stream (internal) |
| 7900 | TCP | Relay | Data stream relay |

## Environment Variables

Configure cdk-erigon via environment variables in docker-compose:

```yaml
services:
  cdk-erigon:
    environment:
      - ERIGON_DATADIR=/data
      - ERIGON_HTTP_ENABLED=true
      - ERIGON_HTTP_ADDR=0.0.0.0
```

## Resource Limits

For production, set appropriate resource limits:

```yaml
services:
  cdk-erigon:
    deploy:
      resources:
        limits:
          cpus: '8'
          memory: 64G
        reservations:
          cpus: '4'
          memory: 32G
```

## Health Checks

Add health checks for container orchestration:

```yaml
services:
  cdk-erigon:
    healthcheck:
      test: ["CMD", "curl", "-f", "-H", "X-ERIGON-HEALTHCHECK: synced", "http://localhost:8545"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
```

## Building Custom Image

To build from source with custom modifications:

```bash
# Clone the repository
git clone https://github.com/0xPolygonHermez/cdk-erigon.git
cd cdk-erigon

# Build the Docker image
docker build -t my-cdk-erigon:latest .

# Run with your custom image
docker run -d \
  --name cdk-erigon \
  -v ./data:/home/erigon/.local/share/erigon \
  my-cdk-erigon:latest \
  --config="./mainnet.yaml"
```

## Troubleshooting

### Permission Denied on Volume

Set the correct user ID:

```bash
# Check your user ID
id -u

# Run with matching UID/GID
docker run -d \
  --user $(id -u):$(id -g) \
  -v ./data:/home/erigon/.local/share/erigon \
  hermeznetwork/cdk-erigon ...
```

### Container Exits Immediately

Check logs for errors:

```bash
docker logs cdk-erigon
```

### Out of Memory

Increase Docker's memory limit or use `mem_swappiness: 0` and set proper limits in compose file.

## Next Steps

- [Configure your node](../configuration/index.md)
- [Set up monitoring](../operations/monitoring.md)
- [Deploy to Kubernetes](./kubernetes.md)
