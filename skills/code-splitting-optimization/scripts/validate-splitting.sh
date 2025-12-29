#!/bin/bash
# Validate Code-Splitting and Bundle Optimization Configuration
# Part of code-splitting-optimization skill - Golden Format E703 Compliant

set -e

PROJECT_DIR="${1:-.}"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

log_error() { echo -e "${RED}✗ $1${NC}"; ((ERRORS++)); }
log_success() { echo -e "${GREEN}✓ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠ $1${NC}"; ((WARNINGS++)); }
log_info() { echo -e "${BLUE}ℹ $1${NC}"; }

echo -e "${BLUE}=== Code-Splitting & Bundle Optimization Validation ===${NC}\n"

# 1. Detect bundler configuration
echo -e "${YELLOW}Detecting bundler configuration...${NC}"
BUNDLER="unknown"

if [ -f "$PROJECT_DIR/webpack.config.js" ] || [ -f "$PROJECT_DIR/webpack.config.ts" ]; then
    BUNDLER="webpack"
    log_success "webpack configuration detected"
    CONFIG_FILE=$(find "$PROJECT_DIR" -name "webpack.config.*" -type f | head -1)
    log_info "Config file: $CONFIG_FILE"
fi

if [ -f "$PROJECT_DIR/vite.config.js" ] || [ -f "$PROJECT_DIR/vite.config.ts" ]; then
    if [ "$BUNDLER" != "unknown" ]; then
        log_warning "Multiple bundlers detected (vite.config found)"
    else
        BUNDLER="vite"
    fi
    log_success "Vite configuration detected"
    CONFIG_FILE=$(find "$PROJECT_DIR" -name "vite.config.*" -type f | head -1)
    log_info "Config file: $CONFIG_FILE"
fi

if [ "$BUNDLER" = "unknown" ]; then
    log_warning "No bundler configuration found"
    if [ -f "$PROJECT_DIR/package.json" ]; then
        if grep -q '"webpack"' "$PROJECT_DIR/package.json"; then
            log_info "webpack listed as dependency in package.json"
        fi
        if grep -q '"vite"' "$PROJECT_DIR/package.json"; then
            log_info "Vite listed as dependency in package.json"
        fi
    fi
fi

# 2. Validate webpack configuration
echo -e "\n${YELLOW}Analyzing webpack configuration...${NC}"
if [ "$BUNDLER" = "webpack" ] && [ -n "$CONFIG_FILE" ]; then
    # Check for entry configuration
    if grep -q 'entry' "$CONFIG_FILE"; then
        log_success "Entry points configured"
        ENTRY_COUNT=$(grep -o 'entry[^}]*' "$CONFIG_FILE" | wc -l)
        log_info "Found $ENTRY_COUNT entry point configurations"
    fi

    # Check for output configuration
    if grep -q 'output' "$CONFIG_FILE"; then
        log_success "Output configuration found"
        if grep -q 'filename.*\[hash\]\|\[chunkhash\]\|\[contenthash\]' "$CONFIG_FILE"; then
            log_success "Cache-busting hash patterns configured"
        fi
    fi

    # Check for optimization.splitChunks
    if grep -q 'splitChunks' "$CONFIG_FILE"; then
        log_success "Code-splitting strategy configured"
        if grep -q 'vendor' "$CONFIG_FILE" && grep -q 'splitChunks.*cacheGroups' "$CONFIG_FILE"; then
            log_success "Vendor chunk separation configured"
        fi
        if grep -q 'common' "$CONFIG_FILE"; then
            log_success "Common chunk extraction configured"
        fi
    else
        log_warning "No explicit splitChunks configuration (using webpack defaults)"
    fi

    # Check for runtimeChunk
    if grep -q 'runtimeChunk' "$CONFIG_FILE"; then
        log_success "Runtime chunk configuration found"
    else
        log_warning "Runtime chunk not explicitly configured"
    fi

    # Check for moduleIds
    if grep -q 'moduleIds' "$CONFIG_FILE"; then
        log_success "Module IDs configuration found"
        if grep -q "moduleIds.*'deterministic'" "$CONFIG_FILE"; then
            log_success "Deterministic module IDs enabled (stable hashes)"
        fi
    fi

    # Check for usedExports (tree-shaking)
    if grep -q 'usedExports' "$CONFIG_FILE"; then
        log_success "Tree-shaking (usedExports) enabled"
    else
        log_warning "Tree-shaking (usedExports) not explicitly enabled"
    fi

    # Check for minification
    if grep -q 'TerserPlugin\|minimize' "$CONFIG_FILE"; then
        log_success "Minification configured"
    fi

    # Check for named chunks
    if grep -q 'namedChunks.*true\|chunkFilename' "$CONFIG_FILE"; then
        log_success "Named chunks configured for debugging"
    fi
