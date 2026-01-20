---
sidebar_position: 5
title: Kurtosis
description: Local CDK development with Kurtosis
---

# Kurtosis

Set up a local CDK development environment using Kurtosis.

## Overview

[kurtosis-cdk](https://github.com/0xPolygon/kurtosis-cdk) provides a complete local CDK stack for development and testing.

## Prerequisites

- Docker
- Kurtosis CLI

## Installation

### Install Kurtosis

```bash
# macOS
brew install kurtosis-tech/tap/kurtosis-cli

# Linux
echo "deb [trusted=yes] https://apt.fury.io/kurtosis-tech/ /" | \
  sudo tee /etc/apt/sources.list.d/kurtosis.list
sudo apt update
sudo apt install kurtosis-cli
```

## Quick Start

```bash
# Clone kurtosis-cdk
git clone https://github.com/0xPolygon/kurtosis-cdk.git
cd kurtosis-cdk

# Start the stack
kurtosis run .
```

## Components Started

- cdk-erigon (Sequencer)
- cdk-erigon (RPC)
- cdk-node
- Prover
- Bridge service
- L1 (local Ethereum)

## Access Points

| Service | URL |
|---------|-----|
| L2 RPC | http://localhost:8545 |
| L1 RPC | http://localhost:8546 |
| Explorer | http://localhost:4000 |

## Stop Environment

```bash
kurtosis clean -a
```

## Next Steps

- [Architecture Overview](./architecture-overview) - Understand the stack
- [Getting Started](../getting-started/quickstart) - Production setup
