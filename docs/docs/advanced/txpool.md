# Transaction Pool Configuration

This document covers CDK-specific transaction pool modifications and configuration options that differ from mainline Erigon.

## Priority Senders

CDK Erigon supports priority senders - addresses whose transactions receive preferential treatment in the transaction pool ordering.

### Configuration

Use the `--txpool.priority-senders-json-location` flag to specify a JSON file containing priority addresses:

```bash
cdk-erigon --txpool.priority-senders-json-location=/path/to/priority-senders.json
```

### JSON Format

The priority senders file uses this format:

```json
{
  "senders": [
    "0x1234567890abcdef1234567890abcdef12345678",
    "0xabcdef1234567890abcdef1234567890abcdef12"
  ]
}
```

Addresses listed earlier in the array have higher priority. The first address gets the highest priority value, decreasing for subsequent addresses.

### Behavior

- Priority senders' transactions are sorted ahead of regular transactions in the pending pool
- Priority is applied during transaction selection for block building
- The sequencer considers priority when yielding transactions from the pool

## Sequencer Transaction Pool

When running as a sequencer (`--zkevm.is-sequencer`), the transaction pool has additional requirements and behaviors.

### Required Settings

The transaction pool must be enabled for sequencer mode:

```bash
# txpool.disable must be false (default)
--txpool.disable=false
```

### Sequencer-Specific Flags

| Flag | Description | Default |
|------|-------------|---------|
| `--zkevm.sequencer-timeout-on-empty-txpool` | Timeout before re-checking pool when empty | `5ms` |
| `--zkevm.txpool-reject-smart-contract-deployments` | Reject contract deployment transactions | `false` |

### Transaction Selection

The sequencer's `YieldBest` function selects transactions considering:

1. Priority sender status
2. Effective tip (fee cap minus base fee)
3. Gas limits and available block space
4. Nonce ordering per sender

## Gas Price Handling

CDK Erigon implements zkEVM-specific gas price mechanics.

### Effective Gas Price Multipliers

Different transaction types can have different effective gas price factors (0.0 to 1.0):

| Flag | Description |
|------|-------------|
| `--zkevm.effective-gas-price-for-eth-transfer` | Multiplier for ETH transfers |
| `--zkevm.effective-gas-price-for-erc20-transfer` | Multiplier for ERC20 transfers |
| `--zkevm.effective-gas-price-for-contract-invocation` | Multiplier for contract calls |
| `--zkevm.effective-gas-price-for-contract-deployment` | Multiplier for deployments |

### Gas Price Configuration

| Flag | Description | Default |
|------|-------------|---------|
| `--zkevm.default-gas-price` | Default gas price when not specified | - |
| `--zkevm.max-gas-price` | Maximum allowed gas price | - |
| `--zkevm.gas-price-factor` | Gas price adjustment factor | - |

### Low Gas Price Rejection

| Flag | Description |
|------|-------------|
| `--zkevm.reject-low-gas-price-transactions` | Enable rejection of low gas price txs |
| `--zkevm.reject-low-gas-price-tolerance` | Tolerance factor for rejection |
| `--zkevm.gas-price-check-frequency` | How often to check gas prices |
| `--zkevm.gas-price-history-count` | Number of historical prices to track |

## Access Control Lists (ACL)

CDK Erigon supports transaction filtering via ACLs.

### Configuration

```bash
--acl.json-location=/path/to/acl.json
```

The ACL system can allow or deny transactions based on sender address and action type.

## Differences from Mainline Erigon

| Feature | Mainline Erigon | CDK Erigon |
|---------|-----------------|------------|
| Priority senders | Not supported | Supported via JSON config |
| Effective gas price multipliers | Not supported | Per-transaction-type multipliers |
| ACL filtering | Not supported | Supported |
| Contract deployment rejection | Not supported | Optional via flag |
| zkEVM gas price handling | N/A | Integrated |

## Standard Transaction Pool Flags

CDK Erigon also supports standard Erigon transaction pool configuration:

| Flag | Description |
|------|-------------|
| `--txpool.disable` | Disable the transaction pool |
| `--txpool.locals` | Comma-separated local sender addresses |
| `--txpool.nolocals` | Disable local transaction exemptions |
| `--txpool.pricelimit` | Minimum gas price for acceptance |
| `--txpool.pricebump` | Price bump percentage for replacement |
| `--txpool.accountslots` | Minimum slots per account |
| `--txpool.globalslots` | Maximum pending transactions |
| `--txpool.accountqueue` | Maximum queued transactions per account |
| `--txpool.globalqueue` | Maximum queued transactions total |
| `--txpool.lifetime` | Maximum time a transaction stays in pool |
