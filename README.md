<div align="center">

<!-- Animated Typing Banner -->
<img src="https://readme-typing-svg.demolab.com?font=Fira+Code&weight=600&size=28&duration=3000&pause=1000&color=2E9EF7&center=true&vCenter=true&multiline=true&repeat=true&width=600&height=100&lines=Frontend+Assistant;8+Agents+%7C+41+Skills;Claude+Code+Plugin" alt="Frontend Assistant" />

<br/>

<!-- Badge Row 1: Status Badges -->
[![Version](https://img.shields.io/badge/Version-2.0.3-blue?style=for-the-badge)](https://github.com/pluginagentmarketplace/custom-plugin-frontend/releases)
[![License](https://img.shields.io/badge/License-Custom-yellow?style=for-the-badge)](LICENSE)
[![Status](https://img.shields.io/badge/Status-Production-brightgreen?style=for-the-badge)](#)
[![SASMP](https://img.shields.io/badge/SASMP-v1.3.0-blueviolet?style=for-the-badge)](#)

<!-- Badge Row 2: Content Badges -->
[![Agents](https://img.shields.io/badge/Agents-8-orange?style=flat-square&logo=robot)](#-agents)
[![Skills](https://img.shields.io/badge/Skills-41-purple?style=flat-square&logo=lightning)](#-skills)
[![Commands](https://img.shields.io/badge/Commands-7-green?style=flat-square&logo=terminal)](#-commands)

<br/>

<!-- Quick CTA Row -->
[📦 **Install Now**](#-quick-start) · [🤖 **Explore Agents**](#-agents) · [📖 **Documentation**](#-documentation) · [⭐ **Star this repo**](https://github.com/pluginagentmarketplace/custom-plugin-frontend)

---

### What is this?

> **Frontend Assistant** is a Claude Code plugin with **8 agents** and **41 skills** for frontend development.

</div>

---

## 📑 Table of Contents

<details>
<summary>Click to expand</summary>

- [Quick Start](#-quick-start)
- [Features](#-features)
- [Agents](#-agents)
- [Skills](#-skills)
- [Commands](#-commands)
- [Documentation](#-documentation)
- [Contributing](#-contributing)
- [License](#-license)

</details>

---

## 🚀 Quick Start

### Prerequisites

- Claude Code CLI v2.0.27+
- Active Claude subscription

### Installation (Choose One)

<details open>
<summary><strong>Option 1: From Marketplace (Recommended)</strong></summary>

```bash
# Step 1️⃣ Add the marketplace
/plugin marketplace add pluginagentmarketplace/custom-plugin-frontend

# Step 2️⃣ Install the plugin
/plugin install frontend-development-assistant@pluginagentmarketplace-frontend

# Step 3️⃣ Restart Claude Code
# Close and reopen your terminal/IDE
```

</details>

<details>
<summary><strong>Option 2: Local Installation</strong></summary>

```bash
# Clone the repository
git clone https://github.com/pluginagentmarketplace/custom-plugin-frontend.git
cd custom-plugin-frontend

# Load locally
/plugin load .

# Restart Claude Code
```

</details>

### ✅ Verify Installation

After restart, you should see these agents:

```
frontend-development-assistant:advanced-topics
frontend-development-assistant:frameworks
frontend-development-assistant:build-tools
frontend-development-assistant:state-management
frontend-development-assistant:testing
... and 2 more
```

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🤖 **8 Agents** | Specialized AI agents for frontend tasks |
| 🛠️ **41 Skills** | Reusable capabilities with Golden Format |
| ⌨️ **7 Commands** | Quick slash commands |
| 🔄 **SASMP v1.3.0** | Full protocol compliance |

---

## 🤖 Agents

### 8 Specialized Agents

| # | Agent | Purpose |
|---|-------|---------|
| 1 | **advanced-topics** | Master enterprise frontend development. Learn PWAs, security |
| 2 | **frameworks** | Master React, Vue, Angular, and Svelte. Learn component arch |
| 3 | **build-tools** | Master modern package managers and build tools. Learn NPM, Y |
| 4 | **state-management** | Master state management solutions and architectural patterns |
| 5 | **testing** | Master comprehensive testing strategies from unit to E2E. Le |
| 6 | **performance** | Master web performance optimization. Learn Core Web Vitals,  |
| 7 | **fundamentals** | Master web fundamentals, core technologies, version control, |

---

## 🛠️ Skills

### Available Skills

| Skill | Description | Invoke |
|-------|-------------|--------|
| `ssr-ssg-frameworks` | Master Next.js, Nuxt, and SSR/SSG patterns for server-side r | `Skill("frontend-development-assistant:ssr-ssg-frameworks")` |
| `bundle-analysis-splitting` | Analyze and optimize bundle sizes through code splitting, la | `Skill("frontend-development-assistant:bundle-analysis-splitting")` |
| `react-fundamentals` | Master React fundamentals - components, JSX, state, props, a | `Skill("frontend-development-assistant:react-fundamentals")` |
| `asset-optimization` | Master image optimization, modern formats (WebP, AVIF), resp | `Skill("frontend-development-assistant:asset-optimization")` |
| `e2e-testing-cypress-playwright` | Master end-to-end testing with Cypress and Playwright for co | `Skill("frontend-development-assistant:e2e-testing-cypress-playwright")` |
| `component-testing-libraries` | Master React Testing Library, Vue Test Utils, and user-centr | `Skill("frontend-development-assistant:component-testing-libraries")` |
| `redux-fundamentals` | Core Redux concepts including store setup, reducers, actions | `Skill("frontend-development-assistant:redux-fundamentals")` |
| `angular-dependency-injection` | Master Angular's dependency injection system, services, prov | `Skill("frontend-development-assistant:angular-dependency-injection")` |
| `dom-manipulation` | Master DOM selection, manipulation, event handling, and dyna | `Skill("frontend-development-assistant:dom-manipulation")` |
| `unit-testing-jest-vitest` | Master Jest and Vitest for unit testing with mocking, assert | `Skill("frontend-development-assistant:unit-testing-jest-vitest")` |
| ... | +31 more | See skills/ directory |

---

## ⌨️ Commands

| Command | Description |
|---------|-------------|
| `/advanced-topics` | topics |
| `/frameworks` | /frameworks |
| `/build-tools` | tools |
| `/state-management` | management |
| `/testing` | /testing |
| `/performance` | /performance |
| `/fundamentals` | /fundamentals |

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [CHANGELOG.md](CHANGELOG.md) | Version history |
| [CONTRIBUTING.md](CONTRIBUTING.md) | How to contribute |
| [LICENSE](LICENSE) | License information |

---

## 📁 Project Structure

<details>
<summary>Click to expand</summary>

```
custom-plugin-frontend/
├── 📁 .claude-plugin/
│   ├── plugin.json
│   └── marketplace.json
├── 📁 agents/              # 8 agents
├── 📁 skills/              # 41 skills (Golden Format)
├── 📁 commands/            # 7 commands
├── 📁 hooks/
├── 📄 README.md
├── 📄 CHANGELOG.md
└── 📄 LICENSE
```

</details>

---

## 📅 Metadata

| Field | Value |
|-------|-------|
| **Version** | 2.0.3 |
| **Last Updated** | 2026-01-05 |
| **Status** | Production Ready |
| **SASMP** | v1.3.0 |
| **Agents** | 8 |
| **Skills** | 41 |
| **Commands** | 7 |

---

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md).

1. Fork the repository
2. Create your feature branch
3. Follow the Golden Format for new skills
4. Submit a pull request

---

## ⚠️ Security

> **Important:** This repository contains third-party code and dependencies.
>
> - ✅ Always review code before using in production
> - ✅ Check dependencies for known vulnerabilities
> - ✅ Follow security best practices
> - ✅ Report security issues privately via [Issues](../../issues)

---

## 🔧 Troubleshooting

<details>
<summary><strong>E308: Duplicate hooks file detected</strong></summary>

**Error Message:**
```
Duplicate hooks file detected: ./hooks/hooks.json resolves to already-loaded file.
The standard hooks/hooks.json is loaded automatically, so manifest.hooks
should only reference additional hook files.
```

**Cause:** Claude Code v2.0.27+ auto-discovers `hooks/hooks.json` from the standard location. If `plugin.json` also has `"hooks": "./hooks/hooks.json"`, it creates a duplicate loading error.

**Fix:**
```bash
# 1. Navigate to plugin cache
cd ~/.claude/plugins/cache/pluginagentmarketplace-frontend/frontend-development-assistant/VERSION/

# 2. Edit plugin.json and REMOVE the "hooks" line
# Remove: "hooks": "./hooks/hooks.json"

# 3. Restart Claude Code
exit
claude
```

**Prevention:** Standard `hooks/hooks.json` location is auto-discovered. Only use `"hooks"` field in `plugin.json` for ADDITIONAL hook files, not the standard location.

</details>

<details>
<summary><strong>Plugin not loading after installation</strong></summary>

**Solutions:**
1. Restart Claude Code completely (close and reopen terminal)
2. Verify installation: `/plugin list`
3. Check settings.json has the plugin enabled
4. Clear cache: `rm -rf ~/.claude/plugins/cache/pluginagentmarketplace-frontend/`

</details>

<details>
<summary><strong>Agents not appearing</strong></summary>

**Solutions:**
1. Verify plugin is installed: `/plugin list`
2. Check for errors in plugin loading
3. Restart Claude Code after any plugin changes
4. Ensure Claude Code version is 2.0.27+

</details>

---

## 📝 License

Copyright © 2025 **Dr. Umit Kacar** & **Muhsin Elcicek**

Custom License - See [LICENSE](LICENSE) for details.

---

## 👥 Contributors

<table>
<tr>
<td align="center">
<strong>Dr. Umit Kacar</strong><br/>
Senior AI Researcher & Engineer
</td>
<td align="center">
<strong>Muhsin Elcicek</strong><br/>
Senior Software Architect
</td>
</tr>
</table>

---

<div align="center">

**Made with ❤️ for the Claude Code Community**

[![GitHub](https://img.shields.io/badge/GitHub-pluginagentmarketplace-black?style=for-the-badge&logo=github)](https://github.com/pluginagentmarketplace)

</div>
