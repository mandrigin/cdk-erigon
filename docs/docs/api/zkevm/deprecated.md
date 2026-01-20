---
sidebar_position: 7
title: Deprecated Methods
description: Deprecated zkevm RPC methods
---

# Deprecated Methods

These methods are deprecated and may be removed in future versions.

## zkevm_getBroadcastURI

:::warning Deprecated
This method is deprecated and will be removed in a future version.
:::

Previously used for broadcast URI retrieval.

---

## zkevm_virtualCounters

:::warning Deprecated
This method is deprecated. Use `zkevm_estimateCounters` instead.
:::

Legacy counter estimation method.

---

## zkevm_traceTransactionCounters

:::warning Deprecated
This method is deprecated. Use `zkevm_getBatchCountersByNumber` instead.
:::

Legacy transaction counter tracing.

## Migration Guide

| Deprecated Method | Replacement |
|-------------------|-------------|
| `zkevm_virtualCounters` | `zkevm_estimateCounters` |
| `zkevm_traceTransactionCounters` | `zkevm_getBatchCountersByNumber` |
| `zkevm_getBroadcastURI` | None (removed functionality) |

## Next Steps

- [Counter Methods](./counter-methods) - Current counter APIs
- [API Overview](../overview) - All available APIs
