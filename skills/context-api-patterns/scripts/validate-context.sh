#!/bin/bash
# Validate Context API implementation and patterns

set -e

CONTEXT_DIR="${1:-src/context}"
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
echo -e "${BLUE}Context API Patterns Validation${NC}"
echo -e "${BLUE}═══════════════════════════════════════════${NC}\n"

# Check context directory exists
if [ ! -d "$CONTEXT_DIR" ]; then
    log_error "Context directory not found: $CONTEXT_DIR"
    exit 1
fi

log_info "Validating Context API in: $CONTEXT_DIR\n"

# Find all context files
CONTEXT_FILES=$(find "$CONTEXT_DIR" -name "*Context*" -o -name "*context*" | grep -E "\.(js|jsx|ts|tsx)$" 2>/dev/null)

if [ -z "$CONTEXT_FILES" ]; then
    log_warning "No context files found in $CONTEXT_DIR"
fi

echo -e "${BLUE}Checking Context Files...${NC}\n"

# Validate each context file
while IFS= read -r file; do
    if [ -z "$file" ]; then
        continue
    fi

    # Check for createContext
    if grep -q "createContext\|React.createContext" "$file"; then
        log_success "createContext found in $(basename "$file")"
    else
        log_warning "createContext not found in $(basename "$file")"
    fi
done <<< "$CONTEXT_FILES"

echo ""

# Check for Provider files
PROVIDER_FILES=$(find "$CONTEXT_DIR" -name "*Provider*" 2>/dev/null)

if [ -n "$PROVIDER_FILES" ]; then
    echo -e "${BLUE}Checking Provider Files...${NC}\n"

    while IFS= read -r file; do
        if [ -z "$file" ]; then
            continue
        fi

        # Check Provider export
        if grep -qE "export.*Provider|export default.*Provider" "$file"; then
            log_success "Provider exported in $(basename "$file")"
        else
            log_warning "Provider export pattern unclear in $(basename "$file")"
        fi

        # Check for useReducer
        if grep -q "useReducer" "$file"; then
            log_success "useReducer found in $(basename "$file")"
        else
            log_warning "useReducer not found - consider using it for complex state"
        fi

        # Check for context value
        if grep -qE "value=|\.Provider" "$file"; then
            log_success "Context.Provider with value found in $(basename "$file")"
        else
            log_warning "Context value not properly set"
        fi

        # Check for useMemo optimization
        if grep -q "useMemo" "$file"; then
            log_success "useMemo found for value optimization in $(basename "$file")"
        else
            log_warning "Consider using useMemo for context value to prevent unnecessary renders"
        fi
    done <<< "$PROVIDER_FILES"
else
    log_warning "No Provider files found - consider creating Provider components"
fi

echo ""

# Check for custom hooks
HOOK_FILES=$(find "$CONTEXT_DIR" -name "*use*" -o -name "*hook*" 2>/dev/null | grep -E "\.(js|jsx|ts|tsx)$")

if [ -n "$HOOK_FILES" ]; then
    echo -e "${BLUE}Checking Custom Hooks...${NC}\n"

    while IFS= read -r file; do
        if [ -z "$file" ]; then
            continue
        fi

        # Check for useContext
        if grep -q "useContext" "$file"; then
            log_success "useContext hook found in $(basename "$file")"
        else
            log_warning "useContext not found in hook file"
        fi

        # Check for custom hook export
        if grep -qE "^export.*function use|export const use" "$file"; then
            log_success "Custom hook properly exported in $(basename "$file")"
        else
            log_warning "Custom hook export pattern unclear"
        fi

        # Check for null/undefined checks
        if grep -qE "if.*context|!context|context\s*===\s*undefined" "$file"; then
            log_success "Null/undefined context checks found in $(basename "$file")"
        else
            log_warning "Consider adding null/undefined checks in custom hook"
        fi
    done <<< "$HOOK_FILES"
else
    log_warning "No custom hook files found - consider creating custom hooks for context consumption"
fi

echo ""

# Check for reducer files
REDUCER_FILES=$(find "$CONTEXT_DIR" -name "*reducer*" 2>/dev/null | grep -E "\.(js|jsx|ts|tsx)$")

