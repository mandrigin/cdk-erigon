# Network Configurations

This guide covers configuration for supported networks: zkEVM Mainnet, zkEVM Cardona testnet, and custom CDK chains.

## Network Overview

| Network | Chain ID | L1 Network | Status | Config File |
|---------|----------|------------|--------|-------------|
| zkEVM Mainnet | 1101 | Ethereum Mainnet | Production | `hermezconfig-mainnet.yaml` |
| zkEVM Cardona | 2442 | Sepolia | Testnet | `hermezconfig-cardona.yaml` |
| Custom CDK | varies | varies | varies | `dynamic-{network}.yaml` |

---

## zkEVM Mainnet (Chain ID: 1101)

zkEVM Mainnet is the production Polygon zkEVM network secured by Ethereum mainnet.

### Prerequisites

- **L1 RPC**: A reliable Ethereum mainnet RPC endpoint
  - Recommended: Use a dedicated node or premium RPC provider
  - Rate limits on public RPCs may cause sync issues
- **Disk Space**: 500GB+ SSD recommended
- **Memory**: 32GB+ RAM recommended

### Configuration

Create `hermezconfig-mainnet.yaml`:

```yaml
datadir: /data/cdk-erigon
chain: hermez-mainnet

# HTTP/WS RPC
http: true
http.addr: 0.0.0.0
http.api: [eth, debug, net, trace, web3, erigon, zkevm]
http.vhosts: any
http.corsdomain: any
ws: true

# Internal API
private.api.addr: localhost:9091

# L2 Network Configuration
zkevm.l2-chain-id: 1101
zkevm.l2-sequencer-rpc-url: https://zkevm-rpc.com
zkevm.l2-datastreamer-url: stream.zkevm-rpc.com:6900

# L1 Configuration (Ethereum Mainnet)
zkevm.l1-chain-id: 1
zkevm.l1-rpc-url: https://your-ethereum-mainnet-rpc.com
zkevm.l1-first-block: 16896700
zkevm.l1-rollup-id: 1
zkevm.l1-block-range: 20000
zkevm.l1-query-delay: 6000

# Contract Addresses (Mainnet)
zkevm.address-sequencer: "0x148Ee7dAF16574cD020aFa34CC658f8F3fbd2800"
zkevm.address-zkevm: "0x519E42c24163192Dca44CD3fBDCEBF6be9130987"
zkevm.address-rollup: "0x5132A183E9F3CB7C848b0AAC5Ae0c4f0491B7aB2"
zkevm.address-ger-manager: "0x580bda1e7A0CFAe92Fa7F6c20A3794F169CE3CFb"

# Gas Configuration
zkevm.default-gas-price: 1000000000
zkevm.max-gas-price: 0
zkevm.gas-price-factor: 0.0375

externalcl: true
```

### Starting the Node

```bash
./build/bin/cdk-erigon --config="./hermezconfig-mainnet.yaml"
```

### Docker

```bash
docker run -d \
  -p 8545:8545 \
  -v ./mainnet-data:/home/erigon/.local/share/erigon \
  hermeznetwork/cdk-erigon \
  --config="./mainnet.yaml" \
  --zkevm.l1-rpc-url=https://your-ethereum-mainnet-rpc.com
```

### L1 RPC Requirements

For mainnet, your L1 RPC must support:
- `eth_getLogs` with large block ranges (up to 20,000 blocks)
- Historical state queries back to block 16896700
- Archive node recommended for full functionality

