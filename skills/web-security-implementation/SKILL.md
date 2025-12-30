---
name: web-security-implementation
description: Master CORS, XSS prevention, CSRF protection, CSP headers, and secure authentication patterns.
sasmp_version: "1.3.0"
version: "2.0.0"
bonded_agent: 07-advanced-topics-agent
bond_type: PRIMARY_BOND
category: security
tags: [security, xss, csrf, cors, csp, authentication, encryption]
complexity: advanced
estimated_time: 5-7 hours
prerequisites:
  - HTTP protocol understanding
  - Authentication concepts
  - Basic cryptography knowledge
  - Web browser security model
---

# Web Security Implementation

Build secure frontend applications with defense-in-depth strategies, secure authentication, and protection against common vulnerabilities.

## Input/Output Schema

### Input Requirements
```yaml
security_context:
  type: object
  required:
    - app_type: enum             # spa|mpa|ssr|static
    - authentication_method: enum # jwt|session|oauth|saml
    - api_endpoints: array        # Protected API URLs
    - sensitive_data_types: array # pii|financial|health|auth
  optional:
    - cors_origins: array         # Allowed origins
    - csp_directives: object      # CSP configuration
    - rate_limit_config: object   # Rate limiting rules
    - trusted_domains: array      # Whitelisted domains

vulnerability_scan:
  type: object
  required:
    - scan_type: enum            # static|dynamic|both
    - severity_threshold: enum    # critical|high|medium|low
  optional:
    - exclude_patterns: array     # Patterns to ignore
    - custom_rules: array         # Additional security rules
```

### Output Deliverables
```yaml
security_implementations:
  - XSS prevention middleware
  - CSRF token implementation
  - CSP header configuration
  - Secure cookie settings
  - Input validation schemas
  - Authentication guards

documentation:
  - Security audit report
  - Vulnerability assessment
  - Remediation guidelines
  - Security checklist

metrics:
  - OWASP compliance score: >85%
  - Zero critical vulnerabilities
  - Security headers grade: A+
  - Penetration test results: pass
```

## MANDATORY

### 1. XSS Prevention Techniques

#### Content Sanitization
```javascript
import DOMPurify from 'dompurify';

// Sanitize user input
function sanitizeHTML(dirty) {
  return DOMPurify.sanitize(dirty, {
    ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a'],
    ALLOWED_ATTR: ['href']
  });
}

// React example
function SafeComponent({ userContent }) {
  return (
    <div
      dangerouslySetInnerHTML={{
        __html: sanitizeHTML(userContent)
      }}
    />
  );
}
```

#### Output Encoding
```javascript
// HTML entity encoding
function escapeHTML(str) {
  const div = document.createElement('div');
  div.textContent = str;
  return div.innerHTML;
}

// JavaScript context encoding
function escapeJS(str) {
  return str
    .replace(/\\/g, '\\\\')
    .replace(/'/g, "\\'")
    .replace(/"/g, '\\"')
    .replace(/\n/g, '\\n')
    .replace(/\r/g, '\\r');
}

// URL encoding
function escapeURL(str) {
  return encodeURIComponent(str);
}
```

### 2. CORS Configuration

```javascript
// Backend: Express CORS configuration
const cors = require('cors');

app.use(cors({
  origin: function(origin, callback) {
    const allowedOrigins = [
      'https://app.example.com',
      'https://admin.example.com'
    ];

    if (!origin || allowedOrigins.indexOf(origin) !== -1) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  maxAge: 86400 // 24 hours
}));
```

```javascript
// Frontend: Fetch with credentials
fetch('https://api.example.com/data', {
  method: 'POST',
  credentials: 'include',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify(data)
});
```

### 3. CSRF Protection

```javascript
// Double Submit Cookie Pattern
class CSRFProtection {
  static generateToken() {
    return crypto.randomUUID();
  }

  static setToken() {
    const token = this.generateToken();

    // Set cookie
    document.cookie = `csrf_token=${token}; Secure; SameSite=Strict`;

    // Store in meta tag
    const meta = document.createElement('meta');
    meta.name = 'csrf-token';
    meta.content = token;
    document.head.appendChild(meta);

    return token;
  }

  static getToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content;
  }

  static validateRequest(request) {
    const token = this.getToken();
    request.headers.set('X-CSRF-Token', token);
    return request;
  }
}

// Usage with fetch
fetch('/api/data', {
  method: 'POST',
  headers: {
    'X-CSRF-Token': CSRFProtection.getToken(),
    'Content-Type': 'application/json'
  },
  body: JSON.stringify(data)
});
```

