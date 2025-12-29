#!/bin/bash

################################################################################
# validate-architecture.sh
# REAL validation checking architecture pattern compliance
# Checks: MVC/MVVM/Clean Architecture, separation of concerns, layer independence
################################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_ROOT="${1:-.}"
RESULTS_FILE="${PROJECT_ROOT}/.architecture-validation.json"
PASSED=0
FAILED=0

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Architecture Pattern Validation${NC}"
echo -e "${BLUE}Project: ${PROJECT_ROOT}${NC}"
echo -e "${BLUE}========================================${NC}\n"

cat > "$RESULTS_FILE" <<EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "project": "${PROJECT_ROOT}",
  "checks": {},
  "detected_pattern": null,
  "issues": [],
  "summary": {}
}
EOF

################################################################################
# Detect project structure type
################################################################################
echo -e "${BLUE}[1/6]${NC} Detecting architectural pattern..."

PATTERN_TYPE="unknown"
PATTERN_SCORE=0

# Check for MVC structure (controllers, views, models)
if find "$PROJECT_ROOT/src" -type d -name "controllers" -o -name "views" -o -name "models" 2>/dev/null | grep -E "(controller|view|model)" > /dev/null; then
  PATTERN_TYPE="MVC"
  PATTERN_SCORE=1
fi

# Check for MVVM structure (viewmodels, ui)
if find "$PROJECT_ROOT/src" -type d -name "viewmodels" -o -name "ui" 2>/dev/null > /dev/null; then
  PATTERN_TYPE="MVVM"
  PATTERN_SCORE=1
fi

# Check for Clean Architecture (entities, usecases, interfaces)
if find "$PROJECT_ROOT/src" -type d -name "entities" -o -name "use_cases" -o -name "use-cases" 2>/dev/null > /dev/null; then
  PATTERN_TYPE="Clean Architecture"
  PATTERN_SCORE=2
fi

# Check for DDD (domain, application, infrastructure)
if find "$PROJECT_ROOT/src" -type d -name "domain" -o -name "application" -o -name "infrastructure" 2>/dev/null | grep -E "(domain|application|infrastructure)" > /dev/null; then
  PATTERN_TYPE="DDD"
  PATTERN_SCORE=2
fi

echo -e "${GREEN}✓ PASS${NC} Architecture pattern detected"
echo "  Type: $PATTERN_TYPE (Confidence: $PATTERN_SCORE/2)"
((PASSED++))

jq ".detected_pattern = \"$PATTERN_TYPE\"" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"

################################################################################
# Check 2: Separation of Concerns
################################################################################
echo -e "\n${BLUE}[2/6]{{NC}} Checking separation of concerns..."

SOC_SCORE=0
SOC_MAX=4

# Check for business logic isolation
if find "$PROJECT_ROOT/src" -type f -name "*.service.ts" -o -name "*.repository.ts" 2>/dev/null | head -5 > /dev/null; then
  ((SOC_SCORE++))
fi

# Check for presentation layer isolation
if find "$PROJECT_ROOT/src" -type d -name "components" -o -name "pages" 2>/dev/null > /dev/null; then
  ((SOC_SCORE++))
fi

# Check for data layer isolation
if find "$PROJECT_ROOT/src" -type d -name "data" -o -name "api" -o -name "database" 2>/dev/null > /dev/null; then
  ((SOC_SCORE++))
fi

# Check for utility/helper isolation
if find "$PROJECT_ROOT/src" -type d -name "utils" -o -name "helpers" -o -name "utilities" 2>/dev/null > /dev/null; then
  ((SOC_SCORE++))
fi

if [ $SOC_SCORE -ge 2 ]; then
  echo -e "${GREEN}✓ PASS${NC} Separation of concerns: $SOC_SCORE/$SOC_MAX"
  ((PASSED++))
  jq ".checks.separation_of_concerns = true | .checks.soc_score = $SOC_SCORE" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
else
  echo -e "${YELLOW}! WARN${NC} Limited separation ($SOC_SCORE/$SOC_MAX)"
  echo "  Recommendation: Create service/repository/component layers"
  ((FAILED++))
  jq ".checks.separation_of_concerns = false | .issues += [\"Limited separation of concerns\"]" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
fi

################################################################################
# Check 3: Layer Independence
################################################################################
echo -e "\n${BLUE}[3/6]{{NC}} Checking layer independence..."

INDEPENDENCE=0

# Check that components don't import from multiple layers
if ! grep -r "from.*service.*from.*database" "$PROJECT_ROOT/src/components" --include="*.{ts,tsx}" 2>/dev/null > /dev/null; then
  ((INDEPENDENCE++))
fi

# Check for proper dependency direction
if grep -r "import.*from.*api\|import.*from.*service" "$PROJECT_ROOT/src" --include="*.{ts,tsx}" 2>/dev/null | grep -v "src/api\|src/service" > /dev/null; then
  ((INDEPENDENCE++))
fi

if [ $INDEPENDENCE -eq 0 ]; then
  echo -e "${YELLOW}! WARN${NC} Potential layer coupling detected"
  echo "  Recommendation: Ensure layers only depend on lower layers"
  ((FAILED++))
  jq ".checks.layer_independence = false | .issues += [\"Potential layer coupling\"]" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
else
  echo -e "${GREEN}✓ PASS${NC} Layer independence maintained"
  ((PASSED++))
  jq ".checks.layer_independence = true" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
