#!/bin/bash
# Validate Zustand store implementation and patterns

set -e

STORE_DIR="${1:-src/store}"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

VALIDATION_PASSED=0
VALIDATION_WARNINGS=0
VALIDATION_ERRORS=0

log_error() {
    echo -e "${RED}✗ $1${NC}"
    ((VALIDATION_ERRORS++))
}

log_success() {
    echo -e "${GREEN}✓ $1${NC}"
    ((VALIDATION_PASSED++))
}

log_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
    ((VALIDATION_WARNINGS++))
}

log_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Header
echo -e "\n${BLUE}═══════════════════════════════════════════${NC}"
echo -e "${BLUE}Zustand Store Validation${NC}"
echo -e "${BLUE}═══════════════════════════════════════════${NC}\n"

# Check store directory exists
if [ ! -d "$STORE_DIR" ]; then
    log_error "Store directory not found: $STORE_DIR"
    exit 1
fi

log_info "Validating Zustand stores in: $STORE_DIR\n"

# Find all store files
STORE_FILES=$(find "$STORE_DIR" -name "*[Ss]tore*" -type f | grep -E "\.(js|jsx|ts|tsx)$" 2>/dev/null)

if [ -z "$STORE_FILES" ]; then
    log_warning "No store files found in $STORE_DIR"
    log_info "Looking for any .js/.ts files instead..."
    STORE_FILES=$(find "$STORE_DIR" -maxdepth 1 -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" 2>/dev/null)
fi

if [ -z "$STORE_FILES" ]; then
    log_error "No store files found in $STORE_DIR"
    exit 1
fi

echo -e "${BLUE}Checking Store Files...${NC}\n"

# Validate each store file
while IFS= read -r file; do
    if [ -z "$file" ]; then
        continue
    fi

    filename=$(basename "$file")
    log_info "Validating: $filename"

    # Check for create function (Zustand)
    if grep -q "create(function\|create((" "$file"; then
        log_success "Zustand create() found in $filename"
    else
        log_warning "Zustand create() not found - ensure using zustand/create"
    fi

    # Check for state definition
    if grep -qE "state:\s*\{|return\s*\{" "$file"; then
        log_success "State definition found in $filename"
    else
        log_warning "State definition not clearly found"
    fi

    # Check for actions
    if grep -qE "actions?\s*:|set\s*=>" "$file"; then
        log_success "Actions/setters found in $filename"
    else
        log_warning "Actions not clearly defined - add state update functions"
    fi

    # Check for middleware
    if grep -qE "persist|immer|devtools|middleware" "$file"; then
        log_success "Middleware detected in $filename"

        # Check specific middleware
        if grep -q "persist" "$file"; then
            log_success "  • Persist middleware found"
        fi
        if grep -q "immer" "$file"; then
            log_success "  • Immer middleware found"
        fi
        if grep -q "devtools" "$file"; then
            log_success "  • DevTools middleware found"
        fi
    else
        log_warning "No middleware detected - consider adding persist/devtools"
    fi

done <<< "$STORE_FILES"

echo ""

# Check for selector files
SELECTOR_FILES=$(find "$STORE_DIR" -name "*selector*" -type f | grep -E "\.(js|jsx|ts|tsx)$")

if [ -n "$SELECTOR_FILES" ]; then
    echo -e "${BLUE}Checking Selector Files...${NC}\n"

    while IFS= read -r file; do
        if [ -z "$file" ]; then
            continue
        fi

        filename=$(basename "$file")

        # Check selector pattern
        if grep -qE "store\.|useShallow|useStore" "$file"; then
            log_success "Selector pattern found in $filename"
        else
            log_warning "Selector pattern unclear in $filename"
        fi

        # Check for useShallow (optimized equality)
        if grep -q "useShallow" "$file"; then
            log_success "useShallow equality optimization found in $filename"
        else
            log_info "Consider using useShallow for optimized selectors"
        fi
    done <<< "$SELECTOR_FILES"
else
    log_warning "No selector files found - consider creating separate selector files"
fi

echo ""

# Check for middleware files
MIDDLEWARE_FILES=$(find "$STORE_DIR" -name "*middleware*" -type f | grep -E "\.(js|jsx|ts|tsx)$")

if [ -n "$MIDDLEWARE_FILES" ]; then
    echo -e "${BLUE}Checking Middleware Files...${NC}\n"

    while IFS= read -r file; do
        if [ -z "$file" ]; then
            continue
        fi

        filename=$(basename "$file")

        # Check middleware function pattern
        if grep -qE "store\s*=>\|function.*middleware" "$file"; then
            log_success "Middleware function pattern found in $filename"
        else
            log_warning "Middleware pattern unclear"
        fi
    done <<< "$MIDDLEWARE_FILES"
fi

echo ""

# Check for test files
TEST_FILES=$(find "$STORE_DIR" -name "*.test.*" -o -name "*.spec.*" 2>/dev/null | grep -E "\.(js|jsx|ts|tsx)$")

if [ -n "$TEST_FILES" ]; then
    echo -e "${BLUE}Checking Test Files...${NC}\n"

    while IFS= read -r file; do
        if [ -z "$file" ]; then
            continue
        fi

        filename=$(basename "$file")

        # Check for test patterns
        if grep -qE "describe|it\(|test\(" "$file"; then
            log_success "Test structure found in $filename"
        fi

        # Check for store imports
        if grep -qE "import.*Store|require.*Store" "$file"; then
            log_success "Store imports found in $filename"
        fi

        # Check for assertions
        if grep -qE "expect\(|assert\(|toBe|toEqual" "$file"; then
            log_success "Test assertions found in $filename"
        fi
    done <<< "$TEST_FILES"
else
    log_warning "No test files found - add .test.js files for store testing"
fi

echo ""

# Check package.json for Zustand dependency
if [ -f "package.json" ]; then
    echo -e "${BLUE}Checking Dependencies...${NC}\n"

    if grep -q "zustand" package.json; then
        log_success "Zustand found in package.json"

        # Check version
        ZUSTAND_VERSION=$(grep "zustand" package.json | grep -o '"[^"]*"' | head -1)
        log_info "  Version: $ZUSTAND_VERSION"
    else
        log_error "Zustand not found in package.json - install with: npm install zustand"
    fi

    # Check for optional dependencies
    if grep -q "immer" package.json; then
        log_success "Immer found for middleware"
    fi

    if grep -q "zustand/middleware" package.json || grep -q "zustand" package.json; then
        log_info "Middleware support available"
    fi
fi

echo ""

# Check for component files using the store
COMPONENT_FILES=$(find "$STORE_DIR/../" -maxdepth 2 -name "*.jsx" -o -name "*.tsx" 2>/dev/null | head -5)

if [ -n "$COMPONENT_FILES" ]; then
    echo -e "${BLUE}Checking Store Usage in Components...${NC}\n"

    # Check for store imports
    if grep -r "useStore\|Store" "$STORE_DIR/../" --include="*.jsx" --include="*.tsx" 2>/dev/null | grep -q .; then
        log_success "Store usage detected in components"
    else
        log_warning "Store not used in components - ensure components import and use the store"
    fi

    # Check for hooks
    if grep -r "useShallow\|const.*useStore" "$STORE_DIR/../" --include="*.jsx" --include="*.tsx" 2>/dev/null | grep -q .; then
        log_success "useStore hook usage detected"
    fi
fi

echo ""

# Performance checks
echo -e "${BLUE}Checking Performance Patterns...${NC}\n"

# Check for useShallow
if grep -r "useShallow" "$STORE_DIR" 2>/dev/null | grep -q .; then
    log_success "useShallow found for optimized equality checks"
else
    log_warning "Consider using useShallow for better performance"
fi

# Check for selective subscriptions
if grep -rE "state\s*=>\s*state\.|useStore.*=>|selector" "$STORE_DIR" 2>/dev/null | grep -q .; then
    log_success "Selector patterns for optimized subscriptions found"
else
    log_warning "Use selectors to prevent unnecessary re-renders"
fi

echo ""

# TypeScript support check
TS_FILES=$(find "$STORE_DIR" -name "*.ts" -o -name "*.tsx" 2>/dev/null | wc -l)

if [ "$TS_FILES" -gt 0 ]; then
    echo -e "${BLUE}Checking TypeScript Support...${NC}\n"
    log_success "TypeScript files found ($TS_FILES files)"

    # Check for type annotations
    if grep -r ":" "$STORE_DIR"/*.ts 2>/dev/null | grep -q .; then
        log_success "Type annotations detected"
    fi
fi

echo ""

# Summary
echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo -e "${BLUE}Validation Summary${NC}"
echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Passed: $VALIDATION_PASSED${NC}"
echo -e "${YELLOW}⚠ Warnings: $VALIDATION_WARNINGS${NC}"
echo -e "${RED}✗ Errors: $VALIDATION_ERRORS${NC}"
echo -e "${BLUE}═══════════════════════════════════════════${NC}\n"

if [ $VALIDATION_ERRORS -eq 0 ]; then
    log_success "Zustand store validation completed successfully!"
    exit 0
else
    log_error "Zustand store validation failed with errors"
    exit 1
fi