### 4. Input Validation and Sanitization

```javascript
// Input validation schema
const validationRules = {
  email: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
  phone: /^\+?[1-9]\d{1,14}$/,
  url: /^https?:\/\/.+/,
  alphanumeric: /^[a-zA-Z0-9]+$/
};

function validateInput(input, type) {
  const trimmed = input.trim();

  // Length validation
  if (trimmed.length === 0) {
    throw new Error('Input cannot be empty');
  }

  if (trimmed.length > 1000) {
    throw new Error('Input too long');
  }

  // Pattern validation
  if (validationRules[type] && !validationRules[type].test(trimmed)) {
    throw new Error(`Invalid ${type} format`);
  }

  // SQL injection prevention
  const sqlPatterns = /(\b(SELECT|INSERT|UPDATE|DELETE|DROP|UNION|ALTER)\b)/i;
  if (sqlPatterns.test(trimmed)) {
    throw new Error('Potentially malicious input detected');
  }

  return trimmed;
}

// Usage
try {
  const email = validateInput(userInput, 'email');
  // Process valid email
} catch (error) {
  console.error('Validation error:', error.message);
}
```

### 5. Secure Cookie Handling

```javascript
// Secure cookie configuration
function setSecureCookie(name, value, options = {}) {
  const defaults = {
    secure: true,           // HTTPS only
    httpOnly: true,         // Not accessible via JavaScript
    sameSite: 'Strict',     // CSRF protection
    maxAge: 3600,           // 1 hour
    path: '/',
    domain: undefined
  };

  const config = { ...defaults, ...options };

  let cookie = `${name}=${encodeURIComponent(value)}`;

  if (config.secure) cookie += '; Secure';
  if (config.httpOnly) cookie += '; HttpOnly';
  if (config.sameSite) cookie += `; SameSite=${config.sameSite}`;
  if (config.maxAge) cookie += `; Max-Age=${config.maxAge}`;
  if (config.path) cookie += `; Path=${config.path}`;
  if (config.domain) cookie += `; Domain=${config.domain}`;

  document.cookie = cookie;
}

// Usage
setSecureCookie('session_id', sessionToken, {
  maxAge: 86400,  // 24 hours
  sameSite: 'Lax'
});
```

### 6. HTTPS Enforcement

```javascript
// Redirect to HTTPS
if (location.protocol !== 'https:' && location.hostname !== 'localhost') {
  location.replace(`https:${location.href.substring(location.protocol.length)}`);
}

// Strict Transport Security header (backend)
app.use((req, res, next) => {
  res.setHeader(
    'Strict-Transport-Security',
    'max-age=31536000; includeSubDomains; preload'
  );
  next();
});
```

## OPTIONAL

### 1. Content Security Policy (CSP)

```javascript
// CSP Header Configuration
const cspDirectives = {
  'default-src': ["'self'"],
  'script-src': [
    "'self'",
    "'sha256-abc123...'",  // Inline script hash
    'https://cdn.trusted.com'
  ],
  'style-src': ["'self'", "'unsafe-inline'"],
  'img-src': ["'self'", 'data:', 'https:'],
  'font-src': ["'self'", 'https://fonts.gstatic.com'],
  'connect-src': ["'self'", 'https://api.example.com'],
  'frame-ancestors': ["'none'"],
  'base-uri': ["'self'"],
  'form-action': ["'self'"],
  'upgrade-insecure-requests': []
};

const cspHeader = Object.entries(cspDirectives)
  .map(([key, values]) => `${key} ${values.join(' ')}`)
  .join('; ');

// Set CSP header
res.setHeader('Content-Security-Policy', cspHeader);
```

```html
<!-- CSP Meta Tag (fallback) -->
<meta http-equiv="Content-Security-Policy"
      content="default-src 'self'; script-src 'self' https://cdn.trusted.com">
```

### 2. Security Headers Configuration

