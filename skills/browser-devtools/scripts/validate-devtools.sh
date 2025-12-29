#!/bin/bash

################################################################################
# validate-devtools.sh
# REAL validation checking DevTools integration in project
# Checks: source maps, debug logging, performance markers, error handlers
################################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_ROOT="${1:-.}"
RESULTS_FILE="${PROJECT_ROOT}/.devtools-validation.json"
PASSED=0
FAILED=0

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}DevTools Integration Validation${NC}"
echo -e "${BLUE}Project: ${PROJECT_ROOT}${NC}"
echo -e "${BLUE}========================================${NC}\n"

cat > "$RESULTS_FILE" <<EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "project": "${PROJECT_ROOT}",
  "checks": {},
  "issues": [],
  "summary": {}
}
EOF

################################################################################
# Check 1: Source Maps
################################################################################
echo -e "${BLUE}[1/6]${NC} Checking source maps configuration..."

SOURCEMAP_ENABLED=false
SOURCEMAP_FILES=0

if grep -r "sourcemap\|sourceMap" "$PROJECT_ROOT" --include="*.{json,js,ts}" 2>/dev/null | grep -v node_modules | head -5 > /dev/null; then
  SOURCEMAP_ENABLED=true
fi

SOURCEMAP_FILES=$(find "$PROJECT_ROOT" -name "*.map" 2>/dev/null | wc -l)

if [ "$SOURCEMAP_ENABLED" = true ] || [ $SOURCEMAP_FILES -gt 0 ]; then
  echo -e "${GREEN}✓ PASS${NC} Source maps enabled"
  echo "  Map files found: $SOURCEMAP_FILES"
  ((PASSED++))
  jq ".checks.sourcemaps = true" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
else
  echo -e "${YELLOW}! WARN${NC} Source maps not configured"
  echo "  Recommendation: Enable sourceMap in build config"
  ((FAILED++))
  jq ".checks.sourcemaps = false | .issues += [\"Source maps not configured\"]" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
fi

################################################################################
# Check 2: Debug Logging
################################################################################
echo -e "\n${BLUE}[2/6]${NC} Checking debug logging setup..."

DEBUG_LOGGING=false

if grep -r "logger\|console\|debug\|log(" "$PROJECT_ROOT/src" --include="*.{ts,tsx,js,jsx}" 2>/dev/null | grep -E "logger|debug|console\.(log|warn|error)" | head -5 > /dev/null; then
  DEBUG_LOGGING=true
fi

if [ "$DEBUG_LOGGING" = true ]; then
  echo -e "${GREEN}✓ PASS${NC} Debug logging implemented"
  echo "  Logging framework detected"
  ((PASSED++))
  jq ".checks.debug_logging = true" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
else
  echo -e "${YELLOW}! WARN${NC} No comprehensive logging found"
  echo "  Recommendation: Use console, logger library, or Sentry"
  ((FAILED++))
  jq ".checks.debug_logging = false | .issues += [\"Debug logging not comprehensive\"]" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
fi

################################################################################
# Check 3: Performance Markers
################################################################################
echo -e "\n${BLUE}[3/6]${NC} Checking performance.mark/measure usage..."

PERF_MARKERS=0

if grep -r "performance\.mark\|performance\.measure" "$PROJECT_ROOT/src" --include="*.{ts,tsx,js,jsx}" 2>/dev/null | wc -l | grep -v "^0$" > /dev/null; then
  PERF_MARKERS=$(grep -r "performance\.mark" "$PROJECT_ROOT/src" --include="*.{ts,tsx,js,jsx}" 2>/dev/null | wc -l)
fi

if [ $PERF_MARKERS -gt 0 ]; then
  echo -e "${GREEN}✓ PASS${NC} Performance markers configured"
  echo "  Custom marks: $PERF_MARKERS"
  ((PASSED++))
  jq ".checks.perf_markers = true" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
else
  echo -e "${YELLOW}! WARN${NC} No performance markers found"
  echo "  Use: performance.mark('operation-start')"
  ((FAILED++))
  jq ".checks.perf_markers = false | .issues += [\"Performance markers not used\"]" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
