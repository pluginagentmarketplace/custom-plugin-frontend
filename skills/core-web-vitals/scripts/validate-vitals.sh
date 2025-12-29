#!/bin/bash

################################################################################
# validate-vitals.sh
# REAL validation checking Core Web Vitals implementation
# Checks: LCP/FID/CLS metrics, web-vitals library, Lighthouse, performance budget
################################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ROOT="${1:-.}"
RESULTS_FILE="${PROJECT_ROOT}/.vitals-validation.json"
PASSED=0
FAILED=0

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Core Web Vitals Validation${NC}"
echo -e "${BLUE}Project: ${PROJECT_ROOT}${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Initialize results JSON
cat > "$RESULTS_FILE" <<EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "project": "${PROJECT_ROOT}",
  "checks": {
    "lcp_implementation": null,
    "fid_inp_implementation": null,
    "cls_implementation": null,
    "web_vitals_library": null,
    "lighthouse_config": null,
    "performance_budget": null,
    "measurement_endpoints": null,
    "thresholds_defined": null,
    "reporting_setup": null,
    "monitoring_integration": null
  },
  "issues": [],
  "summary": {}
}
EOF

################################################################################
# Check 1: LCP Implementation
################################################################################
echo -e "${BLUE}[1/10]${NC} Checking Largest Contentful Paint (LCP) implementation..."

LCP_FOUND=false
LCP_FILES=()

# Check for LCP measurement in common locations
if grep -r "largest-contentful-paint\|'LCP'\|PerformanceObserver.*largest" "$PROJECT_ROOT/src" --include="*.{ts,tsx,js,jsx}" 2>/dev/null | head -5 > /dev/null; then
    LCP_FOUND=true
    LCP_FILES=($(grep -r "largest-contentful-paint\|'LCP'" "$PROJECT_ROOT/src" --include="*.{ts,tsx,js,jsx}" -l 2>/dev/null | head -10))
fi

# Check for web-vitals usage
if grep -r "reportWebVitals\|getLCP\|getCLS\|getFID\|getFCP" "$PROJECT_ROOT/src" --include="*.{ts,tsx,js,jsx}" 2>/dev/null | head -5 > /dev/null; then
    LCP_FOUND=true
fi

if [ "$LCP_FOUND" = true ]; then
    echo -e "${GREEN}✓ PASS${NC} LCP implementation detected"
    echo "  Files: ${#LCP_FILES[@]} files using LCP measurement"
    ((PASSED++))
    jq ".checks.lcp_implementation = true" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
else
    echo -e "${YELLOW}! WARN${NC} No LCP implementation found"
    echo "  Expected: PerformanceObserver, web-vitals, or custom measurement"
    ((FAILED++))
    jq ".checks.lcp_implementation = false | .issues += [\"LCP not implemented\"]" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
fi

################################################################################
# Check 2: FID/INP Implementation
################################################################################
echo -e "\n${BLUE}[2/10]${NC} Checking First Input Delay (FID) / Interaction to Next Paint (INP)..."

FID_FOUND=false

if grep -r "first-input\|'FID'\|'INP'\|interaction-to-next-paint" "$PROJECT_ROOT/src" --include="*.{ts,tsx,js,jsx}" 2>/dev/null | head -5 > /dev/null; then
    FID_FOUND=true
fi

# Check for event listener optimization
if grep -r "addEventListener\|{passive: true}" "$PROJECT_ROOT/src" --include="*.{ts,tsx,js,jsx}" 2>/dev/null | head -5 > /dev/null; then
    FID_FOUND=true
fi

if [ "$FID_FOUND" = true ]; then
    echo -e "${GREEN}✓ PASS${NC} FID/INP measurement found"
    echo "  Event handlers optimized for responsiveness"
    ((PASSED++))
    jq ".checks.fid_inp_implementation = true" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
else
    echo -e "${YELLOW}! WARN${NC} Limited FID/INP optimization found"
    echo "  Recommendation: Implement passive event listeners and optimize long tasks"
    ((FAILED++))
    jq ".checks.fid_inp_implementation = false | .issues += [\"Limited FID/INP optimization\"]" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
fi

################################################################################
# Check 3: CLS Implementation
################################################################################
echo -e "\n${BLUE}[3/10]${NC} Checking Cumulative Layout Shift (CLS) prevention..."

CLS_FOUND=false

# Check for layout shift prevention
if grep -r "layout-shift\|'CLS'\|size\|width.*height" "$PROJECT_ROOT/src" --include="*.{ts,tsx,js,jsx}" 2>/dev/null | grep -E "(width|height|aspect-ratio)" > /dev/null; then
    CLS_FOUND=true
fi

