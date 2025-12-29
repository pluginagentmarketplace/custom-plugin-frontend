# Web Security Implementation Technical Guide

## OWASP Top 10 Vulnerabilities and Prevention

The OWASP Top 10 represents the most critical security risks to web applications. Understanding and mitigating these is essential for production applications.

### 1. Broken Access Control
Occurs when users can act outside their intended permissions.

**Prevention:**
- Implement role-based access control (RBAC)
- Check authorization on every protected resource
- Use middleware to enforce access policies
- Log all access attempts

```javascript
// Express middleware for role checking
const authorizeRole = (requiredRoles) => {
  return (req, res, next) => {
    if (!req.user || !requiredRoles.includes(req.user.role)) {
      return res.status(403).json({ error: 'Forbidden' });
    }
    next();
  };
};

// Usage
app.delete('/admin/users/:id', authorizeRole(['admin']), deleteUser);
```

### 2. Cryptographic Failures
Failure to protect sensitive data through encryption.

**Prevention:**
- Always use HTTPS/TLS in production
- Encrypt sensitive data at rest
- Never log passwords or tokens
- Use bcrypt for password hashing with at least 12 rounds
- Rotate encryption keys regularly

```javascript
const bcrypt = require('bcryptjs');

// Hash password securely
async function hashPassword(password) {
  const salt = await bcrypt.genSalt(12);
  return bcrypt.hash(password, salt);
}

// Verify password
async function verifyPassword(password, hash) {
  return bcrypt.compare(password, hash);
}

// JWT with expiration
const jwt = require('jsonwebtoken');

function generateToken(user) {
  return jwt.sign(
    { userId: user.id, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: '24h' } // Critical: set expiration
  );
}
```

### 3. Injection Attacks
Injecting malicious code through user input (SQL, NoSQL, Command).

**Prevention:**
- Use parameterized queries (prepared statements)
- Never concatenate user input into queries
- Validate and sanitize all inputs
- Use ORMs that prevent injection

```javascript
// ❌ DANGEROUS - SQL Injection
const query = `SELECT * FROM users WHERE email = '${email}'`;
db.query(query);

// ✅ SAFE - Parameterized Query
const query = 'SELECT * FROM users WHERE email = ?';
db.query(query, [email]);

// ✅ SAFE - ORM
const user = await User.findOne({ email: email });

// ❌ DANGEROUS - Command Injection
const result = execSync(`convert ${userInput}.jpg result.jpg`);

// ✅ SAFE - Use safe methods
const { execFile } = require('child_process');
execFile('convert', [userInput + '.jpg', 'result.jpg']);
```

### 4. Insecure Design
Missing security controls during design phase.

**Prevention:**
- Threat modeling during planning
- Principle of least privilege
- Defense in depth (multiple layers)
- Secure by default settings

### 5. Security Misconfiguration
Insecure default settings, incomplete security setup.

**Prevention:**
- Disable DEBUG mode in production
- Use security headers (see below)
- Keep frameworks updated
- Remove unnecessary services
- Use strong default configurations

## Cross-Site Scripting (XSS) Prevention

XSS allows attackers to inject JavaScript code into web pages viewed by other users.

### Types of XSS

**Stored XSS**: Malicious script stored in database, executed for all users.
**Reflected XSS**: Malicious script in URL parameter, reflected in response.
**DOM XSS**: Client-side vulnerability in DOM manipulation.

### Prevention Techniques

**1. Input Validation**
```javascript
const validator = require('validator');

function isValidComment(comment) {
  return validator.isLength(comment, { min: 1, max: 1000 }) &&
         !comment.includes('<script>');
}
```

**2. Output Encoding/Escaping**
```javascript
const escape = require('html-escape');

// Always escape user-generated content
const safeComment = escape(userInput);
response.body = `<p>${safeComment}</p>`; // Safe from XSS
```

**3. Content Security Policy (CSP)**
```javascript
// Strict CSP header - no inline scripts
res.setHeader(
  'Content-Security-Policy',
  "default-src 'self'; script-src 'self'; style-src 'self'"
);

// CSP with nonce for inline scripts
const crypto = require('crypto');
const nonce = crypto.randomBytes(16).toString('hex');

res.setHeader(
  'Content-Security-Policy',
  `script-src 'nonce-${nonce}'`
);

// In HTML
response.body = `
  <script nonce="${nonce}">
    console.log('This is safe');
  </script>
`;
```

**4. Using DOMPurify/XSS Libraries**
```javascript
const DOMPurify = require('isomorphic-dompurify');

// Sanitize user-provided HTML
const clean = DOMPurify.sanitize(userInput, {
  ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a'],
  ALLOWED_ATTR: ['href']
});
```

**5. React/Framework Protection**
```javascript
// React auto-escapes by default
const Comment = ({ text }) => {
  // This is safe - React escapes the content
  return <p>{text}</p>;
};

// Only use dangerouslySetInnerHTML with sanitized input
import DOMPurify from 'dompurify';

const SafeHTML = ({ html }) => {
  const clean = DOMPurify.sanitize(html);
  return <div dangerouslySetInnerHTML={{ __html: clean }} />;
};
```

## Cross-Site Request Forgery (CSRF) Protection

