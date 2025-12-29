#!/bin/bash

# Code Quality Tools Validator
# Validates ESLint, Prettier, TypeScript, Husky, and lint-staged setup
# Usage: ./validate-quality.sh [project-path]

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

echo -e "${BLUE}🧪 Code Quality Tools Validator${NC}"
echo "=================================="
echo "Project: $PROJECT_PATH"
echo ""

echo "📋 Checking ESLint Configuration..."
echo "------------------------------------"

if [ -f "$PROJECT_PATH/.eslintrc.json" ] || [ -f "$PROJECT_PATH/.eslintrc.js" ] || [ -f "$PROJECT_PATH/.eslintrc.yml" ]; then
    CONFIG_FILE=$(ls "$PROJECT_PATH"/.eslintrc.* 2>/dev/null | head -1 | xargs basename)
    echo -e "${GREEN}✓${NC} Found ESLint config ($CONFIG_FILE)"
    ((PASS++))

    # Check for recommended rules
    if grep -q "eslint:recommended\|plugin:" "$PROJECT_PATH/.eslintrc."*; then
        echo -e "  ${GREEN}✓${NC} Uses recommended/plugin rules"
    fi
else
    echo -e "${RED}✗${NC} No ESLint configuration found"
    ((FAIL++))
fi

echo ""
echo "🎨 Checking Prettier Configuration..."
echo "------------------------------------"

if [ -f "$PROJECT_PATH/.prettierrc" ] || [ -f "$PROJECT_PATH/.prettierrc.json" ] || [ -f "$PROJECT_PATH/.prettierrc.js" ]; then
    CONFIG_FILE=$(ls "$PROJECT_PATH"/.prettierrc* 2>/dev/null | head -1 | xargs basename)
    echo -e "${GREEN}✓${NC} Found Prettier config ($CONFIG_FILE)"
    ((PASS++))

    # Check for common settings
    if grep -q "printWidth\|tabWidth" "$PROJECT_PATH/.prettierrc"*; then
        echo -e "  ${GREEN}✓${NC} Prettier configuration looks complete"
    fi
else
    echo -e "${YELLOW}!${NC} No Prettier configuration (consider adding)"
    ((WARN++))
fi

echo ""
echo "📦 Checking TypeScript Configuration..."
echo "------------------------------------"

if [ -f "$PROJECT_PATH/tsconfig.json" ]; then
    echo -e "${GREEN}✓${NC} Found tsconfig.json"
    ((PASS++))

    # Check for strict mode
    if grep -q '"strict": true' "$PROJECT_PATH/tsconfig.json"; then
        echo -e "  ${GREEN}✓${NC} TypeScript strict mode enabled"
    else
        echo -e "  ${YELLOW}!${NC} TypeScript strict mode not enabled"
        ((WARN++))
    fi

    # Check for noImplicitAny
    if grep -q '"noImplicitAny": true' "$PROJECT_PATH/tsconfig.json"; then
        echo -e "  ${GREEN}✓${NC} noImplicitAny enabled"
    fi

    # Check for strictNullChecks
    if grep -q '"strictNullChecks": true' "$PROJECT_PATH/tsconfig.json"; then
        echo -e "  ${GREEN}✓${NC} strictNullChecks enabled"
    fi
else
    echo -e "${YELLOW}!{{NC} No tsconfig.json found (optional for JS projects)"
    ((WARN++))
fi

echo ""
echo "🪝 Checking Husky Setup..."
echo "------------------------------------"

if [ -d "$PROJECT_PATH/.husky" ]; then
    echo -e "${GREEN}✓${NC} Found .husky directory"
    ((PASS++))

    # Check for pre-commit hook
    if [ -f "$PROJECT_PATH/.husky/pre-commit" ]; then
        echo -e "  ${GREEN}✓${NC} pre-commit hook exists"
        ((PASS++))

        # Check hook content
        if grep -q "lint-staged\|eslint" "$PROJECT_PATH/.husky/pre-commit"; then
            echo -e "  ${GREEN}✓${NC} pre-commit hook contains linting commands"
        fi
    else
        echo -e "  ${YELLOW}!${NC} No pre-commit hook"
        ((WARN++))
    fi

    # Check for commit-msg hook
    if [ -f "$PROJECT_PATH/.husky/commit-msg" ]; then
        echo -e "  ${GREEN}✓${NC} commit-msg hook exists"
    fi
else
    echo -e "${YELLOW}!${NC} Husky not set up (consider adding)"
    ((WARN++))
fi

echo ""
echo "📝 Checking lint-staged Configuration..."
echo "------------------------------------"

