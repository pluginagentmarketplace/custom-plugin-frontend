#!/bin/bash
# HTML/CSS Validation Script
# Part of html-css-essentials skill - Golden Format E703 Compliant

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔍 HTML/CSS Validation Script"
echo "=============================="

# Check if target directory is provided
TARGET_DIR="${1:-.}"

# Validate HTML files
echo -e "\n${YELLOW}Validating HTML files...${NC}"
html_errors=0

for file in $(find "$TARGET_DIR" -name "*.html" -type f 2>/dev/null); do
    echo "  Checking: $file"

    # Check for DOCTYPE
    if ! grep -q "<!DOCTYPE html>" "$file"; then
        echo -e "    ${RED}✗ Missing DOCTYPE declaration${NC}"
        ((html_errors++))
    fi

    # Check for lang attribute
    if ! grep -q '<html.*lang=' "$file"; then
        echo -e "    ${YELLOW}⚠ Missing lang attribute on html tag${NC}"
    fi

    # Check for meta charset
    if ! grep -q '<meta charset=' "$file"; then
        echo -e "    ${YELLOW}⚠ Missing charset meta tag${NC}"
    fi

    # Check for viewport meta
    if ! grep -q 'viewport' "$file"; then
        echo -e "    ${YELLOW}⚠ Missing viewport meta tag${NC}"
    fi
done

# Validate CSS files
echo -e "\n${YELLOW}Validating CSS files...${NC}"
css_errors=0

for file in $(find "$TARGET_DIR" -name "*.css" -type f 2>/dev/null); do
    echo "  Checking: $file"

    # Check for !important overuse
    important_count=$(grep -c '!important' "$file" 2>/dev/null || echo "0")
    if [ "$important_count" -gt 5 ]; then
        echo -e "    ${YELLOW}⚠ High !important usage: $important_count instances${NC}"
    fi

    # Check for vendor prefixes without standard
    if grep -q '\-webkit\-' "$file" && ! grep -q 'display: flex' "$file"; then
        echo -e "    ${YELLOW}⚠ Consider checking vendor prefix usage${NC}"
    fi
done

# Summary
echo -e "\n=============================="
if [ $html_errors -eq 0 ]; then
    echo -e "${GREEN}✓ All HTML files valid${NC}"
else
    echo -e "${RED}✗ Found $html_errors HTML errors${NC}"
fi

echo -e "${GREEN}✓ Validation complete${NC}"
exit 0
