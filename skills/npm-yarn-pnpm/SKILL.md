---
name: npm-yarn-pnpm
description: Master NPM, Yarn, and PNPM package managers. Learn dependency management, versioning, and monorepo setup.
sasmp_version: "1.3.0"
bonded_agent: 02-build-tools-agent
bond_type: PRIMARY_BOND

# Production Configuration
validation:
  input_schema: true
  output_schema: true

retry_logic:
  max_attempts: 3
  backoff: exponential
  initial_delay_ms: 1000

logging:
  level: INFO
  observability: true
---

# Package Managers (NPM, Yarn, PNPM)

> **Purpose:** Master modern package managers for dependency management, task automation, and monorepo orchestration.

## Input/Output Schema

```typescript
interface PackageManagerInput {
  manager: 'npm' | 'yarn' | 'pnpm';
  projectPath: string;
  command: 'install' | 'update' | 'audit' | 'publish' | 'run';
  packages?: string[];
  flags?: string[];
  workspaceMode?: boolean;
}

interface PackageManagerOutput {
  success: boolean;
  installedPackages: Array<{
    name: string;
    version: string;
    type: 'dependencies' | 'devDependencies' | 'peerDependencies';
  }>;
  lockFileUpdated: boolean;
  warnings: string[];
  errors: string[];
  auditResults?: {
    vulnerabilities: {
      low: number;
      moderate: number;
      high: number;
      critical: number;
    };
    totalDependencies: number;
  };
}

interface PackageJson {
  name: string;
  version: string;
  description?: string;
  main?: string;
  scripts: Record<string, string>;
  dependencies: Record<string, string>;
  devDependencies: Record<string, string>;
  peerDependencies?: Record<string, string>;
  engines?: Record<string, string>;
  workspaces?: string[];
}
```

## MANDATORY
- Package installation and management (install, uninstall, update)
- package.json and lock files (package-lock.json, yarn.lock, pnpm-lock.yaml)
- Semantic versioning (semver) - ^ vs ~ vs exact versions
- npm scripts for automation
- Development vs production dependencies (-D, --save-dev)
- Global vs local installations (-g flag)

## OPTIONAL
- Workspaces and monorepo management
- Security auditing (npm audit, yarn audit)
- Package publishing to registries
- Private registries configuration (.npmrc)
- Yarn PnP (Plug'n'Play) for zero-install
- PNPM strict dependencies and peer resolution

## ADVANCED
- Custom npm scripts with pre/post hooks
- Package linking for local development (npm link, yarn link)
- Patch-package for dependency fixes
- Monorepo tools (Turborepo, Nx, Lerna)
- Dependency version strategies (lockfile management)
- Publishing scoped packages (@org/package-name)

## Error Handling

| Error | Root Cause | Solution |
|-------|-----------|----------|
| `ENOENT: package.json not found` | Missing package.json | Initialize project: `npm init` or `npm init -y` |
| `Conflicting peer dependency` | Incompatible peer versions | Check version requirements, use --legacy-peer-deps |
| `EACCES: permission denied` | Insufficient permissions | Use sudo or fix npm permissions (change global dir) |
| `Unable to resolve dependency tree` | Version conflicts | Clear cache, delete node_modules and lock file, reinstall |
| `Package not found` | Invalid package name or registry | Verify package name, check registry URL in .npmrc |
| `Integrity checksum failed` | Corrupted download or lockfile | Clear cache, delete lock file, reinstall |
| `ERESOLVE unable to resolve dependency` | Peer dependency conflict | Use --force or --legacy-peer-deps (npm), resolutions (yarn) |
| `Workspace not found` | Incorrect workspace path | Check workspace paths in package.json workspaces field |

## Test Template

```json
// package.json
{
  "name": "my-project",
  "version": "1.0.0",
  "description": "Production-ready package configuration",
  "main": "dist/index.js",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview",
    "test": "vitest",
    "lint": "eslint src --ext ts,tsx",
    "format": "prettier --write \"src/**/*.{ts,tsx}\"",
    "prepare": "husky install",
    "precommit": "lint-staged",
    "audit:fix": "npm audit fix",
    "clean": "rm -rf dist node_modules"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "@types/react": "^18.2.0",
    "@typescript-eslint/eslint-plugin": "^6.0.0",
    "eslint": "^8.45.0",
    "prettier": "^3.0.0",
    "typescript": "^5.0.0",
    "vite": "^5.0.0",
    "vitest": "^1.0.0"
  },
  "engines": {
    "node": ">=18.0.0",
    "npm": ">=9.0.0"
  },
  "peerDependencies": {
    "react": "^18.0.0"
  }
}
```

```yaml
# .npmrc - NPM configuration
registry=https://registry.npmjs.org/
save-exact=false
package-lock=true
legacy-peer-deps=false
engine-strict=true
```

```yaml
# pnpm-workspace.yaml - PNPM monorepo
packages:
  - 'packages/*'
  - 'apps/*'
  - '!**/test/**'
```

```javascript
// Validation script
const { execSync } = require('child_process');

// Test installation
console.log('Testing package manager installation...');
try {
  execSync('npm install --dry-run', { stdio: 'inherit' });
  console.log('✓ Installation test passed');
} catch (error) {
  console.error('✗ Installation test failed');
  process.exit(1);
}

// Test audit
console.log('Running security audit...');
try {
  execSync('npm audit --audit-level=moderate', { stdio: 'inherit' });
  console.log('✓ Security audit passed');
} catch (error) {
  console.warn('⚠ Security vulnerabilities found');
}
```

## Best Practices

1. **Lock Files**: Always commit lock files for consistent installations
2. **Exact Versions**: Use exact versions for critical dependencies in production
3. **Security Audits**: Run `npm audit` or `yarn audit` regularly
4. **Clean Installs**: Use `npm ci` in CI/CD for reproducible builds
5. **Workspace Management**: Use workspaces for monorepos instead of manual linking
6. **Engine Specification**: Define Node/npm versions in package.json engines
7. **Script Organization**: Group scripts logically (dev, build, test, deploy)
8. **Dependency Pruning**: Regularly review and remove unused dependencies
9. **Private Packages**: Use .npmrc for private registry configuration
10. **Version Constraints**: Understand ^ (minor updates) vs ~ (patch updates)

## Assets
- See `assets/package-manager-config.yaml` for configuration patterns

## Resources
- [NPM Docs](https://docs.npmjs.com/)
- [Yarn Docs](https://yarnpkg.com/)
- [PNPM Docs](https://pnpm.io/)
- [Semantic Versioning](https://semver.org/)
- [npm Workspaces](https://docs.npmjs.com/cli/v7/using-npm/workspaces)

---
**Status:** Active | **Version:** 2.0.0
