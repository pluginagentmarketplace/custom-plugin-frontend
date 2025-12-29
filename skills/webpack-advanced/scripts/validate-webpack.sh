#!/bin/bash
# Webpack Configuration Validation Script
# Validates webpack.config.js structure, entry points, plugins, and loaders

set -e

WEBPACK_CONFIG="${1:-webpack.config.js}"
PROJECT_DIR="${2:-.}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_error() { echo -e "${RED}✗ $1${NC}"; }
log_success() { echo -e "${GREEN}✓ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }

if [ ! -f "$PROJECT_DIR/$WEBPACK_CONFIG" ]; then
    log_error "Webpack config not found: $PROJECT_DIR/$WEBPACK_CONFIG"
    exit 1
fi

log_success "Found webpack config at $PROJECT_DIR/$WEBPACK_CONFIG"

# Check for valid Node.js module syntax
if ! node -c "$PROJECT_DIR/$WEBPACK_CONFIG" 2>/dev/null; then
    log_error "Webpack config has syntax errors"
    exit 1
fi
log_success "Config has valid JavaScript syntax"

# Check required entry point
if ! grep -q "entry:" "$PROJECT_DIR/$WEBPACK_CONFIG" && ! grep -q "entry\s*:" "$PROJECT_DIR/$WEBPACK_CONFIG"; then
    log_warning "No entry point specified in webpack config"
fi

# Check for output configuration
if ! grep -q "output:" "$PROJECT_DIR/$WEBPACK_CONFIG" && ! grep -q "output\s*:" "$PROJECT_DIR/$WEBPACK_CONFIG"; then
    log_warning "No output configuration found"
fi

# Validate loaders configuration
if grep -q "module:" "$PROJECT_DIR/$WEBPACK_CONFIG" || grep -q "module\s*:" "$PROJECT_DIR/$WEBPACK_CONFIG"; then
    log_success "Module loaders configuration found"
else
    log_warning "No loaders module configuration found"
fi

# Check for plugins
if grep -q "plugins:" "$PROJECT_DIR/$WEBPACK_CONFIG" || grep -q "plugins\s*:" "$PROJECT_DIR/$WEBPACK_CONFIG"; then
    PLUGIN_COUNT=$(grep -c "new\s\+" "$PROJECT_DIR/$WEBPACK_CONFIG" || echo "0")
    log_success "Found $PLUGIN_COUNT plugins configured"
else
    log_warning "No plugins configured"
fi

# Validate devServer configuration for dev mode
if grep -q "devServer:" "$PROJECT_DIR/$WEBPACK_CONFIG" || grep -q "devServer\s*:" "$PROJECT_DIR/$WEBPACK_CONFIG"; then
    log_success "Development server configuration found"
fi

# Check mode specification
if grep -q "mode:" "$PROJECT_DIR/$WEBPACK_CONFIG" || grep -q "mode\s*:" "$PROJECT_DIR/$WEBPACK_CONFIG"; then
    log_success "Mode (development/production) is specified"
else
    log_warning "No mode specified; webpack will default to 'production'"
fi

# Validate babel loader if present
if grep -q "babel-loader" "$PROJECT_DIR/$WEBPACK_CONFIG"; then
    if [ -f "$PROJECT_DIR/.babelrc" ] || [ -f "$PROJECT_DIR/babel.config.js" ]; then
        log_success "Babel loader found with configuration"
    else
        log_warning "Babel loader found but no .babelrc or babel.config.js"
    fi
fi

# Validate style loaders
if grep -qE "(style-loader|css-loader|postcss-loader)" "$PROJECT_DIR/$WEBPACK_CONFIG"; then
    log_success "Style loaders configured"
fi

# Validate file loaders
if grep -qE "(file-loader|url-loader|asset)" "$PROJECT_DIR/$WEBPACK_CONFIG"; then
    log_success "File/asset loaders configured"
fi

log_success "Webpack configuration validation completed successfully"
exit 0