**Recommended L1 providers:**
- Self-hosted Geth/Erigon archive node
- Alchemy, Infura, or QuickNode with archive access
- [Gateway.fm](https://gateway.fm) Ethereum RPC

### Block Explorers

- [PolygonScan zkEVM](https://zkevm.polygonscan.com/)

---

## zkEVM Cardona Testnet (Chain ID: 2442)

Cardona is the public testnet for zkEVM development and testing.

### Prerequisites

- **L1 RPC**: Sepolia testnet RPC endpoint
- **Disk Space**: 100GB+ SSD recommended
- **Memory**: 16GB+ RAM recommended

### Configuration

Create `hermezconfig-cardona.yaml`:

```yaml
datadir: /data/cdk-erigon-cardona
chain: hermez-cardona

# HTTP/WS RPC
http: true
http.addr: 0.0.0.0
http.api: [eth, debug, net, trace, web3, erigon, zkevm]
http.vhosts: any
http.corsdomain: any
ws: true

# Internal API (use different port from mainnet)
private.api.addr: localhost:9092

# L2 Network Configuration
zkevm.l2-chain-id: 2442
zkevm.l2-sequencer-rpc-url: https://rpc.cardona.zkevm-rpc.com/
zkevm.l2-datastreamer-url: datastream.cardona.zkevm-rpc.com:6900

# L1 Configuration (Sepolia Testnet)
zkevm.l1-chain-id: 11155111
zkevm.l1-rpc-url: https://rpc.sepolia.org
zkevm.l1-first-block: 4789190
zkevm.l1-rollup-id: 1
zkevm.l1-block-range: 20000
zkevm.l1-query-delay: 6000

# Contract Addresses (Cardona)
zkevm.address-sequencer: "0x761d53b47334bee6612c0bd1467fb881435375b2"
zkevm.address-zkevm: "0xA13Ddb14437A8F34897131367ad3ca78416d6bCa"
zkevm.address-rollup: "0x32d33d5137a7cffb54c5bf8371172bcec5f310ff"
zkevm.address-ger-manager: "0xAd1490c248c5d3CbAE399Fd529b79B42984277DF"

# Gas Configuration
zkevm.default-gas-price: 1000000000
zkevm.max-gas-price: 0
zkevm.gas-price-factor: 0.12

# Disable txpool for RPC-only node
txpool.disable: true

# Different torrent port to avoid conflicts
torrent.port: 42070

externalcl: true
```

### Starting the Node

```bash
./build/bin/cdk-erigon --config="./hermezconfig-cardona.yaml"
```

### Docker

```bash
docker run -d \
  -p 8546:8545 \
  -v ./cardona-data:/home/erigon/.local/share/erigon \
  hermeznetwork/cdk-erigon \
  --config="./cardona.yaml" \
  --zkevm.l1-rpc-url=https://rpc.sepolia.org
```

### Docker Compose

```bash
NETWORK=cardona L1_RPC_URL=https://rpc.sepolia.org docker-compose -f docker-compose-example.yml up -d
```

### Block Explorers

- [PolygonScan Cardona](https://cardona-zkevm.polygonscan.com/)

---

## Custom CDK Chains

For chains other than the defaults, cdk-erigon supports dynamic configuration.

### Overview

Custom CDK chains require:
1. Chain name starting with `dynamic-` prefix
2. Configuration files defining the network parameters
3. Contract addresses from network deployment

### Method 1: Multiple Configuration Files

Create separate files for each aspect of the configuration:

#### Directory Structure

```
dynamic-mynetwork/
├── dynamic-mynetwork.yaml           # Main config
├── dynamic-mynetwork-allocs.json    # Genesis allocations
├── dynamic-mynetwork-chainspec.json # Chain specification
└── dynamic-mynetwork-conf.json      # Additional config
```

#### 1. Chainspec File (`dynamic-mynetwork-chainspec.json`)

Defines chain parameters and fork blocks:

```json
{
  "ChainName": "dynamic-mynetwork",
  "chainId": 10001,
  "consensus": "ethash",
  "homesteadBlock": 0,
  "daoForkBlock": 0,
  "eip150Block": 0,
  "eip155Block": 0,
  "byzantiumBlock": 0,
  "constantinopleBlock": 0,
  "petersburgBlock": 0,
  "istanbulBlock": 0,
  "muirGlacierBlock": 0,
  "berlinBlock": 0,
  "londonBlock": 9999999999999999999999999999999999999999999999999,
  "arrowGlacierBlock": 9999999999999999999999999999999999999999999999999,
  "grayGlacierBlock": 9999999999999999999999999999999999999999999999999,
  "terminalTotalDifficulty": 58750000000000000000000,
  "terminalTotalDifficultyPassed": false,
  "shanghaiTime": 9999999999999999999999999999999999999999999999999,
  "cancunTime": 9999999999999999999999999999999999999999999999999,
  "pragueTime": 9999999999999999999999999999999999999999999999999,
  "ethash": {}
}
```

#### 2. Genesis Config (`dynamic-mynetwork-conf.json`)

Defines genesis block parameters:

```json
{
  "root": "0xd6dad0250a1b52d1d03b45e0fcc909444b6389463ae3ec7a5da75c3f53ae21c2",
  "timestamp": 1700000000,
  "gasLimit": 30000000,
  "difficulty": 1
}
```

#### 3. Allocations File (`dynamic-mynetwork-allocs.json`)

Pre-deployed contracts and initial balances:

```json
{
  "0x1234...": {
    "contractName": "MyContract",
    "balance": "0",
    "nonce": "1",
    "code": "0x6080...",
    "storage": {
      "0x0": "0x..."
    }
  }
}
```

**Tip:** If you have allocations in Polygon's format from network deployment, convert them:

```bash
go run cmd/hack/allocs/main.go your-allocs-file.json
```

#### 4. Main Config (`dynamic-mynetwork.yaml`)

```yaml
datadir: /data/dynamic-mynetwork
chain: dynamic-mynetwork

http: true
http.addr: 0.0.0.0
http.api: [eth, debug, net, trace, web3, erigon, zkevm]
private.api.addr: localhost:9091

zkevm.l2-chain-id: 10001
zkevm.l2-sequencer-rpc-url: https://rpc.mynetwork.com
zkevm.l2-datastreamer-url: datastream.mynetwork.com:6900

zkevm.l1-chain-id: 11155111
zkevm.l1-rpc-url: https://rpc.sepolia.org
zkevm.l1-first-block: 5000000

# Contract addresses from deployment output files
# create_rollup_output.json => sequencer
zkevm.address-sequencer: "0x..."
# create_rollup_output.json => rollupAddress
zkevm.address-zkevm: "0x..."
# deploy_output.json => polygonRollupManagerAddress
zkevm.address-rollup: "0x..."
# deploy_output.json => polygonZkEVMGlobalExitRootAddress
zkevm.address-ger-manager: "0x..."

externalcl: true
```

#### Starting with Method 1

```bash
./build/bin/cdk-erigon --config="./dynamic-mynetwork/dynamic-mynetwork.yaml"
```

With Docker, mount the config directory:

```bash
docker run -d \
  -v ./dynamic-mynetwork:/dynamic-mynetwork \
  hermeznetwork/cdk-erigon \
  --config="/dynamic-mynetwork/dynamic-mynetwork.yaml"
```

### Method 2: Unified Configuration File

Combine all configuration into a single JSON file.

#### 1. Create Unified Config (`dynamic-mynetwork.json`)

See `zk/examples/dynamic-configs/union-dynamic-config.json` for a complete example.

The file contains:
- Chain specification
- Genesis configuration
- Pre-deployed contract allocations
- All in one JSON structure

#### 2. Reference in YAML Config

```yaml
datadir: /data/dynamic-mynetwork
chain: dynamic-mynetwork

# Point to unified config
zkevm.genesis-config-path: "/dynamic-mynetwork/dynamic-mynetwork.json"

http: true
http.api: [eth, debug, net, trace, web3, erigon, zkevm]

zkevm.l2-chain-id: 10001
zkevm.l1-chain-id: 11155111
zkevm.l1-rpc-url: https://rpc.sepolia.org

zkevm.address-sequencer: "0x..."
zkevm.address-zkevm: "0x..."
zkevm.address-rollup: "0x..."
zkevm.address-ger-manager: "0x..."

externalcl: true
```

#### Starting with Method 2

```bash
./build/bin/cdk-erigon --config="./config.yaml" \
  --zkevm.genesis-config-path="/path/to/dynamic-mynetwork.json"
```

### Finding Contract Addresses

When deploying a new CDK chain, contract addresses are found in deployment output files:

| Config Flag | Source File | JSON Key |
|-------------|-------------|----------|
| `zkevm.address-sequencer` | `create_rollup_output.json` | `sequencer` |
| `zkevm.address-zkevm` | `create_rollup_output.json` | `rollupAddress` |
| `zkevm.address-rollup` | `deploy_output.json` | `polygonRollupManagerAddress` |
| `zkevm.address-ger-manager` | `deploy_output.json` | `polygonZkEVMGlobalExitRootAddress` |

### Example Dynamic Config Files

Example files are provided in the repository:

```
zk/examples/dynamic-configs/
├── dynamic-hermez-cardona-allocs.json
├── dynamic-hermez-cardona-chainspec.json
├── dynamic-hermez-cardona-conf.json
└── union-dynamic-config.json
```

### Custom Chain Checklist

Before starting your custom CDK chain node:

- [ ] Chain name starts with `dynamic-`
- [ ] `chainId` in chainspec matches `zkevm.l2-chain-id`
- [ ] L1 RPC is accessible and supports required methods
- [ ] `zkevm.l1-first-block` is correct (first block with rollup data)
- [ ] All contract addresses are correct
- [ ] For AggLayer networks: `zkevm.l1-first-block` must be the L1 block where GER Manager was deployed

---

## Running Multiple Networks

To run multiple networks on the same machine, ensure:

1. **Different data directories**: Use unique `datadir` for each network
2. **Different ports**:
   - `private.api.addr` (default: 9091)
   - `http.port` (default: 8545)
   - `torrent.port` (default: 42069)
   - `zkevm.data-stream-port` (default: 6900)

Example for running mainnet and Cardona simultaneously:

**Mainnet config:**
```yaml
datadir: /data/mainnet
private.api.addr: localhost:9091
http.port: 8545
torrent.port: 42069
```

**Cardona config:**
```yaml
datadir: /data/cardona
private.api.addr: localhost:9092
http.port: 8546
torrent.port: 42070
```

## Next Steps

- [RPC Node Setup](./rpc-node.md) - General RPC node configuration
- [Sequencer Setup](./sequencer.md) - Running a sequencer
- [Mode Switching](./mode-switching.md) - Switching between RPC and sequencer
