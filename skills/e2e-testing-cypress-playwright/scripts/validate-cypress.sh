#!/bin/bash

# Cypress E2E Testing Validator
# Validates Cypress configuration, spec files, and best practices
# Usage: ./validate-cypress.sh [project-path]

set -e

PROJECT_PATH="${1:-.}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS=0
FAIL=0
WARN=0

echo -e "${BLUE}🧪 Cypress E2E Testing Validator${NC}"
echo "===================================="
echo "Project: $PROJECT_PATH"
echo ""

# Check main config
echo "📋 Checking Cypress Configuration..."
echo "------------------------------------"

if [ -f "$PROJECT_PATH/cypress.config.js" ] || [ -f "$PROJECT_PATH/cypress.config.ts" ]; then
    CONFIG_FILE=$([ -f "$PROJECT_PATH/cypress.config.js" ] && echo "cypress.config.js" || echo "cypress.config.ts")
    echo -e "${GREEN}✓${NC} Found cypress.config.js"
    ((PASS++))

    # Check for key settings
    if grep -q "baseUrl\|e2e:" "$PROJECT_PATH/$CONFIG_FILE"; then
        echo -e "  ${GREEN}✓${NC} Configuration contains baseUrl or e2e settings"
    fi
else
    echo -e "${RED}✗${NC} No cypress.config.js found"
    ((FAIL++))
fi

echo ""
echo "📁 Checking Cypress Project Structure..."
echo "------------------------------------"

# Check directories
if [ -d "$PROJECT_PATH/cypress" ]; then
    echo -e "${GREEN}✓${NC} Found cypress/ directory"
    ((PASS++))

    # Check subdirectories
    [ -d "$PROJECT_PATH/cypress/e2e" ] && echo -e "  ${GREEN}✓${NC} Found cypress/e2e/" || echo -e "  ${YELLOW}!${NC} No cypress/e2e/ directory"
    [ -d "$PROJECT_PATH/cypress/support" ] && echo -e "  ${GREEN}✓${NC} Found cypress/support/" || echo -e "  ${YELLOW}!${NC} No cypress/support/"
    [ -d "$PROJECT_PATH/cypress/fixtures" ] && echo -e "  ${GREEN}✓${NC} Found cypress/fixtures/" || echo -e "  ${YELLOW}!${NC} No cypress/fixtures/"
else
    echo -e "${RED}✗${NC} No cypress/ directory found"
    ((FAIL++))
fi

echo ""
echo "🧬 Checking Test Files..."
echo "------------------------------------"

SPEC_COUNT=$(find "$PROJECT_PATH/cypress/e2e" -name "*.cy.js" -o -name "*.cy.ts" 2>/dev/null | wc -l)

