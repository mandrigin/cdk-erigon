# Mode Switching

cdk-erigon supports switching between RPC node and sequencer modes using the same data directory. This guide covers how to migrate a node between modes safely.

## Operational Modes

| Mode | Environment Variable | Purpose |
|------|---------------------|---------|
| **RPC Node** | `CDK_ERIGON_SEQUENCER` unset or `0` | Syncs from sequencer, serves read requests |
| **Sequencer** | `CDK_ERIGON_SEQUENCER=1` | Produces blocks, requires executor integration |

## RPC to Sequencer Migration

### When to Migrate

Migrate an RPC node to sequencer mode when:
- The current sequencer needs to be replaced
- Failover to a backup node is required
- Testing sequencer functionality with existing state

### Prerequisites

Before switching to sequencer mode:

1. **Stop the RPC node gracefully**
2. **Ensure executor connectivity** - sequencer requires working executor URLs
3. **Verify data integrity** - confirm the node is fully synced
4. **Update configuration** - add sequencer-specific flags

### Migration Steps

#### Step 1: Stop the Node

```bash
# If running directly
kill -SIGTERM $(pgrep cdk-erigon)

# If using Docker
docker stop cdk-erigon-rpc

# If using systemd
systemctl stop cdk-erigon
```

#### Step 2: Update Configuration

Add sequencer-specific configuration to your YAML file:

```yaml
# Existing RPC configuration...

# Add sequencer configuration
zkevm.executor-urls: "executor1.example.com:50071,executor2.example.com:50071"
zkevm.executor-strict: true
zkevm.witness-full: false

# Enable data stream server for downstream RPC nodes
zkevm.data-stream-host: "0.0.0.0"
zkevm.data-stream-port: 6900
```

#### Step 3: Start as Sequencer

```bash
CDK_ERIGON_SEQUENCER=1 ./build/bin/cdk-erigon --config="./config.yaml"
```

Or with Docker:

```bash
docker run -d \
  -e CDK_ERIGON_SEQUENCER=1 \
  -v ./data:/home/erigon/.local/share/erigon \
  hermeznetwork/cdk-erigon \
  --config="./config.yaml"
```

#### Step 4: Verify Operation

Check that the node is producing blocks:

```bash
# Check sync status
curl -X POST --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' \
  http://localhost:8545

# Check latest block (should increment)
curl -X POST --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
  http://localhost:8545

# Check batch number
curl -X POST --data '{"jsonrpc":"2.0","method":"zkevm_batchNumber","params":[],"id":1}' \
  http://localhost:8545
```

---

## Sequencer to RPC Migration

### When to Migrate

Migrate a sequencer to RPC mode when:
- Retiring a sequencer for maintenance
- Converting to a read-only archive node
- Reducing resource requirements

### Migration Steps

#### Step 1: Stop Block Production Gracefully

Allow the sequencer to finalize any pending batches:

```bash
# Wait for pending batches to be processed
# Monitor logs for batch finalization

# Then stop the node
kill -SIGTERM $(pgrep cdk-erigon)
```

#### Step 2: Update Configuration

Remove or comment out sequencer-specific flags:

```yaml
# Comment out sequencer configuration
# zkevm.executor-urls: "..."
# zkevm.executor-strict: true

# Update data stream to connect to new sequencer
zkevm.l2-datastreamer-url: new-sequencer.example.com:6900
```

#### Step 3: Start as RPC Node

Start without the `CDK_ERIGON_SEQUENCER` environment variable:

```bash
./build/bin/cdk-erigon --config="./config.yaml"
```

Or explicitly unset:

```bash
CDK_ERIGON_SEQUENCER=0 ./build/bin/cdk-erigon --config="./config.yaml"
```

#### Step 4: Verify Sync

Confirm the node is syncing from the new sequencer:

```bash
curl -X POST --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' \
  http://localhost:8545
```

---

## Configuration Reference

### Keeping Consistent Configuration

You can maintain a single configuration file that works for both modes by including all flags:

