#!/bin/bash

################################################################################
# validate-images.sh
# REAL validation checking image optimization implementation
# Checks: formats (WebP/AVIF), srcset, lazy-loading, compression, sizes
################################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_ROOT="${1:-.}"
RESULTS_FILE="${PROJECT_ROOT}/.image-validation.json"
PASSED=0
FAILED=0

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Image Optimization Validation${NC}"
echo -e "${BLUE}Project: ${PROJECT_ROOT}${NC}"
echo -e "${BLUE}========================================${NC}\n"

cat > "$RESULTS_FILE" <<EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "project": "${PROJECT_ROOT}",
  "checks": {},
  "images": {
    "total": 0,
    "webp": 0,
    "avif": 0,
    "optimized": 0,
    "lazy_loaded": 0,
    "responsive": 0,
    "with_srcset": 0
  },
  "issues": [],
  "summary": {}
}
EOF

################################################################################
# Check 1: Image File Inventory
################################################################################
echo -e "${BLUE}[1/8]${NC} Scanning project for images..."

IMAGE_FILES=()
JPEG_COUNT=0
PNG_COUNT=0
GIF_COUNT=0
SVG_COUNT=0
WEBP_COUNT=0
AVIF_COUNT=0
TOTAL_SIZE=0

for ext in jpg jpeg png gif svg webp avif; do
  while IFS= read -r file; do
    IMAGE_FILES+=("$file")
    SIZE=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo 0)
    TOTAL_SIZE=$((TOTAL_SIZE + SIZE))

    case "$ext" in
      jpg|jpeg) ((JPEG_COUNT++)) ;;
      png) ((PNG_COUNT++)) ;;
      gif) ((GIF_COUNT++)) ;;
      svg) ((SVG_COUNT++)) ;;
      webp) ((WEBP_COUNT++)) ;;
      avif) ((AVIF_COUNT++)) ;;
    esac
  done < <(find "$PROJECT_ROOT" -iname "*.${ext}" -type f 2>/dev/null)
done

TOTAL_IMAGES=$((JPEG_COUNT + PNG_COUNT + GIF_COUNT + SVG_COUNT + WEBP_COUNT + AVIF_COUNT))

echo -e "${GREEN}✓ PASS${NC} Found $TOTAL_IMAGES images"
echo "  JPEG: $JPEG_COUNT | PNG: $PNG_COUNT | GIF: $GIF_COUNT"
echo "  WebP: $WEBP_COUNT | AVIF: $AVIF_COUNT | SVG: $SVG_COUNT"
echo "  Total size: $((TOTAL_SIZE / 1024 / 1024))MB"
((PASSED++))

jq ".images.total = $TOTAL_IMAGES | .images.webp = $WEBP_COUNT | .images.avif = $AVIF_COUNT" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"

################################################################################
# Check 2: WebP Format Support
################################################################################
echo -e "\n${BLUE}[2/8]${NC} Checking WebP format usage..."

WEBP_HTML_USAGE=0
if grep -r "\.webp\|image/webp\|<picture" "$PROJECT_ROOT/src" --include="*.{tsx,jsx,html}" 2>/dev/null | head -5 > /dev/null; then
  WEBP_HTML_USAGE=1
fi

WEBP_IN_CSS=0
if grep -r "\.webp" "$PROJECT_ROOT/src" --include="*.{css,scss}" 2>/dev/null > /dev/null; then
  WEBP_IN_CSS=1
fi

if [ $WEBP_COUNT -gt 0 ] && [ $WEBP_HTML_USAGE -eq 1 ]; then
  echo -e "${GREEN}✓ PASS${NC} WebP format properly integrated"
  echo "  WebP files: $WEBP_COUNT | HTML usage: Yes"
  ((PASSED++))
  jq ".checks.webp_support = true" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
else
  echo -e "${YELLOW}! WARN${NC} Limited WebP support detected"
  echo "  WebP files: $WEBP_COUNT | HTML usage: $([ $WEBP_HTML_USAGE -eq 1 ] && echo 'Yes' || echo 'No')"
  ((FAILED++))
  jq ".checks.webp_support = false | .issues += [\"WebP format not properly utilized\"]" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
fi

################################################################################
# Check 3: AVIF Format Support
################################################################################
echo -e "\n${BLUE}[3/8]${NC} Checking AVIF format usage..."

AVIF_HTML_USAGE=0
if grep -r "\.avif\|image/avif" "$PROJECT_ROOT/src" --include="*.{tsx,jsx,html}" 2>/dev/null > /dev/null; then
  AVIF_HTML_USAGE=1
