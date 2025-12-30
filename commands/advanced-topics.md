---
name: learn_advanced_topics
description: Master advanced frontend - PWAs, Security, SSR/SSG, Micro-frontends, TypeScript
allowed-tools: Read
version: "2.0.0"
agent: 07-advanced-topics-agent

# Command Configuration
input_validation:
  skill_name:
    type: string
    required: false
    allowed_values:
      - pwa-offline-first
      - web-security-implementation
      - ssr-ssg-frameworks
      - micro-frontend-architecture
      - typescript-enterprise-patterns

exit_codes:
  0: success
  1: invalid_skill
  2: skill_not_found
  3: agent_unavailable
---

# /advanced-topics

> Master advanced frontend: PWAs, Security, SSR/SSG, Micro-frontends, TypeScript.

## Usage

```bash
/advanced-topics [skill-name]
```

## Available Skills

| Skill | Description | Duration |
|-------|-------------|----------|
| `pwa-offline-first` | Service Workers, caching | 4-5 hours |
| `web-security-implementation` | XSS, CSRF, CSP, OWASP | 5-6 hours |
| `ssr-ssg-frameworks` | Next.js, Nuxt, Astro | 5-6 hours |
| `micro-frontend-architecture` | Module Federation | 4-5 hours |
| `typescript-enterprise-patterns` | Advanced type patterns | 4-5 hours |

## Examples

```bash
# List all advanced skills
/advanced-topics

# PWA development
/advanced-topics pwa-offline-first

# Security
/advanced-topics web-security-implementation

# SSR/SSG
/advanced-topics ssr-ssg-frameworks

# Micro-frontends
/advanced-topics micro-frontend-architecture

# TypeScript
/advanced-topics typescript-enterprise-patterns
```

## Security Checklist

| Control | Description |
|---------|-------------|
| HTTPS | Enforce TLS everywhere |
| CSP | Content Security Policy |
| XSS | Input sanitization |
| CSRF | Token validation |
| CORS | Proper origin control |

## Description

Enterprise-level frontend development practices:

- **PWAs** - Offline support, push notifications
- **Security** - OWASP Top 10, best practices
- **SSR/SSG** - Next.js, Nuxt, Astro
- **Micro-frontends** - Module Federation
- **TypeScript** - Advanced patterns

## Meta-Framework Comparison

| Framework | Type | Best For |
|-----------|------|----------|
| **Next.js** | React SSR/SSG | Full-stack React |
| **Nuxt** | Vue SSR/SSG | Vue applications |
| **Astro** | Multi-framework | Content sites |
| **SvelteKit** | Svelte SSR | Svelte apps |

## Prerequisites

- All previous agents completed
- Production deployment experience
- Strong TypeScript knowledge

## Enterprise Considerations

| Aspect | Requirement |
|--------|-------------|
| Scale | Multi-team coordination |
| Security | Compliance (GDPR, SOC2) |
| Performance | Global CDN distribution |
| Monitoring | Observability stack |

---
**Command Version:** 2.0.0 | **Agent:** 07-advanced-topics-agent