CSRF attacks trick users into performing unwanted actions on authenticated sites.

### CSRF Token Pattern

```javascript
const session = require('express-session');
const csrf = require('csurf');
const cookieParser = require('cookie-parser');

app.use(cookieParser());
app.use(session({
  secret: process.env.SESSION_SECRET,
  cookie: {
    secure: true,
    httpOnly: true,
    sameSite: 'strict'
  }
}));

// CSRF protection middleware
const csrfProtection = csrf({ cookie: false }); // Use session-based tokens

// GET request - show form with token
app.get('/form', csrfProtection, (req, res) => {
  res.send(`
    <form action="/process" method="POST">
      <input type="hidden" name="_csrf" value="${req.csrfToken()}">
      <input type="text" name="data">
      <button type="submit">Submit</button>
    </form>
  `);
});

// POST request - verify token
app.post('/process', csrfProtection, (req, res) => {
  // Token is automatically verified
  res.send('Data processed safely');
});
```

### CSRF for APIs

```javascript
// Include CSRF token in custom header
fetch('/api/action', {
  method: 'POST',
  headers: {
    'X-CSRF-Token': document.querySelector('[name="_csrf"]').value,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({ data: 'value' })
});

// Server validates header
const validateCsrf = (req, res, next) => {
  const token = req.get('X-CSRF-Token');
  csrf.verify(req, token, (err) => {
    if (err) return res.status(403).json({ error: 'CSRF invalid' });
    next();
  });
};
```

## Content Security Policy (CSP)

CSP is a browser security mechanism that restricts resource loading and execution.

### CSP Directives

```
default-src 'self'              # Default for all resources
script-src 'self'               # JavaScript sources only
style-src 'self' 'unsafe-inline'  # CSS sources
img-src 'self' https: data:     # Images from self, HTTPS, data URIs
font-src 'self'                 # Fonts sources
connect-src 'self' https:       # Fetch, XHR, WS connections
frame-ancestors 'none'          # Can't be embedded in frames
upgrade-insecure-requests       # Upgrade HTTP to HTTPS
```

### CSP Header Example

```javascript
app.use((req, res, next) => {
  const nonce = crypto.randomBytes(16).toString('hex');
  res.locals.nonce = nonce;

  res.setHeader(
    'Content-Security-Policy',
    [
      "default-src 'self'",
      `script-src 'self' 'nonce-${nonce}' trusted-cdn.com`,
      "style-src 'self' 'unsafe-inline'", // Tighten in production
      "img-src 'self' https: data:",
      "font-src 'self' fonts.googleapis.com",
      "connect-src 'self' https:",
      "frame-ancestors 'none'",
      "base-uri 'self'",
      "form-action 'self'"
    ].join('; ')
  );

  next();
});
```

## Secure Headers Implementation

Production-critical security headers every app should implement:

### 1. Strict-Transport-Security (HSTS)
```javascript
res.setHeader(
  'Strict-Transport-Security',
  'max-age=31536000; includeSubDomains; preload'
);
// Force HTTPS for 1 year, subdomains, and add to HSTS preload list
```

### 2. X-Frame-Options (Clickjacking Protection)
```javascript
res.setHeader('X-Frame-Options', 'DENY');
// Prevent your site from being embedded in frames
// Options: DENY, SAMEORIGIN, ALLOW-FROM <url>
```

### 3. X-Content-Type-Options
```javascript
res.setHeader('X-Content-Type-Options', 'nosniff');
// Prevent MIME type sniffing attacks
```

### 4. Referrer-Policy
```javascript
res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin');
// Control what referrer info is sent to other sites
```

### 5. Permissions-Policy
```javascript
res.setHeader(
  'Permissions-Policy',
  'geolocation=(), microphone=(), camera=(), payment=()'
);
// Disable features the app doesn't use
```

## HTTPS/TLS Requirements

Service Workers, PWAs, and modern features require HTTPS.

### Self-Signed Certificate for Development
```bash
openssl req -x509 -newkey rsa:2048 \
  -keyout key.pem -out cert.pem \
  -days 365 -nodes
```

### Express HTTPS Server
```javascript
const https = require('https');
const fs = require('fs');

const options = {
  key: fs.readFileSync('key.pem'),
  cert: fs.readFileSync('cert.pem')
};

https.createServer(options, app).listen(443);
```

### Production with Let's Encrypt
```bash
# Free HTTPS certificate
certbot certonly --standalone -d example.com
```

## Dependency Vulnerability Scanning

Keep dependencies secure and up-to-date.

```bash
# Scan for vulnerabilities
npm audit

# Auto-fix low and moderate issues
npm audit fix

# Manual review and fix
npm audit fix --audit-level=moderate

# Check with Snyk
npx snyk test

# Generate detailed report
npm audit --json > audit-report.json
```

### Package.json Security Check
```javascript
// In CI/CD pipeline
const { execSync } = require('child_process');

function checkSecurityIssues() {
  try {
    execSync('npm audit --audit-level=moderate', { stdio: 'inherit' });
    console.log('✓ No security issues found');
  } catch (error) {
    console.error('✗ Security vulnerabilities detected');
    process.exit(1);
  }
}
```

This comprehensive approach ensures your application is protected against the most common and critical security threats.