fi

# 3. Validate Vite configuration
echo -e "\n${YELLOW}Analyzing Vite configuration...${NC}"
if [ "$BUNDLER" = "vite" ] && [ -n "$CONFIG_FILE" ]; then
    # Check for rollupOptions
    if grep -q 'rollupOptions' "$CONFIG_FILE"; then
        log_success "Rollup options configured"
        if grep -q 'output.*entryFileNames\|output.*chunkFileNames' "$CONFIG_FILE"; then
            log_success "Output filename patterns configured"
        fi
    fi

    # Check for chunk optimization
    if grep -q 'manualChunks' "$CONFIG_FILE"; then
        log_success "Manual chunk configuration found"
    fi

    # Check for chunk size warning
    if grep -q 'chunkSizeWarningLimit' "$CONFIG_FILE"; then
        log_success "Chunk size warning threshold configured"
    else
        log_warning "No chunk size warning threshold set (default: 500KB)"
    fi

    # Check for minify configuration
    if grep -q 'minify' "$CONFIG_FILE"; then
        log_success "Minification configured"
        if grep -q "minify.*'terser'" "$CONFIG_FILE"; then
            log_info "Using Terser for minification"
        fi
    fi

    # Check for CSS code-splitting
    if grep -q 'cssCodeSplit' "$CONFIG_FILE"; then
        log_success "CSS code-splitting configured"
    fi

    # Check for build configuration
    if grep -q 'build:' "$CONFIG_FILE" || grep -q 'build' "$CONFIG_FILE"; then
        log_success "Build configuration found"
    fi
fi

# 4. Analyze source code for dynamic imports
echo -e "\n${YELLOW}Analyzing source code for dynamic patterns...${NC}"
if [ -d "$PROJECT_DIR/src" ]; then
    # Count dynamic imports
    DYNAMIC_IMPORTS=$(grep -r "import(" "$PROJECT_DIR/src" 2>/dev/null | wc -l || echo "0")
    if [ "$DYNAMIC_IMPORTS" -gt 0 ]; then
        log_success "Found $DYNAMIC_IMPORTS dynamic imports"
    else
        log_warning "No dynamic imports found (code-splitting may not be effective)"
    fi

    # Check for React.lazy
    REACT_LAZY=$(grep -r "React\.lazy\|lazy(" "$PROJECT_DIR/src" 2>/dev/null | wc -l || echo "0")
    if [ "$REACT_LAZY" -gt 0 ]; then
        log_success "Found $REACT_LAZY React.lazy patterns"
    fi

    # Check for Suspense usage
    SUSPENSE=$(grep -r "<Suspense" "$PROJECT_DIR/src" 2>/dev/null | wc -l || echo "0")
    if [ "$SUSPENSE" -gt 0 ]; then
        log_success "Found $SUSPENSE Suspense boundaries"
    fi

    # Check for webpack magic comments
    MAGIC_COMMENTS=$(grep -r "/\* webpackChunkName" "$PROJECT_DIR/src" 2>/dev/null | wc -l || echo "0")
    if [ "$MAGIC_COMMENTS" -gt 0 ]; then
        log_success "Found $MAGIC_COMMENTS webpack magic comments (named chunks)"
    fi

    # Check for prefetch/preload hints
    PREFETCH=$(grep -r "/\* webpackPrefetch\|webpackPreload" "$PROJECT_DIR/src" 2>/dev/null | wc -l || echo "0")
    if [ "$PREFETCH" -gt 0 ]; then
        log_success "Found $PREFETCH prefetch/preload hints"
    fi
fi

