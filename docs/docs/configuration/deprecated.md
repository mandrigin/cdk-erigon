---
sidebar_position: 8
title: Deprecated Flags
description: Removed and deprecated configuration options
---

# Deprecated Flags

Configuration options that have been removed or deprecated.

## Removed Flags

### externalcl

Previously used for external consensus layer. Removed as cdk-erigon uses data stream sync.

### l1-cache-enabled

L1 caching flag. Caching behavior is now automatic.

## Migration Guide

If you're upgrading from an older version, remove these flags from your configuration:

```yaml
# Remove these lines:
# externalcl: true
# l1-cache-enabled: true
```

## Deprecated RPC Methods

See [API Deprecated Methods](../api/zkevm/deprecated) for deprecated JSON-RPC methods.

## Next Steps

- [Upgrading](../operations/upgrading) - Version upgrade guide
- [Migration](../running/migration) - Mode migration
