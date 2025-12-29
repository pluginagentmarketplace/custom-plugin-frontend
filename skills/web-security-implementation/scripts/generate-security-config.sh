#!/bin/bash
# Security Configuration Generator - Produces production-ready security configs

set -e

PROJECT_PATH="${1:-.}"
mkdir -p "$PROJECT_PATH/config"

echo "Security Configuration Generator"
echo "=================================="
echo ""

# 1. Generate security headers middleware
echo "📝 Generating security headers middleware..."
cat > "$PROJECT_PATH/config/security-headers.js" << 'EOF'
/**
 * Security Headers Middleware
 * Implements OWASP recommended headers for production
 */

const securityHeaders = (req, res, next) => {
  // Prevent Clickjacking (XFrame)
  res.setHeader('X-Frame-Options', 'DENY');

  // Prevent MIME type sniffing
  res.setHeader('X-Content-Type-Options', 'nosniff');

  // Enable XSS Filter in older browsers
  res.setHeader('X-XSS-Protection', '1; mode=block');

  // HTTP Strict Transport Security - Force HTTPS
  res.setHeader(
    'Strict-Transport-Security',
    'max-age=31536000; includeSubDomains; preload'
  );

  // Referrer Policy - Control what referrer info is sent
  res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin');

  // Permissions Policy (formerly Feature-Policy)
  res.setHeader(
    'Permissions-Policy',
    'geolocation=(), microphone=(), camera=(), payment=()'
  );

  // Content Security Policy - Most important header
  res.setHeader(
    'Content-Security-Policy',
    [
      "default-src 'self'",
      "script-src 'self' 'unsafe-inline' 'unsafe-eval'", // Tighten in production
      "style-src 'self' 'unsafe-inline'",
      "img-src 'self' https: data:",
      "font-src 'self'",
      "connect-src 'self' https:",
      "frame-ancestors 'none'",
      "base-uri 'self'",
      "form-action 'self'"
    ].join('; ')
  );

  next();
};

module.exports = securityHeaders;
EOF
echo "✓ Created: config/security-headers.js"

# 2. Generate strict CSP policy
echo "📝 Generating strict CSP policy..."
cat > "$PROJECT_PATH/config/csp-policy.js" << 'EOF'
/**
 * Content Security Policy Configuration
 * Strict version for production applications
 */

const CSP_POLICIES = {
  // Development - allows more sources for tooling
  development: [
    "default-src 'self'",
    "script-src 'self' 'unsafe-inline' 'unsafe-eval' localhost:* 127.0.0.1:*", // Dev tools
    "style-src 'self' 'unsafe-inline'",
    "img-src 'self' https: data: blob:",
    "font-src 'self' data:",
    "connect-src 'self' https: localhost:* ws: wss:",
    "frame-ancestors 'self'",
    "base-uri 'self'",
    "form-action 'self'",
    "upgrade-insecure-requests"
  ].join('; '),

  // Production - strict policy
  production: [
    "default-src 'self'",
    "script-src 'self'", // No inline scripts!
    "style-src 'self'", // No inline styles!
    "img-src 'self' https: data:",
    "font-src 'self'",
    "connect-src 'self' https:",
    "frame-ancestors 'none'",
    "base-uri 'self'",
    "form-action 'self'",
    "upgrade-insecure-requests",
    "require-trusted-types-for 'script'"
  ].join('; '),

  // Strict CSP with nonce for inline scripts
  strict: (nonce) => [
    "default-src 'self'",
    `script-src 'self' 'nonce-${nonce}'`,
    "style-src 'self'",
    "img-src 'self' https:",
    "font-src 'self'",
    "connect-src 'self' https:",
    "frame-ancestors 'none'",
    "base-uri 'self'",
    "form-action 'self'",
    "upgrade-insecure-requests"
  ].join('; ')
};

module.exports = CSP_POLICIES;
EOF
echo "✓ Created: config/csp-policy.js"

# 3. Generate CORS configuration
echo "📝 Generating CORS configuration..."
cat > "$PROJECT_PATH/config/cors.js" << 'EOF'
/**
 * CORS Configuration
 * Cross-Origin Resource Sharing with security
 */

const ALLOWED_ORIGINS = process.env.ALLOWED_ORIGINS
  ? process.env.ALLOWED_ORIGINS.split(',')
  : ['http://localhost:3000', 'http://localhost:3001'];

