#!/bin/bash
# Local Docusaurus development server launcher for cdk-erigon docs
# Usage: ./run-local.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    npm install
fi

# Start development server
echo "Starting Docusaurus development server..."
echo "Documentation will be available at http://localhost:3000"
echo "Press Ctrl+C to stop"
echo ""
npm run start
