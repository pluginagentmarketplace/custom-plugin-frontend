---
name: learn_build_tools
description: Master package managers and build tools - NPM, Yarn, PNPM, Webpack, Vite
allowed-tools: Read
version: "2.0.0"
agent: 02-build-tools-agent

# Command Configuration
input_validation:
  skill_name:
    type: string
    required: false
    allowed_values:
      - npm-yarn-pnpm
      - webpack-advanced
      - vite-bundling
      - code-splitting-optimization
      - code-splitting-bundling

exit_codes:
  0: success
  1: invalid_skill
  2: skill_not_found
  3: agent_unavailable
---

# /build-tools

> Master package managers and build tools: NPM, Yarn, PNPM, Webpack, and Vite.

## Usage

```bash
/build-tools [skill-name]
```

## Available Skills

| Skill | Description | Duration |
|-------|-------------|----------|
| `npm-yarn-pnpm` | Package managers, workspaces | 3-4 hours |
| `webpack-advanced` | Configuration, loaders, plugins | 5-6 hours |
| `vite-bundling` | Modern dev server, Rollup builds | 3-4 hours |
| `code-splitting-optimization` | Bundle optimization strategies | 2-3 hours |
| `code-splitting-bundling` | Dynamic imports, lazy loading | 2-3 hours |

## Examples

```bash
# List all build tool skills
/build-tools

# Learn specific skill
/build-tools npm-yarn-pnpm
/build-tools webpack-advanced
/build-tools vite-bundling
/build-tools code-splitting-optimization
```

## Tool Comparison

| Tool | Best For | Speed |
|------|----------|-------|
| **NPM** | Compatibility, native Node | Standard |
| **Yarn** | Workspaces, deterministic | Fast |
| **PNPM** | Disk space, monorepos | Fastest |
| **Webpack** | Complex builds, legacy support | Configurable |
| **Vite** | Modern dev experience | Very Fast |

## Description

Learn modern build tooling essential for professional development:

- **Package Management** - NPM, Yarn, PNPM
- **Webpack** - Configuration and optimization
- **Vite** - Next-generation bundling
- **Code Splitting** - Optimal bundle strategies

## Prerequisites

- Frontend Fundamentals (`/fundamentals`)
- Node.js installed (v18+)
- Command line basics

## Build Optimization Targets

| Metric | Target |
|--------|--------|
| JS Bundle | < 100KB gzipped |
| CSS Bundle | < 30KB gzipped |
| Dev Server Start | < 3 seconds |
| Production Build | < 60 seconds |

## Next Steps

After mastering build tools:
- `/frameworks` - Framework-specific builds
- `/performance` - Bundle analysis
- `/advanced-topics` - Micro-frontends with Module Federation

---
**Command Version:** 2.0.0 | **Agent:** 02-build-tools-agent