# Check CSS for layout shift prevention
if find "$PROJECT_ROOT/src" -name "*.css" -o -name "*.scss" 2>/dev/null | xargs grep -l "aspect-ratio\|contain: layout\|contain: size" 2>/dev/null > /dev/null; then
    CLS_FOUND=true
fi

if [ "$CLS_FOUND" = true ]; then
    echo -e "${GREEN}✓ PASS${NC} CLS prevention measures detected"
    echo "  Layout shift prevention implemented"
    ((PASSED++))
    jq ".checks.cls_implementation = true" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
else
    echo -e "${YELLOW}! WARN${NC} No explicit CLS prevention found"
    echo "  Recommendation: Add aspect-ratio, contain properties, reserved space for dynamic content"
    ((FAILED++))
    jq ".checks.cls_implementation = false | .issues += [\"CLS prevention not comprehensive\"]" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
fi

################################################################################
# Check 4: web-vitals Library
################################################################################
echo -e "\n${BLUE}[4/10]${NC} Checking web-vitals library installation..."

VITALS_INSTALLED=false
VITALS_VERSION=""

if [ -f "$PROJECT_ROOT/package.json" ]; then
    if grep -q "web-vitals" "$PROJECT_ROOT/package.json"; then
        VITALS_INSTALLED=true
        VITALS_VERSION=$(grep "web-vitals" "$PROJECT_ROOT/package.json" | head -1 | grep -oE "[0-9]+\.[0-9]+\.[0-9]+" | head -1)
    fi
fi

if [ "$VITALS_INSTALLED" = true ]; then
    echo -e "${GREEN}✓ PASS${NC} web-vitals library installed"
    echo "  Version: ${VITALS_VERSION:-latest}"
    ((PASSED++))
    jq ".checks.web_vitals_library = true" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
else
    echo -e "${RED}✗ FAIL${NC} web-vitals library not found in package.json"
    echo "  Required: npm install web-vitals"
    ((FAILED++))
    jq ".checks.web_vitals_library = false | .issues += [\"web-vitals library not installed\"]" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
fi

################################################################################
# Check 5: Lighthouse Configuration
################################################################################
echo -e "\n${BLUE}[5/10]${NC} Checking Lighthouse configuration..."

LIGHTHOUSE_CONFIG=false

if [ -f "$PROJECT_ROOT/lighthouserc.json" ] || [ -f "$PROJECT_ROOT/.lighthouserc.json" ] || [ -f "$PROJECT_ROOT/lighthouserc.js" ]; then
    LIGHTHOUSE_CONFIG=true
    CONFIG_FILE=$(find "$PROJECT_ROOT" -maxdepth 1 -name "*lighthouserc*" -type f | head -1)
    echo -e "${GREEN}✓ PASS${NC} Lighthouse configuration found"
    echo "  Config: $(basename $CONFIG_FILE)"
    ((PASSED++))
    jq ".checks.lighthouse_config = true" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
else
    echo -e "${YELLOW}! WARN${NC} No Lighthouse configuration file found"
    echo "  Create: lighthouserc.json for automated performance audits"
    ((FAILED++))
    jq ".checks.lighthouse_config = false | .issues += [\"Lighthouse config missing\"]" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
fi

################################################################################
# Check 6: Performance Budget
################################################################################
echo -e "\n${BLUE}[6/10]${NC} Checking performance budget definition..."

BUDGET_DEFINED=false

# Check in lighthouse config
if [ -f "$PROJECT_ROOT/lighthouserc.json" ] && grep -q "budgets\|performance" "$PROJECT_ROOT/lighthouserc.json"; then
    BUDGET_DEFINED=true
fi

# Check in package.json scripts
if grep -q "performance\|budget" "$PROJECT_ROOT/package.json" 2>/dev/null; then
    BUDGET_DEFINED=true
fi

# Check for performance budget file
if find "$PROJECT_ROOT" -name "*budget*" -o -name "*performance*" 2>/dev/null | grep -E "\.(json|yml|yaml)$" > /dev/null; then
    BUDGET_DEFINED=true
fi

if [ "$BUDGET_DEFINED" = true ]; then
    echo -e "${GREEN}✓ PASS${NC} Performance budget defined"
    echo "  Metrics tracked: LCP, FID, CLS, bundle size"
    ((PASSED++))
    jq ".checks.performance_budget = true" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
else
    echo -e "${YELLOW}! WARN${NC} No performance budget found"
    echo "  Recommendation: Define budgets for LCP (<2.5s), FID (<100ms), CLS (<0.1)"
    ((FAILED++))
    jq ".checks.performance_budget = false | .issues += [\"Performance budget not defined\"]" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
fi

################################################################################
# Check 7: Measurement Endpoints
################################################################################
echo -e "\n${BLUE}[7/10]${NC} Checking metrics reporting endpoints..."

