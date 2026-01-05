# Changelog

All notable changes to the Frontend Development Assistant plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [2.0.3] - 2026-01-05

### Fixed
- **CRITICAL**: Fixed `/plugin add marketplace` → `/plugin marketplace add` command syntax
  - Previous documentation had incorrect command order
  - Now follows official Claude Code CLI syntax
- Added comprehensive Troubleshooting section to README

### Added
- **E308 Error Documentation** - "Duplicate hooks file detected" troubleshooting guide
  - Root cause explanation (Claude Code v2.0.27+ auto-discovery)
  - Step-by-step fix instructions
  - Prevention guidelines
- **Plugin not loading** troubleshooting
- **Agents not appearing** troubleshooting

### Documentation
- README.md version updated to 2.0.3
- Last updated date: 2026-01-05

---

## [2.0.2] - 2025-12-28

### Changed
- README updated to match template v2.1.0 (18 required sections)
- Added Verified Installation notice
- Fixed Quick Start commands (`/plugin add marketplace` format)
- Added Available Skills table with `Skill("...")` invoke syntax
- Added Usage Examples section with before/after code
- Added Plugin Structure directory tree
- Added Technology Coverage table
- Added Learning Paths table
- Improved Commands section

### Fixed
- Quick Start commands now use proper `/plugin` format

---

## [2.0.1] - 2025-12-28

### Fixed
- **Documentation Sync** - Fixed skill count mismatch (28→41 in all documents)
- **plugin.json** - Added 13 missing skills to registration
- **README.md** - Updated badges, animated text, features table, metadata
- **marketplace.json** - Synced description with correct skill count
- **Agent Structure** - Removed nested `agents/*/skills/` old format directories

### Changed
- Version bump to 2.0.1 for documentation accuracy

---

## [2.0.0] - 2025-12-28

### Added
- **SASMP v1.3.0 Compliance** - Full Standard Agent-Skill Matching Protocol support
- **marketplace.json** - E303 collision prevention with proper naming
- **CONTRIBUTING.md** - Professional contributor guidelines
- **Golden Format** - All 41 skills now have assets/, scripts/, references/
- 6 new SKILL.md files for skills that were missing documentation:
  - git-version-control
  - javascript-fundamentals
  - react-fundamentals
  - vue-composition-api
  - code-splitting-lazy-loading
  - code-splitting-optimization
- Production-ready code templates for all skills

### Changed
- **Plugin Name**: `custom-plugin-frontend` -> `frontend-development-assistant`
- **plugin.json** - Updated to template v2.1.0 format
  - License: `SEE LICENSE IN LICENSE`
  - Author: Added URL field
- **hooks.json** - Fixed to valid format `{"hooks": {}}`
- **LICENSE** - Updated to MIT with Additional Terms
- **README.md** - Complete restructure with:
  - Animated typing header
  - Badge row (License, SASMP, Agents, Skills)
  - Table of Contents
  - Security Notice section
  - Metadata table
  - Contributors section
- All 41 skill `bonded_agent` values corrected to include `-agent` suffix

### Fixed
- E303 name collision prevention (marketplace.name ≠ plugin.name)
- Agent-Skill bond alignment (E502 prevention)
- Invalid hooks.json event names removed
- Missing SKILL.md files created for 6 skills
- Orphan skill `architectural-patterns` bonded to `07-advanced-topics-agent`

### Security
- Added Security Notice section in README
- Documented security topics covered (CORS, XSS, CSRF, CSP)

---

## [1.0.0] - 2025-01-01

### Added

#### Core Plugin Structure
- `.claude-plugin/plugin.json` - Plugin manifest with official Claude Code format
- 7 specialized agents with YAML frontmatter
- Comprehensive plugin documentation (README.md, plugin.md)
- Quick start guide for users
- Best practices documentation

#### Agents (7 Total)
1. **Frontend Fundamentals Agent** - HTML, CSS, JavaScript, Git, DOM (4-6 weeks)
2. **Package Managers & Build Tools Agent** - NPM, Yarn, Webpack, Vite (3-4 weeks)
3. **Frontend Frameworks Agent** - React, Vue, Angular, Svelte (6-8 weeks)
4. **State Management Agent** - Redux, Context API, Zustand, patterns (3-4 weeks)
5. **Testing & QA Agent** - Jest, Vitest, Cypress, Playwright (4-5 weeks)
6. **Performance Agent** - Web Vitals, Lighthouse, optimization (3-4 weeks)
7. **Advanced Topics Agent** - PWAs, Security, SSR/SSG, TypeScript (4-6 weeks)

#### Skills Infrastructure
- Foundation for skill modules in `skills/` directory
- Created first skill: `skills/html-css-essentials/SKILL.md`
- Prepared structure for 28+ additional skills

#### Documentation
- `docs/QUICK_START.md` - Comprehensive getting started guide
- `docs/BEST_PRACTICES.md` - Frontend development best practices
- `plugin.md` - Detailed plugin overview and usage guide

---

## Version History Summary

| Version | Date | Description |
|---------|------|-------------|
| 2.0.3 | 2026-01-05 | Fix plugin command syntax + E308 troubleshooting |
| 2.0.2 | 2025-12-28 | README template v2.1.0 compliance |
| 2.0.0 | 2025-12-28 | SASMP v1.3.0 + Template v2.1.0 compliance |
| 1.0.0 | 2025-01-01 | Initial release |

---

## Upgrade Guide

### From 1.x to 2.0.0

1. **Plugin renamed** - Now `frontend-development-assistant`
2. **marketplace.json required** - Must exist for installation
3. **Skill bonds updated** - All use `-agent` suffix now
4. **Golden Format** - Each skill has assets/, scripts/, references/

### Breaking Changes in 2.0.0

- Plugin name: `custom-plugin-frontend` -> `frontend-development-assistant`
- Marketplace name: `pluginagentmarketplace-frontend`
- Agent names now include `-agent` suffix

---

## Contributors

- **Dr. Umit Kacar** - Senior AI Researcher & Engineer
- **Muhsin Elcicek** - Senior Software Architect

---

*Last Updated: 2026-01-05*
