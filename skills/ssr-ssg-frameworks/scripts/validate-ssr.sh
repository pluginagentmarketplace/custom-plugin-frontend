#!/bin/bash
# SSR/SSG Framework Validation - Real checks for Next.js/Nuxt configuration

set -e

PROJECT_PATH="${1:-.}"
PASS=0
FAIL=0
WARN=0

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "===================================="
echo "SSR/SSG Framework Validation"
echo "===================================="
echo ""

# ============================================================================
# FRAMEWORK DETECTION
# ============================================================================
echo "--- Framework Detection ---"

if [ -f "$PROJECT_PATH/next.config.js" ] || [ -f "$PROJECT_PATH/next.config.ts" ]; then
  echo -e "${GREEN}✓${NC} Framework: Next.js detected"
  FRAMEWORK="nextjs"
  ((PASS++))
elif [ -f "$PROJECT_PATH/nuxt.config.ts" ] || [ -f "$PROJECT_PATH/nuxt.config.js" ]; then
  echo -e "${GREEN}✓${NC} Framework: Nuxt detected"
  FRAMEWORK="nuxt"
  ((PASS++))
elif [ -f "$PROJECT_PATH/gatsby-config.js" ]; then
  echo -e "${GREEN}✓${NC} Framework: Gatsby detected"
  FRAMEWORK="gatsby"
  ((PASS++))
else
  echo -e "${RED}✗${NC} Framework: No SSR/SSG framework detected"
  ((FAIL++))
  exit 1
fi

echo ""
echo "--- Package.json Dependencies ---"

# Check for framework in dependencies
if grep -q "\"next\"" "$PROJECT_PATH/package.json" 2>/dev/null; then
  next_version=$(grep "\"next\"" "$PROJECT_PATH/package.json" | head -1)
  echo -e "${GREEN}✓${NC} Dependencies: Next.js installed"
  echo "  $next_version"
  ((PASS++))
fi

if grep -q "\"nuxt\"" "$PROJECT_PATH/package.json" 2>/dev/null; then
  echo -e "${GREEN}✓${NC} Dependencies: Nuxt installed"
  ((PASS++))
fi

if grep -q "\"gatsby\"" "$PROJECT_PATH/package.json" 2>/dev/null; then
  echo -e "${GREEN}✓${NC} Dependencies: Gatsby installed"
  ((PASS++))
fi

echo ""
echo "--- Pages Structure ---"

# Check for pages directory
if [ -d "$PROJECT_PATH/pages" ]; then
  pages_count=$(find "$PROJECT_PATH/pages" -name "*.tsx" -o -name "*.ts" -o -name "*.jsx" -o -name "*.js" 2>/dev/null | wc -l)
  echo -e "${GREEN}✓${NC} Pages: Found $pages_count page files"
  ((PASS++))
else
  if [ "$FRAMEWORK" == "nextjs" ]; then
    if [ ! -d "$PROJECT_PATH/app" ]; then
      echo -e "${RED}✗${NC} Pages: No pages/ or app/ directory found"
      ((FAIL++))
    else
      app_count=$(find "$PROJECT_PATH/app" -name "*.tsx" -o -name "*.ts" 2>/dev/null | wc -l)
      echo -e "${GREEN}✓${NC} App Router: Found $app_count files in app/"
      ((PASS++))
    fi
  fi
fi

echo ""
echo "--- Data Fetching Methods ---"

if [ "$FRAMEWORK" == "nextjs" ]; then
  echo "Checking for getServerSideProps..."
  if find "$PROJECT_PATH/pages" -type f \( -name "*.tsx" -o -name "*.jsx" \) 2>/dev/null | \
     xargs grep -l "getServerSideProps" 2>/dev/null | grep -q .; then
    echo -e "${GREEN}✓${NC} getServerSideProps: Found in pages"
    ((PASS++))
  else
    echo -e "${YELLOW}!${NC} getServerSideProps: Not found"
    ((WARN++))
  fi

  echo "Checking for getStaticProps..."
  if find "$PROJECT_PATH/pages" -type f \( -name "*.tsx" -o -name "*.jsx" \) 2>/dev/null | \
     xargs grep -l "getStaticProps" 2>/dev/null | grep -q .; then
    echo -e "${GREEN}✓${NC} getStaticProps: Found in pages"
    ((PASS++))
  else
    echo -e "${YELLOW}!${NC} getStaticProps: Not found"
    ((WARN++))
  fi

  echo "Checking for getStaticPaths..."
  if find "$PROJECT_PATH/pages" -type f \( -name "*.tsx" -o -name "*.jsx" \) 2>/dev/null | \
     xargs grep -l "getStaticPaths" 2>/dev/null | grep -q .; then
    echo -e "${GREEN}✓${NC} getStaticPaths: Found for dynamic routes"
    ((PASS++))
  else
    echo -e "${YELLOW}!${NC} getStaticPaths: Not found"
    ((WARN++))
  fi

  echo "Checking for Incremental Static Regeneration (ISR)..."
  if find "$PROJECT_PATH/pages" -type f \( -name "*.tsx" -o -name "*.jsx" \) 2>/dev/null | \
     xargs grep -l "revalidate" 2>/dev/null | grep -q .; then
    echo -e "${GREEN}✓${NC} ISR: revalidate found in pages"
    ((PASS++))
  else
    echo -e "${YELLOW}!${NC} ISR: revalidate not configured (optional)"
    ((WARN++))
  fi
