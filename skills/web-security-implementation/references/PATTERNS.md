# Web Security Implementation Patterns

Enterprise-level security patterns and real-world implementations for production applications.

## XSS Prevention Patterns

### Pattern 1: Layered XSS Prevention

Implement multiple layers of XSS defense:

```javascript
// Layer 1: Input Validation
const validateUserInput = (input) => {
  if (typeof input !== 'string') return null;
  if (input.length > 1000) return null;
  if (/<script|javascript:|on\w+\s*=/i.test(input)) return null;
  return input;
};

// Layer 2: Sanitization
const DOMPurify = require('isomorphic-dompurify');
const sanitizeInput = (input) => {
  return DOMPurify.sanitize(input, {
    ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a', 'p'],
    ALLOWED_ATTR: ['href', 'title'],
    KEEP_CONTENT: true
  });
};

// Layer 3: Output Encoding
const escapeHtml = (text) => {
  const map = {
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#039;'
  };
  return text.replace(/[&<>"']/g, (m) => map[m]);
};

// Layer 4: CSP Header
const cspHeader = "default-src 'self'; script-src 'self'; style-src 'self'";

// Usage
app.use((req, res, next) => {
  res.setHeader('Content-Security-Policy', cspHeader);
  next();
});

app.post('/comment', (req, res) => {
  let input = req.body.comment;

  // Apply all layers
  input = validateUserInput(input);
  if (!input) return res.status(400).json({ error: 'Invalid input' });

  input = sanitizeInput(input);
  input = escapeHtml(input);

  // Safe to store and display
  db.comments.insert({ text: input });
  res.json({ success: true });
});
```

### Pattern 2: Content Encoding by Context

Encode output differently based on context:

```javascript
class XSSProtection {
  // HTML context - encode for HTML
  encodeHtml(str) {
    const div = document.createElement('div');
    div.textContent = str;
    return div.innerHTML;
  }

  // JavaScript context - encode for JS strings
  encodeJs(str) {
    return str
      .replace(/\\/g, '\\\\')
      .replace(/"/g, '\\"')
      .replace(/'/g, "\\'")
      .replace(/\n/g, '\\n')
      .replace(/\r/g, '\\r');
  }

  // URL context - encode for URLs
  encodeUrl(str) {
    return encodeURIComponent(str);
  }

  // CSS context - encode for CSS values
  encodeCss(str) {
    return str.replace(/[^a-zA-Z0-9]/g, (c) => '\\' + c.charCodeAt(0));
  }

  // JSON context - encode for JSON strings
  encodeJson(str) {
    return JSON.stringify(str);
  }
}

// Usage in templates
const protection = new XSSProtection();

app.get('/profile/:username', (req, res) => {
  const username = protection.encodeHtml(req.params.username);

  const page = `
    <div>
      <h1>${username}</h1>
      <script>
        // Safe JavaScript context
        const user = "${protection.encodeJs(req.params.username)}";
      </script>
    </div>
  `;

  res.send(page);
});
```

## CSRF Protection Patterns

### Pattern 1: Double-Submit Cookie CSRF

Two-token approach using cookies and headers:

```javascript
const crypto = require('crypto');

class CsrfTokenManager {
  generateToken() {
    return crypto.randomBytes(32).toString('hex');
  }

  // Generate token and set in cookie
  setTokenCookie(res, token) {
    res.cookie('XSRF-TOKEN', token, {
      httpOnly: false, // Accessible to JavaScript
      secure: true,
      sameSite: 'strict',
      maxAge: 3600000
    });
  }

  // Generate session token
  setSessionToken(req, token) {
    req.session.csrfToken = token;
  }

  // Verify tokens match
  verifyTokens(reqToken, sessionToken, cookieToken) {
    return reqToken === sessionToken && reqToken === cookieToken;
  }
}

// Middleware to add CSRF token to responses
app.use((req, res, next) => {
  const csrfManager = new CsrfTokenManager();

  if (!req.session.csrfToken) {
    req.session.csrfToken = csrfManager.generateToken();
    const token = req.session.csrfToken;
    csrfManager.setTokenCookie(res, token);
  }

  res.locals.csrfToken = req.session.csrfToken;
  next();
});

// Middleware to verify CSRF token on state-changing requests
const verifyCsrfToken = (req, res, next) => {
  const csrfManager = new CsrfTokenManager();

  const token = req.get('X-CSRF-Token') || req.body._csrf;
  const sessionToken = req.session.csrfToken;
  const cookieToken = req.cookies['XSRF-TOKEN'];

  if (!csrfManager.verifyTokens(token, sessionToken, cookieToken)) {
    return res.status(403).json({ error: 'CSRF token invalid' });
  }

  next();
};

// Protect state-changing endpoints
app.post('/api/update', verifyCsrfToken, (req, res) => {
  // Safe from CSRF attacks
  res.json({ success: true });
});
```

