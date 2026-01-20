# Running a Node

This section covers how to run cdk-erigon in various configurations.

## Guides

| Guide | Description |
|-------|-------------|
| [RPC Node Setup](./rpc-node.md) | Running a read-only node that syncs from a sequencer |
| [Sequencer Setup](./sequencer.md) | Running a block-producing sequencer node |
| [Network Configurations](./networks.md) | Configurations for mainnet, Cardona, and custom chains |
| [Mode Switching](./mode-switching.md) | Switching between RPC and sequencer modes |
| [L1 Recovery Mode](./l1-recovery.md) | Recovering a sequencer from L1 data |

## Quick Start

### RPC Node (Mainnet)

```bash
./build/bin/cdk-erigon --config="./hermezconfig-mainnet.yaml"
```

### RPC Node (Cardona Testnet)

```bash
./build/bin/cdk-erigon --config="./hermezconfig-cardona.yaml"
```

### Sequencer

```bash
CDK_ERIGON_SEQUENCER=1 ./build/bin/cdk-erigon --config="./sequencer.yaml"
```

### Docker (Mainnet)

```bash
docker run -d -p 8545:8545 \
  -v ./data:/home/erigon/.local/share/erigon \
  hermeznetwork/cdk-erigon \
  --config="./mainnet.yaml" \
  --zkevm.l1-rpc-url=https://your-l1-rpc.com
```

## Operational Modes

cdk-erigon supports two operational modes:

| Mode | Purpose | Environment Variable |
|------|---------|---------------------|
| **RPC Node** | Read-only sync from sequencer | Default (unset) |
| **Sequencer** | Block production | `CDK_ERIGON_SEQUENCER=1` |

See [Mode Switching](./mode-switching.md) for details on migrating between modes.

## Supported Networks

| Network | Chain ID | Status | Guide |
|---------|----------|--------|-------|
| zkEVM Mainnet | 1101 | Production | [Networks](./networks.md#zkevm-mainnet-chain-id-1101) |
| zkEVM Cardona | 2442 | Testnet | [Networks](./networks.md#zkevm-cardona-testnet-chain-id-2442) |
| Custom CDK | varies | varies | [Networks](./networks.md#custom-cdk-chains) |

## Common Configuration

All modes share these core configuration options:

```yaml
# Data directory
datadir: /data/cdk-erigon

# Network chain
chain: hermez-mainnet

# HTTP RPC
http: true
http.addr: 0.0.0.0
http.api: [eth, debug, net, trace, web3, erigon, zkevm]

# L1 configuration
zkevm.l1-chain-id: 1
zkevm.l1-rpc-url: https://your-l1-rpc.com

# L2 configuration
zkevm.l2-chain-id: 1101

# Required
externalcl: true
```

See [Configuration Reference](../configuration/reference.md) for all available options.
