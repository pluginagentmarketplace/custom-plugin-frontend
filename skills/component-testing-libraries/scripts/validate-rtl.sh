#!/bin/bash

# React Testing Library Validator
# Validates RTL setup, query patterns, and testing best practices
# Usage: ./validate-rtl.sh [project-path]

set -e

PROJECT_PATH="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
PASS=0
FAIL=0
WARN=0

echo -e "${BLUE}🧪 React Testing Library Validator${NC}"
echo "====================================="
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

check_dependency() {
    local dep=$1
    local description=$2

    if [ -f "$PROJECT_PATH/package.json" ] && grep -q "\"$dep\"" "$PROJECT_PATH/package.json"; then
        echo -e "${GREEN}✓${NC} $description installed"
        ((PASS++))
        return 0
    else
        echo -e "${YELLOW}!${NC} $description not found"
        ((WARN++))
        return 1
    fi
}

echo "📦 Checking RTL Dependencies..."
echo "--------------------------------------"

# Check for React Testing Library packages
check_dependency "@testing-library/react" "@testing-library/react"
check_dependency "@testing-library/jest-dom" "@testing-library/jest-dom"
check_dependency "@testing-library/user-event" "@testing-library/user-event"

echo ""
echo "📋 Checking Test Files..."
echo "--------------------------------------"

# Count test files
TEST_COUNT=$(find "$PROJECT_PATH/src" \
    \( -name "*.test.jsx" -o -name "*.test.tsx" \
    -o -name "*.test.js" -o -name "*.test.ts" \) \
    2>/dev/null | wc -l)

