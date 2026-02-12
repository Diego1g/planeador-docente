#!/bin/bash

# Common functions and variables for lesson management scripts
# This file should be sourced by other scripts: source "$(dirname "$0")/common.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get common directory paths
get_script_dir() {
    echo "$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)"
}

get_project_root() {
    local script_dir="$1"
    echo "$(dirname "$script_dir")"
}

get_lessons_dir() {
    local project_root="$1"
    echo "$project_root/lessons"
}

# Check if jq is available
has_jq() {
    command -v jq &> /dev/null
    return $?
}

# Extract metadata from config file
get_config_value() {
    local config_file="$1"
    local key="$2"
    
    if has_jq; then
        jq -r "$key" "$config_file"
    else
        log_warning "jq not found, unable to extract value for: $key"
        echo "N/A"
    fi
}
