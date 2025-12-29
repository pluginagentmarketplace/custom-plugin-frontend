#!/bin/bash
# Validate Package Manager Configuration and Consistency
# Part of npm-yarn-pnpm skill - Golden Format E703 Compliant

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

echo -e "${BLUE}=== Package Manager Validation ===${NC}\n"

# 1. Detect package manager and lock files
echo -e "${YELLOW}Detecting package manager...${NC}"
MANAGER="unknown"
LOCK_FILES=0

if [ -f "$PROJECT_DIR/pnpm-lock.yaml" ]; then
    MANAGER="pnpm"
    LOCK_FILES=$((LOCK_FILES+1))
    log_success "pnpm detected (pnpm-lock.yaml)"
fi

if [ -f "$PROJECT_DIR/yarn.lock" ]; then
    if [ "$MANAGER" != "unknown" ]; then
        log_warning "Multiple lock files detected (yarn.lock also present)"
    else
        MANAGER="yarn"
    fi
    LOCK_FILES=$((LOCK_FILES+1))
fi

if [ -f "$PROJECT_DIR/package-lock.json" ]; then
    if [ "$MANAGER" != "unknown" ]; then
        log_warning "Multiple lock files detected (package-lock.json also present)"
    else
        MANAGER="npm"
    fi
    LOCK_FILES=$((LOCK_FILES+1))
fi

if [ "$MANAGER" = "unknown" ]; then
    log_warning "No lock file found - dependencies may not be reproducible"
fi

# 2. Validate package.json structure
echo -e "\n${YELLOW}Validating package.json...${NC}"
if [ ! -f "$PROJECT_DIR/package.json" ]; then
    log_error "package.json not found"
    exit 1
fi
log_success "package.json found"

# Check for required fields
if grep -q '"name"' "$PROJECT_DIR/package.json"; then
    PACKAGE_NAME=$(grep -o '"name": "[^"]*"' "$PROJECT_DIR/package.json" | cut -d'"' -f4)
    log_success "Package name: $PACKAGE_NAME"
else
    log_error "Package name missing from package.json"
fi

if grep -q '"version"' "$PROJECT_DIR/package.json"; then
    PACKAGE_VERSION=$(grep -o '"version": "[^"]*"' "$PROJECT_DIR/package.json" | cut -d'"' -f4)
    log_success "Package version: $PACKAGE_VERSION"
else
    log_error "Package version missing from package.json"
fi

# 3. Validate dependency types
echo -e "\n${YELLOW}Validating dependencies...${NC}"
DEP_COUNT=$(grep -c '"[a-zA-Z0-9@\-]*":' "$PROJECT_DIR/package.json" || echo "0")
log_info "Found $DEP_COUNT dependencies/scripts"

if grep -q '"dependencies"' "$PROJECT_DIR/package.json"; then
    log_success "Production dependencies declared"
else
    log_warning "No production dependencies found"
fi

if grep -q '"devDependencies"' "$PROJECT_DIR/package.json"; then
    log_success "Dev dependencies declared"
fi

if grep -q '"peerDependencies"' "$PROJECT_DIR/package.json"; then
    log_success "Peer dependencies declared"
fi

if grep -q '"optionalDependencies"' "$PROJECT_DIR/package.json"; then
    log_warning "Optional dependencies present (ensure graceful fallback)"
fi

if grep -q '"bundledDependencies"' "$PROJECT_DIR/package.json"; then
    log_info "Bundled dependencies present"
fi

# 4. Check npm/yarn/pnpm configuration files
echo -e "\n${YELLOW}Checking package manager config...${NC}"
if [ -f "$PROJECT_DIR/.npmrc" ]; then
    log_success ".npmrc configuration file found"
    if grep -q 'registry=' "$PROJECT_DIR/.npmrc"; then
        REGISTRY=$(grep 'registry=' "$PROJECT_DIR/.npmrc" | head -1 | cut -d'=' -f2)
        log_info "Registry: $REGISTRY"
    fi
    if grep -q 'legacy-peer-deps=true' "$PROJECT_DIR/.npmrc"; then
        log_warning ".npmrc uses legacy-peer-deps=true (consider resolving peer dependencies)"
    fi
else
    log_info ".npmrc not found (using default npm settings)"
fi

if [ -f "$PROJECT_DIR/.yarnrc.yml" ] || [ -f "$PROJECT_DIR/.yarnrc" ]; then
    log_success "Yarn configuration file found"
    if [ -f "$PROJECT_DIR/.yarnrc.yml" ]; then
        if grep -q 'nodeLinker:' "$PROJECT_DIR/.yarnrc.yml"; then
            NODE_LINKER=$(grep 'nodeLinker:' "$PROJECT_DIR/.yarnrc.yml" | awk '{print $2}')
            log_info "Yarn nodeLinker mode: $NODE_LINKER"
        fi
    fi
fi

if [ -f "$PROJECT_DIR/.pnpmrc" ] || [ -f "$PROJECT_DIR/pnpm-workspace.yaml" ]; then
    log_success "pnpm configuration file found"
