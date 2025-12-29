#!/bin/bash
# Validate React.lazy() and Suspense Implementation
# Part of code-splitting-lazy-loading skill - Golden Format E703 Compliant

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

echo -e "${BLUE}=== React.lazy() & Suspense Validation ===${NC}\n"

# 1. Check React installation and version
echo -e "${YELLOW}Checking React setup...${NC}"
if [ -f "$PROJECT_DIR/package.json" ]; then
    if grep -q '"react"' "$PROJECT_DIR/package.json"; then
        REACT_VERSION=$(grep '"react"' "$PROJECT_DIR/package.json" | head -1 | grep -o '[0-9]\+\.[0-9]\+')
        log_success "React found (v$REACT_VERSION)"
        if [[ "$REACT_VERSION" < "16.8" ]]; then
            log_error "React version $REACT_VERSION is too old (requires 16.8+)"
        fi
    else
        log_error "React not found in package.json"
    fi
else
    log_warning "package.json not found"
fi

# 2. Analyze React.lazy usage
echo -e "\n${YELLOW}Analyzing React.lazy patterns...${NC}"
if [ -d "$PROJECT_DIR/src" ]; then
    # Count React.lazy imports
    LAZY_COUNT=$(grep -r "React\.lazy\|lazy(" "$PROJECT_DIR/src" 2>/dev/null | grep -v ".test" | grep -v ".spec" | wc -l || echo "0")
    if [ "$LAZY_COUNT" -gt 0 ]; then
        log_success "Found $LAZY_COUNT React.lazy() patterns"
    else
        log_warning "No React.lazy() patterns found"
    fi

    # Count lazy imports
    LAZY_IMPORTS=$(grep -r "import.*lazy.*from.*react\|const.*lazy.*=.*require.*lazy" "$PROJECT_DIR/src" 2>/dev/null | wc -l || echo "0")
    if [ "$LAZY_IMPORTS" -gt 0 ]; then
        log_success "Found $LAZY_IMPORTS lazy imports"
    fi

    # Check lazy components
    LAZY_COMPONENTS=$(grep -r "const.*=.*lazy(.*=>" "$PROJECT_DIR/src" 2>/dev/null | wc -l || echo "0")
    log_info "Found $LAZY_COMPONENTS lazy component declarations"
fi

# 3. Validate Suspense boundaries
echo -e "\n${YELLOW}Validating Suspense boundaries...${NC}"
if [ -d "$PROJECT_DIR/src" ]; then
    # Count Suspense usage
    SUSPENSE_COUNT=$(grep -r "<Suspense" "$PROJECT_DIR/src" 2>/dev/null | grep -v ".test" | grep -v ".spec" | wc -l || echo "0")
    if [ "$SUSPENSE_COUNT" -gt 0 ]; then
        log_success "Found $SUSPENSE_COUNT Suspense boundaries"
    else
        log_warning "No Suspense boundaries found"
    fi

    # Check for fallback props
    FALLBACK_COUNT=$(grep -r "fallback=" "$PROJECT_DIR/src" 2>/dev/null | grep "Suspense" | wc -l || echo "0")
    if [ "$FALLBACK_COUNT" -gt 0 ]; then
        log_success "Found $FALLBACK_COUNT fallback implementations"
    else
        log_warning "Suspense boundaries without fallback"
    fi

    # Check fallback implementations
    echo -e "\n${YELLOW}Analyzing fallback implementations...${NC}"

    # Check for Loader/Loading components
    LOADING_COMPONENTS=$(grep -r "Loader\|Loading\|Spinner" "$PROJECT_DIR/src" 2>/dev/null | grep -E "(import|export|function|const)" | wc -l || echo "0")
    if [ "$LOADING_COMPONENTS" -gt 0 ]; then
        log_success "Found $LOADING_COMPONENTS loading/spinner components"
    fi

    # Check for null fallback (not recommended)
    NULL_FALLBACK=$(grep -r 'fallback={null}' "$PROJECT_DIR/src" 2>/dev/null | wc -l || echo "0")
    if [ "$NULL_FALLBACK" -gt 0 ]; then
        log_warning "Found $NULL_FALLBACK Suspense with null fallback (consider adding loading UI)"
    fi