# 5. Check build output and chunks
echo -e "\n${YELLOW}Analyzing build output...${NC}"
if [ -d "$PROJECT_DIR/dist" ]; then
    # Count JS chunks
    JS_FILES=$(find "$PROJECT_DIR/dist" -name "*.js" -type f 2>/dev/null | wc -l)
    JS_CHUNKS=$(find "$PROJECT_DIR/dist" -name "*chunk*.js" -o -name "*vendor*.js" 2>/dev/null | wc -l)
    log_info "Found $JS_FILES JavaScript files"
    if [ "$JS_CHUNKS" -gt 0 ]; then
        log_success "Found $JS_CHUNKS chunk files"
    fi

    # Analyze chunk sizes
    echo -e "\n${YELLOW}  Chunk sizes (top 5):${NC}"
    find "$PROJECT_DIR/dist" -name "*.js" -type f 2>/dev/null | xargs ls -lh 2>/dev/null | sort -k5 -hr | head -5 | while read line; do
        size=$(echo "$line" | awk '{print $5}')
        file=$(echo "$line" | awk '{print $NF}')
        if [ $(echo "$size" | grep -o '[0-9]*' | head -1) -gt 500 ]; then
            echo -e "    ${YELLOW}! $file - $size (large chunk)${NC}"
        else
            echo -e "    ${GREEN}✓ $file - $size${NC}"
        fi
    done

    # Check for source maps
    SOURCEMAPS=$(find "$PROJECT_DIR/dist" -name "*.map" -type f 2>/dev/null | wc -l)
    if [ "$SOURCEMAPS" -gt 0 ]; then
        log_success "Found $SOURCEMAPS source map files"
    else
        log_warning "No source maps found (enable for debugging)"
    fi
elif [ -d "$PROJECT_DIR/build" ]; then
    log_info "Build output directory: ./build"
    JS_FILES=$(find "$PROJECT_DIR/build" -name "*.js" -type f 2>/dev/null | wc -l)
    log_info "Found $JS_FILES JavaScript files"
fi

# 6. Check optimization settings
echo -e "\n${YELLOW}Checking optimization settings...${NC}"
if [ -f "$PROJECT_DIR/package.json" ]; then
    # Check for build scripts
    if grep -q '"build"' "$PROJECT_DIR/package.json"; then
        log_success "Build script defined in package.json"
    fi

    # Check for bundle analysis tools
    if grep -q 'webpack-bundle-analyzer\|rollup-plugin-visualizer' "$PROJECT_DIR/package.json"; then
        log_success "Bundle analysis tools installed"
    else
        log_warning "No bundle analysis tools found (consider webpack-bundle-analyzer or rollup-plugin-visualizer)"
    fi

    # Check for compression
    if grep -q 'compression-webpack-plugin\|vite-plugin-compression' "$PROJECT_DIR/package.json"; then
        log_success "Bundle compression plugin installed"
    fi
fi

# 7. Check tsconfig/jsconfig for module resolution
echo -e "\n${YELLOW}Checking module resolution...${NC}"
if [ -f "$PROJECT_DIR/tsconfig.json" ] || [ -f "$PROJECT_DIR/jsconfig.json" ]; then
    CONFIG_FILE=$([ -f "$PROJECT_DIR/tsconfig.json" ] && echo "tsconfig.json" || echo "jsconfig.json")
    log_success "Module resolution config found: $CONFIG_FILE"
    if grep -q '"paths"' "$PROJECT_DIR/$CONFIG_FILE"; then
        log_success "Path aliases configured (helps with import organization)"
    fi
fi

# 8. Summary and exit status
echo -e "\n${BLUE}=== Validation Summary ===${NC}"
echo -e "Errors: ${RED}$ERRORS${NC}"
echo -e "Warnings: ${YELLOW}$WARNINGS${NC}"
echo -e "Bundler: ${GREEN}$BUNDLER${NC}"

if [ $ERRORS -eq 0 ]; then
    echo -e "\n${GREEN}✓ Code-splitting validation passed${NC}"
    exit 0
else
    echo -e "\n${RED}✗ Code-splitting validation failed ($ERRORS errors)${NC}"
    exit 1
fi
