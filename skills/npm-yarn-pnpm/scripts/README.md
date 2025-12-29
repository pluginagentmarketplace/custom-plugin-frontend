# npm-yarn-pnpm Scripts

This directory contains validation and generation scripts for package manager configuration and project management.

## Available Scripts

### validate-npm.sh
Validates package manager configuration, lock files, dependencies, and monorepo setup.

**Usage:**
```bash
./scripts/validate-npm.sh [PROJECT_DIR]
```

**Checks:**
- Package manager detection (npm, yarn, pnpm)
- `package.json` structure and required fields
- Lock file consistency (package-lock.json, yarn.lock, pnpm-lock.yaml)
- Dependencies organization (dependencies, devDependencies, peerDependencies)
- npm/yarn/pnpm configuration files (.npmrc, .yarnrc.yml, .pnpmrc)
- Monorepo workspace configuration
- Node version constraints (engines field)
- Lock file synchronization

**Example:**
```bash
./scripts/validate-npm.sh /path/to/project
```

### generate-npm-config.sh
Generates package manager configuration files with best practices.

**Usage:**
```bash
./scripts/generate-npm-config.sh [OUTPUT_DIR]
```

**Generates:**
- `.npmrc` - npm configuration with security and performance settings
- `.yarnrc.yml` - Yarn 3+ configuration with plugin settings
- `pnpm-workspace.yaml` - pnpm monorepo configuration with catalog
- Workspace-aware configurations for monorepo projects

**Example:**
```bash
./scripts/generate-npm-config.sh /path/to/project
```

## Script Features

### Validation Script
- Color-coded output (green for success, red for errors, yellow for warnings)
- Comprehensive package.json validation
- Lock file format verification
- Dependency tree integrity checks
- Workspace/monorepo detection
- Version constraint validation
- npm scripts inventory

### Generation Script
- Creates production-ready configurations
- Security-focused npm settings (audit, security levels)
- Performance optimizations (timeouts, retries)
- Workspace configuration templates
- Catalog-based dependency management (pnpm)
- Plugin configuration for Yarn Berry
- Cross-platform compatibility

## Configuration Files Created

### .npmrc
Registry configuration, authentication, audit settings, fetch timeouts

### .yarnrc.yml
Node linker mode, script enablement, plugin definitions, install state management

### pnpm-workspace.yaml
Package paths, catalog definitions, version constraints for centralized dependency management

## Best Practices

1. Run validation before and after dependency updates
2. Commit lock files to version control
3. Use `npm ci` (or equivalent) in CI/CD pipelines
4. Generate configurations at project setup
5. Validate after adding new packages
6. Check workspace configuration for monorepo projects