fi

# 4. Validate error boundaries
echo -e "\n${YELLOW}Validating error boundaries...${NC}"
if [ -d "$PROJECT_DIR/src" ]; then
    # Count error boundary usage
    ERROR_BOUNDARY=$(grep -r "ErrorBoundary\|extends React.Component.*componentDidCatch" "$PROJECT_DIR/src" 2>/dev/null | wc -l || echo "0")
    if [ "$ERROR_BOUNDARY" -gt 0 ]; then
        log_success "Found $ERROR_BOUNDARY error boundary implementations"
    else
        log_warning "No error boundaries found (recommended for lazy components)"
    fi

    # Check error boundary wrapping lazy components
    WRAPPED_LAZY=$(grep -B 5 -A 5 "<.*Boundary" "$PROJECT_DIR/src" 2>/dev/null | grep -c "<Suspense\|lazy(" || echo "0")
    if [ "$WRAPPED_LAZY" -gt 0 ]; then
        log_success "Found error boundary wrapping lazy/Suspense"
    fi

    # Check getDerivedStateFromError
    DERIVED_ERROR=$(grep -r "getDerivedStateFromError\|componentDidCatch" "$PROJECT_DIR/src" 2>/dev/null | wc -l || echo "0")
    if [ "$DERIVED_ERROR" -gt 0 ]; then
        log_success "Error handling implemented ($DERIVED_ERROR methods)"
    fi
fi

# 5. Validate dynamic imports
echo -e "\n${YELLOW}Validating dynamic import patterns...${NC}"
if [ -d "$PROJECT_DIR/src" ]; then
    # Count dynamic imports
    DYNAMIC_IMPORTS=$(grep -r "import(" "$PROJECT_DIR/src" 2>/dev/null | grep -v ".test" | grep -v ".spec" | wc -l || echo "0")
    if [ "$DYNAMIC_IMPORTS" -gt 0 ]; then
        log_success "Found $DYNAMIC_IMPORTS dynamic imports"
    else
        log_warning "No dynamic imports found"
    fi

    # Check for webpack magic comments
    MAGIC_COMMENTS=$(grep -r "/\* webpackChunkName" "$PROJECT_DIR/src" 2>/dev/null | wc -l || echo "0")
    if [ "$MAGIC_COMMENTS" -gt 0 ]; then
        log_success "Found $MAGIC_COMMENTS webpack magic comments (named chunks)"
    else
        log_info "No webpack magic comments (consider adding for better debugging)"
    fi

    # Check for webpackPrefetch
    PREFETCH=$(grep -r "webpackPrefetch" "$PROJECT_DIR/src" 2>/dev/null | wc -l || echo "0")
    if [ "$PREFETCH" -gt 0 ]; then
        log_success "Found $PREFETCH prefetch hints"
    fi
fi

# 6. Check route lazy loading
echo -e "\n${YELLOW}Checking route lazy loading...${NC}"
if [ -d "$PROJECT_DIR/src" ]; then
    # Look for route definitions
    ROUTE_FILES=$(find "$PROJECT_DIR/src" -name "*route*" -o -name "*Route*" 2>/dev/null | wc -l)
    log_info "Found $ROUTE_FILES route-related files"

    # Check Router configuration
    ROUTER_CONFIG=$(grep -r "BrowserRouter\|RouterProvider\|Switch\|Routes" "$PROJECT_DIR/src" 2>/dev/null | wc -l || echo "0")
    if [ "$ROUTER_CONFIG" -gt 0 ]; then
        log_success "Found router configuration"

        # Check for lazy routes
        LAZY_ROUTES=$(grep -r "Route.*lazy\|lazy.*Route" "$PROJECT_DIR/src" 2>/dev/null | wc -l || echo "0")
        if [ "$LAZY_ROUTES" -gt 0 ]; then
            log_success "Found $LAZY_ROUTES lazy routes"
        else
            log_warning "No lazy routes found (consider lazy-loading page components)"
        fi
    fi
