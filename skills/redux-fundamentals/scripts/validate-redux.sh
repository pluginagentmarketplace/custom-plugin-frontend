#!/bin/bash
# Validate Redux store implementation for fundamentals

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
echo -e "${BLUE}Redux Fundamentals Validation${NC}"
echo -e "${BLUE}═══════════════════════════════════════════${NC}\n"

# Check store directory exists
if [ ! -d "$STORE_DIR" ]; then
    log_error "Store directory not found: $STORE_DIR"
    exit 1
fi

log_info "Validating Redux store in: $STORE_DIR\n"

# Check for store configuration file
if [ -f "$STORE_DIR/index.js" ] || [ -f "$STORE_DIR/index.ts" ]; then
    STORE_FILE=$([ -f "$STORE_DIR/index.js" ] && echo "$STORE_DIR/index.js" || echo "$STORE_DIR/index.ts")
    log_success "Store configuration file found: $STORE_FILE"

    # Check for store creation
    if grep -qE "createStore|configureStore" "$STORE_FILE"; then
        log_success "Store creation function found (createStore/configureStore)"
    else
        log_error "Store creation not found - missing createStore() or configureStore()"
    fi

    # Check for reducer
    if grep -qE "reducer[:\s]|combineReducers" "$STORE_FILE"; then
        log_success "Reducer configuration found"
    else
        log_warning "Reducer configuration not explicitly found - ensure reducers are passed to store"
    fi

    # Check for middleware
    if grep -qE "middleware|applyMiddleware|getDefaultMiddleware" "$STORE_FILE"; then
        log_success "Middleware configuration found"
    else
        log_warning "Middleware not explicitly configured - store will use default middleware"
    fi

    # Check for DevTools integration
    if grep -qE "composeEnhancers|__REDUX_DEVTOOLS_EXTENSION__|compose" "$STORE_FILE"; then
        log_success "Redux DevTools integration found"
    else
        log_warning "Redux DevTools not configured - consider enabling for debugging"
    fi
else
    log_error "Store index file not found - expected src/store/index.js or src/store/index.ts"
fi

echo ""

# Check for actions file
if [ -f "$STORE_DIR/actions.js" ] || [ -f "$STORE_DIR/actions.ts" ] || find "$STORE_DIR" -name "*action*" -type f | grep -q .; then
    ACTIONS_FILE=$(find "$STORE_DIR" -name "*action*" -type f | head -1)
    log_success "Actions file found: $ACTIONS_FILE"

    # Check action type constants
    if grep -qE "export const|const.*=.*'|const.*=.*\"" "$ACTIONS_FILE" 2>/dev/null; then
        log_success "Action type constants defined"
    else
        log_warning "Action constants not clearly defined - use uppercase constants"
    fi

    # Check action creators
    if grep -qE "export (const|function).*=.*=>" "$ACTIONS_FILE" 2>/dev/null; then
        log_success "Action creator functions found"
    else
        log_warning "Action creators not explicitly found - consider using them"
    fi
else
    log_warning "Actions file not found - consider creating separate actions file for maintainability"
fi

echo ""

# Check for reducer file
if [ -f "$STORE_DIR/reducer.js" ] || [ -f "$STORE_DIR/reducer.ts" ] || find "$STORE_DIR" -name "*reducer*" -type f | grep -q .; then
    REDUCER_FILE=$(find "$STORE_DIR" -name "*reducer*" -type f | head -1)
    log_success "Reducer file found: $REDUCER_FILE"

    # Check reducer is pure function
    if grep -qE "export.*function|export.*const.*=.*\(.*\)" "$REDUCER_FILE" 2>/dev/null; then
        log_success "Reducer exported as function"
    else
        log_warning "Reducer export format unclear"
    fi

    # Check for switch statement or if-else logic
    if grep -qE "switch|case|if.*===|else if" "$REDUCER_FILE" 2>/dev/null; then
        log_success "Reducer action handling logic found (switch/if-else)"
    else
        log_warning "No clear action handling logic found - ensure reducer handles actions"
    fi

    # Check for default state
    if grep -qE "const.*=.*\{|initialState|default:" "$REDUCER_FILE" 2>/dev/null; then
        log_success "Initial state definition found"
    else
        log_warning "Initial state not clearly defined"
    fi

    # Check for immutable patterns
    if grep -qE "\.\.\.|spread|Object\.assign|immer|produce" "$REDUCER_FILE" 2>/dev/null; then
        log_success "Immutable update patterns found (spread/Object.assign/Immer)"
    else
        log_warning "Ensure reducer updates state immutably"
    fi
else
    log_warning "Separate reducer file not found - reducer logic may be in store index"
fi

echo ""

# Check for selectors
if [ -f "$STORE_DIR/selectors.js" ] || [ -f "$STORE_DIR/selectors.ts" ] || find "$STORE_DIR" -name "*selector*" -type f | grep -q .; then
    SELECTOR_FILE=$(find "$STORE_DIR" -name "*selector*" -type f | head -1)
    log_success "Selectors file found: $SELECTOR_FILE"

    # Check for selector pattern
    if grep -qE "export const|state =>" "$SELECTOR_FILE" 2>/dev/null; then
        log_success "Selector functions properly defined"
    fi
else
    log_warning "Selectors not found - consider creating selectors for derived state"
fi

echo ""

# Check for Redux Thunk integration (optional but common)
if grep -rE "redux-thunk|thunk" "$STORE_DIR" --include="*.js" --include="*.ts" --include="*.json" 2>/dev/null | grep -q .; then
    log_success "Redux Thunk detected for async actions"
elif [ -f "package.json" ] && grep -q "redux-thunk" package.json; then
    log_success "Redux Thunk dependency found in package.json"
else
    log_warning "Redux Thunk not found - for async actions, consider adding it"
fi

echo ""

# Check for React-Redux Provider (check in parent directory)
if [ -f "$STORE_DIR/../App.jsx" ] || [ -f "$STORE_DIR/../App.tsx" ] || [ -f "$STORE_DIR/../index.jsx" ] || [ -f "$STORE_DIR/../index.tsx" ]; then
    APP_FILE=$(find "$STORE_DIR/../" -maxdepth 1 \( -name "App.jsx" -o -name "App.tsx" -o -name "index.jsx" -o -name "index.tsx" \) | head -1)
    if [ -n "$APP_FILE" ] && grep -qE "Provider|store" "$APP_FILE"; then
        log_success "React-Redux Provider usage found in: $APP_FILE"
    else
        log_warning "React-Redux Provider not found - wrap App with <Provider store={store}>"
    fi
fi

echo ""

# Check React-Redux hooks usage
if grep -rE "useSelector|useDispatch|useCallback" "$STORE_DIR/../" --include="*.jsx" --include="*.tsx" 2>/dev/null | grep -q .; then
    log_success "React-Redux hooks (useSelector/useDispatch) usage detected"
else
    log_warning "React-Redux hooks not found - ensure components use useSelector and useDispatch"
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
    log_success "Redux fundamentals validation completed successfully!"
    exit 0
else
    log_error "Redux fundamentals validation failed with errors"
    exit 1
fi
