#!/bin/bash
# Web Security Validation Script - Real checks for common vulnerabilities

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
echo "Web Security Validation"
echo "======================================"
echo ""

# ============================================================================
# XSS (Cross-Site Scripting) VULNERABILITY CHECKS
# ============================================================================
echo "--- XSS Vulnerability Patterns ---"

# Check for dangerous patterns
check_xss_patterns() {
  local pattern="$1"
  local description="$2"
  local files=$(find "$PROJECT_PATH" \( -name "*.jsx" -o -name "*.tsx" -o -name "*.js" -o -name "*.ts" \) 2>/dev/null | head -20)

  if [ -z "$files" ]; then
    echo -e "${YELLOW}!${NC} No JavaScript files found"
    ((WARN++))
    return
  fi

  if echo "$files" | xargs grep -l "$pattern" 2>/dev/null | grep -q .; then
    echo -e "${RED}✗${NC} XSS: $description found"
    ((FAIL++))
  else
    echo -e "${GREEN}✓${NC} XSS: No $description detected"
    ((PASS++))
  fi
}

check_xss_patterns "dangerouslySetInnerHTML" "dangerouslySetInnerHTML (potential XSS)"
check_xss_patterns "innerHTML\s*=" "innerHTML assignment (potential XSS)"
check_xss_patterns "eval(" "eval() usage (critical vulnerability)"
check_xss_patterns "Function(" "Function constructor (potential code injection)"

# Check for sanitization library usage
if [ -f "$PROJECT_PATH/package.json" ]; then
  if grep -q "dompurify\|sanitize-html\|xss" "$PROJECT_PATH/package.json"; then
    echo -e "${GREEN}✓${NC} XSS: Sanitization library installed"
    ((PASS++))
  else
    echo -e "${YELLOW}!${NC} XSS: No sanitization library found (warning)"
    ((WARN++))
  fi
fi

echo ""
echo "--- CSRF Protection ---"

# Check for CSRF token usage
csrf_found=0
if [ -d "$PROJECT_PATH/src" ]; then
  if find "$PROJECT_PATH/src" -type f \( -name "*.jsx" -o -name "*.tsx" -o -name "*.js" \) -exec grep -l "csrf\|CSRF" {} \; 2>/dev/null | grep -q .; then
    echo -e "${GREEN}✓${NC} CSRF: Token implementation found"
    ((PASS++))
    csrf_found=1
  fi
fi

# Check for cookie security in backend
if [ -f "$PROJECT_PATH/.env" ] || [ -f "$PROJECT_PATH/.env.example" ]; then
  if grep -q "SESSION_SECRET\|JWT_SECRET\|CSRF" "$PROJECT_PATH/.env" "$PROJECT_PATH/.env.example" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} CSRF: Session/JWT configuration found"
    ((PASS++))
  fi
fi

if [ $csrf_found -eq 0 ]; then
  echo -e "${YELLOW}!${NC} CSRF: No explicit CSRF token implementation found"
  ((WARN++))
fi

echo ""
echo "--- Content Security Policy (CSP) ---"

# Check HTML files for CSP headers
if find "$PROJECT_PATH" -name "*.html" 2>/dev/null | grep -q .; then
  html_files=$(find "$PROJECT_PATH" -name "*.html" -type f)
  if echo "$html_files" | xargs grep -l "Content-Security-Policy\|<meta.*http-equiv" 2>/dev/null | grep -q .; then
    echo -e "${GREEN}✓${NC} CSP: Found in HTML files"
    ((PASS++))
  else
    echo -e "${YELLOW}!${NC} CSP: Not found in HTML (check server headers)"
    ((WARN++))
  fi
fi

# Check for CSP in middleware/config
config_files=$(find "$PROJECT_PATH" -type f \( -name "*.js" -o -name "*.ts" -o -name "server.js" -o -name "next.config.js" \) 2>/dev/null | head -10)
if echo "$config_files" | xargs grep -l "Content-Security-Policy\|csp" 2>/dev/null | grep -q .; then
  echo -e "${GREEN}✓${NC} CSP: Server configuration found"
  ((PASS++))
