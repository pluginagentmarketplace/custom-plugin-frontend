#!/bin/bash
# PWA Validation Script - Real checks for production-ready PWAs
# Validates manifest.json, service workers, caching strategies, offline support

set -e

PROJECT_PATH="${1:-.}"
PASS=0
FAIL=0
WARN=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "================================"
echo "PWA Validation Check"
echo "================================"
echo ""

# Function to check files
check_file() {
    local file="$1"
    local description="$2"

    if [ -f "$PROJECT_PATH/$file" ]; then
        echo -e "${GREEN}✓${NC} $description: $file"
        ((PASS++))
        return 0
    else
        echo -e "${RED}✗${NC} $description: $file (NOT FOUND)"
        ((FAIL++))
        return 1
    fi
}

# Function to check directory
check_dir() {
    local dir="$1"
    local description="$2"

    if [ -d "$PROJECT_PATH/$dir" ]; then
        echo -e "${GREEN}✓${NC} $description: $dir"
        ((PASS++))
        return 0
    else
        echo -e "${YELLOW}!${NC} $description: $dir (not found)"
        ((WARN++))
        return 1
    fi
}

# Function to validate JSON
validate_json() {
    local file="$1"
    if command -v jq &> /dev/null; then
        if jq empty "$file" 2>/dev/null; then
            return 0
        else
            return 1
        fi
    fi
    return 0
}

# Function to check for string in file
check_content() {
    local file="$1"
    local pattern="$2"
    local description="$3"

    if [ ! -f "$PROJECT_PATH/$file" ]; then
        echo -e "${YELLOW}!${NC} $description: File not found - $file"
        ((WARN++))
        return 1
    fi

    if grep -q "$pattern" "$PROJECT_PATH/$file" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} $description"
        ((PASS++))
        return 0
    else
        echo -e "${RED}✗${NC} $description"
        ((FAIL++))
        return 1
    fi
}

echo "--- Basic Files ---"
check_file "public/manifest.json" "Web App Manifest"
check_file "public/offline.html" "Offline Fallback Page"
check_file "src/sw.js" "Service Worker"

echo ""
echo "--- Manifest Validation ---"
if [ -f "$PROJECT_PATH/public/manifest.json" ]; then
    manifest="$PROJECT_PATH/public/manifest.json"

    # Check required fields using grep
    grep -q '"name"' "$manifest" && echo -e "${GREEN}✓${NC} Manifest: name field" || echo -e "${RED}✗${NC} Manifest: missing name"
    grep -q '"short_name"' "$manifest" && echo -e "${GREEN}✓${NC} Manifest: short_name field" || echo -e "${RED}✗${NC} Manifest: missing short_name"
    grep -q '"start_url"' "$manifest" && echo -e "${GREEN}✓${NC} Manifest: start_url field" || echo -e "${RED}✗${NC} Manifest: missing start_url"
    grep -q '"display"' "$manifest" && echo -e "${GREEN}✓${NC} Manifest: display field" || echo -e "${RED}✗${NC} Manifest: missing display"
    grep -q '"background_color"' "$manifest" && echo -e "${GREEN}✓${NC} Manifest: background_color field" || echo -e "${RED}✗${NC} Manifest: missing background_color"
    grep -q '"theme_color"' "$manifest" && echo -e "${GREEN}✓${NC} Manifest: theme_color field" || echo -e "${RED}✗${NC} Manifest: missing theme_color"
    grep -q '"icons"' "$manifest" && echo -e "${GREEN}✓${NC} Manifest: icons array" || echo -e "${RED}✗${NC} Manifest: missing icons array"

    # Check JSON validity
    if validate_json "$manifest"; then
        echo -e "${GREEN}✓${NC} Manifest: valid JSON"
        ((PASS++))
    else
        echo -e "${RED}✗${NC} Manifest: invalid JSON syntax"
        ((FAIL++))
    fi
fi

echo ""
echo "--- Service Worker Registration ---"
check_content "src/index.js" "serviceWorker" "Service Worker registration in main entry point" || \
check_content "src/main.ts" "serviceWorker" "Service Worker registration in main entry point" || \
check_content "src/main.tsx" "serviceWorker" "Service Worker registration in main entry point" || \
check_content "public/index.html" "sw.js" "Service Worker registration in HTML" || \
echo -e "${YELLOW}!${NC} Service Worker registration not found (warn)"

