# Web Security Implementation Scripts

Validation and generation scripts for enterprise web security.

## Scripts

### `validate-security.sh`
Real security vulnerability checks:
- XSS (Cross-Site Scripting) vulnerability patterns
- CSRF (Cross-Site Request Forgery) token validation
- Content Security Policy (CSP) header presence
- HTTPS/TLS requirement verification
- Security headers (HSTS, X-Frame-Options, X-Content-Type-Options)
- Secure cookie flags (HttpOnly, Secure, SameSite)

Usage:
```bash
./scripts/validate-security.sh /path/to/project
```

### `generate-security-config.sh`
Generate production-ready security configurations:
- Security headers middleware config
- CSP policy templates
- HTTPS redirect setup
- CORS configuration
- Secure session configuration
- Dependency vulnerability scan setup

Usage:
```bash
./scripts/generate-security-config.sh /path/to/project
```

## Security Checklist

- [ ] HTTPS/TLS enabled
- [ ] Security headers configured
- [ ] CSP policy implemented
- [ ] CSRF tokens in place
- [ ] XSS prevention (input sanitization, escaping)
- [ ] Secure cookies (HttpOnly, Secure, SameSite)
- [ ] CORS properly configured
- [ ] Dependencies scanned for vulnerabilities
- [ ] Authentication secure (bcrypt, JWT with expiry)
- [ ] Rate limiting implemented
- [ ] Secrets not in code (.env used)
- [ ] API input validation
- [ ] Error handling (no sensitive data in errors)