```javascript
// Comprehensive security headers
const securityHeaders = {
  'X-Content-Type-Options': 'nosniff',
  'X-Frame-Options': 'DENY',
  'X-XSS-Protection': '1; mode=block',
  'Referrer-Policy': 'strict-origin-when-cross-origin',
  'Permissions-Policy': 'geolocation=(), microphone=(), camera=()',
  'Strict-Transport-Security': 'max-age=31536000; includeSubDomains; preload'
};

// Apply all headers
Object.entries(securityHeaders).forEach(([header, value]) => {
  res.setHeader(header, value);
});
```

### 3. JWT Handling Best Practices

```javascript
// Secure JWT storage and handling
class SecureJWT {
  static store(token, refreshToken) {
    // Store access token in memory only
    this.accessToken = token;

    // Store refresh token in httpOnly cookie
    setSecureCookie('refresh_token', refreshToken, {
      httpOnly: true,
      secure: true,
      sameSite: 'Strict',
      maxAge: 604800 // 7 days
    });
  }

  static async refresh() {
    const response = await fetch('/api/auth/refresh', {
      method: 'POST',
      credentials: 'include' // Include refresh token cookie
    });

    const { accessToken } = await response.json();
    this.accessToken = accessToken;
    return accessToken;
  }

  static getToken() {
    return this.accessToken;
  }

  static clear() {
    this.accessToken = null;
    document.cookie = 'refresh_token=; Max-Age=0';
  }
}

// Auto-refresh on 401
async function authenticatedFetch(url, options = {}) {
  let response = await fetch(url, {
    ...options,
    headers: {
      ...options.headers,
      'Authorization': `Bearer ${SecureJWT.getToken()}`
    }
  });

  if (response.status === 401) {
    await SecureJWT.refresh();
    response = await fetch(url, {
      ...options,
      headers: {
        ...options.headers,
        'Authorization': `Bearer ${SecureJWT.getToken()}`
      }
    });
  }

  return response;
}
```

### 4. OAuth/OIDC Integration

```javascript
// OAuth 2.0 PKCE flow
class OAuth2PKCE {
  static async generateCodeVerifier() {
    const array = new Uint8Array(32);
    crypto.getRandomValues(array);
    return this.base64URLEncode(array);
  }

  static async generateCodeChallenge(verifier) {
    const encoder = new TextEncoder();
    const data = encoder.encode(verifier);
    const hash = await crypto.subtle.digest('SHA-256', data);
    return this.base64URLEncode(new Uint8Array(hash));
  }

  static base64URLEncode(buffer) {
    return btoa(String.fromCharCode(...buffer))
      .replace(/\+/g, '-')
      .replace(/\//g, '_')
      .replace(/=/g, '');
  }

  static async initiateLogin() {
    const verifier = await this.generateCodeVerifier();
    const challenge = await this.generateCodeChallenge(verifier);

    sessionStorage.setItem('code_verifier', verifier);

    const params = new URLSearchParams({
      client_id: 'your-client-id',
      redirect_uri: 'https://app.example.com/callback',
      response_type: 'code',
      scope: 'openid profile email',
      code_challenge: challenge,
      code_challenge_method: 'S256',
      state: crypto.randomUUID()
    });

    window.location.href = `https://auth.example.com/authorize?${params}`;
  }
}
```

### 5. Rate Limiting Awareness

```javascript
// Client-side rate limiting
class RateLimiter {
  constructor(maxRequests, windowMs) {
    this.maxRequests = maxRequests;
    this.windowMs = windowMs;
    this.requests = [];
  }

  async throttle(fn) {
    const now = Date.now();
    this.requests = this.requests.filter(time => now - time < this.windowMs);

    if (this.requests.length >= this.maxRequests) {
      const oldestRequest = this.requests[0];
      const waitTime = this.windowMs - (now - oldestRequest);

      await new Promise(resolve => setTimeout(resolve, waitTime));
      return this.throttle(fn);
    }

    this.requests.push(now);
    return fn();
  }
}

// Usage
const limiter = new RateLimiter(10, 60000); // 10 requests per minute

limiter.throttle(() => fetch('/api/data'));
```

### 6. Subresource Integrity (SRI)

```html
<!-- SRI for external scripts and styles -->
<script
  src="https://cdn.example.com/library.js"
  integrity="sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC"
  crossorigin="anonymous">
