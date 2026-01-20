# CLI Reference

Complete reference for the cdk-erigon command-line interface.

## Usage

```bash
cdk-erigon [command] [flags]
```

## Commands

cdk-erigon supports the following subcommands:

| Command | Description |
|---------|-------------|
| `init` | Initialize a new node with genesis configuration |
| `import` | Import blocks from a file |
| `snapshots` | Manage state snapshots |
| `support` | Diagnostic and support utilities |

Run `cdk-erigon <command> --help` for detailed usage of each command.

## Configuration Methods

cdk-erigon supports three configuration methods (in order of precedence):

1. **CLI flags**: `--flag-name=value`
2. **YAML config file**: Specified with `--config="/path/to/config.yaml"`
3. **TOML config file**: Specified with `--config="/path/to/config.toml"`

### Example YAML Configuration

```yaml
datadir: /data/cdk-erigon
chain: hermez-mainnet

# HTTP RPC
http.api: ["eth", "debug", "net", "trace", "web3", "erigon", "zkevm"]
http.addr: "0.0.0.0"
http.port: 8545
http.vhosts: ["*"]
http.corsdomain: ["*"]

# zkEVM specific
zkevm.l2-chain-id: 1101
zkevm.l2-sequencer-rpc-url: "https://zkevm-rpc.com"
zkevm.l2-datastreamer-url: "datastreamer.zkevm-rpc.com:6900"
zkevm.l1-rpc-url: "https://eth-mainnet.rpc.com"
```

## Global Options

### Core Options

| Flag | Description | Default |
|------|-------------|---------|
| `--config` | Path to YAML or TOML configuration file | N/A |
| `--datadir` | Data directory for the databases | `~/.local/share/erigon` |
| `--chain` | Name of the network to join | `mainnet` |

### Network Options

| Flag | Description | Default |
|------|-------------|---------|
| `--http` | Enable HTTP-RPC server | `false` |
| `--http.addr` | HTTP-RPC server listening interface | `localhost` |
| `--http.port` | HTTP-RPC server listening port | `8545` |
| `--http.api` | API namespaces to enable | `eth,erigon,engine` |
| `--http.corsdomain` | CORS allowed domains | N/A |
| `--http.vhosts` | Virtual hosts allowed | `localhost` |
| `--ws` | Enable WebSocket RPC server | `false` |
| `--ws.addr` | WebSocket listening interface | `localhost` |
| `--ws.port` | WebSocket listening port | `8546` |
| `--private.api.addr` | gRPC server address | `127.0.0.1:9090` |

### Logging Options

| Flag | Description | Default |
|------|-------------|---------|
| `--log.console.verbosity` | Log level (trace, debug, info, warn, error, crit) | `info` |
| `--log.console.json` | Output logs in JSON format | `false` |
| `--log.dir.path` | Directory path for log files | N/A |

### Transaction Pool Options

| Flag | Description | Default |
|------|-------------|---------|
| `--txpool.disable` | Disable transaction pool | `false` |
| `--txpool.pricelimit` | Minimum gas price limit | `1` |
| `--txpool.accountslots` | Minimum slots per account | `16` |
| `--txpool.globalslots` | Maximum slots for all accounts | `10000` |

## zkEVM-Specific Options

All zkEVM-specific flags use the `zkevm.` prefix. See [zkEVM Configuration Flags](./zkevm-flags.md) for the complete reference.

### Essential zkEVM Flags

| Flag | Description | Required |
|------|-------------|----------|
| `--zkevm.l2-chain-id` | L2 network chain ID | Yes |
| `--zkevm.l2-sequencer-rpc-url` | Upstream L2 sequencer RPC endpoint | Yes (RPC node) |
| `--zkevm.l2-datastreamer-url` | L2 data stream endpoint | Yes (RPC node) |
| `--zkevm.l1-rpc-url` | L1 Ethereum RPC URL | Yes |
| `--zkevm.l1-chain-id` | L1 network chain ID | Yes |
| `--zkevm.address-zkevm` | zkEVM contract address on L1 | Yes |

### Sequencer Mode

Enable sequencer mode by setting the environment variable:

```bash
CDK_ERIGON_SEQUENCER=1 cdk-erigon --config="./config.yaml"
```

Additional sequencer-specific flags:

| Flag | Description |
|------|-------------|
| `--zkevm.executor-urls` | Comma-separated list of executor URLs |
| `--zkevm.executor-strict` | Enable strict verification mode |
| `--zkevm.data-stream-port` | Port for serving data stream |
| `--zkevm.data-stream-host` | Host for serving data stream |

## Subcommand Reference

### init

Initialize a new node with genesis configuration.

```bash
cdk-erigon init --datadir=/data/cdk-erigon genesis.json
```

### import

Import blocks from an exported file.

```bash
cdk-erigon import --datadir=/data/cdk-erigon blocks.rlp
```

### snapshots

Manage state snapshots for faster sync.

```bash
# List available snapshots
cdk-erigon snapshots list

# Create a snapshot
cdk-erigon snapshots create --datadir=/data/cdk-erigon
```

### support

Diagnostic and support utilities.

```bash
cdk-erigon support --datadir=/data/cdk-erigon
```

## Environment Variables

cdk-erigon recognizes the following environment variables:

| Variable | Description |
|----------|-------------|
| `CDK_ERIGON_SEQUENCER` | Set to `1` to enable sequencer mode |
| `ERIGON_DATADIR` | Default data directory |

## Exit Codes

| Code | Description |
|------|-------------|
| `0` | Success |
| `1` | General error |

## See Also

- [Getting Started](../getting-started.md) - Quick start guide
- [zkEVM Configuration Flags](./zkevm-flags.md) - Complete zkEVM flag reference
- [Configuration Reference](../configuration/) - Full configuration documentation
