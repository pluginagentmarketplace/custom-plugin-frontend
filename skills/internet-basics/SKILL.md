---
name: internet-basics
description: Understand how the internet works - TCP/IP, HTTP/HTTPS, DNS, browsers, and web architecture.
sasmp_version: "1.3.0"
bonded_agent: 01-fundamentals-agent
bond_type: SECONDARY_BOND

# Production Configuration
validation:
  input_schema: true
  output_schema: true
  security_awareness: true

retry_logic:
  max_attempts: 3
  backoff: exponential
  initial_delay_ms: 1000

logging:
  level: INFO
  observability: true
  network_tracking: true
---

# Internet Basics

> **Purpose:** Understand web architecture fundamentals for effective frontend development.

## Input/Output Schema

```typescript
interface InternetBasicsInput {
  topic: 'http' | 'dns' | 'browser' | 'security' | 'performance';
  depth: 'overview' | 'detailed' | 'deep-dive';
}

interface InternetBasicsOutput {
  explanation: string;
  diagram?: string;
  practicalExample: string;
  securityConsiderations: string[];
}
```

## MANDATORY
- TCP/IP protocol fundamentals
- HTTP/HTTPS request-response cycle
- HTTP methods (GET, POST, PUT, DELETE, PATCH)
- Status codes and headers
- DNS resolution process
- Browser rendering pipeline (parse, layout, paint)

## OPTIONAL
- WebSockets for real-time communication
- HTTP/2 and HTTP/3 features
- CORS and same-origin policy
- Cookies and session management
- CDN and caching strategies
- SSL/TLS certificates

## ADVANCED
- Service Workers and caching
- Web Workers for background processing
- Browser storage APIs (IndexedDB, LocalStorage)
- Push notifications
- Network debugging and profiling
- Resource hints (preload, prefetch, preconnect)

## Error Handling

| Error | Root Cause | Solution |
|-------|------------|----------|
| `CORS error` | Cross-origin blocked | Configure server CORS headers |
| `Mixed content` | HTTP on HTTPS page | Use HTTPS for all resources |
| `DNS failure` | Name resolution failed | Check domain, try different DNS |
| `Certificate error` | Invalid SSL | Renew or fix certificate |

## HTTP Status Codes

| Code | Meaning | Action |
|------|---------|--------|
| 200 | Success | Process response |
| 301/302 | Redirect | Follow location header |
| 400 | Bad Request | Fix request payload |
| 401 | Unauthorized | Add authentication |
| 403 | Forbidden | Check permissions |
| 404 | Not Found | Verify URL |
| 500 | Server Error | Retry or report |

## Best Practices
- Always use HTTPS
- Implement proper caching headers
- Use CDN for static assets
- Minimize HTTP requests
- Compress responses (gzip, brotli)

## Resources
- [MDN: How the Web Works](https://developer.mozilla.org/en-US/docs/Learn/Getting_started_with_the_web/How_the_Web_works)
- [MDN: HTTP Guide](https://developer.mozilla.org/en-US/docs/Web/HTTP)

---
**Status:** Active | **Version:** 2.0.0
