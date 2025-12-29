# Package Manager Design Patterns & Strategies

## Pattern 1: Monorepo with Shared Dependencies

Centralize common dependencies to reduce duplication and ensure consistency:

```json
// Root package.json
{
  "workspaces": ["packages/*"],
  "devDependencies": {
    "typescript": "^5.0.0",
    "eslint": "^8.0.0",
    "prettier": "^3.0.0"
  }
}

// packages/ui/package.json
{
  "name": "@myapp/ui",
  "dependencies": {
    "react": "workspace:*"
  }
}

// packages/api/package.json
{
  "name": "@myapp/api",
  "dependencies": {
    "express": "^4.18.0"
  }
}
```

## Pattern 2: Private Package Publishing

Maintain private packages within monorepo:

```json
{
  "name": "@mycompany/internal-lib",
  "version": "1.0.0",
  "private": true,
  "publishConfig": {
    "registry": "https://npm.mycompany.com"
  }
}
```

## Pattern 3: Workspace Scripts Orchestration

Execute commands across multiple workspaces:

```json
// Root package.json
{
  "scripts": {
    "build": "pnpm -r build",
    "test": "pnpm -r test",
    "lint": "pnpm -r lint",
    "format": "pnpm -r exec prettier --write .",
    "changeset": "pnpm changeset",
    "publish": "pnpm changeset publish"
  }
}
```

```bash
# Yarn workspaces equivalent
yarn workspaces run build
yarn workspace @myapp/ui build
```

## Pattern 4: Dependency Pinning and Versions

Enforce consistent versions across workspace:

```yaml
# pnpm-workspace.yaml (pnpm 7+)
packages:
  - 'packages/*'

catalog:
  react: ^18.2.0
  react-dom: ^18.2.0
  typescript: ^5.0.0
  prettier: ^3.0.0
  eslint: ^8.0.0

# packages/ui/package.json
{
  "dependencies": {
    "react": "catalog:react",
    "react-dom": "catalog:react-dom"
  }
}
```

## Pattern 5: Peer Dependency Management

Properly declare and handle peer dependencies:

```json
{
  "name": "react-plugin",
  "peerDependencies": {
    "react": ">=16.8.0",
    "react-dom": ">=16.8.0"
  },
  "peerDependenciesMeta": {
    "react": {
      "optional": true
    }
  },
  "devDependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  }
}
```

## Pattern 6: Lockfile Strategy

Ensure reproducible installs across teams and CI:

```bash
# npm - Always use ci in CI/CD
npm ci --legacy-peer-deps

# Yarn - Use immutable install
yarn install --immutable --immutable-cache

# pnpm - Use frozen lockfile
pnpm install --frozen-lockfile
```

## Pattern 7: Breaking Change Management

Manage major version updates across monorepo:

```bash
# Check which packages need updates
pnpm outdated

# Update specific package carefully
pnpm update @types/react --depth=10

# Review changes
git diff package.json pnpm-lock.yaml
```

## Pattern 8: Conditional Dependencies

Include dependencies based on environment or platform:

```json
{
  "dependencies": {
    "react": "^18.2.0"
  },
  "devDependencies": {
    "jest": "^29.0.0"
  },
  "optionalDependencies": {
    "fsevents": "^2.3.0"
  },
  "bundledDependencies": [
    "lodash-es"
  ]
}
```

## Pattern 9: Private Registry Configuration

Use private registries for internal packages:

```bash
# .npmrc configuration
@mycompany:registry=https://npm.mycompany.com
//npm.mycompany.com/:_authToken=YOUR_TOKEN

# Yarn configuration (.yarnrc.yml)
registries:
  npm: https://registry.npmjs.org
  "@mycompany": https://npm.mycompany.com

  authenticateMessage: |
    Please provide your credentials for @mycompany

# pnpm configuration (.pnpmrc)
registry=https://registry.npmjs.org
@mycompany:registry=https://npm.mycompany.com
```

## Pattern 10: Dependency Deduplication

Reduce duplicate packages in node_modules:

```bash
# npm - Deduplicate
npm dedupe

# Yarn - Extract common dependencies
yarn install --check-files

# pnpm - Automatically deduplicated via symlinks
pnpm install
```

## Pattern 11: CI/CD Optimization

Optimize package manager for CI pipelines:

```yaml
# GitHub Actions example
name: CI

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [18, 20]

    steps:
      - uses: actions/checkout@v3

      - name: Setup pnpm
        uses: pnpm/action-setup@v2
        with:
          version: 8

      - name: Setup Node
        uses: actions/setup-node@v3
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'pnpm'

      - name: Install dependencies
        run: pnpm install --frozen-lockfile

      - name: Build
        run: pnpm build
```

## Pattern 12: Version Bump Workflow

Automate semantic versioning and changelog:

```bash
# Using changesets
pnpm add -D @changesets/cli

# Create changeset
pnpm changeset

# Generate version bumps
pnpm changeset version

# Publish to registry
pnpm changeset publish
```

```json
// .changeset/config.json
{
  "changelog": "@changesets/cli/changelog",
  "commit": false,
  "fixed": [],
  "linked": [],
  "access": "public",
  "baseBranch": "main",
  "updateInternalDependencies": "patch"
}
```

## Pattern 13: Workspace-Specific Scripts

Run scripts in specific workspaces only:

```bash
# pnpm - Filter by name
pnpm -r --filter @myapp/ui build

# pnpm - Filter changed packages
pnpm -r --changed build

# Yarn
yarn workspace @myapp/ui build
yarn workspaces foreach -A build

# npm - No native support, use custom scripts
npm run build --workspace=@myapp/ui
```

## Pattern 14: Cross-Platform Lock Files

Handle platform-specific dependencies:

```bash
# pnpm - Automatically resolves platform-specific
pnpm install

# Yarn - Ensure lock file is generated on all platforms
yarn install --network-timeout 100000

# npm - Handle platform-specific in npm scripts
"postinstall": "npm run native:build || true"
```

## Pattern 15: Dependency Constraint Enforcement

Define and enforce dependency rules:

```json
// .npmrc
legacy-peer-deps=true
audit-level=moderate

// pnpm-workspace.yaml
pnpm:
  overrides:
    webpack: ^5.0.0

// package.json
{
  "engines": {
    "node": ">=18.0.0",
    "npm": ">=9.0.0"
  }
}
```

