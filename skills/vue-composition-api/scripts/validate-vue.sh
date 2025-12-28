#!/bin/bash
# Vue 3 Project Validation Script
# Part of vue-composition-api skill - Golden Format E703 Compliant

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🔍 Vue 3 Project Validation"
echo "============================"

TARGET_DIR="${1:-.}"
errors=0
warnings=0

# Check for Vue 3 in dependencies
echo -e "\n${YELLOW}Checking dependencies...${NC}"
if [ -f "$TARGET_DIR/package.json" ]; then
    if grep -q '"vue".*"3\.' "$TARGET_DIR/package.json" 2>/dev/null || grep -q '"vue".*"\^3\.' "$TARGET_DIR/package.json" 2>/dev/null; then
        echo -e "  ${GREEN}✓ Vue 3 dependency found${NC}"
    else
        echo -e "  ${RED}✗ Vue 3 not found in package.json${NC}"
        ((errors++))
    fi
fi

# Check for Composition API usage
echo -e "\n${YELLOW}Checking Composition API patterns...${NC}"

for file in $(find "$TARGET_DIR/src" -name "*.vue" 2>/dev/null); do
    filename=$(basename "$file")

    # Check for script setup (preferred)
    if grep -q '<script setup' "$file" 2>/dev/null; then
        echo -e "  ${GREEN}✓ <script setup> in $filename${NC}"
    elif grep -q 'setup()' "$file" 2>/dev/null; then
        echo -e "  ${GREEN}✓ setup() function in $filename${NC}"
    elif grep -q 'export default {' "$file" 2>/dev/null; then
        if ! grep -q 'setup' "$file" 2>/dev/null; then
            echo -e "  ${YELLOW}⚠ Options API in $filename - consider Composition API${NC}"
            ((warnings++))
        fi
    fi

    # Check for proper ref/reactive usage
    if grep -q 'ref(' "$file" 2>/dev/null; then
        echo -e "  ${GREEN}✓ ref() used in $filename${NC}"
    fi

    if grep -q 'reactive(' "$file" 2>/dev/null; then
        echo -e "  ${GREEN}✓ reactive() used in $filename${NC}"
    fi
done

# Check component naming
echo -e "\n${YELLOW}Checking component naming...${NC}"

for file in $(find "$TARGET_DIR/src/components" -name "*.vue" 2>/dev/null); do
    filename=$(basename "$file" .vue)

    # Check PascalCase
    if [[ ! "$filename" =~ ^[A-Z] ]]; then
        echo -e "  ${YELLOW}⚠ Component should be PascalCase: $filename${NC}"
        ((warnings++))
    fi
done

# Check for common issues
echo -e "\n${YELLOW}Checking common issues...${NC}"

for file in $(find "$TARGET_DIR/src" -name "*.vue" -o -name "*.ts" 2>/dev/null); do
    # Check for console.log
    if grep -q 'console\.log' "$file" 2>/dev/null; then
        echo -e "  ${YELLOW}⚠ console.log in $(basename $file)${NC}"
        ((warnings++))
    fi

    # Check for proper defineProps/defineEmits
    if grep -q '<script setup' "$file" 2>/dev/null; then
        if grep -q 'props' "$file" 2>/dev/null && ! grep -q 'defineProps' "$file" 2>/dev/null; then
            echo -e "  ${YELLOW}⚠ Missing defineProps in $(basename $file)${NC}"
            ((warnings++))
        fi
    fi
done

# Check for composables
echo -e "\n${YELLOW}Checking composables...${NC}"

if [ -d "$TARGET_DIR/src/composables" ]; then
    echo -e "  ${GREEN}✓ composables directory exists${NC}"

    for file in $(find "$TARGET_DIR/src/composables" -name "*.ts" 2>/dev/null); do
        filename=$(basename "$file")

        # Check use* naming convention
        if [[ ! "$filename" =~ ^use ]]; then
            echo -e "  ${YELLOW}⚠ Composable should start with 'use': $filename${NC}"
            ((warnings++))
        fi
    done
else
    echo -e "  ${YELLOW}⚠ Consider creating composables/ directory${NC}"
fi

# Summary
echo -e "\n============================"
echo -e "Errors: ${RED}$errors${NC}"
echo -e "Warnings: ${YELLOW}$warnings${NC}"

if [ $errors -eq 0 ]; then
    echo -e "${GREEN}✓ Vue 3 validation passed${NC}"
    exit 0
else
    echo -e "${RED}✗ Vue 3 validation failed${NC}"
    exit 1
fi