</script>

<link
  rel="stylesheet"
  href="https://cdn.example.com/styles.css"
  integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u"
  crossorigin="anonymous">
```

```javascript
// Generate SRI hash
const crypto = require('crypto');
const fs = require('fs');

function generateSRI(filePath) {
  const content = fs.readFileSync(filePath);
  const hash = crypto.createHash('sha384').update(content).digest('base64');
  return `sha384-${hash}`;
}
```

## ADVANCED

### 1. Penetration Testing Basics

```javascript
// Security testing checklist
const securityTests = {
  xss: [
    '<script>alert("XSS")</script>',
    '<img src=x onerror="alert(\'XSS\')">',
    'javascript:alert("XSS")',
    '<svg onload=alert("XSS")>'
  ],
  sqlInjection: [
    "' OR '1'='1",
    "1; DROP TABLE users--",
    "' UNION SELECT NULL--"
  ],
  pathTraversal: [
    '../../../etc/passwd',
    '....//....//etc/passwd'
  ]
};

async function runSecurityTests() {
  const results = [];

  for (const [type, payloads] of Object.entries(securityTests)) {
    for (const payload of payloads) {
      try {
        const response = await fetch('/api/test', {
          method: 'POST',
          body: JSON.stringify({ input: payload })
        });

        const text = await response.text();

        if (text.includes(payload)) {
          results.push({
            type,
            payload,
            vulnerable: true,
            severity: 'high'
          });
        }
      } catch (error) {
        // Request blocked - good!
      }
    }
  }

  return results;
}
```

### 2. Security Audit Automation

```javascript
// Automated security checks
async function auditSecurity() {
  const audit = {
    headers: await checkSecurityHeaders(),
    cookies: await checkCookieSecurity(),
    csp: await checkCSP(),
    dependencies: await checkDependencies(),
    secrets: await checkForSecrets()
  };

  return audit;
}

async function checkSecurityHeaders() {
  const response = await fetch(window.location.href);
  const requiredHeaders = [
    'Strict-Transport-Security',
    'X-Content-Type-Options',
    'X-Frame-Options',
    'Content-Security-Policy'
  ];

  return requiredHeaders.map(header => ({
    header,
    present: response.headers.has(header),
    value: response.headers.get(header)
  }));
}

async function checkCookieSecurity() {
  const cookies = document.cookie.split(';');

  return cookies.map(cookie => {
    const [name] = cookie.trim().split('=');
    return {
      name,
      secure: cookie.includes('Secure'),
      httpOnly: cookie.includes('HttpOnly'),
      sameSite: cookie.match(/SameSite=(\w+)/)?.[1]
    };
  });
}
```

### 3. Zero-Trust Architecture

```javascript
// Zero-trust implementation
class ZeroTrustAuth {
  static async verifyRequest(request) {
    // 1. Verify device fingerprint
    const deviceId = await this.getDeviceFingerprint();

    // 2. Verify user session
    const sessionValid = await this.validateSession();

    // 3. Verify request context
    const contextValid = this.verifyContext(request);

    // 4. Check permissions
    const hasPermission = await this.checkPermissions(request.resource);

    return deviceId && sessionValid && contextValid && hasPermission;
  }

  static async getDeviceFingerprint() {
    const components = {
      userAgent: navigator.userAgent,
      language: navigator.language,
      timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
      screen: `${screen.width}x${screen.height}`,
      plugins: Array.from(navigator.plugins).map(p => p.name).sort()
    };

    const fingerprint = JSON.stringify(components);
    const hash = await crypto.subtle.digest(
      'SHA-256',
      new TextEncoder().encode(fingerprint)
    );

    return btoa(String.fromCharCode(...new Uint8Array(hash)));
  }

