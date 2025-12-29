#!/bin/bash
# Validate Redux store configuration

set -e

STORE_FILE="${1:-src/store/index.js}"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_error() { echo -e "${RED}✗ $1${NC}"; }
log_success() { echo -e "${GREEN}✓ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }

if [ ! -f "$STORE_FILE" ]; then
    log_error "Store file not found: $STORE_FILE"
    exit 1
fi

# Check for createStore or configureStore
if grep -q "createStore\|configureStore" "$STORE_FILE"; then
    log_success "Store creation found"
fi

# Check for reducers
if grep -q "reducer" "$STORE_FILE" || grep -q "combineReducers" "$STORE_FILE"; then
    log_success "Reducers configured"
fi

# Check for middleware
if grep -q "middleware\|applyMiddleware" "$STORE_FILE"; then
    log_success "Middleware configured"
fi

# Check for devtools integration
if grep -q "devtool\|compose\|composeEnhancers" "$STORE_FILE"; then
    log_success "DevTools integration found"
fi

# Check Redux Toolkit usage
if grep -q "@reduxjs/toolkit" "$STORE_FILE" || [ -f "package.json" ] && grep -q "@reduxjs/toolkit" package.json; then
    log_success "Redux Toolkit detected"
fi

log_success "Redux configuration validation completed"
exit 0
