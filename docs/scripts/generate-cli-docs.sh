#!/bin/bash
# Generate CLI documentation from cdk-erigon --help output
# This script auto-generates the CLI reference documentation

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCS_DIR="$(dirname "$SCRIPT_DIR")"
OUTPUT_FILE="$DOCS_DIR/docs/configuration/cli-reference.md"
ERIGON_BIN="${ERIGON_BIN:-cdk-erigon}"

echo "Generating CLI documentation..."

# Check if cdk-erigon binary is available
if ! command -v "$ERIGON_BIN" &> /dev/null; then
    echo "Warning: $ERIGON_BIN not found in PATH"
    echo "Set ERIGON_BIN environment variable to specify the binary location"
    echo "Generating placeholder documentation..."

    cat > "$OUTPUT_FILE" << 'EOF'
---
sidebar_position: 10
title: CLI Reference
description: Complete command-line reference for cdk-erigon
---

# CLI Reference

:::note
This documentation is auto-generated from `cdk-erigon --help` output.
Run `docs/scripts/generate-cli-docs.sh` to regenerate.
:::

## Usage

```bash
cdk-erigon [global options] command [command options] [arguments...]
```

## Global Options

Run `cdk-erigon --help` for the complete list of options.

## Commands

Run `cdk-erigon <command> --help` for command-specific options.
EOF
    exit 0
fi

# Generate documentation header
cat > "$OUTPUT_FILE" << 'EOF'
---
sidebar_position: 10
title: CLI Reference
description: Complete command-line reference for cdk-erigon
---

# CLI Reference

:::note Auto-generated
This documentation is auto-generated from `cdk-erigon --help` output.
Run `docs/scripts/generate-cli-docs.sh` to regenerate.
:::

## Usage

```bash
cdk-erigon [global options] command [command options] [arguments...]
```

## Global Options

EOF

# Extract and format help output
"$ERIGON_BIN" --help 2>&1 | while IFS= read -r line; do
    # Skip empty lines at start
    [[ -z "$line" ]] && continue

    # Format flag lines
    if [[ "$line" =~ ^[[:space:]]+--([a-z]) ]]; then
        echo "\`\`\`"
        echo "$line"
        echo "\`\`\`"
        echo ""
    else
        echo "$line"
    fi
done >> "$OUTPUT_FILE"

echo "CLI documentation generated: $OUTPUT_FILE"