fi

if [ "$FRAMEWORK" == "nuxt" ]; then
  echo "Checking for asyncData..."
  if find "$PROJECT_PATH" -type f \( -name "*.vue" \) 2>/dev/null | \
     xargs grep -l "asyncData\|fetch" 2>/dev/null | grep -q .; then
    echo -e "${GREEN}✓${NC} Nuxt: asyncData/fetch found"
    ((PASS++))
  else
    echo -e "${YELLOW}!${NC} Nuxt: No asyncData/fetch found"
    ((WARN++))
  fi
fi

echo ""
echo "--- API Routes ---"

if [ -d "$PROJECT_PATH/pages/api" ]; then
  api_count=$(find "$PROJECT_PATH/pages/api" -name "*.ts" -o -name "*.js" 2>/dev/null | wc -l)
  echo -e "${GREEN}✓${NC} API Routes: Found $api_count API endpoints"
  ((PASS++))
elif [ -d "$PROJECT_PATH/server/api" ]; then
  api_count=$(find "$PROJECT_PATH/server/api" -name "*.ts" 2>/dev/null | wc -l)
  echo -e "${GREEN}✓${NC} API Routes: Found $api_count API endpoints"
  ((PASS++))
else
  echo -e "${YELLOW}!${NC} API Routes: No api directory found"
  ((WARN++))
fi

echo ""
echo "--- Configuration Files ---"

if [ "$FRAMEWORK" == "nextjs" ]; then
  if [ -f "$PROJECT_PATH/next.config.js" ] || [ -f "$PROJECT_PATH/next.config.ts" ]; then
    config_file=$(find "$PROJECT_PATH" -maxdepth 1 -name "next.config.*" | head -1)
    echo -e "${GREEN}✓${NC} Next.js Config: $(basename $config_file)"
    ((PASS++))

    # Check for important configs
    if grep -q "images:\|experimental:\|headers:" "$config_file" 2>/dev/null; then
      echo -e "${GREEN}✓${NC} Config: Advanced settings found"
      ((PASS++))
    fi
  fi
fi

echo ""
echo "--- Build Output ---"

if [ -d "$PROJECT_PATH/.next" ]; then
  build_size=$(du -sh "$PROJECT_PATH/.next" 2>/dev/null | awk '{print $1}')
  echo -e "${GREEN}✓${NC} Build Output: .next directory ($build_size)"
  ((PASS++))

  # Check for prerendered pages
  if [ -d "$PROJECT_PATH/.next/server/pages" ]; then
    prerendered=$(find "$PROJECT_PATH/.next/server/pages" -name "*.html" 2>/dev/null | wc -l)
    echo -e "${GREEN}✓${NC} Prerendered: $prerendered static pages"
    ((PASS++))
  fi
elif [ -d "$PROJECT_PATH/dist" ]; then
  build_size=$(du -sh "$PROJECT_PATH/dist" 2>/dev/null | awk '{print $1}')
  echo -e "${GREEN}✓${NC} Build Output: dist directory ($build_size)"
  ((PASS++))
else
  echo -e "${YELLOW}!${NC} Build Output: No build directory found (run build)"
  ((WARN++))
fi

echo ""
echo "--- Middleware ---"

if [ -f "$PROJECT_PATH/middleware.ts" ] || [ -f "$PROJECT_PATH/middleware.js" ]; then
  echo -e "${GREEN}✓${NC} Middleware: File found"
  ((PASS++))
else
  echo -e "${YELLOW}!${NC} Middleware: No middleware configured"
  ((WARN++))
fi

echo ""
echo "--- Environment Configuration ---"

if [ -f "$PROJECT_PATH/.env.local" ]; then
  echo -e "${GREEN}✓${NC} Env: .env.local found"
  ((PASS++))
else
  if [ -f "$PROJECT_PATH/.env" ]; then
    echo -e "${GREEN}✓${NC} Env: .env found"
    ((PASS++))
  else
    echo -e "${YELLOW}!${NC} Env: No .env file found"
    ((WARN++))
  fi
fi

echo ""
echo "===================================="
echo "SSR/SSG Validation Summary"
echo "===================================="
echo -e "${GREEN}Passed:${NC} $PASS"
echo -e "${RED}Failed:${NC} $FAIL"
echo -e "${YELLOW}Warnings:${NC} $WARN"
echo ""

if [ $FAIL -eq 0 ]; then
  echo -e "${GREEN}✓ Framework validation passed!${NC}"
  exit 0
else
  echo -e "${RED}✗ Framework validation failed.${NC}"
  exit 1
fi
