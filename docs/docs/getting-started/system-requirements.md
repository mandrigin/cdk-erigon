---
sidebar_position: 2
title: System Requirements
description: Hardware and software requirements for running cdk-erigon
---

# System Requirements

See [Hardware Recommendations](../installation/hardware-recommendations) for detailed sizing guidance based on your use case.

## Hardware Requirements

### Minimum (RPC Node)

| Component | Requirement |
|-----------|-------------|
| CPU | 4+ cores |
| RAM | 16 GB |
| Storage | 500 GB NVMe SSD |
| Network | 25 Mbps |

### Recommended (Production RPC)

| Component | Requirement |
|-----------|-------------|
| CPU | 8+ cores |
| RAM | 32 GB |
| Storage | 1 TB NVMe SSD |
| Network | 100 Mbps |

### Sequencer Node

For sequencer setup, see [Sequencer Configuration](../running/sequencer) and [Prover Integration](../integration/prover).

| Component | Requirement |
|-----------|-------------|
| CPU | 16+ cores |
| RAM | 64 GB |
| Storage | 2 TB NVMe SSD |
| Network | 1 Gbps |

## Software Requirements

### Operating System

- Linux (Ubuntu 22.04+ recommended)
- macOS 12+ (development only)

### Dependencies

- Go 1.19+
- GCC/G++ 12+
- Make
- Git

## Network Requirements

- Outbound access to L1 Ethereum RPC
- Outbound access to data stream endpoint
- Inbound access on configured RPC ports (default: 8545)

## Next Steps

- [Quick Start](./quickstart) - Get running quickly
- [Installation](../installation/binaries) - Detailed installation guide