const corsOptions = {
  // Specific origins only - NEVER use wildcard in production
  origin: (origin, callback) => {
    if (!origin || ALLOWED_ORIGINS.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('CORS not allowed'));
    }
  },

  // Allow credentials (cookies, auth headers)
  credentials: true,

  // Allowed methods
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],

  // Allowed headers
  allowedHeaders: [
    'Content-Type',
    'Authorization',
    'X-Requested-With',
    'X-CSRF-Token'
  ],

  // Headers exposed to client
  exposedHeaders: [
    'X-Total-Count',
    'X-Page-Number',
    'Content-Range'
  ],

  // Max age for preflight cache
  maxAge: 3600, // 1 hour

  // Credentials mode: include
  preflightContinue: false
};

module.exports = corsOptions;
EOF
echo "✓ Created: config/cors.js"

# 4. Generate HTTPS redirect configuration
echo "📝 Generating HTTPS redirect..."
cat > "$PROJECT_PATH/config/https-redirect.js" << 'EOF'
/**
 * HTTPS Redirect Middleware
 * Force all traffic to HTTPS in production
 */

const httpsRedirect = (req, res, next) => {
  // Skip in development or for health checks
  if (process.env.NODE_ENV === 'development' ||
      req.path === '/health' ||
      req.path === '/ping') {
    return next();
  }

  // Redirect HTTP to HTTPS
  if (req.header('x-forwarded-proto') !== 'https') {
    return res.redirect(301, `https://${req.header('host')}${req.url}`);
  }

  next();
};

module.exports = httpsRedirect;
EOF
echo "✓ Created: config/https-redirect.js"

# 5. Generate secure session configuration
echo "📝 Generating secure session config..."
cat > "$PROJECT_PATH/config/session-config.js" << 'EOF'
/**
 * Secure Session Configuration
 * For Express with express-session
 */

const sessionConfig = {
  // Session store should be Redis or Memcached in production
  // Do NOT use memory store in production
  secret: process.env.SESSION_SECRET || 'change-me-in-production',

  resave: false,
  saveUninitialized: false,

  // CRITICAL: Secure cookie settings
  cookie: {
    secure: process.env.NODE_ENV === 'production', // HTTPS only
    httpOnly: true, // No JavaScript access
    sameSite: 'strict', // CSRF protection
    maxAge: 1000 * 60 * 60 * 24, // 24 hours
    domain: process.env.COOKIE_DOMAIN || undefined,
    path: '/'
  },

  // Session ID settings
  name: 'sessionId', // Don't use default 'connect.sid'
  genid: () => {
    // Use crypto for secure random ID
    const { randomBytes } = require('crypto');
    return randomBytes(16).toString('hex');
  }
};

module.exports = sessionConfig;
EOF
echo "✓ Created: config/session-config.js"

# 6. Generate CSRF protection configuration
echo "📝 Generating CSRF protection..."
cat > "$PROJECT_PATH/config/csrf-protection.js" << 'EOF'
/**
 * CSRF (Cross-Site Request Forgery) Protection
 */

const csrf = require('csurf');
const cookieParser = require('cookie-parser');

// CSRF protection middleware
const csrfProtection = csrf({
  cookie: {
    secure: process.env.NODE_ENV === 'production',
    httpOnly: true,
    sameSite: 'strict'
  }
});

// Middleware stack for CSRF
const csrfMiddleware = [
  cookieParser(),
  csrfProtection
];

// Get CSRF token for forms
const getCsrfToken = (req, res) => {
  return req.csrfToken();
};

// Validation middleware
const validateCsrf = (req, res, next) => {
  try {
    csrfProtection(req, res, next);
  } catch (err) {
    if (err.code === 'EBADCSRFTOKEN') {
      res.status(403).json({ error: 'CSRF token invalid' });
    } else {
      next(err);
    }
  }
};

module.exports = {
  csrfProtection,
  csrfMiddleware,
  getCsrfToken,
  validateCsrf
};
EOF
echo "✓ Created: config/csrf-protection.js"

# 7. Generate input validation and sanitization
echo "📝 Generating input validation..."
cat > "$PROJECT_PATH/config/input-validation.js" << 'EOF'
/**
 * Input Validation and Sanitization
 * Prevent injection attacks and XSS
 */

