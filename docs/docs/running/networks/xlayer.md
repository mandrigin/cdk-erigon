---
sidebar_position: 4
title: XLayer
description: Running cdk-erigon on XLayer (OKX's zkEVM L2)
---

# XLayer

Connect to XLayer, OKX's zkEVM-based Layer 2 network powered by Polygon CDK.

## Network Details

### Mainnet

| Property | Value |
|----------|-------|
| Chain ID | 196 |
| Network Name | XLayer Mainnet |
| L1 Network | Ethereum Mainnet |
| L1 Rollup ID | 3 |
| RPC URL | https://rpc.xlayer.tech |
| Datastream | stream.xlayer.tech:8800 |

### Testnet

| Property | Value |
|----------|-------|
| Chain ID | 195 |
| Network Name | XLayer Testnet |
| L1 Network | Sepolia |
| L1 Rollup ID | 1 |
| RPC URL | https://testrpc.xlayer.tech |
| Datastream | teststream.xlayer.tech:8800 |

## Configuration

### Mainnet

Use the provided mainnet configuration:

```bash
cdk-erigon --config xlayerconfig-mainnet.yaml.example
```

Or configure manually:

```yaml
chain: xlayer-mainnet

zkevm:
  l2-chain-id: 196
  l2-sequencer-rpc-url: https://rpc.xlayer.tech
  l2-datastreamer-url: stream.xlayer.tech:8800
  l1-chain-id: 1
  l1-rpc-url: https://your-ethereum-rpc.example.com
  l1-rollup-id: 3
  l1-first-block: 19218658
  l1-block-range: 2000
  l1-query-delay: 1000
  datastream-version: 3

  # Contract addresses (mainnet)
  address-sequencer: "0xAF9d27ffe4d51eD54AC8eEc78f2785D7E11E5ab1"
  address-zkevm: "0x2B0ee28D4D51bC9aDde5E58E295873F61F4a0507"
  address-rollup: "0x5132A183E9F3CB7C848b0AAC5Ae0c4f0491B7aB2"
  address-ger-manager: "0x580bda1e7A0CFAe92Fa7F6c20A3794F169CE3CFb"
```

### Testnet

Use the provided testnet configuration:

```bash
cdk-erigon --config xlayerconfig-testnet.yaml.example
```

Or configure manually:

```yaml
chain: xlayer-testnet

zkevm:
  l2-chain-id: 195
  l2-sequencer-rpc-url: https://testrpc.xlayer.tech
  l2-datastreamer-url: teststream.xlayer.tech:8800
  l1-chain-id: 11155111
  l1-rpc-url: https://your-sepolia-rpc.example.com
  l1-rollup-id: 1
  l1-first-block: 4648290
  l1-block-range: 2000
  l1-query-delay: 1000
  datastream-version: 3

  # Contract addresses (testnet)
  address-sequencer: "0xD6DdA5AA7749142B7fDa3Fe4662C9f346101B8A6"
  address-zkevm: "0x01469dACfDDA885D68Ff0f8628F2629c14F95a20"
  address-rollup: "0x6662621411A8DACC3cA7049C8BddABaa9a999ce3"
  address-ger-manager: "0x66E61bA00F58b857A9DD2C500F3aBc424A46BD20"
```

## L1 RPC Requirements

XLayer requires an L1 RPC endpoint for synchronization with the settlement layer.

### Mainnet (Ethereum)

- **Archive node recommended**: For full historical verification
- **Minimum requirements**: Standard full node with eth_call support
- **Rate limits**: Consider providers with high rate limits (2000+ req/min)

**Recommended providers:**
- Alchemy (Ethereum mainnet)
- Infura (Ethereum mainnet)
- Ankr (public/premium endpoints)
- QuickNode

### Testnet (Sepolia)

- **Standard Sepolia node**: Archive not required for testnet
- **Rate limits**: Lower traffic, public endpoints often sufficient

**Recommended providers:**
- Alchemy (Sepolia)
- Infura (Sepolia)
- Ankr (public Sepolia endpoint)

## Chain-Specific Considerations

### L1 Block Range

XLayer uses `l1-block-range: 2000` for efficient batch queries. Adjust if your L1 RPC has stricter limits.

### L1 Query Delay

The `l1-query-delay: 1000` (milliseconds) helps prevent rate limiting. Increase for public RPC endpoints.

### Datastream Version

XLayer uses datastream version 3. Ensure compatibility with your cdk-erigon version.

## Next Steps

- [zkEVM Mainnet](./mainnet) - Polygon zkEVM setup
- [Cardona Testnet](./cardona) - Test network setup
- [Custom CDK](./custom-cdk) - Deploy your own chain
