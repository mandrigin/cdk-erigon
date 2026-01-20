---
sidebar_position: 5
title: FAQ
description: Frequently asked questions about cdk-erigon
---

# FAQ

Frequently asked questions about cdk-erigon.

## General

### What is cdk-erigon?

cdk-erigon is a fork of Erigon optimized for Polygon zkEVM and CDK-powered chains. It provides high-performance execution client capabilities for ZK rollups.

### How is it different from regular Erigon?

cdk-erigon adds:
- zkEVM RPC namespace (25+ methods)
- Sparse Merkle Tree state storage
- Data stream synchronization
- L1 recovery capabilities
- Sequencer mode

### Which networks does it support?

- Polygon zkEVM Mainnet (Chain ID: 1101)
- Polygon zkEVM Cardona Testnet (Chain ID: 2442)
- Custom CDK chains

## Operations

### How long does initial sync take?

Sync time depends on:
- Network speed
- Hardware performance
- Current chain height

Expect several hours to days for full sync.

### How much disk space is needed?

- RPC Node: ~500GB+
- Archive Node: ~2TB+

Space requirements grow over time.

### Can I run multiple nodes?

Yes, you can run multiple RPC nodes pointing to the same sequencer.

## Troubleshooting

### Why is my node not syncing?

Common causes:
1. Incorrect data stream URL
2. Network connectivity issues
3. Insufficient resources

See [Sync Issues](./sync-issues) for detailed troubleshooting.

### Why is SMT rebuilding?

SMT rebuilds when:
- First sync
- Fork ID upgrade
- State divergence detected

This is normal and automatic.

### How do I check if my node is healthy?

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}'
```

Returns `false` when fully synced.

## Resources

- [GitHub Repository](https://github.com/0xPolygon/cdk-erigon)
- [Polygon CDK Documentation](https://docs.polygon.technology/cdk/)
- [Discord Community](https://discord.gg/polygon)