if [ "$TEST_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✓${NC} Found $TEST_COUNT test file(s)"
    ((PASS++))

    echo "  Sample test files:"
    find "$PROJECT_PATH/src" \
        \( -name "*.test.jsx" -o -name "*.test.tsx" \
        -o -name "*.test.js" -o -name "*.test.ts" \) \
        2>/dev/null | head -5 | sed 's/^/    /'
else
    echo -e "${YELLOW}!${NC} No test files found"
    ((WARN++))
fi

echo ""
echo "🔍 Checking RTL Query Usage Patterns..."
echo "--------------------------------------"

# Check for RTL queries in test files
ROLE_QUERIES=$(grep -r "getByRole\|getByLabelText\|getByText\|getByAltText" "$PROJECT_PATH/src" 2>/dev/null | wc -l)
TEST_ID_QUERIES=$(grep -r "getByTestId\|queryByTestId\|findByTestId" "$PROJECT_PATH/src" 2>/dev/null | wc -l)

if [ "$ROLE_QUERIES" -gt 0 ]; then
    echo -e "${GREEN}✓${NC} User-centric queries found ($ROLE_QUERIES)"
    ((PASS++))
else
    echo -e "${YELLOW}!${NC} No user-centric queries (getByRole, getByText) found"
    ((WARN++))
fi

if [ "$TEST_ID_QUERIES" -gt 0 ]; then
    echo -e "${YELLOW}!${NC} Found $TEST_ID_QUERIES testId queries (use sparingly)"
    ((WARN++))
fi

echo ""
echo "⏳ Checking Async Patterns..."
echo "--------------------------------------"

# Check for waitFor usage
WAIT_FOR=$(grep -r "waitFor\|findBy" "$PROJECT_PATH/src" 2>/dev/null | wc -l)

if [ "$WAIT_FOR" -gt 0 ]; then
    echo -e "${GREEN}✓${NC} Async patterns detected ($WAIT_FOR)"
    ((PASS++))
else
    echo -e "${YELLOW}!${NC} No async waiting patterns (waitFor, findBy) detected"
    ((WARN++))
fi

# Check for userEvent usage
USER_EVENT=$(grep -r "userEvent\|user\\.type\|user\\.click" "$PROJECT_PATH/src" 2>/dev/null | wc -l)

if [ "$USER_EVENT" -gt 0 ]; then
    echo -e "${GREEN}✓${NC} User event patterns found ($USER_EVENT)"
    ((PASS++))
else
    echo -e "${YELLOW}!${NC} No userEvent patterns found (prefer over fireEvent)"
    ((WARN++))
fi

echo ""
echo "♿ Checking Accessibility Testing..."
echo "--------------------------------------"

# Check for render function with proper setup
RENDER_SETUP=$(grep -r "render(.*component" "$PROJECT_PATH/src" 2>/dev/null | wc -l)

if [ "$RENDER_SETUP" -gt 0 ]; then
    echo -e "${GREEN}✓${NC} Component rendering found ($RENDER_SETUP)"
    ((PASS++))
else
    echo -e "${YELLOW}!${NC} No component rendering patterns detected"
    ((WARN++))
fi

# Check for screen object usage
SCREEN_USAGE=$(grep -r "screen\\.getBy\|screen\\.findBy\|screen\\.query" "$PROJECT_PATH/src" 2>/dev/null | wc -l)

if [ "$SCREEN_USAGE" -gt 0 ]; then
    echo -e "${GREEN}✓${NC} Screen object usage found ($SCREEN_USAGE)"
    ((PASS++))
else
    echo -e "${YELLOW}!{{NC} Consider using 'screen' object for queries"
    ((WARN++))
fi

echo ""
echo "📝 Checking Best Practices..."
echo "--------------------------------------"

# Check for fireEvent (should use userEvent instead)
FIRE_EVENT=$(grep -r "fireEvent\." "$PROJECT_PATH/src" 2>/dev/null | wc -l)

if [ "$FIRE_EVENT" -gt 0 ]; then
    echo -e "${YELLOW}!${NC} Found $FIRE_EVENT fireEvent usages (prefer userEvent)"
    ((WARN++))
fi

# Check for container/root access (should use screen instead)
CONTAINER=$(grep -r "\\.container\|\\.root" "$PROJECT_PATH/src" 2>/dev/null | wc -l)

if [ "$CONTAINER" -gt 0 ]; then
    echo -e "${YELLOW}!${NC} Found $CONTAINER direct DOM queries (prefer screen object)"
    ((WARN++))
fi

# Check for act() wrapper usage
ACT_WRAPPER=$(grep -r "act(" "$PROJECT_PATH/src" 2>/dev/null | wc -l)

if [ "$ACT_WRAPPER" -gt 0 ]; then
    echo -e "${GREEN}✓${NC} Found $ACT_WRAPPER act() wrapper usages"
    ((PASS++))
fi

echo ""
echo "🧬 Checking Mock Setup..."
echo "--------------------------------------"

# Check for MSW (Mock Service Worker)
if grep -q "@testing-library/msw\|msw" "$PROJECT_PATH/package.json" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Mock Service Worker (MSW) installed"
    ((PASS++))
else
    echo -e "${YELLOW}!${NC} Consider using Mock Service Worker for API mocking"
    ((WARN++))
fi

# Check for test setup files
if [ -f "$PROJECT_PATH/src/setupTests.js" ] || [ -f "$PROJECT_PATH/src/setupTests.ts" ]; then
    echo -e "${GREEN}✓${NC} Test setup file found"
    ((PASS++))
else
    echo -e "${YELLOW}!${NC} No setupTests.js found"
    ((WARN++))
fi

echo ""
echo "🧪 Checking Component Test Structure..."
echo "--------------------------------------"

# Analyze first test file structure
if [ -f "$PROJECT_PATH/src/__tests__/components/Button.test.jsx" ]; then
    TEST_FILE="$PROJECT_PATH/src/__tests__/components/Button.test.jsx"
elif find "$PROJECT_PATH/src" -name "*.test.jsx" -o -name "*.test.tsx" | head -1 | read TEST_FILE; then
    TEST_FILE=$(find "$PROJECT_PATH/src" -name "*.test.jsx" -o -name "*.test.tsx" | head -1)
fi

if [ -n "$TEST_FILE" ] && [ -f "$TEST_FILE" ]; then
    echo "  Analyzing: $(basename "$TEST_FILE")"

    # Check for describe block
    if grep -q "describe(" "$TEST_FILE"; then
        echo -e "    ${GREEN}✓${NC} describe blocks found"
    fi

    # Check for render
    if grep -q "render(" "$TEST_FILE"; then
        echo -e "    ${GREEN}✓${NC} render() calls found"
    fi

    # Check for assertions
    if grep -q "expect(" "$TEST_FILE"; then
        echo -e "    ${GREEN}✓${NC} expect() assertions found"
    fi
fi

echo ""
echo "====================================="
echo "📊 Validation Summary"
echo "====================================="
echo -e "${GREEN}Passed:${NC}  $PASS"
echo -e "${RED}Failed:${NC}  $FAIL"
echo -e "${YELLOW}Warnings:${NC} $WARN"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}✅ RTL setup is valid!${NC}"
    echo ""
    echo "Tips for better tests:"
    echo "  1. Prefer getByRole() for accessibility"
    echo "  2. Use userEvent instead of fireEvent"
    echo "  3. Use screen object for queries"
    echo "  4. Use waitFor() for async operations"
    echo "  5. Consider MSW for API mocking"
    exit 0
else
    echo -e "${RED}❌ RTL setup has issues to address.${NC}"
    exit 1
fi
