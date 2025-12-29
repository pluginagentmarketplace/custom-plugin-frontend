# Package Manager Guide: npm, Yarn, pnpm

## Comparison Overview

| Feature | npm | Yarn | pnpm |
|---------|-----|------|------|
| Speed | Medium | Fast | Fastest |
| Disk Space | High | High | Minimal |
| Monorepo | Fair | Excellent | Excellent |
| Hoisting | Yes | Yes | No |
| Lock File | package-lock.json | yarn.lock | pnpm-lock.yaml |

## npm (Node Package Manager)

### Installation and Basic Usage

```bash
# Install dependencies
npm install

# Install specific version
npm install react@18.2.0

# Save to devDependencies
npm install --save-dev typescript

# Update packages
npm update
npm update react --save
```

### npm Configuration

```bash
# Set registry
npm config set registry https://registry.npmjs.org/

# Set authentication token
npm config set //registry.npmjs.org/:_authToken=YOUR_TOKEN

# View all config
npm config list
```

### Managing Dependencies

```json
{
  "dependencies": {
    "react": "^18.2.0"
  },
  "devDependencies": {
    "typescript": "^5.0.0"
  },
  "peerDependencies": {
    "react": ">=17.0.0"
  },
  "optionalDependencies": {
    "fsevents": "optional-package"
  }
}
```

## Yarn (v1 and v3+)

### Installation and Basic Usage

```bash
# Install dependencies
yarn install

# Add package
yarn add react
yarn add -D typescript

# Remove package
yarn remove react

# Update packages
yarn upgrade
yarn upgrade react
```

### Yarn Workspaces (Monorepo)

```json
{
  "workspaces": [
    "packages/*",
    "apps/*"
  ]
}
```

```bash
# Install all workspace dependencies
yarn install

# Run script in all workspaces
yarn workspaces run build

# Run script in specific workspace
yarn workspace @myapp/ui build
```

### Yarn Berry Features (v3+)

```bash
# Enable Yarn Berry
corepack enable

# Create new project with Yarn v3
yarn create vite my-app
```

### .yarnrc.yml Configuration

```yaml
nodeLinker: node-modules
enableScripts: true

plugins:
  - path: .yarn/plugins/@yarnpkg/plugin-workspace-tools.cjs
    spec: "@yarnpkg/plugin-workspace-tools"

catalogs:
  default:
    react: 18.2.0
    react-dom: 18.2.0
```

## pnpm (Performant npm)

### Installation and Basic Usage

```bash
# Install pnpm
npm install -g pnpm

# Install dependencies
pnpm install

# Add package
pnpm add react
pnpm add -D typescript

# Remove package
pnpm remove react

# Update packages
pnpm update
pnpm update react
```

### pnpm Monorepo Setup

```yaml
# pnpm-workspace.yaml
packages:
  - 'packages/*'
  - 'apps/*'

catalog:
  react: ^18.2.0
  react-dom: ^18.2.0
  typescript: ^5.0.0
```

```bash
# Install workspace dependencies
pnpm install

# Run script in workspace
pnpm -r build

# Run script in specific package
pnpm -C packages/ui build
```

### Filtering and Recursion

```bash
# Run command in specific packages
pnpm -r --filter web build

# Run only in packages that changed
pnpm -r --changed build

# Run command before dependency builds
pnpm -r --depth=10 build
```

### Dependency Management

```json
{
  "dependencies": {
    "react": "catalog:react"
  }
}
```

## Lock File Management

### npm package-lock.json

```json
{
  "name": "my-app",
  "version": "1.0.0",
  "lockfileVersion": 3,
  "packages": {
    "": {
      "name": "my-app",
      "version": "1.0.0",
      "dependencies": {
        "react": "^18.2.0"
      }
    },
    "node_modules/react": {
      "version": "18.2.0"
    }
  }
}
```

### Yarn yarn.lock

```
react@^18.2.0:
  version "18.2.0"
  resolved "https://registry.npmjs.org/react/-/react-18.2.0.tgz"
  integrity sha512-5e9fWUEHfnxLqOc8GNVnEz96c0q2Zr6HKkHyIVXdxPMsqpQW+S+n8xGKWxRhFDNV2Ou8EsrF4mK5L/HT2zcbg==
```

### pnpm pnpm-lock.yaml

```yaml
lockfileVersion: '6.0'

packages:
  react@18.2.0:
    resolution: {integrity: sha512-...}
    peerDependencies:
      react-dom: 18.2.0
```

## Performance Tips

### npm Optimization

```bash
# Use npm ci for CI/CD (faster, more reliable)
npm ci

# Prune unnecessary packages
npm prune

# Audit vulnerabilities
npm audit
npm audit fix
```

### Yarn Optimization

```bash
# Use PnP for reduced node_modules
yarn install --pnp

# Zero-install with git
yarn install --immutable
```

### pnpm Performance

```bash
# pnpm is fastest by default
# Use store hard-linking for additional speed
pnpm config set store-dir ~/.pnpm-store

# Manage monorepo efficiently
pnpm -r --depth=10 build
```

## Dependency Resolution

### Version Specifiers

```json
{
  "react": "18.2.0",      // Exact version
  "react": "^18.2.0",     // Compatible with version
  "react": "~18.2.0",     // Patch updates only
  "react": ">18.0.0",     // Greater than
  "react": "*",           // Latest version
  "react": "18.2.0 || 17.0.0"  // Multiple versions
}
```

### Resolution Strategies

```bash
# Resolve conflicting dependencies
npm ls react  # Show dependency tree

# Force specific resolution
npm dedupe

# Peer dependency issues
npm install --legacy-peer-deps
```

## Monorepo Best Practices

1. **Centralized Node Modules**: Share dependencies across packages
2. **Workspace Scripts**: Define scripts in workspace root
3. **Semantic Versioning**: Use consistent versioning strategy
4. **Publish Workflow**: Automate version bumping and publishing
5. **Dependency Constraints**: Restrict which packages can depend on others

