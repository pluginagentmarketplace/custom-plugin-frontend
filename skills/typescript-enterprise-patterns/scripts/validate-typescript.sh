#!/bin/bash
# TypeScript Enterprise Validation - Real checks for advanced patterns

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
echo "TypeScript Enterprise Validation"
echo "======================================"
echo ""

# ============================================================================
# TYPESCRIPT CONFIGURATION
# ============================================================================
echo "--- TypeScript Configuration ---"

if [ -f "$PROJECT_PATH/tsconfig.json" ]; then
  echo -e "${GREEN}✓${NC} TypeScript: tsconfig.json found"
  ((PASS++))

  # Check for strict mode
  if grep -q '"strict": true' "$PROJECT_PATH/tsconfig.json"; then
    echo -e "${GREEN}✓${NC} Strict Mode: Enabled"
    ((PASS++))
  else
    echo -e "${RED}✗${NC} Strict Mode: Not enabled (CRITICAL)"
    ((FAIL++))
  fi

  # Check for noImplicitAny
  if grep -q '"noImplicitAny": true' "$PROJECT_PATH/tsconfig.json"; then
    echo -e "${GREEN}✓${NC} No Implicit Any: Enabled"
    ((PASS++))
  else
    echo -e "${YELLOW}!${NC} No Implicit Any: Not explicitly enabled"
    ((WARN++))
  fi

  # Check for strictNullChecks
  if grep -q '"strictNullChecks": true' "$PROJECT_PATH/tsconfig.json"; then
    echo -e "${GREEN}✓${NC} Strict Null Checks: Enabled"
    ((PASS++))
  else
    echo -e "${YELLOW}!${NC} Strict Null Checks: Not enabled"
    ((WARN++))
  fi

  # Check target version
  if grep -q '"target": "es2020\|es2021\|es2022\|esnext' "$PROJECT_PATH/tsconfig.json"; then
    echo -e "${GREEN}✓${NC} Target: Modern ES version"
    ((PASS++))
  else
    echo -e "${YELLOW}!${NC} Target: Consider modern ES version"
    ((WARN++))
  fi
else
  echo -e "${RED}✗${NC} TypeScript: tsconfig.json not found"
  ((FAIL++))
fi

echo ""
echo "--- Generics Usage ---"

ts_files=$(find "$PROJECT_PATH/src" -type f \( -name "*.ts" -o -name "*.tsx" \) 2>/dev/null | head -20)

if echo "$ts_files" | xargs grep -l "<\w*>" 2>/dev/null | grep -q .; then
  echo -e "${GREEN}✓${NC} Generics: Found in codebase"
  ((PASS++))

  # Check for generic factories
  if echo "$ts_files" | xargs grep -l "function.*<" 2>/dev/null | grep -q .; then
    echo -e "${GREEN}✓${NC} Generic Functions: Found"
    ((PASS++))
  fi

  # Check for generic interfaces
  if echo "$ts_files" | xargs grep -l "interface.*<\|type.*<" 2>/dev/null | grep -q .; then
    echo -e "${GREEN}✓${NC} Generic Types: Found"
    ((PASS++))
  fi
else
  echo -e "${YELLOW}!${NC} Generics: Not found (recommendation: use for reusability)"
  ((WARN++))
fi

echo ""
echo "--- Any Type Usage ---"

any_count=$(echo "$ts_files" | xargs grep -c ": any\|as any" 2>/dev/null | awk -F: '{sum+=$NF} END {print sum}')

if [ "$any_count" -eq 0 ]; then
  echo -e "${GREEN}✓${NC} Any Types: None found (excellent)"
  ((PASS++))
elif [ "$any_count" -lt 5 ]; then
  echo -e "${YELLOW}!${NC} Any Types: $any_count found (minimize usage)"
  ((WARN++))
else
  echo -e "${RED}✗${NC} Any Types: $any_count found (CRITICAL: use unknown instead)"
  ((FAIL++))
fi

echo ""
echo "--- Unknown Type Usage ---"

unknown_count=$(echo "$ts_files" | xargs grep -c ": unknown" 2>/dev/null | awk -F: '{sum+=$NF} END {print sum}')

if [ "$unknown_count" -gt 0 ]; then
  echo -e "${GREEN}✓${NC} Unknown Type: $unknown_count usages (safer than any)"
  ((PASS++))
fi

echo ""
echo "--- Decorators ---"

