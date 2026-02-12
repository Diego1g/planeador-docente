#!/bin/bash

# This script sets up the directory structure for lesson artifacts, including 
# highlights, discourse, and slides. It ensures that the necessary directories
# are created for storing generated content.

set -e

# Source common functions and variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

log_info "Creating lesson artifacts directory structure..."

# Create the .lesson/artifacts/ directory if it doesn't exist and its subdirectories
mkdir -p ".lesson/artifacts/highlights" ".lesson/artifacts/discourse" ".lesson/artifacts/slides"

log_success "Artifacts directory structure created successfully!"
echo ""
echo "📂 Created directories:"
echo "   .lesson/artifacts/highlights/"
echo "   .lesson/artifacts/discourse/"
echo "   .lesson/artifacts/slides/"
