---
sidebar_position: 5
title: Hardware Recommendations
description: Hardware sizing recommendations by use case
---

# Hardware Recommendations

## By Use Case

### Development / Testing

| Component | Specification |
|-----------|---------------|
| CPU | 4 cores |
| RAM | 8 GB |
| Storage | 100 GB SSD |

### RPC Node (Light)

| Component | Specification |
|-----------|---------------|
| CPU | 4 cores |
| RAM | 16 GB |
| Storage | 500 GB NVMe |

### RPC Node (Production)

| Component | Specification |
|-----------|---------------|
| CPU | 8+ cores |
| RAM | 32 GB |
| Storage | 1 TB NVMe |

### Archive Node

| Component | Specification |
|-----------|---------------|
| CPU | 16+ cores |
| RAM | 64 GB |
| Storage | 4+ TB NVMe |

### Sequencer

| Component | Specification |
|-----------|---------------|
| CPU | 16+ cores |
| RAM | 64 GB |
| Storage | 2 TB NVMe |
| Network | 1 Gbps |

## Storage Notes

- NVMe SSDs strongly recommended
- IOPS requirements scale with RPC load
- Consider RAID configurations for production

## Next Steps

- [Running a Node](../running/rpc-node) - Start your node
- [Performance Tuning](../operations/performance-tuning) - Optimize performance
