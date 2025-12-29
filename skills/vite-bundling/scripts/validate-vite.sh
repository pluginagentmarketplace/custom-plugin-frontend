#!/bin/bash
# Vite Configuration Validation Script

set -e

VITE_CONFIG="${1:-vite.config.ts}"
PROJECT_DIR="${2:-.}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_error() { echo -e "${RED}✗ $1${NC}"; }
log_success() { echo -e "${GREEN}✓ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }

if [ ! -f "$PROJECT_DIR/$VITE_CONFIG" ]; then
    log_error "Vite config not found: $PROJECT_DIR/$VITE_CONFIG"
    exit 1
fi

log_success "Found vite config at $PROJECT_DIR/$VITE_CONFIG"

# Check for TypeScript or JavaScript
if [[ "$VITE_CONFIG" == *.ts* ]]; then
    if ! command -v ts-node &> /dev/null; then
        log_warning "TypeScript config detected but ts-node not found"
    fi
fi

# Check for root property
if grep -q "root:" "$PROJECT_DIR/$VITE_CONFIG" || grep -q "root\s*:" "$PROJECT_DIR/$VITE_CONFIG"; then
    log_success "Root directory specified"
fi

# Check for plugins array
if grep -q "plugins:" "$PROJECT_DIR/$VITE_CONFIG" || grep -q "plugins\s*:" "$PROJECT_DIR/$VITE_CONFIG"; then
    PLUGIN_COUNT=$(grep -c "(" "$PROJECT_DIR/$VITE_CONFIG" || echo "0")
    log_success "Vite plugins configured"
fi

# Check for build configuration
if grep -q "build:" "$PROJECT_DIR/$VITE_CONFIG" || grep -q "build\s*:" "$PROJECT_DIR/$VITE_CONFIG"; then
    log_success "Build configuration found"

    if grep -q "rollupOptions:" "$PROJECT_DIR/$VITE_CONFIG"; then
        log_success "Advanced rollup options configured"
    fi
fi

# Check for server configuration
if grep -q "server:" "$PROJECT_DIR/$VITE_CONFIG" || grep -q "server\s*:" "$PROJECT_DIR/$VITE_CONFIG"; then
    log_success "Dev server configuration found"

    if grep -q "middlewareMode:" "$PROJECT_DIR/$VITE_CONFIG"; then
        log_success "Middleware mode enabled for custom server integration"
    fi
fi

# Check for optimizeDeps
if grep -q "optimizeDeps:" "$PROJECT_DIR/$VITE_CONFIG" || grep -q "optimizeDeps\s*:" "$PROJECT_DIR/$VITE_CONFIG"; then
    log_success "Dependency optimization configuration found"
fi

# Check package.json for vite dependency
if [ -f "$PROJECT_DIR/package.json" ]; then
    if grep -q "vite" "$PROJECT_DIR/package.json"; then
        log_success "Vite found in package.json"
    else
        log_warning "Vite not found in package.json"
    fi
fi

# Validate index.html entry point
if [ -f "$PROJECT_DIR/index.html" ]; then
    log_success "index.html found at project root"
    if grep -q "<script" "$PROJECT_DIR/index.html" || grep -q "type=.*module" "$PROJECT_DIR/index.html"; then
        log_success "Module script tag found in index.html"
    fi
else
    log_warning "index.html not found in project root"
fi

log_success "Vite configuration validation completed"
exit 0