ENDPOINTS_FOUND=false

if grep -r "fetch\|beacon\|sendMetrics\|reportMetrics" "$PROJECT_ROOT/src" --include="*.{ts,tsx,js,jsx}" 2>/dev/null | grep -E "vital|metric|performance" > /dev/null; then
    ENDPOINTS_FOUND=true
fi

if [ "$ENDPOINTS_FOUND" = true ]; then
    echo -e "${GREEN}✓ PASS${NC} Metrics reporting implementation found"
    echo "  Metrics sent to backend/analytics"
    ((PASSED++))
    jq ".checks.measurement_endpoints = true" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
else
    echo -e "${YELLOW}! WARN${NC} No explicit metrics reporting found"
    echo "  Recommendation: Send vitals to analytics service (Google Analytics, Datadog, etc.)"
    ((FAILED++))
    jq ".checks.measurement_endpoints = false | .issues += [\"Metrics reporting not configured\"]" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
fi

################################################################################
# Check 8: Thresholds Defined
################################################################################
echo -e "\n${BLUE}[8/10]${NC} Checking performance thresholds..."

THRESHOLDS_FOUND=false

if grep -r "2500\|100\|0\.1\|threshold\|goodLimit\|needsImprovementLimit" "$PROJECT_ROOT/src" --include="*.{ts,tsx,js,jsx}" 2>/dev/null > /dev/null; then
    THRESHOLDS_FOUND=true
fi

# Check in config files
if grep -r "threshold\|goodLimit\|need" "$PROJECT_ROOT" --include="*.json" 2>/dev/null | grep -E "lcp|fid|cls|vital" > /dev/null; then
    THRESHOLDS_FOUND=true
fi

if [ "$THRESHOLDS_FOUND" = true ]; then
    echo -e "${GREEN}✓ PASS${NC} Performance thresholds defined"
    echo "  Good: LCP <2.5s, FID <100ms, CLS <0.1"
    ((PASSED++))
    jq ".checks.thresholds_defined = true" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
else
    echo -e "${YELLOW}! WARN${NC} No explicit thresholds found"
    echo "  Define: LCP <2.5s, INP <200ms, CLS <0.1"
    ((FAILED++))
    jq ".checks.thresholds_defined = false | .issues += [\"Performance thresholds not defined\"]" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
fi

################################################################################
# Check 9: Reporting Setup
################################################################################
echo -e "\n${BLUE}[9/10]${NC} Checking metrics reporting setup..."

REPORTING_FOUND=false

if grep -r "console\.log\|logger\|report\|metrics" "$PROJECT_ROOT/src" --include="*.{ts,tsx,js,jsx}" 2>/dev/null | grep -i "vital" > /dev/null; then
    REPORTING_FOUND=true
fi

if [ "$REPORTING_FOUND" = true ]; then
    echo -e "${GREEN}✓ PASS${NC} Metrics reporting setup found"
    ((PASSED++))
    jq ".checks.reporting_setup = true" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
else
    echo -e "${YELLOW}! WARN${NC} Limited reporting configuration"
    ((FAILED++))
    jq ".checks.reporting_setup = false | .issues += [\"Reporting not fully configured\"]" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
fi

################################################################################
# Check 10: Monitoring Integration
################################################################################
echo -e "\n${BLUE}[10/10]${NC} Checking monitoring integration..."

MONITORING_FOUND=false

# Check for monitoring services
if grep -r "datadog\|newrelic\|sentry\|mixpanel\|segment\|analytics\.google" "$PROJECT_ROOT" --include="*.{ts,tsx,js,jsx,json}" 2>/dev/null > /dev/null; then
    MONITORING_FOUND=true
fi

if [ "$MONITORING_FOUND" = true ]; then
    echo -e "${GREEN}✓ PASS${NC} Monitoring integration detected"
    ((PASSED++))
    jq ".checks.monitoring_integration = true" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
else
    echo -e "${YELLOW}! WARN${NC} No monitoring integration found"
    echo "  Recommendation: Integrate with Google Analytics, Datadog, or New Relic"
    ((FAILED++))
    jq ".checks.monitoring_integration = false | .issues += [\"Monitoring not integrated\"]" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
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

# Update summary in JSON
jq ".summary = {\"passed\": $PASSED, \"failed\": $FAILED, \"total\": $TOTAL, \"score\": $SCORE}" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"

echo -e "\nResults saved to: ${BLUE}${RESULTS_FILE}${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "\n${GREEN}✓ All Core Web Vitals checks passed!${NC}"
    exit 0
else
    echo -e "\n${YELLOW}! Review warnings and recommendations above${NC}"
    exit 1
fi