const xss = require('xss');
const validator = require('validator');

// Sanitization functions
const sanitizers = {
  // Sanitize user input for XSS
  html: (input) => {
    return xss(String(input), {
      whiteList: {}, // No HTML allowed by default
      stripIgnoredTag: true
    });
  },

  // Escape for HTML context
  htmlEscape: (input) => {
    return validator.escape(String(input));
  },

  // Clean SQL input (use parameterized queries instead!)
  sql: (input) => {
    return String(input)
      .replace(/['";\\]/g, '\\$&')
      .substring(0, 255);
  },

  // Validate email
  email: (email) => {
    return validator.isEmail(email) ? email : null;
  },

  // Validate URL
  url: (url) => {
    return validator.isURL(url) ? url : null;
  },

  // Validate integer
  integer: (value) => {
    const parsed = parseInt(value, 10);
    return Number.isInteger(parsed) ? parsed : null;
  },

  // Remove null bytes
  nullBytes: (input) => {
    return String(input).replace(/\0/g, '');
  }
};

// Validation middleware
const validateInput = (schema) => {
  return (req, res, next) => {
    const errors = [];

    for (const [field, rules] of Object.entries(schema)) {
      const value = req.body[field];

      if (rules.required && !value) {
        errors.push(`${field} is required`);
        continue;
      }

      if (value && rules.type === 'email') {
        if (!sanitizers.email(value)) {
          errors.push(`${field} must be valid email`);
        }
      }

      if (value && rules.type === 'url') {
        if (!sanitizers.url(value)) {
          errors.push(`${field} must be valid URL`);
        }
      }

      if (value && rules.maxLength && value.length > rules.maxLength) {
        errors.push(`${field} exceeds max length`);
      }

      if (value && rules.pattern && !rules.pattern.test(value)) {
        errors.push(`${field} format invalid`);
      }
    }

    if (errors.length > 0) {
      return res.status(400).json({ errors });
    }

    next();
  };
};

module.exports = {
  sanitizers,
  validateInput
};
EOF
echo "✓ Created: config/input-validation.js"

# 8. Generate rate limiting configuration
echo "📝 Generating rate limiting..."
cat > "$PROJECT_PATH/config/rate-limit.js" << 'EOF'
/**
 * Rate Limiting Configuration
 * Prevent brute force and DoS attacks
 */

const rateLimit = require('express-rate-limit');
const RedisStore = require('rate-limit-redis');
const redis = require('redis');

// Create Redis client for distributed rate limiting
const redisClient = redis.createClient({
  host: process.env.REDIS_HOST || 'localhost',
  port: process.env.REDIS_PORT || 6379,
  password: process.env.REDIS_PASSWORD
});

// General API rate limiter
const apiLimiter = rateLimit({
  store: new RedisStore({
    client: redisClient,
    prefix: 'api-limit:'
  }),
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP',
  standardHeaders: true, // Return rate limit info in headers
  legacyHeaders: false
});

// Strict limiter for auth endpoints
const authLimiter = rateLimit({
  store: new RedisStore({
    client: redisClient,
    prefix: 'auth-limit:'
  }),
  windowMs: 15 * 60 * 1000,
  max: 5, // Only 5 attempts per 15 minutes
  skipSuccessfulRequests: true, // Don't count successful attempts
  message: 'Too many login attempts'
});

// File upload limiter
const uploadLimiter = rateLimit({
  store: new RedisStore({
    client: redisClient,
    prefix: 'upload-limit:'
  }),
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 10 // 10 uploads per hour
});

module.exports = {
  apiLimiter,
  authLimiter,
  uploadLimiter,
  redisClient
};
EOF
echo "✓ Created: config/rate-limit.js"

# 9. Generate .env.example file
echo "📝 Generating .env.example..."
cat > "$PROJECT_PATH/.env.example" << 'EOF'
# Environment
NODE_ENV=development

# HTTPS/TLS
HTTPS=true
SSL_CERT_PATH=/path/to/cert.pem
SSL_KEY_PATH=/path/to/key.pem

# Session
SESSION_SECRET=your-secret-key-change-in-production
SESSION_COOKIE_DOMAIN=localhost
COOKIE_DOMAIN=localhost

# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=myapp
DB_USER=postgres
DB_PASSWORD=change-me

# JWT/Auth
JWT_SECRET=your-jwt-secret
JWT_EXPIRY=24h
BCRYPT_ROUNDS=12

# CSRF
CSRF_SECRET=your-csrf-secret

# CORS
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:3001

# Redis (for sessions and rate limiting)
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# Email
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@example.com
SMTP_PASSWORD=your-app-password

# Logging
LOG_LEVEL=info
LOG_FILE=/var/log/app.log

# Security
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
EOF
echo "✓ Created: .env.example"

# 10. Generate Express app setup example
echo "📝 Generating Express security setup..."
cat > "$PROJECT_PATH/config/express-setup.js" << 'EOF'
/**
 * Express.js Security Setup
 * Complete configuration for production security
 */

const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const securityHeaders = require('./security-headers');
const httpsRedirect = require('./https-redirect');
const corsOptions = require('./cors');
const { apiLimiter, authLimiter } = require('./rate-limit');
const sessionConfig = require('./session-config');
const { csrfMiddleware, validateCsrf } = require('./csrf-protection');

function setupSecurity(app) {
  // Trust proxy (for HTTPS forwarding)
  app.set('trust proxy', 1);

  // Helmet - security headers
  app.use(helmet({
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        scriptSrc: ["'self'"],
        styleSrc: ["'self'", "'unsafe-inline'"],
        imgSrc: ["'self'", 'https:', 'data:'],
        connectSrc: ["'self'", 'https:'],
        fontSrc: ["'self'"],
        objectSrc: ["'none'"],
        mediaSrc: ["'self'"],
        frameSrc: ["'none'"]
      }
    },
    hsts: {
      maxAge: 31536000,
      includeSubDomains: true,
      preload: true
    },
    noSniff: true,
    xssFilter: true,
    referrerPolicy: { policy: 'strict-origin-when-cross-origin' }
  }));

  // HTTPS redirect in production
  if (process.env.NODE_ENV === 'production') {
    app.use(httpsRedirect);
  }

  // Custom security headers
  app.use(securityHeaders);

  // CORS
  app.use(cors(corsOptions));

  // Rate limiting
  app.use('/api/', apiLimiter);
  app.use('/auth/login', authLimiter);
  app.use('/auth/register', authLimiter);

  // Body parser with size limits
  app.use(express.json({ limit: '10kb' }));
  app.use(express.urlencoded({ limit: '10kb', extended: false }));

  // CSRF Protection
  app.use(csrfMiddleware);

  return app;
}