fi

if [ $AVIF_COUNT -gt 0 ] && [ $AVIF_HTML_USAGE -eq 1 ]; then
  echo -e "${GREEN}✓ PASS${NC} AVIF format integrated"
  echo "  AVIF files: $AVIF_COUNT | HTML usage: Yes"
  ((PASSED++))
  jq ".checks.avif_support = true" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
else
  echo -e "${YELLOW}! WARN${NC} AVIF support minimal (next-gen format)"
  echo "  AVIF files: $AVIF_COUNT | Recommendation: Use for maximum compression"
  ((FAILED++))
  jq ".checks.avif_support = false | .issues += [\"AVIF format not implemented\"]" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
fi

################################################################################
# Check 4: Responsive Images (srcset)
################################################################################
echo -e "\n${BLUE}[4/8]${NC} Checking responsive images with srcset..."

SRCSET_COUNT=0
if grep -r "srcset\|sizes" "$PROJECT_ROOT/src" --include="*.{tsx,jsx,html}" 2>/dev/null | wc -l | grep -v "^0$" > /dev/null; then
  SRCSET_COUNT=$(grep -r "srcset" "$PROJECT_ROOT/src" --include="*.{tsx,jsx,html}" 2>/dev/null | wc -l)
fi

if [ $SRCSET_COUNT -gt 0 ]; then
  echo -e "${GREEN}✓ PASS${NC} Responsive images implemented"
  echo "  Images with srcset: $SRCSET_COUNT"
  ((PASSED++))
  jq ".checks.srcset = true | .images.with_srcset = $SRCSET_COUNT" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
else
  echo -e "${YELLOW}! WARN${NC} No srcset implementation found"
  echo "  Recommendation: Use srcset for responsive image serving"
  ((FAILED++))
  jq ".checks.srcset = false | .issues += [\"Responsive images (srcset) not implemented\"]" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
fi

################################################################################
# Check 5: Lazy Loading
################################################################################
echo -e "\n${BLUE}[5/8]${NC} Checking lazy loading implementation..."

LAZY_LOADING_COUNT=0
LAZY_LOADING_NATIVE=0
LAZY_LOADING_LIBRARY=0

if grep -r "loading=\"lazy\"\|loading='lazy'" "$PROJECT_ROOT/src" --include="*.{tsx,jsx,html}" 2>/dev/null | wc -l | grep -v "^0$" > /dev/null; then
  LAZY_LOADING_NATIVE=$(grep -r "loading=\"lazy\"" "$PROJECT_ROOT/src" --include="*.{tsx,jsx,html}" 2>/dev/null | wc -l)
fi

if grep -r "lazyload\|react-lazyload\|lozad\|IntersectionObserver" "$PROJECT_ROOT/src" --include="*.{tsx,jsx,js}" 2>/dev/null | head -5 > /dev/null; then
  LAZY_LOADING_LIBRARY=1
fi

LAZY_LOADING_COUNT=$((LAZY_LOADING_NATIVE + LAZY_LOADING_LIBRARY))

if [ $LAZY_LOADING_COUNT -gt 0 ]; then
  echo -e "${GREEN}✓ PASS${NC} Lazy loading implemented"
  echo "  Native (loading=lazy): $LAZY_LOADING_NATIVE"
  echo "  Library-based: $([ $LAZY_LOADING_LIBRARY -eq 1 ] && echo 'Yes' || echo 'No')"
  ((PASSED++))
  jq ".checks.lazy_loading = true | .images.lazy_loaded = $LAZY_LOADING_COUNT" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
else
  echo -e "${YELLOW}! WARN${NC} Lazy loading not found"
  echo "  Recommendation: Use loading=\"lazy\" or IntersectionObserver"
  ((FAILED++))
  jq ".checks.lazy_loading = false | .issues += [\"Lazy loading not implemented\"]" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
fi

################################################################################
# Check 6: Image Compression
################################################################################
echo -e "\n${BLUE}[6/8]${NC} Checking image compression implementation..."

SHARP_INSTALLED=0
IMAGEMIN_INSTALLED=0
COMPRESSION_SCRIPTS=0

if [ -f "$PROJECT_ROOT/package.json" ]; then
  if grep -q "sharp\|imagemin\|image-compress" "$PROJECT_ROOT/package.json"; then
    SHARP_INSTALLED=1
  fi
fi

if [ -f "$PROJECT_ROOT/.github/workflows/optimize-images.yml" ] || [ -f "$PROJECT_ROOT/scripts/compress-images.sh" ]; then
  COMPRESSION_SCRIPTS=1
