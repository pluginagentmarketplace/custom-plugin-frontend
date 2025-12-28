#!/bin/bash
# React Hooks Validation Script
# Part of react-hooks-patterns skill - Golden Format E703 Compliant

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🔍 React Hooks Validation Script"
echo "================================="

TARGET_DIR="${1:-.}"
errors=0

# Check for hooks rules violations
echo -e "\n${YELLOW}Checking for hooks rules violations...${NC}"

for file in $(find "$TARGET_DIR" -name "*.tsx" -o -name "*.jsx" -type f 2>/dev/null); do
    # Check for conditional hooks
    if grep -n 'if.*use[A-Z]' "$file" 2>/dev/null; then
        echo -e "  ${RED}✗ Conditional hook detected in $file${NC}"
        ((errors++))
    fi

    # Check for hooks inside loops
    if grep -n 'for.*use[A-Z]\|while.*use[A-Z]' "$file" 2>/dev/null; then
        echo -e "  ${RED}✗ Hook inside loop detected in $file${NC}"
        ((errors++))
    fi

    # Check for missing dependency arrays in useEffect
    if grep -n 'useEffect.*()' "$file" | grep -v '\[\]' 2>/dev/null; then
        echo -e "  ${YELLOW}⚠ useEffect without dependency array in $file${NC}"
    fi
done

# Check for custom hooks naming
echo -e "\n${YELLOW}Checking custom hooks naming...${NC}"
for file in $(find "$TARGET_DIR" -name "use*.ts" -o -name "use*.tsx" -type f 2>/dev/null); do
    basename=$(basename "$file" | sed 's/\.[^.]*$//')
    if [[ ! "$basename" =~ ^use[A-Z] ]]; then
        echo -e "  ${YELLOW}⚠ Custom hook should start with 'use' followed by capital: $file${NC}"
    else
        echo -e "  ${GREEN}✓ $file follows naming convention${NC}"
    fi
done

# Summary
echo -e "\n================================="
if [ $errors -eq 0 ]; then
    echo -e "${GREEN}✓ All hooks validations passed${NC}"
else
    echo -e "${RED}✗ Found $errors errors${NC}"
fi

exit $errors