if echo "$ts_files" | xargs grep -l "@\w\+(" 2>/dev/null | grep -q .; then
  echo -e "${GREEN}✓${NC} Decorators: Found in codebase"
  ((PASS++))

  # Check decorator types
  if echo "$ts_files" | xargs grep -E "@(Deprecated|Cached|Validated|Logged)" 2>/dev/null | grep -q .; then
    echo -e "${GREEN}✓${NC} Custom Decorators: Found"
    ((PASS++))
  fi
else
  echo -e "${YELLOW}!${NC} Decorators: Not found (useful for cross-cutting concerns)"
  ((WARN++))
fi

# Check tsconfig for decorator support
if grep -q '"experimentalDecorators": true' "$PROJECT_PATH/tsconfig.json" 2>/dev/null; then
  echo -e "${GREEN}✓${NC} Decorator Support: Enabled in tsconfig"
  ((PASS++))
fi

echo ""
echo "--- Type Inference ---"

# Check for explicit return types
method_count=$(echo "$ts_files" | xargs grep -c "^\s*\w\+(" 2>/dev/null | awk -F: '{sum+=$NF} END {print sum}')
explicit_types=$(echo "$ts_files" | xargs grep -c ")\s*:\s*\w" 2>/dev/null | awk -F: '{sum+=$NF} END {print sum}')

if [ "$method_count" -gt 0 ] && [ "$explicit_types" -gt 0 ]; then
  ratio=$((explicit_types * 100 / method_count))
  if [ "$ratio" -ge 70 ]; then
    echo -e "${GREEN}✓${NC} Return Type Annotations: ~${ratio}% explicit"
    ((PASS++))
  else
    echo -e "${YELLOW}!${NC} Return Type Annotations: ~${ratio}% explicit (target >70%)"
    ((WARN++))
  fi
fi

echo ""
echo "--- Type Guards ---"

if echo "$ts_files" | xargs grep -l "is\s\+\w\|typeof\s\|instanceof" 2>/dev/null | grep -q .; then
  echo -e "${GREEN}✓${NC} Type Guards: Found in codebase"
  ((PASS++))
else
  echo -e "${YELLOW}!${NC} Type Guards: Not found (useful for type narrowing)"
  ((WARN++))
fi

echo ""
echo "--- Discriminated Unions ---"

if echo "$ts_files" | xargs grep -l "kind\|type:" 2>/dev/null | grep -q .; then
  echo -e "${GREEN}✓${NC} Discriminated Unions: Pattern detected"
  ((PASS++))
fi

echo ""
echo "--- Utility Types ---"

utility_types=0

for type in "Partial" "Required" "Readonly" "Pick" "Record" "Omit" "Exclude" "Extract"; do
  if echo "$ts_files" | xargs grep -l "$type<" 2>/dev/null | grep -q .; then
    ((utility_types++))
  fi
done

if [ $utility_types -gt 3 ]; then
  echo -e "${GREEN}✓${NC} Utility Types: Using $utility_types different types"
  ((PASS++))
elif [ $utility_types -gt 0 ]; then
  echo -e "${YELLOW}!${NC} Utility Types: Using $utility_types (explore more)"
  ((WARN++))
else
  echo -e "${YELLOW}!${NC} Utility Types: None found (powerful for type manipulation)"
  ((WARN++))
fi

echo ""
echo "--- Interfaces vs Types ---"

interface_count=$(echo "$ts_files" | xargs grep -c "^interface " 2>/dev/null | awk -F: '{sum+=$NF} END {print sum}')
type_count=$(echo "$ts_files" | xargs grep -c "^type " 2>/dev/null | awk -F: '{sum+=$NF} END {print sum}')

if [ "$interface_count" -gt 0 ] && [ "$type_count" -gt 0 ]; then
  echo -e "${GREEN}✓${NC} Interfaces: $interface_count | Types: $type_count"
  ((PASS++))
fi

echo ""
echo "======================================"
echo "TypeScript Validation Summary"
echo "======================================"
echo -e "${GREEN}Passed:${NC} $PASS"
echo -e "${RED}Failed:${NC} $FAIL"
echo -e "${YELLOW}Warnings:${NC} $WARN"
echo ""

if [ $FAIL -eq 0 ]; then
  echo -e "${GREEN}✓ TypeScript validation passed!${NC}"
  exit 0
else
  echo -e "${RED}✗ TypeScript validation failed.${NC}"
  exit 1
fi
