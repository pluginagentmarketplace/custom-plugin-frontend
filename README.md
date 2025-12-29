<div align="center">

# Frontend Development Assistant

### Complete Frontend Learning System for Claude Code

**Master modern web development with 7 specialized agents covering React, Vue, Angular, Svelte, TypeScript, testing, and performance**

[![Verified](https://img.shields.io/badge/Verified-Working-success?style=flat-square&logo=checkmarx)](https://github.com/pluginagentmarketplace/custom-plugin-frontend)
[![License](https://img.shields.io/badge/License-Custom-yellow?style=flat-square)](LICENSE)
[![Version](https://img.shields.io/badge/Version-2.0.2-blue?style=flat-square)](https://github.com/pluginagentmarketplace/custom-plugin-frontend)
[![Status](https://img.shields.io/badge/Status-Production_Ready-brightgreen?style=flat-square)](https://github.com/pluginagentmarketplace/custom-plugin-frontend)
[![Agents](https://img.shields.io/badge/Agents-7-orange?style=flat-square)](#agents-overview)
[![Skills](https://img.shields.io/badge/Skills-41-purple?style=flat-square)](#skills-reference)
[![SASMP](https://img.shields.io/badge/SASMP-v1.3.0-blueviolet?style=flat-square)](#)

[![React](https://img.shields.io/badge/React-61DAFB?style=for-the-badge&logo=react&logoColor=black)](https://react.dev)
[![Vue](https://img.shields.io/badge/Vue-4FC08D?style=for-the-badge&logo=vuedotjs&logoColor=white)](https://vuejs.org)
[![Angular](https://img.shields.io/badge/Angular-DD0031?style=for-the-badge&logo=angular&logoColor=white)](https://angular.io)
[![TypeScript](https://img.shields.io/badge/TypeScript-3178C6?style=for-the-badge&logo=typescript&logoColor=white)](https://typescriptlang.org)

[Quick Start](#quick-start) | [Agents](#agents-overview) | [Skills](#skills-reference) | [Commands](#commands)

</div>

---

## Verified Installation

> **This plugin has been tested and verified working on Claude Code.**
> Last verified: December 2025

---

## Quick Start

### Option 1: Install from GitHub (Recommended)

```bash
# Step 1: Add the marketplace from GitHub
/plugin add marketplace pluginagentmarketplace/custom-plugin-frontend

# Step 2: Install the plugin
/plugin install frontend-development-assistant@pluginagentmarketplace-frontend

# Step 3: Restart Claude Code to load new plugins
```

### Option 2: Clone and Load Locally

```bash
# Clone the repository
git clone https://github.com/pluginagentmarketplace/custom-plugin-frontend.git

# Navigate to the directory in Claude Code
cd custom-plugin-frontend

# Load the plugin
/plugin load .
```

After loading, restart Claude Code.

### Verify Installation

After restarting Claude Code, verify the plugin is loaded. You should see these agents available:

```
custom-plugin-frontend:fundamentals
custom-plugin-frontend:build-tools
custom-plugin-frontend:frameworks
custom-plugin-frontend:state-management
custom-plugin-frontend:testing
custom-plugin-frontend:performance
custom-plugin-frontend:advanced-topics
```

---

## Available Skills

Once installed, these 41 skills become available (showing key skills):

| Skill | Invoke Command | Golden Format |
|-------|----------------|---------------|
| HTML/CSS Essentials | `Skill("custom-plugin-frontend:html-css-essentials")` | html5-template.yaml |
| JavaScript Fundamentals | `Skill("custom-plugin-frontend:javascript-fundamentals")` | modern-js-patterns.yaml |
| React Fundamentals | `Skill("custom-plugin-frontend:react-fundamentals")` | react-component.yaml |
| React Hooks Patterns | `Skill("custom-plugin-frontend:react-hooks-patterns")` | hooks-patterns.yaml |
| Vue Composition API | `Skill("custom-plugin-frontend:vue-composition-api")` | vue-composable.yaml |
| Angular DI | `Skill("custom-plugin-frontend:angular-dependency-injection")` | angular-service.yaml |
| Redux State | `Skill("custom-plugin-frontend:redux-fundamentals")` | redux-slice.yaml |
| Zustand State | `Skill("custom-plugin-frontend:zustand-lightweight-state")` | zustand-store.yaml |
| Unit Testing | `Skill("custom-plugin-frontend:unit-testing-jest-vitest")` | jest-config.yaml |
| E2E Testing | `Skill("custom-plugin-frontend:e2e-testing-cypress-playwright")` | playwright-config.yaml |
| Core Web Vitals | `Skill("custom-plugin-frontend:core-web-vitals")` | performance-checklist.yaml |
| TypeScript Enterprise | `Skill("custom-plugin-frontend:typescript-enterprise-patterns")` | tsconfig.yaml |
| PWA Offline-First | `Skill("custom-plugin-frontend:pwa-offline-first")` | pwa-manifest.yaml |
| SSR/SSG Frameworks | `Skill("custom-plugin-frontend:ssr-ssg-frameworks")` | nextjs-config.yaml |
| Web Security | `Skill("custom-plugin-frontend:web-security-implementation")` | security-headers.yaml |

**See [full skill list](#skills-reference) below for all 41 skills.**

---

## What This Plugin Does

This plugin provides **7 specialized agents** and **41 production-ready skills** for frontend mastery:

| Agent | Purpose |
|-------|---------|
| **Fundamentals** | HTML, CSS, JavaScript, DOM, Git, Internet basics |
| **Build Tools** | npm/yarn/pnpm, Webpack, Vite, bundling, code splitting |
| **Frameworks** | React, Vue, Angular, Svelte component architecture |
| **State Management** | Redux, Zustand, Context API, MobX, state patterns |
| **Testing** | Jest, Vitest, Cypress, Playwright, RTL |
| **Performance** | Core Web Vitals, Lighthouse, optimization |
| **Advanced Topics** | TypeScript, PWA, SSR/SSG, Micro-frontends, Security |

---

## Agents Overview

### 7 Implementation Agents

Each agent is designed to **do the work**, not just explain:

| Agent | Capabilities | Example Prompts |
|-------|--------------|-----------------|
| **Fundamentals** | HTML/CSS, JavaScript, DOM, Git | `"Create responsive layout"`, `"Explain event loop"` |
| **Build Tools** | Package managers, bundlers, optimization | `"Configure Vite project"`, `"Set up Webpack"` |
| **Frameworks** | React, Vue, Angular, Svelte | `"Create React component"`, `"Build Vue composable"` |
| **State Management** | Redux, Zustand, Context, patterns | `"Implement Redux store"`, `"Create Zustand slice"` |
| **Testing** | Unit, integration, E2E testing | `"Write Jest tests"`, `"Create Playwright E2E"` |
| **Performance** | Web Vitals, optimization, profiling | `"Optimize bundle size"`, `"Improve LCP"` |
| **Advanced Topics** | TypeScript, PWA, SSR, security | `"Add TypeScript types"`, `"Implement CSP"` |

---

## Commands

7 interactive commands for frontend workflows:

| Command | Usage | Description |
|---------|-------|-------------|
| `/fundamentals` | `/fundamentals` | Start with web fundamentals |
| `/build-tools` | `/build-tools` | Learn package managers and bundlers |
| `/frameworks` | `/frameworks` | Explore React, Vue, Angular, Svelte |
| `/state-management` | `/state-management` | Master state patterns |
| `/testing` | `/testing` | Learn testing strategies |
| `/performance` | `/performance` | Optimize web performance |
| `/advanced-topics` | `/advanced-topics` | TypeScript, PWA, SSR, Security |

---

## Skills Reference

Each skill includes **Golden Format** content:
- `assets/` - YAML templates and configurations
- `scripts/` - Automation scripts
- `references/` - Methodology guides

### All 41 Skills by Category

| Category | Skills |
|----------|--------|
| **Fundamentals** | html-css-essentials, javascript-fundamentals, dom-manipulation, internet-basics, git-version-control |
| **Build Tools** | npm-yarn-pnpm, webpack-advanced, vite-bundling, code-splitting-bundling, code-quality-linting |
| **React** | react-fundamentals, react-hooks-patterns, context-api-hooks, context-api-patterns |
| **Vue** | vue-composition-api, vue-composition-api-advanced |
| **Angular** | angular-dependency-injection |
| **Svelte** | svelte-reactivity-stores |
| **State** | redux-fundamentals, redux-state-management, zustand-lightweight-state, zustand-minimalist, state-patterns-architecture |
| **Testing** | unit-testing-jest-vitest, e2e-testing-cypress-playwright, component-testing-libraries |
| **Performance** | core-web-vitals, web-vitals-lighthouse, devtools-profiling, browser-devtools, bundle-analysis-splitting, asset-optimization, image-optimization, code-splitting-lazy-loading, code-splitting-optimization |
| **Advanced** | typescript-enterprise-patterns, pwa-offline-first, ssr-ssg-frameworks, micro-frontend-architecture, web-security-implementation, architectural-patterns |

---

## Usage Examples

### Example 1: Create React Component

```tsx
// Before: Basic component without patterns

// After (with Frameworks agent):
Skill("custom-plugin-frontend:react-fundamentals")

// Generates:
// - Functional component with hooks
// - TypeScript interfaces
// - Proper prop validation
// - Performance optimizations (memo, useCallback)
```

### Example 2: Configure Vite Project

```javascript
// Before: Manual configuration

// After (with Build Tools agent):
Skill("custom-plugin-frontend:vite-bundling")

// Provides:
// - vite.config.ts template
// - Path aliases setup
// - Environment variables
// - Build optimization config
```

### Example 3: Implement Redux Store

```typescript
// Before: Boilerplate Redux setup

// After (with State Management agent):
Skill("custom-plugin-frontend:redux-fundamentals")

// Creates:
// - Redux Toolkit slice
// - TypeScript types
// - Async thunks
// - Selector patterns
```

---

## Learning Paths

| Path | Duration | Focus |
|------|----------|-------|
| React Full-Stack | 12-16 weeks | React ecosystem complete |
| Vue Specialist | 10-14 weeks | Vue 3 Composition API |
| Enterprise Angular | 14-18 weeks | Angular with RxJS |
| TypeScript Master | 16-20 weeks | Full-stack TypeScript |

---

## Plugin Structure

```
custom-plugin-frontend/
├── .claude-plugin/
│   ├── plugin.json           # Plugin manifest
│   └── marketplace.json      # Marketplace config
├── agents/                   # 7 specialized agents
│   ├── fundamentals.md
│   ├── build-tools.md
│   ├── frameworks.md
│   ├── state-management.md
│   ├── testing.md
│   ├── performance.md
│   └── advanced-topics.md
├── skills/                   # 41 skills (Golden Format)
│   ├── react-fundamentals/
│   │   ├── SKILL.md
│   │   ├── assets/
│   │   ├── scripts/
│   │   └── references/
│   ├── vue-composition-api/
│   ├── angular-dependency-injection/
│   ├── typescript-enterprise-patterns/
│   └── ... (37 more skills)
├── commands/                 # 7 slash commands
│   ├── fundamentals.md
│   ├── build-tools.md
│   ├── frameworks.md
│   ├── state-management.md
│   ├── testing.md
│   ├── performance.md
│   └── advanced-topics.md
├── docs/
│   ├── QUICK_START.md
│   └── BEST_PRACTICES.md
├── hooks/hooks.json
├── README.md
├── CHANGELOG.md
├── CONTRIBUTING.md
└── LICENSE
```

---

## Technology Coverage

| Category | Technologies |
|----------|--------------|
| **Frameworks** | React, Vue 3, Angular, Svelte, Solid.js |
| **State** | Redux Toolkit, Zustand, Pinia, MobX, Jotai |
| **Build** | Vite, Webpack 5, esbuild, Rollup, Parcel |
| **Testing** | Jest, Vitest, Cypress, Playwright, RTL |
| **TypeScript** | Strict mode, generics, type guards |
| **Performance** | Core Web Vitals, Lighthouse, Chrome DevTools |

---

## Security Notice

This plugin is designed for **authorized development use only**:

**USE FOR:**
- Learning frontend development
- Building web applications
- Performance optimization
- Security implementation

**SECURITY TOPICS:**
- Cross-Origin Resource Sharing (CORS)
- Cross-Site Scripting (XSS) Prevention
- Cross-Site Request Forgery (CSRF)
- Content Security Policy (CSP)

---

## Contributing

Contributions are welcome:

1. Fork the repository
2. Create a feature branch
3. Follow the Golden Format for new skills
4. Submit a pull request

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

---

## Metadata

| Field | Value |
|-------|-------|
| **Last Updated** | 2025-12-28 |
| **Maintenance Status** | Active |
| **SASMP Version** | 1.3.0 |
| **Support** | [Issues](../../issues) |

---

## License

Custom License - See [LICENSE](LICENSE) for details.

---

## Contributors

**Authors:**
- **Dr. Umit Kacar** - Senior AI Researcher & Engineer
- **Muhsin Elcicek** - Senior Software Architect

---

<div align="center">

**Master frontend development with AI assistance!**

[![Made for Frontend](https://img.shields.io/badge/Made%20for-Frontend-61DAFB?style=for-the-badge&logo=react)](https://github.com/pluginagentmarketplace/custom-plugin-frontend)

**Built by Dr. Umit Kacar & Muhsin Elcicek**

*Based on [roadmap.sh/frontend](https://roadmap.sh/frontend)*

</div>