else
  echo -e "${RED}✗${NC} CSP: No server CSP configuration found"
  ((FAIL++))
fi

echo ""
echo "--- HTTPS/TLS Requirement ---"

# Check for HTTPS enforcement
enforce_https=0
if [ -f "$PROJECT_PATH/next.config.js" ]; then
  if grep -q "https\|ssl" "$PROJECT_PATH/next.config.js"; then
    echo -e "${GREEN}✓${NC} HTTPS: Next.js HTTPS configuration found"
    ((PASS++))
    enforce_https=1
  fi
fi

if [ -f "$PROJECT_PATH/server.js" ] || [ -f "$PROJECT_PATH/index.js" ]; then
  server_file=$(find "$PROJECT_PATH" -maxdepth 1 \( -name "server.js" -o -name "index.js" \) -type f)
  if grep -q "https\|ssl\|tlsv1" "$server_file" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} HTTPS: HTTPS server configuration found"
    ((PASS++))
    enforce_https=1
  fi
fi

if [ -f "$PROJECT_PATH/.env" ] || [ -f "$PROJECT_PATH/.env.example" ]; then
  if grep -q "HTTPS\|SSL" "$PROJECT_PATH/.env" "$PROJECT_PATH/.env.example" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} HTTPS: HTTPS configuration in env"
    ((PASS++))
    enforce_https=1
  fi
fi

if [ $enforce_https -eq 0 ]; then
  echo -e "${RED}✗${NC} HTTPS: No HTTPS/SSL configuration found"
  ((FAIL++))
fi

echo ""
echo "--- Security Headers ---"

check_header() {
  local header="$1"
  local description="$2"

  config_files=$(find "$PROJECT_PATH" -type f \( -name "*.js" -o -name "*.ts" -o -name "next.config.js" -o -name "*.json" \) 2>/dev/null | head -15)

  if echo "$config_files" | xargs grep -l "$header" 2>/dev/null | grep -q .; then
    echo -e "${GREEN}✓${NC} Header: $description"
    ((PASS++))
  else
    echo -e "${YELLOW}!${NC} Header: $description not found"
    ((WARN++))
  fi
}

check_header "Strict-Transport-Security\|HSTS" "HSTS (HTTP Strict Transport Security)"
check_header "X-Frame-Options\|frame-ancestors" "X-Frame-Options (Clickjacking protection)"
check_header "X-Content-Type-Options\|nosniff" "X-Content-Type-Options"
check_header "Referrer-Policy" "Referrer-Policy"
check_header "Permissions-Policy\|Feature-Policy" "Permissions-Policy"

echo ""
echo "--- Secure Cookies ---"

# Check for secure cookie flags
if find "$PROJECT_PATH" \( -name "*.js" -o -name "*.ts" \) 2>/dev/null | xargs grep -l "cookie\|Cookie" 2>/dev/null | grep -q .; then
  cookie_files=$(find "$PROJECT_PATH" \( -name "*.js" -o -name "*.ts" \) 2>/dev/null | xargs grep -l "cookie\|Cookie" 2>/dev/null)

  if echo "$cookie_files" | xargs grep -l "HttpOnly\|httpOnly" 2>/dev/null | grep -q .; then
    echo -e "${GREEN}✓${NC} Cookies: HttpOnly flag set"
    ((PASS++))
  else
    echo -e "${RED}✗${NC} Cookies: HttpOnly flag missing"
    ((FAIL++))
  fi

  if echo "$cookie_files" | xargs grep -l "Secure\|secure" 2>/dev/null | grep -q .; then
    echo -e "${GREEN}✓${NC} Cookies: Secure flag set"
    ((PASS++))
  else
    echo -e "${YELLOW}!${NC} Cookies: Secure flag not found"
    ((WARN++))
  fi

  if echo "$cookie_files" | xargs grep -l "SameSite\|sameSite" 2>/dev/null | grep -q .; then
    echo -e "${GREEN}✓${NC} Cookies: SameSite flag set"
    ((PASS++))
  else
    echo -e "${RED}✗${NC} Cookies: SameSite flag missing"
    ((FAIL++))
  fi