if [ "$SPEC_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✓${NC} Found $SPEC_COUNT spec file(s)"
    ((PASS++))

    echo "  Sample spec files:"
    find "$PROJECT_PATH/cypress/e2e" \( -name "*.cy.js" -o -name "*.cy.ts" \) 2>/dev/null | head -5 | sed 's/^/    /'
else
    echo -e "${YELLOW}!${NC} No spec files found (*.cy.js, *.cy.ts)"
    ((WARN++))
fi

echo ""
echo "🎯 Checking Selector Patterns..."
echo "------------------------------------"

DATA_CY=$(grep -r "data-cy\|data-test" "$PROJECT_PATH/src" 2>/dev/null | wc -l)
if [ "$DATA_CY" -gt 0 ]; then
    echo -e "${GREEN}✓${NC} Found $DATA_CY data-cy/data-test attributes"
    ((PASS++))
else
    echo -e "${YELLOW}!${NC} No data-cy attributes found (recommended for stable selectors)"
    ((WARN++))
fi

# Check for good selector patterns in tests
GOOD_SELECTORS=$(grep -r "\[data-cy=\|cy.contains\|cy.get.*role" "$PROJECT_PATH/cypress/e2e" 2>/dev/null | wc -l)
if [ "$GOOD_SELECTORS" -gt 0 ]; then
    echo -e "${GREEN}✓${NC} Good selector patterns found in tests"
else
    echo -e "${YELLOW}!${NC} Consider using data-cy for stable selectors"
    ((WARN++))
fi

echo ""
echo "🔌 Checking API Intercept Setup..."
echo "------------------------------------"

INTERCEPTS=$(grep -r "cy.intercept\|cy.route" "$PROJECT_PATH/cypress" 2>/dev/null | wc -l)
if [ "$INTERCEPTS" -gt 0 ]; then
    echo -e "${GREEN}✓${NC} API intercepts found ($INTERCEPTS)"
    ((PASS++))
else
    echo -e "${YELLOW}!${NC} No API intercepts found (useful for mocking)"
    ((WARN++))
fi

echo ""
echo "📦 Checking Dependencies..."
echo "------------------------------------"

if [ -f "$PROJECT_PATH/package.json" ]; then
    if grep -q '"cypress"' "$PROJECT_PATH/package.json"; then
        echo -e "${GREEN}✓${NC} Cypress installed"
        ((PASS++))
    else
        echo -e "${RED}✗${NC} Cypress not in package.json"
        ((FAIL++))
    fi

    if grep -q '"cypress-axe"' "$PROJECT_PATH/package.json"; then
        echo -e "${GREEN}✓${NC} Cypress accessibility plugin installed"
    fi
else
    echo -e "${RED}✗${NC} No package.json found"
fi

echo ""
echo "🏗️  Checking Page Object Pattern..."
echo "------------------------------------"

SUPPORT_FILES=$(find "$PROJECT_PATH/cypress/support" -name "*.js" -o -name "*.ts" 2>/dev/null | wc -l)
if [ "$SUPPORT_FILES" -gt 0 ]; then
    echo -e "${GREEN}✓${NC} Support files found ($SUPPORT_FILES)"
    ((PASS++))
else
    echo -e "${YELLOW}!{{NC} No support/helper files (consider Page Object Model)"
    ((WARN++))
fi

echo ""
echo "🔍 Checking Test Patterns..."
echo "------------------------------------"

# Check for describe/test blocks
DESCRIBE=$(grep -r "describe(\|context(" "$PROJECT_PATH/cypress/e2e" 2>/dev/null | wc -l)
if [ "$DESCRIBE" -gt 0 ]; then
    echo -e "${GREEN}✓${NC} Test grouping (describe/context) found"
    ((PASS++))
fi

# Check for beforeEach hooks
HOOKS=$(grep -r "beforeEach\|afterEach\|before\|after" "$PROJECT_PATH/cypress/e2e" 2>/dev/null | wc -l)
if [ "$HOOKS" -gt 0 ]; then
    echo -e "${GREEN}✓${NC} Test hooks found ($HOOKS)"
    ((PASS++))
fi

echo ""
echo "👀 Checking Best Practices..."
echo "------------------------------------"

# Check for hardcoded waits (bad practice)
HARD_WAITS=$(grep -r "cy.wait([0-9])" "$PROJECT_PATH/cypress" 2>/dev/null | wc -l)
if [ "$HARD_WAITS" -gt 0 ]; then
    echo -e "${YELLOW}!${NC} Found $HARD_WAITS hardcoded waits (consider implicit waits)"
    ((WARN++))
fi

# Check for cy.visit() (good - navigating)
VISITS=$(grep -r "cy.visit" "$PROJECT_PATH/cypress/e2e" 2>/dev/null | wc -l)
if [ "$VISITS" -gt 0 ]; then
    echo -e "${GREEN}✓${NC} Found $VISITS cy.visit() calls"
fi

echo ""
echo "===================================="
echo "📊 Validation Summary"
echo "===================================="
echo -e "${GREEN}Passed:${NC}  $PASS"
echo -e "${RED}Failed:${NC}  $FAIL"
echo -e "${YELLOW}Warnings:${NC} $WARN"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}✅ Cypress setup is valid!${NC}"
    echo ""
    echo "Tips for better E2E tests:"
    echo "  1. Use data-cy attributes for stable selectors"
    echo "  2. Implement Page Object Model for reusability"
    echo "  3. Use cy.intercept() for API mocking"
    echo "  4. Avoid hardcoded waits, use cy.contains() or assertions"
    echo "  5. Keep tests independent and focused"
    exit 0
else
    echo -e "${RED}❌ Cypress setup has issues to address.${NC}"
    exit 1
fi