fi

# 5. Validate node_modules if present
echo -e "\n${YELLOW}Checking node_modules...${NC}"
if [ -d "$PROJECT_DIR/node_modules" ]; then
    NODE_MODULES_SIZE=$(du -sh "$PROJECT_DIR/node_modules" 2>/dev/null | awk '{print $1}')
    log_info "node_modules size: $NODE_MODULES_SIZE"

    if [ -d "$PROJECT_DIR/node_modules/.bin" ]; then
        log_success "Binaries installed in node_modules/.bin"
    fi
else
    log_warning "node_modules not present (run install command to create)"
fi

# 6. Validate lock file structure
echo -e "\n${YELLOW}Validating lock file structure...${NC}"
case "$MANAGER" in
    npm)
        if [ -f "$PROJECT_DIR/package-lock.json" ]; then
            if grep -q '"lockfileVersion"' "$PROJECT_DIR/package-lock.json"; then
                LOCKFILE_VERSION=$(grep '"lockfileVersion"' "$PROJECT_DIR/package-lock.json" | head -1 | grep -o '[0-9]*')
                log_success "npm lockfileVersion: $LOCKFILE_VERSION"
            fi
            if grep -q '"packages"' "$PROJECT_DIR/package-lock.json"; then
                log_success "Lock file uses v3 format (nested packages)"
            fi
        fi
        ;;
    yarn)
        if [ -f "$PROJECT_DIR/yarn.lock" ]; then
            YARN_ENTRIES=$(grep -c '^[a-z0-9@]' "$PROJECT_DIR/yarn.lock" || echo "0")
            log_info "Yarn lock entries: $YARN_ENTRIES"
        fi
        ;;
    pnpm)
        if [ -f "$PROJECT_DIR/pnpm-lock.yaml" ]; then
            if grep -q 'lockfileVersion:' "$PROJECT_DIR/pnpm-lock.yaml"; then
                log_success "pnpm lock file format validated"
            fi
        fi
        ;;
esac

# 7. Check for monorepo configuration
echo -e "\n${YELLOW}Checking monorepo setup...${NC}"
MONOREPO=false

if grep -q '"workspaces"' "$PROJECT_DIR/package.json"; then
    log_success "npm/yarn workspaces detected"
    MONOREPO=true
fi

if [ -f "$PROJECT_DIR/pnpm-workspace.yaml" ]; then
    log_success "pnpm workspace configuration found"
    if grep -q '^packages:' "$PROJECT_DIR/pnpm-workspace.yaml"; then
        log_info "Workspace packages patterns detected"
    fi
    if grep -q '^catalog:' "$PROJECT_DIR/pnpm-workspace.yaml"; then
        log_success "pnpm catalog (dependency pinning) configured"
    fi
    MONOREPO=true
fi

if [ "$MONOREPO" = false ]; then
    log_info "Single package project detected"
fi

# 8. Check npm scripts
echo -e "\n${YELLOW}Validating npm scripts...${NC}"
if grep -q '"scripts"' "$PROJECT_DIR/package.json"; then
    SCRIPT_NAMES=$(grep -A 100 '"scripts"' "$PROJECT_DIR/package.json" | grep -o '"[a-z\-]*": "[^"]*"' | wc -l)
    log_success "Found $SCRIPT_NAMES npm scripts"

    if grep -q '"build"' "$PROJECT_DIR/package.json"; then
        log_success "Build script defined"
    fi
    if grep -q '"test"' "$PROJECT_DIR/package.json"; then
        log_success "Test script defined"
    fi
    if grep -q '"start"' "$PROJECT_DIR/package.json"; then
        log_success "Start script defined"
    fi
fi

# 9. Validate Node version constraints
echo -e "\n${YELLOW}Checking Node version constraints...${NC}"
if grep -q '"engines"' "$PROJECT_DIR/package.json"; then
    log_success "Node version constraints specified"

    if grep -q '"node"' "$PROJECT_DIR/package.json"; then
        NODE_VERSION=$(grep -A 5 '"engines"' "$PROJECT_DIR/package.json" | grep '"node"' | grep -o '"[^"]*"' | tail -1 | tr -d '"')
        log_info "Node version requirement: $NODE_VERSION"
    fi
else
    log_warning "No Node version constraints (consider adding to ensure compatibility)"
fi

# 10. Summary and exit status
echo -e "\n${BLUE}=== Validation Summary ===${NC}"
echo -e "Errors: ${RED}$ERRORS${NC}"
echo -e "Warnings: ${YELLOW}$WARNINGS${NC}"
echo -e "Package Manager: ${GREEN}$MANAGER${NC}"
echo -e "Monorepo: ${GREEN}$MONOREPO${NC}"

if [ $ERRORS -eq 0 ]; then
    echo -e "\n${GREEN}✓ Package manager validation passed${NC}"
    exit 0
else
    echo -e "\n${RED}✗ Package manager validation failed ($ERRORS errors)${NC}"
    exit 1
fi