if [ -n "$REDUCER_FILES" ]; then
    echo -e "${BLUE}Checking Reducer Files...${NC}\n"

    while IFS= read -r file; do
        if [ -z "$file" ]; then
            continue
        fi

        # Check reducer export
        if grep -qE "export.*function|export default" "$file"; then
            log_success "Reducer properly exported in $(basename "$file")"
        else
            log_warning "Reducer export pattern unclear"
        fi

        # Check for switch statement
        if grep -q "switch\|case" "$file"; then
            log_success "Switch statement found for action handling in $(basename "$file")"
        else
            log_warning "Consider using switch statement for action handling"
        fi

        # Check for default state
        if grep -qE "=\s*\{|initialState|default:" "$file"; then
            log_success "Default/initial state found in $(basename "$file")"
        else
            log_warning "Initial state not clearly defined"
        fi
    done <<< "$REDUCER_FILES"
else
    log_warning "No reducer files found - consider using useReducer for complex state"
fi

echo ""

# Check for action files
ACTION_FILES=$(find "$CONTEXT_DIR" -name "*action*" 2>/dev/null | grep -E "\.(js|jsx|ts|tsx)$")

if [ -n "$ACTION_FILES" ]; then
    echo -e "${BLUE}Checking Action Files...${NC}\n"

    while IFS= read -r file; do
        if [ -z "$file" ]; then
            continue
        fi

        if grep -qE "export.*const|export.*function" "$file"; then
            log_success "Action creators properly exported in $(basename "$file")"
        else
            log_warning "Action creator export pattern unclear"
        fi
    done <<< "$ACTION_FILES"
fi

echo ""

# Check for component files in parent directory
COMPONENT_FILES=$(find "$CONTEXT_DIR/../" -maxdepth 1 -name "*.jsx" -o -name "*.tsx" 2>/dev/null | head -5)

if [ -n "$COMPONENT_FILES" ]; then
    echo -e "${BLUE}Checking Component Usage...${NC}\n"

    # Check for Provider usage
    if grep -r "Provider" "$CONTEXT_DIR/../" --include="*.jsx" --include="*.tsx" 2>/dev/null | grep -q .; then
        log_success "Provider usage detected in components"
    else
        log_warning "Provider not found in components - ensure Provider wraps components"
    fi

    # Check for useContext usage
    if grep -r "useContext" "$CONTEXT_DIR/../" --include="*.jsx" --include="*.tsx" 2>/dev/null | grep -q .; then
        log_success "useContext hook usage detected in components"
    else
        log_warning "useContext not found - ensure components consume context"
    fi

    # Check for custom hook usage
    if grep -r "use[A-Z]" "$CONTEXT_DIR/../" --include="*.jsx" --include="*.tsx" 2>/dev/null | grep -q .; then
        log_success "Custom hook usage detected in components"
    fi
fi

echo ""

# Performance checks
echo -e "${BLUE}Checking Performance Patterns...${NC}\n"

# Check for useCallback
if grep -r "useCallback" "$CONTEXT_DIR" 2>/dev/null | grep -q .; then
    log_success "useCallback found for function memoization"
else
    log_warning "Consider using useCallback for callback functions in context"
fi

# Check for useMemo
if grep -r "useMemo" "$CONTEXT_DIR" 2>/dev/null | grep -q .; then
    log_success "useMemo found for value optimization"
else
    log_warning "Consider using useMemo for context value memoization"
fi

# Check for React.memo
if grep -r "React.memo\|memo(" "$CONTEXT_DIR" 2>/dev/null | grep -q .; then
    log_success "React.memo found for component optimization"
else
    log_warning "Consider using React.memo for components that consume context"
fi

echo ""

# Check for multiple contexts
CONTEXT_COUNT=$(find "$CONTEXT_DIR" -type f -name "*.js" -o -name "*.jsx" -o -name "*.ts" -o -name "*.tsx" 2>/dev/null | wc -l)

if [ "$CONTEXT_COUNT" -gt 3 ]; then
    log_success "Multiple context files found ($CONTEXT_COUNT files)"
    log_info "Consider organizing contexts into separate folders"
else
    log_info "Context files found: $CONTEXT_COUNT"
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
    log_success "Context API validation completed successfully!"
    exit 0
else
    log_error "Context API validation failed with errors"
    exit 1
fi
