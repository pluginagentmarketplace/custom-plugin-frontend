#!/bin/bash
# Micro-Frontend Validation - Real checks for Module Federation setup

set -e

PROJECT_PATH="${1:-.}"
PASS=0
FAIL=0
WARN=0

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "======================================"
echo "Micro-Frontend Validation"
echo "======================================"
echo ""

# ============================================================================
# MODULE FEDERATION CHECK
# ============================================================================
echo "--- Module Federation Configuration ---"

# Check for webpack.config.js
if [ -f "$PROJECT_PATH/webpack.config.js" ]; then
  echo -e "${GREEN}✓${NC} Webpack: webpack.config.js found"
  ((PASS++))

  # Check for Module Federation
  if grep -q "ModuleFederationPlugin\|moduleFederation" "$PROJECT_PATH/webpack.config.js"; then
    echo -e "${GREEN}✓${NC} Module Federation: Plugin detected"
    ((PASS++))

    # Check for shared dependencies
    if grep -q "shared" "$PROJECT_PATH/webpack.config.js"; then
      echo -e "${GREEN}✓${NC} Shared Dependencies: Configuration found"
      ((PASS++))
    else
      echo -e "${YELLOW}!${NC} Shared Dependencies: No shared config (warning)"
      ((WARN++))
    fi

    # Check for remote/expose
    if grep -q "exposes\|remotes" "$PROJECT_PATH/webpack.config.js"; then
      echo -e "${GREEN}✓${NC} Remote/Expose: Configuration found"
      ((PASS++))
    else
      echo -e "${YELLOW}!${NC} Remote/Expose: Check configuration"
      ((WARN++))
    fi
  else
    echo -e "${RED}✗${NC} Module Federation: Plugin not configured"
    ((FAIL++))
  fi
else
  echo -e "${YELLOW}!${NC} Webpack: No webpack.config.js found"
  ((WARN++))
fi

echo ""
echo "--- Dependencies Check ---"

# Check package.json for required dependencies
if [ -f "$PROJECT_PATH/package.json" ]; then
  if grep -q "webpack.*5\|\"webpack\": \"^5\|\"webpack\": \"~5" "$PROJECT_PATH/package.json"; then
    echo -e "${GREEN}✓${NC} Webpack: Version 5+ installed"
    ((PASS++))
  else
    echo -e "${RED}✗${NC} Webpack: Must be version 5+ for Module Federation"
    ((FAIL++))
  fi

  # Check for React/Vue
  if grep -q "\"react\"\|\"vue\"" "$PROJECT_PATH/package.json"; then
    echo -e "${GREEN}✓${NC} Framework: React or Vue installed"
    ((PASS++))
  else
    echo -e "${YELLOW}!${NC} Framework: No React/Vue found"
    ((WARN++))
  fi
fi

echo ""
echo "--- Component Structure ---"

# Check for components directory
if [ -d "$PROJECT_PATH/src/components" ]; then
  comp_count=$(find "$PROJECT_PATH/src/components" -name "*.tsx" -o -name "*.jsx" | wc -l)
  echo -e "${GREEN}✓${NC} Components: Found $comp_count component files"
  ((PASS++))
else
  echo -e "${YELLOW}!${NC} Components: No src/components directory"
  ((WARN++))
fi

echo ""
echo "--- Remote App Configuration ---"

# Check for remotes configuration
remote_configs=$(find "$PROJECT_PATH" -name "*.ts" -o -name "*.js" | xargs grep -l "remotes\|@/" | wc -l)

if [ $remote_configs -gt 0 ]; then
  echo -e "${GREEN}✓${NC} Remote Loading: Configuration files found"
  ((PASS++))
else
  echo -e "${YELLOW}!${NC} Remote Loading: No remote configuration found"
  ((WARN++))
fi

echo ""
echo "--- Shared Dependency Management ---"

# Check for version management in shared dependencies
if [ -f "$PROJECT_PATH/webpack.config.js" ]; then
  if grep -q "singleton\|requiredVersion" "$PROJECT_PATH/webpack.config.js"; then
    echo -e "${GREEN}✓${NC} Version Management: Singleton pattern found"
    ((PASS++))
  else
    echo -e "${YELLOW}!${NC} Version Management: Consider using singleton"
    ((WARN++))
  fi
fi

echo ""
echo "--- CSS Isolation ---"

# Check for CSS modules or scoping
css_files=$(find "$PROJECT_PATH/src" -name "*.module.css" -o -name "*.module.scss" | wc -l)

if [ $css_files -gt 0 ]; then
  echo -e "${GREEN}✓${NC} CSS Isolation: CSS Modules found ($css_files files)"
  ((PASS++))
elif grep -r "styled-components\|emotion" "$PROJECT_PATH/package.json" 2>/dev/null | grep -q .; then
  echo -e "${GREEN}✓${NC} CSS Isolation: CSS-in-JS library found"
  ((PASS++))
else
  echo -e "${YELLOW}!${NC} CSS Isolation: No CSS scoping mechanism detected"
  ((WARN++))
fi

echo ""
echo "--- Build Configuration ---"

# Check for build script
if grep -q "\"build\"" "$PROJECT_PATH/package.json"; then
  build_cmd=$(grep "\"build\"" "$PROJECT_PATH/package.json" | head -1)
  echo -e "${GREEN}✓${NC} Build Script: Found"
  echo "  $build_cmd"
  ((PASS++))
else
  echo -e "${RED}✗${NC} Build Script: Missing build script"
  ((FAIL++))
fi

echo ""
echo "--- Port Configuration ---"

# Check for dev server port configuration
if grep -q "port\|PORT\|devServer" "$PROJECT_PATH/webpack.config.js" 2>/dev/null; then
  echo -e "${GREEN}✓${NC} Dev Server: Port configuration found"
  ((PASS++))
else
  echo -e "${YELLOW}!${NC} Dev Server: No explicit port configuration"
  ((WARN++))
fi

echo ""
echo "--- Type Safety (TypeScript) ---"

if [ -f "$PROJECT_PATH/tsconfig.json" ]; then
  echo -e "${GREEN}✓${NC} TypeScript: tsconfig.json found"
  ((PASS++))

  # Check for path aliases
  if grep -q "paths\|baseUrl" "$PROJECT_PATH/tsconfig.json"; then
    echo -e "${GREEN}✓${NC} Path Aliases: Configured for imports"
    ((PASS++))
  fi
else
  echo -e "${YELLOW}!${NC} TypeScript: Not configured"
  ((WARN++))
fi

echo ""
echo "======================================"
echo "Micro-Frontend Validation Summary"
echo "======================================"
echo -e "${GREEN}Passed:${NC} $PASS"
echo -e "${RED}Failed:${NC} $FAIL"
echo -e "${YELLOW}Warnings:${NC} $WARN"
echo ""

if [ $FAIL -eq 0 ]; then
  echo -e "${GREEN}✓ Micro-frontend validation passed!${NC}"
  exit 0
else
  echo -e "${RED}✗ Micro-frontend validation failed.${NC}"
  exit 1
fi