module.exports = setupSecurity;
EOF
echo "✓ Created: config/express-setup.js"

# 11. Generate package.json security dependencies
echo "📝 Generating package.json security dependencies..."
cat > "$PROJECT_PATH/security-dependencies.json" << 'EOF'
{
  "dependencies": {
    "helmet": "^7.0.0",
    "cors": "^2.8.5",
    "express-rate-limit": "^7.0.0",
    "rate-limit-redis": "^4.0.0",
    "redis": "^4.6.0",
    "csurf": "^1.11.0",
    "express-session": "^1.17.0",
    "bcryptjs": "^2.4.3",
    "jsonwebtoken": "^9.0.0",
    "xss": "^1.0.14",
    "validator": "^13.11.0",
    "express-validator": "^7.0.0"
  },
  "devDependencies": {
    "snyk": "^1.1250.0",
    "npm-audit-resolver": "^2.4.0"
  },
  "scripts": {
    "security:check": "npm audit && snyk test",
    "security:fix": "npm audit fix",
    "security:validate": "bash scripts/validate-security.sh"
  }
}
EOF
echo "✓ Created: security-dependencies.json"

echo ""
echo "=================================="
echo "✓ Security Configuration Complete!"
echo "=================================="
echo ""
echo "Next steps:"
echo "1. Review and customize config files in config/"
echo "2. Update .env with your values"
echo "3. Install dependencies:"
echo "   npm install helmet cors csurf bcryptjs jsonwebtoken xss validator"
echo "4. Apply Express setup in your app:"
echo "   const setupSecurity = require('./config/express-setup');"
echo "   setupSecurity(app);"
echo "5. Run security validation:"
echo "   bash scripts/validate-security.sh"
echo "6. Run npm audit: npm audit"
echo ""