  static verifyContext(request) {
    // Check request origin
    if (request.origin !== window.location.origin) {
      return false;
    }

    // Check referrer
    if (!document.referrer.startsWith(window.location.origin)) {
      return false;
    }

    return true;
  }
}
```

### 4. WebAuthn/Passkeys

```javascript
// WebAuthn implementation
class WebAuthnAuth {
  static async register() {
    const challenge = await this.getChallenge();

    const publicKeyCredential = await navigator.credentials.create({
      publicKey: {
        challenge: Uint8Array.from(challenge, c => c.charCodeAt(0)),
        rp: {
          name: 'Example App',
          id: 'example.com'
        },
        user: {
          id: Uint8Array.from('user-id', c => c.charCodeAt(0)),
          name: 'user@example.com',
          displayName: 'User Name'
        },
        pubKeyCredParams: [
          { alg: -7, type: 'public-key' },  // ES256
          { alg: -257, type: 'public-key' } // RS256
        ],
        authenticatorSelection: {
          authenticatorAttachment: 'platform',
          requireResidentKey: true,
          userVerification: 'required'
        },
        timeout: 60000
      }
    });

    return publicKeyCredential;
  }

  static async authenticate() {
    const challenge = await this.getChallenge();

    const assertion = await navigator.credentials.get({
      publicKey: {
        challenge: Uint8Array.from(challenge, c => c.charCodeAt(0)),
        timeout: 60000,
        userVerification: 'required'
      }
    });

    return assertion;
  }
}
```

### 5. Secure iframe Communication

```javascript
// Secure postMessage implementation
class SecureMessaging {
  static allowedOrigins = ['https://trusted.example.com'];

  static send(target, message, origin) {
    if (!this.allowedOrigins.includes(origin)) {
      throw new Error('Untrusted origin');
    }

    const nonce = crypto.randomUUID();
    const timestamp = Date.now();

    target.postMessage(
      {
        ...message,
        nonce,
        timestamp
      },
      origin
    );
  }

  static listen(callback) {
    window.addEventListener('message', (event) => {
      // Verify origin
      if (!this.allowedOrigins.includes(event.origin)) {
        console.warn('Message from untrusted origin:', event.origin);
        return;
      }

      // Verify message structure
      if (!event.data.nonce || !event.data.timestamp) {
        console.warn('Invalid message structure');
        return;
      }

      // Check timestamp (prevent replay attacks)
      const age = Date.now() - event.data.timestamp;
      if (age > 60000) { // 1 minute
        console.warn('Message too old');
        return;
      }

      callback(event.data);
    });
  }
}
```

### 6. Supply Chain Security

```javascript
// Package integrity verification
const expectedHashes = {
  'react': 'sha384-abc123...',
  'react-dom': 'sha384-def456...'
};

async function verifyPackageIntegrity(packageName, filePath) {
  const content = await fs.promises.readFile(filePath);
  const hash = crypto.createHash('sha384').update(content).digest('base64');
  const integrity = `sha384-${hash}`;

  if (expectedHashes[packageName] !== integrity) {
    throw new Error(`Package ${packageName} integrity check failed`);
  }
}
```

## Error Handling

| Error Type | Cause | Solution | Recovery Strategy |
|-----------|-------|----------|-------------------|
| `CORS Error` | Origin not whitelisted | Add origin to CORS config | Use proxy in development |
| `CSP Violation` | Blocked resource | Update CSP directives | Use nonces/hashes for inline scripts |
| `Invalid CSRF Token` | Token mismatch/expired | Regenerate token | Refresh page and retry |
| `XSS Attempt Detected` | Malicious input | Sanitize input | Block request, log incident |
| `Authentication Failed` | Invalid credentials | Verify credentials | Prompt for re-login |
| `Token Expired` | JWT/session expired | Refresh token | Auto-refresh or re-authenticate |
| `Rate Limit Exceeded` | Too many requests | Implement backoff | Queue requests, retry later |
| `Insecure Context` | HTTP instead of HTTPS | Enforce HTTPS | Redirect to HTTPS |
| `Permission Denied` | Insufficient privileges | Check permissions | Request elevated access |
| `Validation Error` | Invalid input format | Display error message | Provide input guidance |

### Error Handling Implementation
```javascript
// Global error handler
class SecurityErrorHandler {
  static handle(error, context) {
    const errorMap = {
      'CORS_ERROR': this.handleCORSError,
      'CSP_VIOLATION': this.handleCSPViolation,
      'XSS_ATTEMPT': this.handleXSSAttempt,
      'AUTH_FAILED': this.handleAuthError,
      'RATE_LIMIT': this.handleRateLimit
    };

    const handler = errorMap[error.type] || this.handleGenericError;
    handler.call(this, error, context);

    // Log to security monitoring
    this.logSecurityEvent(error, context);
  }