echo ""
echo "--- Service Worker Features ---"
if [ -f "$PROJECT_PATH/src/sw.js" ]; then
    sw="$PROJECT_PATH/src/sw.js"

    echo "Checking caching strategies..."
    grep -q "cache\.open" "$sw" && echo -e "${GREEN}✓${NC} Service Worker: has cache operations" || echo -e "${YELLOW}!${NC} Service Worker: no explicit cache operations"

    grep -q "cache-first\|cacheFirst" "$sw" && echo -e "${GREEN}✓${NC} Service Worker: cache-first strategy" || echo -e "${YELLOW}!${NC} Service Worker: no cache-first strategy"
    grep -q "network-first\|networkFirst" "$sw" && echo -e "${GREEN}✓${NC} Service Worker: network-first strategy" || echo -e "${YELLOW}!${NC} Service Worker: no network-first strategy"
    grep -q "stale-while-revalidate\|staleWhileRevalidate" "$sw" && echo -e "${GREEN}✓${NC} Service Worker: stale-while-revalidate strategy" || echo -e "${YELLOW}!${NC} Service Worker: no stale-while-revalidate strategy"

    echo "Checking lifecycle events..."
    grep -q "install" "$sw" && echo -e "${GREEN}✓${NC} Service Worker: install event" || echo -e "${RED}✗${NC} Service Worker: missing install event"
    grep -q "activate" "$sw" && echo -e "${GREEN}✓${NC} Service Worker: activate event" || echo -e "${RED}✗${NC} Service Worker: missing activate event"
    grep -q "fetch" "$sw" && echo -e "${GREEN}✓${NC} Service Worker: fetch event" || echo -e "${RED}✗${NC} Service Worker: missing fetch event"
fi

echo ""
echo "--- Offline Support ---"
if [ -f "$PROJECT_PATH/public/offline.html" ]; then
    offline="$PROJECT_PATH/public/offline.html"
    echo -e "${GREEN}✓${NC} Offline page exists"
    grep -q "<!DOCTYPE" "$offline" && echo -e "${GREEN}✓${NC} Offline page: valid HTML structure" || echo -e "${YELLOW}!${NC} Offline page: may not be valid HTML"
else
    echo -e "${RED}✗${NC} No offline.html found"
    ((FAIL++))
fi

echo ""
echo "--- HTTPS & Security ---"
check_content "package.json" "https\|ssl" "HTTPS/SSL configuration" || \
echo -e "${YELLOW}!${NC} HTTPS configuration not found in package.json (may be in server config)"

echo ""
echo "--- Installation Support ---"
check_content "src/index.js" "install\|beforeinstallprompt" "Install prompt handling" || \
check_content "src/main.ts" "install\|beforeinstallprompt" "Install prompt handling" || \
check_content "src/App.tsx" "install\|beforeinstallprompt" "Install prompt handling" || \
check_content "src/App.jsx" "install\|beforeinstallprompt" "Install prompt handling" || \
echo -e "${YELLOW}!${NC} Install prompt handling not found"

echo ""
echo "--- Icons & Assets ---"
icons_dir="$PROJECT_PATH/public"
if [ -d "$icons_dir" ]; then
    icon_count=$(find "$icons_dir" -name "*.png" -o -name "*.jpg" -o -name "*.webp" 2>/dev/null | wc -l)
    if [ "$icon_count" -gt 0 ]; then
        echo -e "${GREEN}✓${NC} Icon assets: found $icon_count image files"
        ((PASS++))
    else
        echo -e "${YELLOW}!${NC} Icon assets: no images found"
        ((WARN++))
    fi
fi

echo ""
echo "--- Cache Management ---"
check_content "src/sw.js" "cache.*delete\|skipWaiting\|clients.claim" "Cache versioning/cleanup" || \
echo -e "${YELLOW}!${NC} No explicit cache management found"

echo ""
echo "================================"
echo "Validation Summary"
echo "================================"
echo -e "${GREEN}Passed:${NC} $PASS"
echo -e "${RED}Failed:${NC} $FAIL"
echo -e "${YELLOW}Warnings:${NC} $WARN"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}✓ PWA validation passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ PWA validation failed. Fix errors above.${NC}"
    exit 1
fi
