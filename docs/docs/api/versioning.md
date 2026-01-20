---
sidebar_position: 2
title: API Versioning
description: API version history, breaking changes, and deprecation policy
---

# API Versioning

cdk-erigon follows semantic versioning for releases and maintains backward compatibility for JSON-RPC APIs where possible.

## Version Concepts

cdk-erigon has multiple version identifiers:

| Version Type | Description | How to Query |
|--------------|-------------|--------------|
| Client Version | cdk-erigon software release | `web3_clientVersion` |
| Fork ID | Protocol version for zkEVM | `zkevm_getForkId` |
| Protocol Version | Ethereum P2P protocol | `net_version` |

## Checking API Version

### Client Version

Get the running cdk-erigon version:

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"web3_clientVersion","params":[],"id":1}'
```

Response:

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": "cdk-erigon/v2.65.0/linux-amd64/go1.21"
}
```

### Fork ID

Get the current zkEVM fork ID:

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"zkevm_getForkId","params":[],"id":1}'
```

### Version History

Get complete protocol version history:

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"zkevm_getVersionHistory","params":[],"id":1}'
```

### All Forks

Get all fork information including activation blocks:

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"zkevm_getForks","params":[],"id":1}'
```

## API Version History

### v2.65.x (Current)

- Added `zkevm_getVersionHistory` method
- Added `zkevm_getForks` for querying all fork data
- Improved counter estimation accuracy

### v2.60.x

- Added `zkevm_estimateCounters` replacing `zkevm_virtualCounters`
- Added `zkevm_getBatchCountersByNumber`
- Deprecated `zkevm_virtualCounters`
- Deprecated `zkevm_traceTransactionCounters`

### v2.55.x

- Added witness methods (`zkevm_getWitness`, `zkevm_getWitnessByBlockHash`)
- Added exit root methods
- Improved batch query performance

### v2.50.x

- Added fork ID query methods
- Enhanced debug namespace support
- Added batch trace capabilities

## Breaking Changes

### v2.60.0

| Change | Migration |
|--------|-----------|
| `zkevm_virtualCounters` deprecated | Use `zkevm_estimateCounters` |
| `zkevm_traceTransactionCounters` deprecated | Use `zkevm_getBatchCountersByNumber` |

### v2.50.0

| Change | Migration |
|--------|-----------|
| Counter response format changed | Update response parsing for new field names |

## Deprecation Policy

cdk-erigon follows a deprecation process to maintain backward compatibility:

1. **Deprecation Notice**: Methods are marked as deprecated in release notes and documentation
2. **Deprecation Period**: Deprecated methods remain functional for at least 2 minor versions
3. **Removal**: After the deprecation period, methods may be removed in a major version

### Currently Deprecated Methods

| Method | Deprecated In | Replacement | Removal Target |
|--------|---------------|-------------|----------------|
| `zkevm_virtualCounters` | v2.60.0 | `zkevm_estimateCounters` | v3.0.0 |
| `zkevm_traceTransactionCounters` | v2.60.0 | `zkevm_getBatchCountersByNumber` | v3.0.0 |
| `zkevm_getBroadcastURI` | v2.55.0 | None (removed functionality) | v3.0.0 |

See [Deprecated Methods](./zkevm/deprecated) for usage details during the transition period.

## Compatibility Notes

### Fork ID Compatibility

Different cdk-erigon versions support different fork IDs. Ensure your node version supports the network's current fork:

| Fork ID | Minimum cdk-erigon | Network Activation |
|---------|-------------------|-------------------|
| 12 | v2.65.0 | Mainnet |
| 11 | v2.60.0 | Mainnet |
| 10 | v2.55.0 | Mainnet |
| 9 | v2.50.0 | Mainnet |

### Client Library Compatibility

| Library | Minimum Version | Notes |
|---------|-----------------|-------|
| ethers.js | 6.0+ | Full zkevm namespace support |
| viem | 1.0+ | Full zkevm namespace support |
| web3.js | 4.0+ | Requires custom method registration |

### Upgrade Recommendations

Before upgrading cdk-erigon:

1. Check release notes for breaking changes
2. Verify fork ID compatibility with network
3. Test deprecated method replacements
4. Update client applications if needed

See [Upgrading](../operations/upgrading) for the complete upgrade process.

## Error Handling

Version-related errors:

| Code | Message | Cause |
|------|---------|-------|
| -32601 | Method not found | Method removed or namespace not enabled |
| -32603 | Internal error | Fork data unavailable during sync |

## Next Steps

- [Fork Methods](./zkevm/fork-methods) - Query fork information
- [Deprecated Methods](./zkevm/deprecated) - Migration guides
- [Upgrading](../operations/upgrading) - Upgrade procedures