### Pattern 2: Synchronizer Token Pattern

Server generates unique token for each form:

```javascript
class TokenStore {
  constructor() {
    this.tokens = new Map();
  }

  generateToken(userId) {
    const token = crypto.randomBytes(32).toString('hex');
    const expiry = Date.now() + 3600000; // 1 hour

    if (!this.tokens.has(userId)) {
      this.tokens.set(userId, []);
    }

    this.tokens.get(userId).push({ token, expiry, used: false });

    // Clean up expired tokens
    this.cleanupExpiredTokens(userId);

    return token;
  }

  validateToken(userId, token) {
    if (!this.tokens.has(userId)) return false;

    const userTokens = this.tokens.get(userId);
    const tokenObj = userTokens.find((t) => t.token === token);

    if (!tokenObj) return false;
    if (tokenObj.used) return false; // Prevent token reuse
    if (tokenObj.expiry < Date.now()) return false; // Token expired

    tokenObj.used = true;
    return true;
  }

  cleanupExpiredTokens(userId) {
    if (!this.tokens.has(userId)) return;

    const userTokens = this.tokens.get(userId);
    const validTokens = userTokens.filter((t) => t.expiry > Date.now());
    this.tokens.set(userId, validTokens);
  }
}

const tokenStore = new TokenStore();

// GET form with token
app.get('/form', (req, res) => {
  const token = tokenStore.generateToken(req.user.id);
  res.send(`
    <form method="POST" action="/submit">
      <input type="hidden" name="token" value="${token}">
      <input type="text" name="data">
      <button type="submit">Submit</button>
    </form>
  `);
});

// POST verify token
app.post('/submit', (req, res) => {
  const isValid = tokenStore.validateToken(req.user.id, req.body.token);

  if (!isValid) {
    return res.status(403).json({ error: 'Invalid or expired token' });
  }

  // Process form safely
  res.json({ success: true });
});
```

## Secure Session Management

### Pattern: Secure Session with Regeneration

```javascript
const session = require('express-session');
const RedisStore = require('connect-redis').default;
const { createClient } = require('redis');

// Redis client for session store
const redisClient = createClient({
  host: process.env.REDIS_HOST,
  port: process.env.REDIS_PORT,
  password: process.env.REDIS_PASSWORD
});

const sessionConfig = {
  store: new RedisStore({ client: redisClient }),

  secret: process.env.SESSION_SECRET,
  resave: false,
  saveUninitialized: false,

  cookie: {
    secure: process.env.NODE_ENV === 'production', // HTTPS only
    httpOnly: true, // No JavaScript access
    sameSite: 'strict', // CSRF protection
    maxAge: 1000 * 60 * 60 * 24 // 24 hours
  },

  // Generate secure session ID
  genid: () => {
    return crypto.randomBytes(16).toString('hex');
  }
};

app.use(session(sessionConfig));

// Regenerate session on login
app.post('/login', async (req, res) => {
  const user = await authenticateUser(req.body.email, req.body.password);

  if (!user) {
    return res.status(401).json({ error: 'Invalid credentials' });
  }

  // Destroy old session and create new one
  req.session.regenerate((err) => {
    if (err) return res.status(500).json({ error: 'Session error' });

    req.session.userId = user.id;
    req.session.role = user.role;
    req.session.loginTime = Date.now();

    res.json({ success: true, redirect: '/dashboard' });
  });
});

// Destroy session on logout
app.post('/logout', (req, res) => {
  req.session.destroy((err) => {
    if (err) return res.status(500).json({ error: 'Logout failed' });

    res.clearCookie('connect.sid');
    res.json({ success: true });
  });
});

// Session timeout check
app.use((req, res, next) => {
  if (req.session && req.session.loginTime) {
    const sessionAge = Date.now() - req.session.loginTime;
    const maxAge = 1000 * 60 * 60 * 24; // 24 hours

    if (sessionAge > maxAge) {
      req.session.destroy();
      return res.status(401).json({ error: 'Session expired' });
    }
  }

  next();
});
```

## Dependency Management Pattern

### Pattern: Automated Vulnerability Management

