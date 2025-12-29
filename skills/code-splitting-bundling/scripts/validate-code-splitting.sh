#!/bin/bash
# Validate code splitting configuration

set -e

CONFIG_FILE="${1:-webpack.config.js}"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_error() { echo -e "${RED}✗ $1${NC}"; }
log_success() { echo -e "${GREEN}✓ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }

if [ ! -f "$CONFIG_FILE" ]; then
    log_error "Config file not found: $CONFIG_FILE"
    exit 1
fi

# Check for splitChunks configuration
if grep -q "splitChunks" "$CONFIG_FILE"; then
    log_success "Code splitting configured"
else
    log_warning "No code splitting configuration found"
fi

# Check for dynamic import syntax
if grep -q "import(" . -r 2>/dev/null || grep -q "webpackChunkName" . -r 2>/dev/null; then
    log_success "Dynamic imports detected"
else
    log_warning "No dynamic imports found"
fi

# Check for lazy loading patterns
if grep -qE "(React\.lazy|lazy\(|lazy import)" . -r 2>/dev/null; then
    log_success "Lazy loading patterns found"
fi

# Check vendor chunk setup
if grep -q "vendor" "$CONFIG_FILE"; then
    log_success "Vendor chunk configured"
fi

log_success "Code splitting validation completed"
exit 0
