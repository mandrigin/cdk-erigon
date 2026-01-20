#!/bin/bash
#
# generate-cli-docs.sh - Auto-generate CLI reference documentation from cdk-erigon --help
#
# This script extracts help information from cdk-erigon and its subcommands,
# then generates markdown documentation suitable for inclusion in the docs site.
#
# Usage:
#   ./scripts/generate-cli-docs.sh [output-dir]
#
# Arguments:
#   output-dir  Directory to write generated docs (default: docs/reference)
#
# Requirements:
#   - cdk-erigon binary must be built (run `make cdk-erigon` first)
#   - Binary should be at ./build/bin/cdk-erigon or in PATH
#

set -e

# Configuration
OUTPUT_DIR="${1:-docs/reference}"
BINARY_NAME="cdk-erigon"
BINARY_PATH="./build/bin/${BINARY_NAME}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Find the cdk-erigon binary
find_binary() {
    if [ -x "$BINARY_PATH" ]; then
        echo "$BINARY_PATH"
    elif command -v "$BINARY_NAME" &> /dev/null; then
        command -v "$BINARY_NAME"
    else
        return 1
    fi
}

# Generate header for markdown file
generate_header() {
    local title="$1"
    local description="$2"
    cat << EOF
# ${title}

${description}

> **Note**: This documentation is auto-generated from \`${BINARY_NAME} --help\`.
> Last updated: $(date -u +"%Y-%m-%d %H:%M UTC")

EOF
}

# Parse help output and convert to markdown
parse_help_to_markdown() {
    local help_text="$1"
    local in_flags=false
    local in_commands=false

    echo "$help_text" | while IFS= read -r line; do
        # Detect sections
        if [[ "$line" =~ ^COMMANDS: ]]; then
            echo "## Commands"
            echo ""
            in_commands=true
            in_flags=false
            continue
        elif [[ "$line" =~ ^GLOBAL\ OPTIONS: ]] || [[ "$line" =~ ^OPTIONS: ]]; then
            echo "## Options"
            echo ""
            echo "| Flag | Description | Default |"
            echo "|------|-------------|---------|"
            in_flags=true
            in_commands=false
            continue
        elif [[ "$line" =~ ^[A-Z]+: ]]; then
            in_flags=false
            in_commands=false
        fi

        # Parse flags section
        if $in_flags; then
            # Match flag lines: --flag-name value  Description (default: value)
            if [[ "$line" =~ ^[[:space:]]*--([a-zA-Z0-9._-]+)(=[^[:space:]]+)?[[:space:]]+(.*) ]]; then
                local flag="${BASH_REMATCH[1]}"
                local value_hint="${BASH_REMATCH[2]}"
                local rest="${BASH_REMATCH[3]}"

                # Extract default value if present
                local default=""
                local description="$rest"
                if [[ "$rest" =~ \(default:\ ([^)]+)\) ]]; then
                    default="${BASH_REMATCH[1]}"
                    description="${rest%% (default:*}"
                fi

                # Clean up description
                description=$(echo "$description" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')

                echo "| \`--${flag}${value_hint}\` | ${description} | ${default:-N/A} |"
            fi
        fi

        # Parse commands section
        if $in_commands; then
            if [[ "$line" =~ ^[[:space:]]+([a-zA-Z0-9_-]+)[[:space:]]+(.*) ]]; then
                local cmd="${BASH_REMATCH[1]}"
                local desc="${BASH_REMATCH[2]}"
                echo "- \`${cmd}\`: ${desc}"
            fi
        fi
    done
}

# Generate documentation for main command
generate_main_docs() {
    local binary="$1"
    local output_file="$2"

    log_info "Generating main CLI reference..."

    local help_text
    help_text=$("$binary" --help 2>&1 || true)

    {
        generate_header "CLI Reference" "Complete reference for the cdk-erigon command-line interface."

        echo "## Usage"
        echo ""
        echo "\`\`\`bash"
        echo "${BINARY_NAME} [command] [flags]"
        echo "\`\`\`"
        echo ""

        parse_help_to_markdown "$help_text"

    } > "$output_file"

    log_info "Written: $output_file"
}

# Generate documentation for subcommands
generate_subcommand_docs() {
    local binary="$1"
    local output_dir="$2"

    local subcommands=("init" "import" "snapshots" "support")

    for cmd in "${subcommands[@]}"; do
        log_info "Generating docs for subcommand: $cmd"

        local help_text
        help_text=$("$binary" "$cmd" --help 2>&1 || true)

        if [ -n "$help_text" ]; then
            local output_file="${output_dir}/${BINARY_NAME}-${cmd}.md"
            {
                generate_header "${BINARY_NAME} ${cmd}" "Reference for the \`${BINARY_NAME} ${cmd}\` subcommand."

                echo "## Usage"
                echo ""
                echo "\`\`\`bash"
                echo "${BINARY_NAME} ${cmd} [flags]"
                echo "\`\`\`"
                echo ""

                parse_help_to_markdown "$help_text"

            } > "$output_file"

            log_info "Written: $output_file"
        else
            log_warn "No help available for subcommand: $cmd"
        fi
    done
}

# Generate zkevm flags reference
generate_zkevm_flags_docs() {
    local binary="$1"
    local output_file="$2"

    log_info "Generating zkEVM flags reference..."

    local help_text
    help_text=$("$binary" --help 2>&1 || true)

    {
        generate_header "zkEVM Configuration Flags" "Complete reference for cdk-erigon zkEVM-specific configuration flags."

        echo "All zkEVM-specific flags use the \`zkevm.\` prefix. These flags configure the zkEVM-specific behavior of cdk-erigon."
        echo ""
        echo "## Configuration Methods"
        echo ""
        echo "Each flag can be set via:"
        echo ""
        echo "1. **CLI flag**: \`--zkevm.flag-name=value\`"
        echo "2. **Environment variable**: \`ZKEVM_FLAG_NAME=value\` (replace dots and hyphens with underscores, uppercase)"
        echo "3. **YAML config file**: \`zkevm.flag-name: value\`"
        echo ""
        echo "## Flags Reference"
        echo ""
        echo "| Flag | Description | Default |"
        echo "|------|-------------|---------|"

        # Extract only zkevm.* flags
        echo "$help_text" | grep -E "^\s*--zkevm\." | while IFS= read -r line; do
            if [[ "$line" =~ ^[[:space:]]*--([a-zA-Z0-9._-]+)(=[^[:space:]]+)?[[:space:]]+(.*) ]]; then
                local flag="${BASH_REMATCH[1]}"
                local value_hint="${BASH_REMATCH[2]}"
                local rest="${BASH_REMATCH[3]}"

                local default=""
                local description="$rest"
                if [[ "$rest" =~ \(default:\ ([^)]+)\) ]]; then
                    default="${BASH_REMATCH[1]}"
                    description="${rest%% (default:*}"
                fi

                description=$(echo "$description" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')

                echo "| \`--${flag}${value_hint}\` | ${description} | ${default:-N/A} |"
            fi
        done

    } > "$output_file"

    log_info "Written: $output_file"
}

# Main execution
main() {
    log_info "Starting CLI documentation generation..."

    # Find binary
    local binary
    if ! binary=$(find_binary); then
        log_error "Cannot find ${BINARY_NAME} binary."
        log_error "Please build it first: make cdk-erigon"
        exit 1
    fi

    log_info "Using binary: $binary"

    # Create output directory
    mkdir -p "$OUTPUT_DIR"

    # Generate documentation
    generate_main_docs "$binary" "${OUTPUT_DIR}/cli-reference.md"
    generate_subcommand_docs "$binary" "$OUTPUT_DIR"
    generate_zkevm_flags_docs "$binary" "${OUTPUT_DIR}/zkevm-flags.md"

    log_info "Documentation generation complete!"
    log_info "Output directory: $OUTPUT_DIR"
}

main "$@"