if [ -f "$PROJECT_PATH/.lintstagedrc" ] || [ -f "$PROJECT_PATH/.lintstagedrc.json" ] || grep -q '"lint-staged"' "$PROJECT_PATH/package.json" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} lint-staged configuration found"
    ((PASS++))

    # Check for common patterns
    if grep -q "*.js\|*.ts\|*.jsx\|*.tsx" "$PROJECT_PATH/.lintstagedrc"* "$PROJECT_PATH/package.json" 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} Configured for JS/TS files"
    fi
else
    echo -e "${YELLOW}!${NC} lint-staged not configured"
    ((WARN++))
fi

echo ""
echo "📦 Checking Dependencies..."
echo "------------------------------------"

if [ -f "$PROJECT_PATH/package.json" ]; then
    # Check for ESLint
    if grep -q '"eslint"' "$PROJECT_PATH/package.json"; then
        echo -e "${GREEN}✓${NC} ESLint installed"
        ((PASS++))
    else
        echo -e "${RED}✗${NC} ESLint not in package.json"
        ((FAIL++))
    fi

    # Check for Prettier
    if grep -q '"prettier"' "$PROJECT_PATH/package.json"; then
        echo -e "${GREEN}✓${NC} Prettier installed"
        ((PASS++))
    else
        echo -e "${YELLOW}!${NC} Prettier not installed"
        ((WARN++))
    fi

    # Check for Husky
    if grep -q '"husky"' "$PROJECT_PATH/package.json"; then
        echo -e "${GREEN}✓${NC} Husky installed"
        ((PASS++))
    else
        echo -e "${YELLOW}!{{NC} Husky not installed"
        ((WARN++))
    fi

    # Check for lint-staged
    if grep -q '"lint-staged"' "$PROJECT_PATH/package.json"; then
        echo -e "${GREEN}✓${NC} lint-staged installed"
        ((PASS++))
    else
        echo -e "${YELLOW}!{{NC} lint-staged not installed"
        ((WARN++))
    fi

    # Check for TypeScript
    if grep -q '"typescript"' "$PROJECT_PATH/package.json"; then
        echo -e "${GREEN}✓${NC} TypeScript installed"
        ((PASS++))
    fi
else
    echo -e "${RED}✗${NC} No package.json found"
    ((FAIL++))
fi

echo ""
echo "🔧 Checking IDE Integration..."
echo "------------------------------------"

if [ -d "$PROJECT_PATH/.vscode" ]; then
    echo -e "${GREEN}✓${NC} Found .vscode directory"
    ((PASS++))

    # Check for settings
    if [ -f "$PROJECT_PATH/.vscode/settings.json" ]; then
        echo -e "  ${GREEN}✓${NC} VSCode settings found"

        if grep -q "eslint\|prettier" "$PROJECT_PATH/.vscode/settings.json"; then
            echo -e "  ${GREEN}✓${NC} ESLint/Prettier integration configured"
        fi
    fi
else
    echo -e "${YELLOW}!{{NC} No VSCode settings (optional)"
    ((WARN++))
fi

echo ""
echo "🔍 Checking .gitignore..."
echo "------------------------------------"

if [ -f "$PROJECT_PATH/.gitignore" ]; then
    echo -e "${GREEN}✓${NC} Found .gitignore"
    ((PASS++))

    # Check for common entries
    if grep -q "node_modules\|coverage\|dist" "$PROJECT_PATH/.gitignore"; then
        echo -e "  ${GREEN}✓${NC} Common patterns ignored"
    fi
else
    echo -e "${YELLOW}!{{NC} No .gitignore file"
    ((WARN++))
fi

echo ""
echo "📊 Checking CI/CD Integration..."
echo "------------------------------------"

if [ -f "$PROJECT_PATH/.github/workflows/quality.yml" ] || [ -f "$PROJECT_PATH/.github/workflows/lint.yml" ]; then
    echo -e "${GREEN}✓${NC} GitHub Actions workflow found"
    ((PASS++))
else
    echo -e "${YELLOW}!{{NC} No GitHub Actions quality workflow"
    ((WARN++))
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
    echo -e "${GREEN}✅ Code quality setup is valid!${NC}"
    echo ""
    echo "Tips for better code quality:"
    echo "  1. Run 'npm lint' before committing"
    echo "  2. Use 'npm run format' to auto-fix code"
    echo "  3. Enable editor plugins for real-time feedback"
    echo "  4. Keep stricter rules for critical code"
    echo "  5. Review linting rules regularly"
    exit 0
else
    echo -e "${RED}❌ Code quality setup has issues.${NC}"
    exit 1
fi