```yaml
datadir: /data/cdk-erigon
chain: hermez-mainnet

# Common configuration
http: true
http.addr: 0.0.0.0
http.api: [eth, debug, net, trace, web3, erigon, zkevm]
private.api.addr: localhost:9091

zkevm.l2-chain-id: 1101
zkevm.l2-sequencer-rpc-url: https://zkevm-rpc.com
zkevm.l2-datastreamer-url: stream.zkevm-rpc.com:6900

zkevm.l1-chain-id: 1
zkevm.l1-rpc-url: https://your-l1-rpc.com
zkevm.l1-first-block: 16896700

zkevm.address-sequencer: "0x148Ee7dAF16574cD020aFa34CC658f8F3fbd2800"
zkevm.address-zkevm: "0x519E42c24163192Dca44CD3fBDCEBF6be9130987"
zkevm.address-rollup: "0x5132A183E9F3CB7C848b0AAC5Ae0c4f0491B7aB2"
zkevm.address-ger-manager: "0x580bda1e7A0CFAe92Fa7F6c20A3794F169CE3CFb"

# Sequencer-specific (used only when CDK_ERIGON_SEQUENCER=1)
zkevm.executor-urls: "executor1.example.com:50071,executor2.example.com:50071"
zkevm.executor-strict: true

# Data stream server (useful for both modes)
zkevm.data-stream-host: "0.0.0.0"
zkevm.data-stream-port: 6900

externalcl: true
```

When running as RPC, the sequencer-specific flags are ignored. This allows easy switching between modes without modifying the configuration file.

---

## Data Directory Handling

### Shared Data Directory

Both modes can use the same data directory. The state data is compatible between modes.

```
/data/cdk-erigon/
├── chaindata/      # Block and state data (shared)
├── txpool/         # Transaction pool (sequencer only)
├── datastream/     # Data stream server data
└── nodes/          # P2P node data
```

### Considerations

1. **Transaction pool**: When switching from sequencer to RPC, pending transactions in the txpool are not processed
2. **Data stream**: If running data stream server, downstream nodes may need to reconnect
3. **Disk space**: Ensure adequate space for both modes if switching frequently

---

## Automated Mode Switching

### Using systemd

Create service files for each mode:

**RPC mode (`/etc/systemd/system/cdk-erigon-rpc.service`):**

```ini
[Unit]
Description=cdk-erigon RPC Node
After=network.target

[Service]
Type=simple
User=erigon
ExecStart=/usr/local/bin/cdk-erigon --config=/etc/cdk-erigon/config.yaml
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

**Sequencer mode (`/etc/systemd/system/cdk-erigon-sequencer.service`):**

```ini
[Unit]
Description=cdk-erigon Sequencer
After=network.target

[Service]
Type=simple
User=erigon
Environment="CDK_ERIGON_SEQUENCER=1"
ExecStart=/usr/local/bin/cdk-erigon --config=/etc/cdk-erigon/config.yaml
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Switch modes:

```bash
# Switch to sequencer
systemctl stop cdk-erigon-rpc
systemctl start cdk-erigon-sequencer

# Switch to RPC
systemctl stop cdk-erigon-sequencer
systemctl start cdk-erigon-rpc
```

### Using Docker Compose

```yaml
version: '3.8'

services:
  cdk-erigon:
    image: hermeznetwork/cdk-erigon:latest
    environment:
      - CDK_ERIGON_SEQUENCER=${SEQUENCER_MODE:-0}
    volumes:
      - ./data:/home/erigon/.local/share/erigon
      - ./config.yaml:/config/config.yaml
    command: --config=/config/config.yaml
    ports:
      - "8545:8545"
      - "6900:6900"
```

Switch modes:

```bash
# Start as RPC
SEQUENCER_MODE=0 docker-compose up -d

# Switch to sequencer
docker-compose down
SEQUENCER_MODE=1 docker-compose up -d
```

---

## Troubleshooting Mode Switches

### Node Won't Start After Switching

**Symptom:** Node fails to start after switching modes

**Solution:**
1. Check logs for specific errors
2. Verify executor URLs are correct (sequencer mode)
3. Verify data stream URL is correct (RPC mode)

### Sync Issues After Switching to RPC

**Symptom:** RPC node can't sync after being a sequencer

**Solution:**
1. Verify data stream URL points to active sequencer
2. Check network connectivity to sequencer
3. May need to resync if sequencer data diverged

### Executor Connection Failed in Sequencer Mode

**Symptom:** Sequencer starts but can't produce blocks

**Solution:**
1. Verify executor URLs and connectivity
2. Check executor service is running
3. Temporarily use `zkevm.executor-strict: false` for debugging (not production!)

## Next Steps

- [L1 Recovery Mode](./l1-recovery.md) - Recovering a sequencer from L1 data
- [RPC Node Setup](./rpc-node.md) - Detailed RPC configuration
- [Sequencer Setup](./sequencer.md) - Detailed sequencer configuration