fi

echo ""
echo "--- CORS Configuration ---"

# Check for CORS setup
if find "$PROJECT_PATH" \( -name "*.js" -o -name "*.ts" \) 2>/dev/null | xargs grep -l "cors\|CORS" 2>/dev/null | grep -q .; then
  cors_files=$(find "$PROJECT_PATH" \( -name "*.js" -o -name "*.ts" \) 2>/dev/null | xargs grep -l "cors\|CORS" 2>/dev/null)

  if echo "$cors_files" | xargs grep "cors.*origin\|allowedOrigins" 2>/dev/null | grep -qv "*"; then
    echo -e "${GREEN}✓${NC} CORS: Specific origins configured (not wildcard)"
    ((PASS++))
  else
    echo -e "${RED}✗${NC} CORS: Wildcard origin found (security risk)"
    ((FAIL++))
  fi
else
  echo -e "${YELLOW}!${NC} CORS: Configuration not found"
  ((WARN++))
fi

echo ""
echo "--- Dependency Vulnerabilities ---"

# Check package.json for audit
if [ -f "$PROJECT_PATH/package.json" ]; then
  echo -e "${GREEN}✓${NC} Dependencies: package.json found"
  ((PASS++))

  # Note about running audit
  echo -e "${YELLOW}ℹ${NC} Run 'npm audit' to check for vulnerabilities"
  echo -e "${YELLOW}ℹ${NC} Run 'npm audit fix' to auto-fix low/moderate issues"
else
  echo -e "${RED}✗${NC} Dependencies: No package.json found"
  ((FAIL++))
fi

echo ""
echo "--- Secrets Management ---"

# Check for hardcoded secrets
found_secrets=0
if find "$PROJECT_PATH/src" -type f \( -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" \) 2>/dev/null | \
   xargs grep -l "password\|secret\|token\|key" 2>/dev/null | grep -q .; then

  secret_files=$(find "$PROJECT_PATH/src" -type f \( -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" \) 2>/dev/null | \
   xargs grep -l "password.*=\|secret.*=\|token.*=" 2>/dev/null)

  if [ ! -z "$secret_files" ]; then
    echo -e "${RED}✗${NC} Secrets: Potential hardcoded secrets found"
    ((FAIL++))
    found_secrets=1
  fi
fi

# Check for .env file
if [ -f "$PROJECT_PATH/.env" ]; then
  echo -e "${GREEN}✓${NC} Secrets: .env file exists"
  ((PASS++))
else
  echo -e "${YELLOW}!${NC} Secrets: No .env file found (use environment variables)"
  ((WARN++))
fi

# Check .gitignore for .env
if [ -f "$PROJECT_PATH/.gitignore" ]; then
  if grep -q "\.env" "$PROJECT_PATH/.gitignore"; then
    echo -e "${GREEN}✓${NC} Secrets: .env in .gitignore"
    ((PASS++))
  else
    echo -e "${RED}✗${NC} Secrets: .env not in .gitignore"
    ((FAIL++))
  fi
else
  echo -e "${YELLOW}!${NC} Secrets: No .gitignore file"
  ((WARN++))
fi

echo ""
echo "======================================"
echo "Security Validation Summary"
echo "======================================"
echo -e "${GREEN}Passed:${NC} $PASS"
echo -e "${RED}Failed:${NC} $FAIL"
echo -e "${YELLOW}Warnings:${NC} $WARN"
echo ""

if [ $FAIL -eq 0 ]; then
  echo -e "${GREEN}✓ Security validation passed!${NC}"
  exit 0
else
  echo -e "${RED}✗ Security issues found. Fix errors above.${NC}"
  exit 1
fi
