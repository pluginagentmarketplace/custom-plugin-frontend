#!/bin/bash

# Jest Configuration Validator
# Validates Jest setup, test structure, and coverage configuration
# Usage: ./validate-jest.sh [project-path]

set -e

PROJECT_PATH="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
PASS=0
FAIL=0
WARN=0

echo "🧪 Jest Configuration Validator"
echo "================================"
echo "Project: $PROJECT_PATH"
echo ""

# Function to check and report
check_file() {
    local file=$1
    local description=$2

    if [ -f "$PROJECT_PATH/$file" ]; then
        echo -e "${GREEN}✓${NC} Found: $description ($file)"
        ((PASS++))
        return 0
    else
        echo -e "${RED}✗${NC} Missing: $description ($file)"
        ((FAIL++))
        return 1
    fi
}

check_directory() {
    local dir=$1
    local description=$2

    if [ -d "$PROJECT_PATH/$dir" ]; then
        echo -e "${GREEN}✓${NC} Found: $description ($dir/)"
        ((PASS++))
        return 0
    else
        echo -e "${YELLOW}!${NC} Missing: $description ($dir/)"
        ((WARN++))
        return 1
    fi
}

echo "📋 Checking Jest Configuration Files..."
echo "----------------------------------------"

# Check main config files
if check_file "jest.config.js" "Jest configuration (JS)"; then
    # Validate jest.config.js content
    if grep -q "coverageThreshold\|testEnvironment\|moduleNameMapper" "$PROJECT_PATH/jest.config.js"; then
        echo -e "${GREEN}  ✓${NC} Config contains expected settings"
    else
        echo -e "${YELLOW}  !${NC} Config might be missing standard settings"
        ((WARN++))
    fi
elif check_file "jest.config.ts" "Jest configuration (TS)"; then
    # Validate jest.config.ts content
    if grep -q "coverageThreshold\|testEnvironment\|moduleNameMapper" "$PROJECT_PATH/jest.config.ts"; then
        echo -e "${GREEN}  ✓${NC} Config contains expected settings"
    else
        echo -e "${YELLOW}  !${NC} Config might be missing standard settings"
        ((WARN++))
    fi
else
    echo -e "${YELLOW}!${NC} No jest.config found (using defaults)"
    ((WARN++))
fi

echo ""
echo "📁 Checking Test Structure..."
echo "----------------------------------------"

# Check test directories
check_directory "__tests__" "Test directory (__tests__/)" || \
    check_directory "tests" "Test directory (tests/)" || \
    echo -e "${YELLOW}!${NC} No standard test directory found"

echo ""
echo "🧬 Checking Test Files..."
echo "----------------------------------------"

# Count test files
TEST_COUNT=$(find "$PROJECT_PATH" \
    \( -name "*.test.js" -o -name "*.test.ts" \
    -o -name "*.test.jsx" -o -name "*.test.tsx" \
    -o -name "*.spec.js" -o -name "*.spec.ts" \
    -o -name "*.spec.jsx" -o -name "*.spec.tsx" \) \
    2>/dev/null | wc -l)

