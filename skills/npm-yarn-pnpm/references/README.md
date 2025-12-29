# npm-yarn-pnpm References

This directory contains comprehensive guides and design patterns for Node.js package managers (npm, Yarn, pnpm).

## Available References

### GUIDE.md - Complete Technical Guide
Comprehensive guide covering:
- npm, Yarn, and pnpm comparison and features
- Lock file strategies and formats
- Package manager configuration
- Monorepo and workspace patterns
- Semantic versioning and version constraints
- npm scripts and automation
- Registry configuration and authentication
- Performance optimization techniques
- Dependency resolution strategies
- Node version constraints and engines field

**Covers 600+ technical details** with real configuration examples.

### PATTERNS.md - Design Patterns & Strategies
15 production-ready design patterns including:

1. **Monorepo with Shared Dependencies** - Centralized dependency management
2. **Private Package Publishing** - Internal package distribution
3. **Workspace Scripts Orchestration** - Cross-workspace command execution
4. **Dependency Pinning and Versions** - Version constraint strategies
5. **Peer Dependency Management** - Handling peer dependencies correctly
6. **Lockfile Strategy** - Reproducible installs across teams
7. **Breaking Change Management** - Major version update workflows
8. **Conditional Dependencies** - Platform/environment-specific packages
9. **Private Registry Configuration** - Enterprise npm registries
10. **Dependency Deduplication** - Reducing node_modules bloat
11. **CI/CD Optimization** - Pipeline-specific settings
12. **Version Bump Workflow** - Semantic versioning automation
13. **Workspace-Specific Scripts** - Filtering and targeted execution
14. **Cross-Platform Lock Files** - Platform-specific handling
15. **Dependency Constraint Enforcement** - Rules and validation

Each pattern includes:
- Real-world use cases
- Code examples
- Configuration templates
- Best practices
- Common pitfalls to avoid

## Quick Links

### By Task

**Setting up a monorepo:**
- GUIDE.md - Monorepo Best Practices section
- PATTERNS.md - Patterns 1, 3, 4, 13, 14

**Managing dependencies:**
- GUIDE.md - Dependency Management & Resolution sections
- PATTERNS.md - Patterns 4, 5, 8, 10, 15

**Publishing packages:**
- GUIDE.md - Registry Configuration section
- PATTERNS.md - Patterns 2, 9

**CI/CD integration:**
- GUIDE.md - Performance Tips section
- PATTERNS.md - Pattern 11

**Version management:**
- GUIDE.md - Semantic Versioning & Resolution sections
- PATTERNS.md - Patterns 7, 12

### By Package Manager

**npm specific:**
- GUIDE.md - npm section with .npmrc config
- PATTERNS.md - Patterns 6 (npm ci usage), 10 (dedupe)

**Yarn specific:**
- GUIDE.md - Yarn section with workspace & .yarnrc.yml config
- PATTERNS.md - Patterns 3 (workspace scripts), 9 (registry config)

**pnpm specific:**
- GUIDE.md - pnpm section with filtering & catalog features
- PATTERNS.md - Pattern 4 (catalog usage), 11 (CI/CD with pnpm)

## Learning Path

### Beginner
1. Read GUIDE.md - Comparison Overview
2. Choose preferred package manager section
3. Study PATTERNS.md - Pattern 1 (monorepo basics)

### Intermediate
1. GUIDE.md - Dependency Resolution section
2. PATTERNS.md - Patterns 3-6 (workspace & dependency management)
3. PATTERNS.md - Pattern 11 (CI/CD setup)

### Advanced
1. GUIDE.md - All sections for deep understanding
2. PATTERNS.md - All patterns, especially 7, 12, 15 (version & constraint management)
3. Integrate patterns into your monorepo structure

## Key Concepts

**Lock Files** - Ensure reproducible installs
- npm: package-lock.json (v3 format with nested structure)
- Yarn: yarn.lock (text-based format)
- pnpm: pnpm-lock.yaml (YAML format)

**Workspaces** - Monorepo dependency management
- npm/Yarn: Built-in workspaces field in package.json
- pnpm: pnpm-workspace.yaml with catalog support

**Semantic Versioning** - Version constraint strategies
- `^` - Compatible versions (minor updates allowed)
- `~` - Patch-level updates only
- `*` - Latest version (use with caution)

**Peer Dependencies** - Library compatibility requirements
- Used by libraries to declare peer assumptions
- Can be optional or required
- Handle version conflicts carefully

**Package Manager Configuration**
- .npmrc for npm settings
- .yarnrc.yml for Yarn v3+
- .pnpmrc for pnpm settings

## Tools & Commands

### Validation Scripts
Use provided scripts to validate:
```bash
./scripts/validate-package-manager.sh  # Check config & consistency
```

### Generation Scripts
Auto-generate configurations:
```bash
./scripts/generate-package-manager-config.sh  # Create config files
```

## Best Practices Summary

1. **Always commit lock files** to version control
2. **Use `npm ci` (or equivalent)** in CI/CD pipelines
3. **Define Node version constraints** in engines field
4. **Use semantic versioning** for consistency
5. **Implement peer dependency checks** in monorepos
6. **Optimize workspace structures** for scalability
7. **Automate version bumping** with changesets
8. **Test across all package managers** if supporting multiple
9. **Document your monorepo structure** clearly
10. **Review and update dependencies** regularly

## Further Reading

- npm Official Docs: https://docs.npmjs.com
- Yarn Official Docs: https://yarnpkg.com/docs
- pnpm Official Docs: https://pnpm.io
- Semantic Versioning: https://semver.org
- Node.js Version Management: https://nodejs.org/en/download/package-manager
