#!/bin/bash
# React Project Validation Script
# Part of react-fundamentals skill - Golden Format E703 Compliant

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🔍 React Project Validation"
echo "============================"

TARGET_DIR="${1:-.}"
errors=0
warnings=0

# Check for React in dependencies
echo -e "\n${YELLOW}Checking dependencies...${NC}"
if [ -f "$TARGET_DIR/package.json" ]; then
    if grep -q '"react"' "$TARGET_DIR/package.json"; then
        echo -e "  ${GREEN}✓ React dependency found${NC}"
    else
        echo -e "  ${RED}✗ React not found in package.json${NC}"
        ((errors++))
    fi

    if grep -q '"react-dom"' "$TARGET_DIR/package.json"; then
        echo -e "  ${GREEN}✓ React DOM dependency found${NC}"
    else
        echo -e "  ${RED}✗ React DOM not found${NC}"
        ((errors++))
    fi
fi

# Check component patterns
echo -e "\n${YELLOW}Checking component patterns...${NC}"

for file in $(find "$TARGET_DIR/src" -name "*.jsx" -o -name "*.tsx" 2>/dev/null); do
    filename=$(basename "$file")

    # Check PascalCase naming
    if [[ ! "$filename" =~ ^[A-Z] ]]; then
        echo -e "  ${YELLOW}⚠ Component file should be PascalCase: $filename${NC}"
        ((warnings++))
    fi

    # Check for class components (prefer functional)
    if grep -q 'extends React.Component\|extends Component' "$file" 2>/dev/null; then
        echo -e "  ${YELLOW}⚠ Class component found in $filename - consider functional${NC}"
        ((warnings++))
    fi

    # Check for proper key usage in lists
    if grep -q '\.map(' "$file" 2>/dev/null; then
        if ! grep -q 'key=' "$file" 2>/dev/null; then
            echo -e "  ${YELLOW}⚠ .map() without key prop in $filename${NC}"
            ((warnings++))
        fi
    fi

    # Check for index as key anti-pattern
    if grep -q 'key={index}\|key={i}' "$file" 2>/dev/null; then
        echo -e "  ${YELLOW}⚠ Using index as key in $filename - use unique ID${NC}"
        ((warnings++))
    fi
done

# Check hooks rules
echo -e "\n${YELLOW}Checking hooks rules...${NC}"

for file in $(find "$TARGET_DIR/src" -name "*.jsx" -o -name "*.tsx" 2>/dev/null); do
    # Check for hooks in conditions
    if grep -q 'if.*useState\|if.*useEffect' "$file" 2>/dev/null; then
        echo -e "  ${RED}✗ Conditional hook in $(basename $file)${NC}"
        ((errors++))
    fi

    # Check for proper useEffect dependencies
    if grep -q 'useEffect.*\[\]' "$file" 2>/dev/null; then
        echo -e "  ${GREEN}✓ useEffect with deps in $(basename $file)${NC}"
    fi
done

# Check for common issues
echo -e "\n${YELLOW}Checking common issues...${NC}"

for file in $(find "$TARGET_DIR/src" -name "*.jsx" -o -name "*.tsx" 2>/dev/null); do
    # Check for console.log
    if grep -q 'console\.log' "$file" 2>/dev/null; then
        echo -e "  ${YELLOW}⚠ console.log in $(basename $file)${NC}"
        ((warnings++))
    fi

    # Check for inline styles (prefer CSS modules or styled-components)
    if grep -q 'style={{' "$file" 2>/dev/null; then
        echo -e "  ${YELLOW}⚠ Inline styles in $(basename $file)${NC}"
        ((warnings++))
    fi
done

# Summary
echo -e "\n============================"
echo -e "Errors: ${RED}$errors${NC}"
echo -e "Warnings: ${YELLOW}$warnings${NC}"

if [ $errors -eq 0 ]; then
    echo -e "${GREEN}✓ React validation passed${NC}"
    exit 0
else
    echo -e "${RED}✗ React validation failed${NC}"
    exit 1
fi
