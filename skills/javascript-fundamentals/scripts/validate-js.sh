#!/bin/bash
# JavaScript Code Validation Script
# Part of javascript-fundamentals skill - Golden Format E703 Compliant

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🔍 JavaScript Validation Script"
echo "================================"

TARGET_DIR="${1:-.}"
errors=0

# Check for common JavaScript issues
echo -e "\n${YELLOW}Checking for common issues...${NC}"

for file in $(find "$TARGET_DIR" -name "*.js" -o -name "*.mjs" -type f 2>/dev/null); do
    # Check for var usage (prefer let/const)
    if grep -n '\bvar\b' "$file" 2>/dev/null; then
        echo -e "  ${YELLOW}⚠ 'var' found in $file - consider let/const${NC}"
    fi

    # Check for == instead of ===
    if grep -n '[^=!]==[^=]' "$file" 2>/dev/null; then
        echo -e "  ${YELLOW}⚠ '==' found in $file - consider '==='${NC}"
    fi

    # Check for console.log (should be removed in production)
    if grep -n 'console\.log' "$file" 2>/dev/null; then
        echo -e "  ${YELLOW}⚠ console.log found in $file${NC}"
    fi
done

# Check for ES6+ syntax support
echo -e "\n${YELLOW}Checking ES6+ patterns...${NC}"

for file in $(find "$TARGET_DIR" -name "*.js" -type f 2>/dev/null); do
    # Check for arrow functions (good practice)
    if grep -q '=>' "$file" 2>/dev/null; then
        echo -e "  ${GREEN}✓ Arrow functions used in $file${NC}"
    fi

    # Check for template literals
    if grep -q '\`.*\${' "$file" 2>/dev/null; then
        echo -e "  ${GREEN}✓ Template literals used in $file${NC}"
    fi

    # Check for destructuring
    if grep -q 'const\s*{' "$file" 2>/dev/null; then
        echo -e "  ${GREEN}✓ Destructuring used in $file${NC}"
    fi
done

# Summary
echo -e "\n================================="
if [ $errors -eq 0 ]; then
    echo -e "${GREEN}✓ JavaScript validation complete${NC}"
else
    echo -e "${RED}✗ Found $errors issues${NC}"
fi

exit $errors