  static handleCORSError(error, context) {
    console.error('CORS error:', error);

    if (context.isDevelopment) {
      alert('CORS error - check server configuration');
    }

    // Fallback to proxy
    context.useProxy = true;
  }

  static handleCSPViolation(error, context) {
    // Report CSP violation
    fetch('/api/security/csp-report', {
      method: 'POST',
      body: JSON.stringify({
        violation: error.violatedDirective,
        blockedURI: error.blockedURI,
        sourceFile: error.sourceFile
      })
    });
  }

  static handleXSSAttempt(error, context) {
    // Block request
    throw new Error('Request blocked for security reasons');
  }

  static logSecurityEvent(error, context) {
    const event = {
      timestamp: new Date().toISOString(),
      type: error.type,
      message: error.message,
      context,
      userAgent: navigator.userAgent,
      url: window.location.href
    };

    // Send to security monitoring service
    navigator.sendBeacon('/api/security/log', JSON.stringify(event));
  }
}

// CSP violation reporting
document.addEventListener('securitypolicyviolation', (e) => {
  SecurityErrorHandler.handle({
    type: 'CSP_VIOLATION',
    violatedDirective: e.violatedDirective,
    blockedURI: e.blockedURI,
    sourceFile: e.sourceFile
  }, {});
});
```

## Test Templates

### Security Unit Tests
```javascript
describe('XSS Prevention', () => {
  it('should sanitize script tags', () => {
    const malicious = '<script>alert("XSS")</script>';
    const sanitized = sanitizeHTML(malicious);

    expect(sanitized).not.toContain('<script>');
    expect(sanitized).not.toContain('alert');
  });

  it('should escape HTML entities', () => {
    const input = '<img src=x onerror="alert(1)">';
    const escaped = escapeHTML(input);

    expect(escaped).toBe('&lt;img src=x onerror="alert(1)"&gt;');
  });

  it('should allow safe HTML tags', () => {
    const safe = '<strong>Bold text</strong>';
    const sanitized = sanitizeHTML(safe);

    expect(sanitized).toContain('<strong>');
  });
});

describe('CSRF Protection', () => {
  it('should generate unique tokens', () => {
    const token1 = CSRFProtection.generateToken();
    const token2 = CSRFProtection.generateToken();

    expect(token1).not.toBe(token2);
  });

  it('should include CSRF token in requests', () => {
    const token = 'test-token';
    CSRFProtection.setToken();

    const request = new Request('/api/test');
    const validatedRequest = CSRFProtection.validateRequest(request);

    expect(validatedRequest.headers.get('X-CSRF-Token')).toBeTruthy();
  });
});

describe('Input Validation', () => {
  it('should reject SQL injection attempts', () => {
    const malicious = "' OR '1'='1";

    expect(() => validateInput(malicious, 'text'))
      .toThrow('Potentially malicious input detected');
  });

  it('should validate email format', () => {
    expect(() => validateInput('invalid-email', 'email'))
      .toThrow('Invalid email format');

    expect(validateInput('valid@email.com', 'email'))
      .toBe('valid@email.com');
  });
});
```

### Integration Tests
```javascript
describe('Security Headers', () => {
  it('should set all security headers', async () => {
    const response = await fetch('/');

    expect(response.headers.get('X-Content-Type-Options')).toBe('nosniff');
    expect(response.headers.get('X-Frame-Options')).toBe('DENY');
    expect(response.headers.get('Strict-Transport-Security')).toContain('max-age');
    expect(response.headers.get('Content-Security-Policy')).toBeTruthy();
  });
});

describe('Authentication Flow', () => {
  it('should require authentication for protected routes', async () => {
    const response = await fetch('/api/protected');

    expect(response.status).toBe(401);
  });

  it('should accept valid JWT token', async () => {
    const token = await login('user', 'password');

    const response = await fetch('/api/protected', {
      headers: { 'Authorization': `Bearer ${token}` }
    });

    expect(response.status).toBe(200);
  });
});
```

### E2E Security Tests (Playwright)
```javascript
test('should prevent XSS attacks', async ({ page }) => {
  await page.goto('/');

  const xssPayload = '<script>window.XSS_EXECUTED=true</script>';
  await page.fill('#user-input', xssPayload);
  await page.click('#submit');

  // Check that script was not executed
  const xssExecuted = await page.evaluate(() => window.XSS_EXECUTED);
  expect(xssExecuted).toBeUndefined();
});