fi

# 7. Check for common issues
echo -e "\n${YELLOW}Checking for common issues...${NC}"
if [ -d "$PROJECT_DIR/src" ]; then
    # Check for lazy in conditionals (anti-pattern)
    LAZY_CONDITIONAL=$(grep -r "if.*lazy\|lazy.*if" "$PROJECT_DIR/src" 2>/dev/null | wc -l || echo "0")
    if [ "$LAZY_CONDITIONAL" -gt 0 ]; then
        log_warning "Found lazy() inside conditionals (may cause issues)"
    fi

    # Check for missing Promise handling
    UNHANDLED_IMPORT=$(grep -r "import(.*)\s*\." "$PROJECT_DIR/src" 2>/dev/null | grep -v "\.then\|\.catch\|await" | wc -l || echo "0")
    if [ "$UNHANDLED_IMPORT" -gt 0 ]; then
        log_warning "Found dynamic imports without Promise handling"
    fi

    # Check for double wrapping
    DOUBLE_WRAP=$(grep -r "lazy.*lazy\|Suspense.*Suspense" "$PROJECT_DIR/src" 2>/dev/null | wc -l || echo "0")
    if [ "$DOUBLE_WRAP" -gt 0 ]; then
        log_warning "Possible double wrapping of lazy/Suspense"
    fi
fi

# 8. TypeScript validation
echo -e "\n${YELLOW}Checking TypeScript setup...${NC}"
if [ -f "$PROJECT_DIR/tsconfig.json" ]; then
    log_success "TypeScript configured"

    if grep -q '"jsx".*"react"' "$PROJECT_DIR/tsconfig.json"; then
        log_success "JSX properly configured"
    fi
else
    log_info "No TypeScript configuration (JavaScript project)"
fi

# 9. Check for testing patterns
echo -e "\n${YELLOW}Checking test coverage...${NC}"
LAZY_TESTS=$(find "$PROJECT_DIR/src" -name "*.test.tsx" -o -name "*.test.ts" -o -name "*.spec.tsx" 2>/dev/null | wc -l)
if [ "$LAZY_TESTS" -gt 0 ]; then
    log_info "Found $LAZY_TESTS test files"

    # Check for lazy component tests
    LAZY_TEST_COVERAGE=$(grep -r "React\.lazy\|Suspense" "$PROJECT_DIR/src"/*.test.tsx "$PROJECT_DIR/src"/*.spec.tsx 2>/dev/null | wc -l || echo "0")
    if [ "$LAZY_TEST_COVERAGE" -gt 0 ]; then
        log_success "Lazy component testing found"
    else
        log_warning "No tests for lazy-loaded components"
    fi
else
    log_warning "No test files found"
fi

# 10. Summary
echo -e "\n${BLUE}=== Validation Summary ===${NC}"
echo -e "Errors: ${RED}$ERRORS${NC}"
echo -e "Warnings: ${YELLOW}$WARNINGS${NC}"
echo -e "Lazy Components: ${GREEN}$LAZY_COUNT${NC}"
echo -e "Suspense Boundaries: ${GREEN}$SUSPENSE_COUNT${NC}"
echo -e "Error Boundaries: ${GREEN}$ERROR_BOUNDARY${NC}"

if [ $ERRORS -eq 0 ]; then
    echo -e "\n${GREEN}✓ Lazy-loading validation passed${NC}"
    exit 0
else
    echo -e "\n${RED}✗ Lazy-loading validation failed ($ERRORS errors)${NC}"
    exit 1
fi
