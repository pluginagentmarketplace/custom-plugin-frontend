---
name: optimize_performance
description: Master web performance - Core Web Vitals, optimization, and DevTools
allowed-tools: Read
version: "2.0.0"
agent: 06-performance-agent

# Command Configuration
input_validation:
  skill_name:
    type: string
    required: false
    allowed_values:
      - core-web-vitals
      - web-vitals-lighthouse
      - image-optimization
      - asset-optimization
      - browser-devtools
      - devtools-profiling
      - bundle-analysis-splitting
      - code-splitting-lazy-loading

exit_codes:
  0: success
  1: invalid_skill
  2: skill_not_found
  3: agent_unavailable
---

# /performance

> Master web performance: Core Web Vitals, optimization, and DevTools.

## Usage

```bash
/performance [skill-name]
```

## Available Skills

| Skill | Description | Duration |
|-------|-------------|----------|
| `core-web-vitals` | LCP, INP, CLS metrics | 3-4 hours |
| `web-vitals-lighthouse` | Lighthouse auditing | 2-3 hours |
| `image-optimization` | WebP, AVIF, lazy loading | 2-3 hours |
| `asset-optimization` | Fonts, CSS, JS optimization | 2-3 hours |
| `browser-devtools` | Chrome DevTools mastery | 3-4 hours |
| `devtools-profiling` | Performance profiling | 2-3 hours |
| `bundle-analysis-splitting` | Webpack/Vite analysis | 2-3 hours |
| `code-splitting-lazy-loading` | Dynamic imports | 2-3 hours |

## Examples

```bash
# List all performance skills
/performance

# Core Web Vitals
/performance core-web-vitals
/performance web-vitals-lighthouse

# Asset Optimization
/performance image-optimization
/performance asset-optimization

# DevTools
/performance browser-devtools
/performance devtools-profiling

# Bundle Analysis
/performance bundle-analysis-splitting
```

## Core Web Vitals Targets

| Metric | Good | Needs Work | Poor |
|--------|------|------------|------|
| **LCP** | ≤ 2.5s | 2.5-4s | > 4s |
| **INP** | ≤ 200ms | 200-500ms | > 500ms |
| **CLS** | ≤ 0.1 | 0.1-0.25 | > 0.25 |

## Performance Budget

| Resource | Budget (gzipped) |
|----------|------------------|
| JavaScript | < 100KB |
| CSS | < 30KB |
| Images | < 500KB total |
| Fonts | < 50KB |

## Description

Create blazing-fast web applications:

- **Core Web Vitals** - LCP, INP, CLS
- **Lighthouse** - Automated auditing
- **Asset Optimization** - Images, fonts, CSS
- **DevTools** - Profiling and debugging
- **Bundle Analysis** - Size optimization

## Prerequisites

- Build Tools Agent (`/build-tools`)
- Framework experience
- Basic networking knowledge

## Next Steps

After mastering performance:
- `/advanced-topics` - PWA offline caching
- Production monitoring setup
- Real User Monitoring (RUM)

---
**Command Version:** 2.0.0 | **Agent:** 06-performance-agent