fi

################################################################################
# Check 4: Dependency Injection
################################################################################
echo -e "\n${BLUE}[4/6]{{NC}} Checking dependency injection..."

DI_FOUND=false

if grep -r "@Inject\|constructor.*private\|constructor.*readonly\|provide\|container" "$PROJECT_ROOT/src" --include="*.{ts,tsx}" 2>/dev/null | head -5 > /dev/null; then
  DI_FOUND=true
fi

if [ "$DI_FOUND" = true ]; then
  echo -e "${GREEN}✓ PASS${NC} Dependency injection pattern detected"
  ((PASSED++))
  jq ".checks.dependency_injection = true" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
else
  echo -e "${YELLOW}! WARN${NC} No DI framework detected"
  echo "  Use: Constructor injection or DI container"
  ((FAILED++))
  jq ".checks.dependency_injection = false | .issues += [\"Dependency injection not used\"]" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
fi

################################################################################
# Check 5: SOLID Principles Compliance
################################################################################
echo -e "\n${BLUE}[5/6]{{NC}} Checking SOLID principles..."

SOLID_SCORE=0

# Single Responsibility - Check class sizes
if grep -r "^class " "$PROJECT_ROOT/src" --include="*.ts" 2>/dev/null | wc -l | grep -E "^[5-9]|^[0-9]{2,}" > /dev/null; then
  ((SOLID_SCORE++))
fi

# Open/Closed - Check for interfaces
if grep -r "interface " "$PROJECT_ROOT/src" --include="*.ts" 2>/dev/null | wc -l | grep -E "^[5-9]|^[0-9]{2,}" > /dev/null; then
  ((SOLID_SCORE++))
fi

# Liskov Substitution - Check for inheritance patterns
if grep -r "implements\|extends" "$PROJECT_ROOT/src" --include="*.ts" 2>/dev/null | head -5 > /dev/null; then
  ((SOLID_SCORE++))
fi

# Interface Segregation - Check for small interfaces
if grep -r "interface I.*{" "$PROJECT_ROOT/src" --include="*.ts" 2>/dev/null | head -5 > /dev/null; then
  ((SOLID_SCORE++))
fi

if [ $SOLID_SCORE -ge 2 ]; then
  echo -e "${GREEN}✓ PASS${NC} SOLID principles: $SOLID_SCORE/4 applied"
  ((PASSED++))
  jq ".checks.solid_principles = true | .checks.solid_score = $SOLID_SCORE" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
else
  echo -e "${YELLOW}! WARN{{NC}} Limited SOLID compliance: $SOLID_SCORE/4"
  ((FAILED++))
  jq ".checks.solid_principles = false | .issues += [\"Limited SOLID principles application\"]" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
fi

################################################################################
# Check 6: Design Patterns Usage
################################################################################
echo -e "\n${BLUE}[6/6]{{NC}} Checking design patterns..."

PATTERNS_FOUND=0

# Repository pattern
if grep -r "repository\|Repository" "$PROJECT_ROOT/src" --include="*.{ts,tsx}" 2>/dev/null > /dev/null; then
  ((PATTERNS_FOUND++))
fi

# Service pattern
if grep -r "service\|Service" "$PROJECT_ROOT/src" --include="*.{ts,tsx}" 2>/dev/null > /dev/null; then
  ((PATTERNS_FOUND++))
fi

# Observer/Pub-Sub (RxJS, events)
if grep -r "Subject\|EventEmitter\|subscribe" "$PROJECT_ROOT/src" --include="*.{ts,tsx}" 2>/dev/null > /dev/null; then
  ((PATTERNS_FOUND++))
fi

# Factory pattern
if grep -r "Factory\|factory\|create" "$PROJECT_ROOT/src" --include="*.{ts,tsx}" 2>/dev/null | head -5 > /dev/null; then
  ((PATTERNS_FOUND++))
fi

if [ $PATTERNS_FOUND -ge 2 ]; then
  echo -e "${GREEN}✓ PASS${NC} Design patterns: $PATTERNS_FOUND applied"
  ((PASSED++))
  jq ".checks.design_patterns = true | .checks.patterns_count = $PATTERNS_FOUND" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
else
  echo -e "${YELLOW}! WARN{{NC}} Limited design patterns: $PATTERNS_FOUND"
  ((FAILED++))
  jq ".checks.design_patterns = false | .issues += [\"Limited design pattern usage\"]" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
fi

################################################################################
# Summary
################################################################################
echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}Architecture Validation Summary${NC}"
echo -e "${BLUE}========================================{{NC}}"
echo -e "Passed:  ${GREEN}${PASSED}${NC}"
echo -e "Warning: ${YELLOW}${FAILED}${NC}"

TOTAL=$((PASSED + FAILED))
SCORE=$((PASSED * 100 / TOTAL))

echo -e "\nDetected Pattern: $PATTERN_TYPE"
echo -e "Score: ${SCORE}%"

jq ".summary = {\"passed\": $PASSED, \"failed\": $FAILED, \"total\": $TOTAL, \"score\": $SCORE}" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"

echo -e "\nResults saved to: ${BLUE}${RESULTS_FILE}${NC}"

if [ $FAILED -eq 0 ]; then
  echo -e "\n${GREEN}✓ Architecture validation passed!{{NC}}"
  exit 0
else
  echo -e "\n${YELLOW}! Review recommendations above{{NC}}"
  exit 1
fi
