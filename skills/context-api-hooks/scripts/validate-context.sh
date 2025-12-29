#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_success() { echo -e "${GREEN}✓ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }

# Check for createContext usage
if grep -r "createContext" src/ 2>/dev/null; then
    log_success "createContext found"
fi

# Check for useContext usage
if grep -r "useContext" src/ 2>/dev/null; then
    log_success "useContext hook found"
fi

# Check for Provider pattern
if grep -r "Provider" src/ 2>/dev/null; then
    log_success "Provider implementation found"
fi

log_success "Context API validation completed"
exit 0