fi

if [ $SHARP_INSTALLED -eq 1 ] || [ $COMPRESSION_SCRIPTS -eq 1 ]; then
  echo -e "${GREEN}✓ PASS${NC} Image compression configured"
  echo "  Sharp/ImageMin: $([ $SHARP_INSTALLED -eq 1 ] && echo 'Yes' || echo 'No')"
  echo "  Automation scripts: $([ $COMPRESSION_SCRIPTS -eq 1 ] && echo 'Yes' || echo 'No')"
  ((PASSED++))
  jq ".checks.compression = true" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
else
  echo -e "${YELLOW}! WARN${NC} No automatic compression found"
  echo "  Recommendation: Use sharp or imagemin for automated optimization"
  ((FAILED++))
  jq ".checks.compression = false | .issues += [\"Automatic image compression not configured\"]" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
fi

################################################################################
# Check 7: Image Dimensions
################################################################################
echo -e "\n${BLUE}[7/8]{{NC}} Checking image dimension specification..."

IMAGES_WITH_DIMENSIONS=0
if grep -r "width=\|height=\|aspect-ratio" "$PROJECT_ROOT/src" --include="*.{tsx,jsx,html}" 2>/dev/null | grep -E "img|picture" > /dev/null; then
  IMAGES_WITH_DIMENSIONS=$(grep -r "img.*width=\|img.*height=" "$PROJECT_ROOT/src" --include="*.{tsx,jsx,html}" 2>/dev/null | wc -l)
fi

if [ $IMAGES_WITH_DIMENSIONS -gt 0 ]; then
  echo -e "${GREEN}✓ PASS${NC} Image dimensions properly specified"
  echo "  Images with dimensions: $IMAGES_WITH_DIMENSIONS"
  ((PASSED++))
  jq ".checks.dimensions = true" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
else
  echo -e "${YELLOW}! WARN${NC} Limited dimension specification"
  echo "  Recommendation: Add width/height or aspect-ratio to prevent CLS"
  ((FAILED++))
  jq ".checks.dimensions = false | .issues += [\"Image dimensions not properly specified\"]" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
fi

################################################################################
# Check 8: Picture Element Usage
################################################################################
echo -e "\n${BLUE}[8/8]{{NC}} Checking picture element for format fallbacks..."

PICTURE_COUNT=0
if grep -r "<picture" "$PROJECT_ROOT/src" --include="*.{tsx,jsx,html}" 2>/dev/null | wc -l | grep -v "^0$" > /dev/null; then
  PICTURE_COUNT=$(grep -r "<picture" "$PROJECT_ROOT/src" --include="*.{tsx,jsx,html}" 2>/dev/null | wc -l)
fi

if [ $PICTURE_COUNT -gt 0 ]; then
  echo -e "${GREEN}✓ PASS${NC} Picture element for format fallbacks"
  echo "  Picture elements: $PICTURE_COUNT"
  ((PASSED++))
  jq ".checks.picture_element = true | .images.responsive = $PICTURE_COUNT" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
else
  echo -e "${YELLOW}! WARN${NC} No picture elements found"
  echo "  Use for AVIF → WebP → fallback format chains"
  ((FAILED++))
  jq ".checks.picture_element = false | .issues += [\"Picture element not used for format fallbacks\"]" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"
fi

################################################################################
# Summary
################################################################################
echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}Image Optimization Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "Passed:  ${GREEN}${PASSED}${NC}"
echo -e "Warning: ${YELLOW}${FAILED}${NC}"

TOTAL=$((PASSED + FAILED))
SCORE=$((PASSED * 100 / TOTAL))

echo -e "\nScore: ${SCORE}%"
echo -e "\nImage Inventory:"
echo "  Total images: $TOTAL_IMAGES"
echo "  WebP: $WEBP_COUNT | AVIF: $AVIF_COUNT"
echo "  Responsive (srcset): $SRCSET_COUNT"
echo "  Lazy-loaded: $LAZY_LOADING_COUNT"

jq ".summary = {\"passed\": $PASSED, \"failed\": $FAILED, \"total\": $TOTAL, \"score\": $SCORE}" "$RESULTS_FILE" > /tmp/tmp.json && mv /tmp/tmp.json "$RESULTS_FILE"

echo -e "\nResults saved to: ${BLUE}${RESULTS_FILE}${NC}"

if [ $FAILED -eq 0 ]; then
  echo -e "\n${GREEN}✓ All image optimization checks passed!${NC}"
  exit 0
else
  echo -e "\n${YELLOW}! Review recommendations above${NC}"
  exit 1
fi