if [ "$TEST_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✓${NC} Found $TEST_COUNT test file(s)"
    ((PASS++))

    # Sample test files
    echo "  Sample test files:"
    find "$PROJECT_PATH" \
        \( -name "*.test.js" -o -name "*.test.ts" \
        -o -name "*.test.jsx" -o -name "*.test.tsx" \
        -o -name "*.spec.js" -o -name "*.spec.ts" \
        -o -name "*.spec.jsx" -o -name "*.spec.tsx" \) \
        2>/dev/null | head -5 | sed 's/^/    /'
else
    echo -e "${YELLOW}!${NC} No test files found (*.test.js, *.spec.js, etc.)"
    ((WARN++))
fi

echo ""
echo "🔧 Checking Setup & Configuration Files..."
echo "----------------------------------------"

# Check setup files
check_file "jest.setup.js" "Jest setup file" || \
check_file "jest.setup.ts" "Jest setup file (TS)" || \
echo -e "${YELLOW}!${NC} No Jest setup file (optional but recommended)"

# Check package.json for jest config
if [ -f "$PROJECT_PATH/package.json" ]; then
    echo -e "${GREEN}✓${NC} Found package.json"
    ((PASS++))

    # Check for test script
    if grep -q '"test"' "$PROJECT_PATH/package.json"; then
        echo -e "${GREEN}  ✓${NC} Test script configured"
    else
        echo -e "${YELLOW}  !${NC} No test script in package.json"
        ((WARN++))
    fi

    # Check for jest in dependencies
    if grep -q '"jest"' "$PROJECT_PATH/package.json"; then
        echo -e "${GREEN}  ✓${NC} Jest in dependencies"
    else
        echo -e "${YELLOW}  !${NC} Jest not listed in package.json"
        ((WARN++))
    fi
else
    echo -e "${RED}✗${NC} Missing package.json"
    ((FAIL++))
fi

echo ""
echo "📊 Checking Coverage Configuration..."
echo "----------------------------------------"

# Check for coverage configuration
if [ -f "$PROJECT_PATH/jest.config.js" ] || [ -f "$PROJECT_PATH/jest.config.ts" ]; then
    CONFIG_FILE=$([ -f "$PROJECT_PATH/jest.config.js" ] && echo "jest.config.js" || echo "jest.config.ts")

    if grep -q "collectCoverageFrom\|coverageThreshold" "$PROJECT_PATH/$CONFIG_FILE"; then
        echo -e "${GREEN}✓${NC} Coverage configuration found"
        ((PASS++))

        # Extract and display thresholds
        echo "  Coverage thresholds:"
        grep -A 5 "coverageThreshold" "$PROJECT_PATH/$CONFIG_FILE" | sed 's/^/    /' || true
    else
        echo -e "${YELLOW}!${NC} No coverage configuration"
        ((WARN++))
    fi
else
    echo -e "${YELLOW}!${NC} Cannot check coverage (no config file)"
fi

echo ""
echo "🎯 Checking Mock & Module Configuration..."
echo "----------------------------------------"

if [ -f "$PROJECT_PATH/jest.config.js" ] || [ -f "$PROJECT_PATH/jest.config.ts" ]; then
    CONFIG_FILE=$([ -f "$PROJECT_PATH/jest.config.js" ] && echo "jest.config.js" || echo "jest.config.ts")

    if grep -q "moduleNameMapper\|moduleDirectories" "$PROJECT_PATH/$CONFIG_FILE"; then
        echo -e "${GREEN}✓${NC} Module mapping configured"
        ((PASS++))
    else
        echo -e "${YELLOW}!${NC} No custom module mapping (using defaults)"
        ((WARN++))
    fi

    if grep -q "testEnvironment" "$PROJECT_PATH/$CONFIG_FILE"; then
        echo -e "${GREEN}✓${NC} Test environment configured"
        local env=$(grep "testEnvironment" "$PROJECT_PATH/$CONFIG_FILE" | grep -o "'[^']*'" | head -1)
        echo "  Environment: $env"
    else
        echo -e "${YELLOW}!${NC} Test environment not specified (using default)"
        ((WARN++))
    fi
else
    echo -e "${YELLOW}!${NC} Cannot check module config (no config file)"
fi

echo ""
echo "📦 Checking Dependencies..."
echo "----------------------------------------"

if [ -f "$PROJECT_PATH/package.json" ]; then
    # Check for common testing libraries
    DEPS_FILE="$PROJECT_PATH/package.json"

    for dep in "jest" "@testing-library/jest-dom" "ts-jest" "babel-jest"; do
        if grep -q "\"$dep\"" "$DEPS_FILE"; then
            echo -e "${GREEN}✓${NC} $dep installed"
            ((PASS++))
        fi
    done
else
    echo -e "${RED}✗${NC} Cannot check dependencies (no package.json)"
fi

echo ""
echo "🔍 Checking Test Discovery..."
echo "----------------------------------------"

# Check if jest can discover tests
if command -v npx &> /dev/null && [ -f "$PROJECT_PATH/package.json" ]; then
    cd "$PROJECT_PATH" 2>/dev/null || true

    TEST_DISCOVERY=$(npx jest --listTests 2>/dev/null | wc -l)
    if [ "$TEST_DISCOVERY" -gt 0 ]; then
        echo -e "${GREEN}✓${NC} Jest test discovery working"
        echo "  Discovered tests: $TEST_DISCOVERY"
        ((PASS++))
    else
        echo -e "${YELLOW}!${NC} Jest test discovery returned 0 tests"
        ((WARN++))
    fi
fi

echo ""
echo "================================"
echo "📊 Validation Summary"
echo "================================"
echo -e "${GREEN}Passed:${NC}  $PASS"
echo -e "${RED}Failed:${NC}  $FAIL"
echo -e "${YELLOW}Warnings:${NC} $WARN"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}✅ Jest configuration is valid!${NC}"
    exit 0
else
    echo -e "${RED}❌ Jest configuration has issues that need fixing.${NC}"
    exit 1
fi