test('should enforce HTTPS', async ({ page, context }) => {
  await page.goto('http://example.com');

  // Should redirect to HTTPS
  expect(page.url()).toContain('https://');
});

test('should validate CSRF protection', async ({ page }) => {
  await page.goto('/');

  // Try to submit form without CSRF token
  await page.evaluate(() => {
    document.querySelector('meta[name="csrf-token"]')?.remove();
  });

  await page.click('#submit-form');

  // Should be blocked
  await expect(page.locator('.error-message')).toContainText('CSRF');
});
```

### Penetration Testing
```bash
# OWASP ZAP automated scan
zap-cli quick-scan --self-contained \
  --start-options '-config api.disablekey=true' \
  https://app.example.com

# Security headers check
curl -I https://app.example.com | grep -E "(X-Frame|X-Content|CSP|HSTS)"

# SSL/TLS configuration test
testssl.sh --parallel --severity MEDIUM https://app.example.com
```

## Best Practices

### Defense in Depth
- Implement multiple layers of security
- Never trust user input
- Validate on both client and server
- Use principle of least privilege
- Fail securely (deny by default)

### Authentication & Authorization
- Use secure session management
- Implement multi-factor authentication
- Store passwords with bcrypt/argon2
- Rotate credentials regularly
- Implement account lockout policies

### Data Protection
- Encrypt sensitive data at rest
- Use TLS 1.3 for data in transit
- Implement proper key management
- Sanitize data before storage
- Regular security audits

### Code Security
- Keep dependencies updated
- Use security linters (ESLint, Semgrep)
- Conduct code reviews
- Implement security testing in CI/CD
- Follow OWASP guidelines

### Monitoring & Incident Response
- Log security events
- Monitor for anomalies
- Set up alerts for suspicious activity
- Have incident response plan
- Regular security training

## Production Configuration

### Security Headers (Nginx)
```nginx
# Security headers
add_header X-Frame-Options "DENY" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline';" always;
add_header Permissions-Policy "geolocation=(), microphone=(), camera=()" always;

# CORS configuration
if ($request_method = 'OPTIONS') {
    add_header 'Access-Control-Allow-Origin' 'https://app.example.com';
    add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
    add_header 'Access-Control-Allow-Headers' 'Authorization, Content-Type';
    add_header 'Access-Control-Max-Age' 86400;
    return 204;
}
```

### Environment Variables
```bash
# .env.production
NODE_ENV=production
SECURE_COOKIES=true
SESSION_SECRET=your-secret-key-min-32-chars
JWT_SECRET=your-jwt-secret-key
CORS_ORIGIN=https://app.example.com
CSP_REPORT_URI=/api/csp-report
RATE_LIMIT_WINDOW=900000
RATE_LIMIT_MAX=100
```

### Webpack Security Plugin
```javascript
const CspHtmlWebpackPlugin = require('csp-html-webpack-plugin');

module.exports = {
  plugins: [
    new CspHtmlWebpackPlugin({
      'default-src': "'self'",
      'script-src': ["'self'"],
      'style-src': ["'self'", "'unsafe-inline'"]
    })
  ]
};
```

### Security Monitoring
```javascript
// Sentry security monitoring
import * as Sentry from '@sentry/browser';

Sentry.init({
  dsn: 'your-dsn',
  integrations: [
    new Sentry.BrowserTracing(),
    new Sentry.Replay()
  ],
  beforeSend(event, hint) {
    // Filter sensitive data
    if (event.request?.headers?.Authorization) {
      delete event.request.headers.Authorization;
    }
    return event;
  }
});
```

## Assets
- See `assets/web-security-config.yaml` for security configurations

## Resources
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Web Security](https://developer.mozilla.org/en-US/docs/Web/Security)
- [Content Security Policy](https://content-security-policy.com/)
- [Security Headers](https://securityheaders.com/)
- [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/)

---
**Status:** Active | **Version:** 2.0.0 | **Complexity:** Advanced | **Estimated Time:** 5-7 hours
