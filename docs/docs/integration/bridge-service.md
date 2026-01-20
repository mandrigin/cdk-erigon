---
sidebar_position: 4
title: Bridge Service
description: Configure cdk-erigon for bridge operations
---

# Bridge Service

Configure cdk-erigon for cross-chain bridge operations.

## Overview

The bridge enables asset transfers between L1 and L2 using:
- Global Exit Root (GER)
- Exit trees
- Bridge contracts

## Global Exit Root (GER)

The Global Exit Root is the cryptographic commitment that enables secure cross-chain communication. It combines exit roots from both L1 (Mainnet) and L2 (Rollup) to create a unified verification mechanism.

### GER Structure

```
Global Exit Root (GER)
        │
        ├── Mainnet Exit Root (L1)
        │   └── Merkle root of L1 → L2 deposits
        │
        └── Rollup Exit Root (L2)
            └── Merkle root of L2 → L1 withdrawals
```

The GER is computed as:
```
GER = keccak256(MainnetExitRoot || RollupExitRoot)
```

### GER Components

| Component | Description | Source |
|-----------|-------------|--------|
| **MainnetExitRoot** | Root of L1 deposit tree | L1 Bridge Contract |
| **RollupExitRoot** | Root of L2 withdrawal tree | L2 Local Exit Root |
| **GER** | Combined hash of both roots | GER Manager Contract |

## GER Manager

The GER Manager contract maintains the Global Exit Root on L2, enabling bridge claim verification.

### L2 GER Manager Address

The canonical L2 GER Manager address is:
```
0xa40D5f56745a118D0906a34E69aeC8C0Db1cB8fA
```

### Configuration

Configure GER manager address in your config:

```yaml
zkevm:
  address-ger-manager: "0xa40D5f56745a118D0906a34E69aeC8C0Db1cB8fA"
```

### GER Storage

The GER Manager stores GER timestamps at computed storage positions:
```
position = keccak256(GER || 0x00...00)  # 32-byte padded storage slot 0
value = timestamp when GER was recorded
```

This allows verification that a specific GER was valid at a given time.

## Exit Trees

Exit trees are Merkle trees that track cross-chain messages.

### L1 Exit Tree (Mainnet)

Tracks deposits from L1 to L2:
- Updated when users deposit assets on L1
- Root becomes the MainnetExitRoot
- L2 reads this to verify incoming deposits

### L2 Exit Tree (Local)

Tracks withdrawals from L2 to L1:
- Updated when users initiate withdrawals on L2
- Root becomes the LocalExitRoot (part of batch data)
- L1 reads this (via ZK proof) to verify outgoing claims

### Exit Root Lifecycle

```
L1 Deposit                           L2 Withdrawal
    │                                     │
    ▼                                     ▼
L1 Exit Tree updated               L2 Exit Tree updated
    │                                     │
    ▼                                     ▼
MainnetExitRoot changes            LocalExitRoot changes
    │                                     │
    └────────► GER Updated ◄──────────────┘
                   │
                   ▼
           L2 receives new GER
           (via L1 Info Tree)
```

## L1 Info Tree

The L1 Info Tree provides L1 state to L2, including GER updates.

### L1InfoTreeUpdate Structure

Each update contains:

| Field | Description |
|-------|-------------|
| `index` | Sequential update index |
| `ger` | Global Exit Root hash |
| `mainnetExitRoot` | L1 exit tree root |
| `rollupExitRoot` | L2 exit tree root |
| `parentHash` | L1 block parent hash |
| `timestamp` | L1 block timestamp |
| `blockNumber` | L1 block number |

### Querying L1 Info Tree

```bash
# Get L2 block info tree data
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"method":"zkevm_getL2BlockInfoTree","params":["0x100"]}'
```

## Bridge Operations

### Deposit Flow (L1 → L2)

```
1. User deposits on L1 Bridge Contract
           │
           ▼
2. L1 Exit Tree updated with deposit
           │
           ▼
3. MainnetExitRoot changes
           │
           ▼
4. New GER computed and posted
           │
           ▼
5. L2 receives GER via L1 Info Tree
           │
           ▼
6. User claims on L2 with Merkle proof
```

### Withdrawal Flow (L2 → L1)

```
1. User initiates withdrawal on L2
           │
           ▼
2. L2 Exit Tree updated
           │
           ▼
3. LocalExitRoot included in batch
           │
           ▼
4. Batch ZK proof verified on L1
           │
           ▼
5. RollupExitRoot updated on L1
           │
           ▼
6. User claims on L1 with Merkle proof
```

## Cross-Chain Verification

Bridge claims require Merkle proofs against the appropriate exit root.

### Verifying L2 Claims

To verify an L2 claim (from L1 deposit):
1. Get the GER that includes the deposit
2. Obtain the MainnetExitRoot from that GER
3. Verify the deposit Merkle proof against MainnetExitRoot

### Verifying L1 Claims

To verify an L1 claim (from L2 withdrawal):
1. Wait for the batch containing the withdrawal to be verified
2. Get the RollupExitRoot from the verified batch state
3. Verify the withdrawal Merkle proof against RollupExitRoot

## RPC Methods

### Get Latest GER

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"method":"zkevm_getLatestGlobalExitRoot","params":[]}'
```

### Get Exit Root Table

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"method":"zkevm_getExitRootTable","params":[]}'
```

### Query by GER

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"method":"zkevm_getExitRootsByGER","params":["0x..."]}'
```

See [Exit Root Methods](../api/zkevm/exit-root-methods) for full API documentation.

## Batch and GER Relationship

Each batch contains a `globalExitRoot` field indicating which GER was active when the batch was created. This links batch execution to the L1 state known at that time.

```
Batch N
├── globalExitRoot: 0x...  ◄── GER used for this batch
├── localExitRoot: 0x...   ◄── L2 exit root after batch
├── stateRoot: 0x...
└── transactions: [...]
```

This enables:
- Bridge claims within the batch to verify against the correct L1 state
- ZK proofs to include L1 state verification

## Next Steps

- [Exit Root Methods](../api/zkevm/exit-root-methods) - Full GER API reference
- [Kurtosis](./kurtosis) - Local development environment
- [Glossary](../glossary) - Bridge terminology