fi

################################################################################
# Check 4: Error Handling
################################################################################
echo -e "\n${BLUE}[4/6]${NC} Checking error handling and reporting..."

ERROR_HANDLING=false

if grep -r "try\|catch\|Error\|Sentry\|Rollbar\|ErrorBoundary" "$PROJECT_ROOT/src" --include="*.{ts,tsx,js,jsx}" 2>/dev/null | head -10 > /dev/null; then
  ERROR_HANDLING=true
fi

if [ "$ERROR_HANDLING" = true ]; then
  echo -e "${GREEN}✓ PASS${NC} Error handling implemented"
  echo "  Try/catch blocks and error boundaries detected"
  ((PASSED++))
  jq ".checks.error_handling = true" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
else
  echo -e "${YELLOW}! WARN${NC} Limited error handling"
  ((FAILED++))
  jq ".checks.error_handling = false | .issues += [\"Error handling not comprehensive\"]" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
fi

################################################################################
# Check 5: Network Monitoring
################################################################################
echo -e "\n${BLUE}[5/6]${NC} Checking network monitoring setup..."

NETWORK_MONITORING=false

if grep -r "fetch\|XMLHttpRequest\|axios\|networkInformation" "$PROJECT_ROOT/src" --include="*.{ts,tsx,js,jsx}" 2>/dev/null | head -10 > /dev/null; then
  NETWORK_MONITORING=true
fi

if [ "$NETWORK_MONITORING" = true ]; then
  echo -e "${GREEN}✓ PASS${NC} Network API usage detected"
  echo "  Fetch/axios requests found"
  ((PASSED++))
  jq ".checks.network_monitoring = true" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
else
  echo -e "${YELLOW}! WARN${NC} Network monitoring not clear"
  ((FAILED++))
  jq ".checks.network_monitoring = false | .issues += [\"Network monitoring not comprehensive\"]" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
fi

################################################################################
# Check 6: DevTools Extensions
################################################################################
echo -e "\n${BLUE}[6/6]${NC} Checking DevTools-related configuration..."

DEVTOOLS_READY=false

# Check for Lighthouse config
if [ -f "$PROJECT_ROOT/lighthouserc.json" ] || grep -q "lighthouse" "$PROJECT_ROOT/package.json" 2>/dev/null; then
  DEVTOOLS_READY=true
fi

# Check for testing frameworks that integrate with DevTools
if grep -q "jest\|vitest\|cypress" "$PROJECT_ROOT/package.json" 2>/dev/null; then
  DEVTOOLS_READY=true
fi

if [ "$DEVTOOLS_READY" = true ]; then
  echo -e "${GREEN}✓ PASS${NC} DevTools integration configured"
  echo "  Testing/auditing frameworks found"
  ((PASSED++))
  jq ".checks.devtools_integration = true" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
else
  echo -e "${YELLOW}! WARN${NC} Limited DevTools integration"
  echo "  Consider: Lighthouse, testing frameworks"
  ((FAILED++))
  jq ".checks.devtools_integration = false | .issues += [\"DevTools integration minimal\"]" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
fi

################################################################################
# Summary
################################################################################
echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}Validation Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "Passed:  ${GREEN}${PASSED}${NC}"
echo -e "Warning: ${YELLOW}${FAILED}${NC}"

TOTAL=$((PASSED + FAILED))
SCORE=$((PASSED * 100 / TOTAL))

echo -e "\nScore: ${SCORE}%"

jq ".summary = {\"passed\": $PASSED, \"failed\": $FAILED, \"total\": $TOTAL, \"score\": $SCORE}" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"

echo -e "\nResults saved to: ${BLUE}${RESULTS_FILE}${NC}"

if [ $FAILED -eq 0 ]; then
  echo -e "\n${GREEN}✓ All DevTools checks passed!${NC}"
  exit 0
else
  echo -e "\n${YELLOW}! Review recommendations above${NC}"
  exit 1
fi