```javascript
// package.json script
{
  "scripts": {
    "security:audit": "npm audit --json > audit.json",
    "security:check": "npm audit --audit-level=moderate",
    "security:fix": "npm audit fix --audit-level=moderate",
    "security:update": "npm update && npm audit fix"
  }
}

// CI/CD integration
class SecurityCheck {
  async runAudit() {
    const { execSync } = require('child_process');

    try {
      execSync('npm audit --audit-level=moderate', {
        stdio: 'inherit'
      });
      console.log('✓ Security check passed');
      return true;
    } catch (error) {
      console.error('✗ Security vulnerabilities found');
      return false;
    }
  }

  async updateDependencies() {
    const { execSync } = require('child_process');

    console.log('Updating dependencies...');
    execSync('npm update', { stdio: 'inherit' });

    console.log('Auto-fixing vulnerabilities...');
    execSync('npm audit fix --audit-level=moderate', {
      stdio: 'inherit'
    });

    console.log('Running security audit...');
    return this.runAudit();
  }

  // Schedule daily checks
  scheduleSecurityCheck() {
    const schedule = require('node-schedule');

    // Every day at 2 AM
    schedule.scheduleJob('0 2 * * *', async () => {
      console.log('Running scheduled security check...');
      const passed = await this.runAudit();

      if (!passed) {
        // Alert developers
        this.notifySecurityIssues();
      }
    });
  }

  notifySecurityIssues() {
    // Send Slack/email notification
    console.log('Notifying security team...');
  }
}
```

## Secret Management Pattern

### Pattern: Environment Variable Secrets

```javascript
// .env file (NEVER commit this)
JWT_SECRET=your-secret-key-here
DB_PASSWORD=database-password
API_KEY=third-party-api-key
ENCRYPTION_KEY=encryption-key

// .env.example (SAFE to commit)
JWT_SECRET=change-me-in-production
DB_PASSWORD=change-me-in-production
API_KEY=change-me-in-production
ENCRYPTION_KEY=change-me-in-production

// config/secrets.js
class SecretManager {
  constructor() {
    this.required = [
      'JWT_SECRET',
      'DB_PASSWORD',
      'SESSION_SECRET'
    ];

    this.validateSecrets();
  }

  validateSecrets() {
    for (const secret of this.required) {
      if (!process.env[secret]) {
        throw new Error(`Missing required secret: ${secret}`);
      }

      // Prevent obvious test values
      if (process.env[secret] === 'change-me' ||
          process.env[secret] === 'test') {
        throw new Error(`Secret ${secret} not properly configured`);
      }
    }
  }

  getSecret(key) {
    if (!process.env[key]) {
      throw new Error(`Secret not found: ${key}`);
    }
    return process.env[key];
  }

  // Load secrets at startup
  static initialize() {
    require('dotenv').config();
    new SecretManager(); // Validates all secrets
  }
}

// In app.js
SecretManager.initialize();
```

## Security Testing Pattern

### Pattern: Automated Security Tests

```javascript
// tests/security.test.js
const request = require('supertest');
const app = require('../app');

describe('Security Tests', () => {
  // Test XSS prevention
  test('XSS payload in comment should be escaped', async () => {
    const xssPayload = '<script>alert("XSS")</script>';

    const response = await request(app)
      .post('/api/comments')
      .send({ text: xssPayload });

    expect(response.status).toBe(201);

    const comment = response.body;
    expect(comment.text).not.toContain('<script>');
    expect(comment.text).toContain('&lt;script&gt;');
  });

  // Test CSRF protection
  test('POST without CSRF token should fail', async () => {
    const response = await request(app)
      .post('/api/update')
      .send({ data: 'value' });

    expect(response.status).toBe(403);
    expect(response.body.error).toContain('CSRF');
  });

  // Test security headers
  test('Response should have security headers', async () => {
    const response = await request(app).get('/');

    expect(response.headers['x-frame-options']).toBe('DENY');
    expect(response.headers['x-content-type-options']).toBe('nosniff');
    expect(response.headers['content-security-policy']).toBeDefined();
  });

  // Test HTTPS redirect in production
  test('HTTP should redirect to HTTPS in production', async () => {
    process.env.NODE_ENV = 'production';

    const response = await request(app)
      .get('/')
      .set('x-forwarded-proto', 'http');

    expect(response.status).toBe(301);
    expect(response.headers.location).toMatch(/^https:/);

    process.env.NODE_ENV = 'test';
  });

  // Test secure cookies
  test('Authentication cookie should be HttpOnly', async () => {
    const response = await request(app)
      .post('/login')
      .send({ email: 'test@example.com', password: 'password123' });

    const setCookieHeader = response.headers['set-cookie'][0];
    expect(setCookieHeader).toContain('HttpOnly');
    expect(setCookieHeader).toContain('Secure');
    expect(setCookieHeader).toContain('SameSite=Strict');
  });

  // Test input validation
  test('SQL injection attempt should be rejected', async () => {
    const sqlInjection = "'; DROP TABLE users; --";

    const response = await request(app)
      .post('/api/search')
      .send({ query: sqlInjection });

    expect(response.status).toBe(400);
    expect(response.body.error).toBeDefined();
  });
});
```

These patterns provide enterprise-level security implementations for production applications with real-world applicability and best practices.
