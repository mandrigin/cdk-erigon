---
sidebar_position: 1
title: CDK Architecture Overview
description: How cdk-erigon fits in the Polygon CDK stack
---

# CDK Architecture Overview

Understanding cdk-erigon's role in the Polygon CDK stack.

## Component Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                      Polygon CDK Stack                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │   cdk-node  │    │ cdk-erigon  │    │   Prover    │     │
│  │  (Sequence  │◄──►│ (Execution) │◄──►│   (ZK)      │     │
│  │   Sender)   │    │             │    │             │     │
│  └─────────────┘    └─────────────┘    └─────────────┘     │
│         │                  │                  │             │
│         │                  │                  │             │
│         ▼                  ▼                  ▼             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │               L1 Ethereum (Settlement)               │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## cdk-erigon Role

cdk-erigon serves as the **execution layer**:

- **Block Production** (Sequencer mode)
- **State Management** (SMT/PMT)
- **JSON-RPC API** (eth, zkevm namespaces)
- **Data Streaming** (to RPC nodes)

## Data Flows

### Sequencer Flow

1. Transactions enter via RPC
2. cdk-erigon validates and sequences
3. Blocks streamed to cdk-node
4. cdk-node submits to L1
5. Prover generates ZK proof

### RPC Node Flow

1. Data stream from sequencer
2. cdk-erigon processes blocks
3. State updated in SMT
4. API serves queries

## Next Steps

- [cdk-node Integration](./cdk-node) - Sequencer integration
- [Prover Integration](./prover) - ZK proof generation
