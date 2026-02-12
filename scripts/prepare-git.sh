#!/bin/bash

# This script unsets the Codespaces environment variables to prevent
# them from interfering with the repository creation process.

set -e

# Source common functions and variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

log_info "Preparing Git authentication..."

# Unset Codespaces token to avoid conflicts
unset GITHUB_TOKEN
log_info "Cleared GITHUB_TOKEN environment variable"

# Check if user is logged in via gh cli, prompt for login if not
if ! gh auth status > /dev/null 2>&1; then
  log_warning "You are not logged in to GitHub CLI"
  log_info "Starting GitHub CLI login process..."
  gh auth login
else
  log_success "Already logged in to GitHub CLI"
fi

# Set up git authentication using GitHub CLI
log_info "Setting up git authentication with GitHub CLI..."
gh auth setup-git

log_success "Git authentication configured successfully!"
