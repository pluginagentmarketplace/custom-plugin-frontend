#!/bin/bash
# Generate Package Manager Configuration Files
# Part of npm-yarn-pnpm skill - Golden Format E703 Compliant

set -e

OUTPUT_DIR="${1:-.}"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Generating package manager configuration files...${NC}\n"

# 1. Generate .npmrc
echo "Creating .npmrc..."
cat > "$OUTPUT_DIR/.npmrc" << 'EOF'
# npm Registry Configuration
registry=https://registry.npmjs.org/

# Dependency Resolution
legacy-peer-deps=false
engine-strict=false
save-exact=false

# Security Settings
audit=true
audit-level=moderate
scope:@mycompany:registry=https://npm.mycompany.com

# Performance & Timeout Settings
fetch-timeout=60000
fetch-retry-mintimeout=10000
fetch-retry-maxtimeout=60000
fetch-retries=3

# Install Settings
prefer-offline=false
offline=false
progress=true

# Script Settings
ignore-scripts=false
script-shell=/bin/bash

# Package & Version Management
update-depth=depth:10
workspace-concurrency=4

# Authentication (use environment variables for security)
# //registry.npmjs.org/:_authToken=${NPM_TOKEN}
# //npm.mycompany.com/:_authToken=${COMPANY_NPM_TOKEN}
EOF
echo -e "${GREEN}✓ Generated .npmrc${NC}"

# 2. Generate .yarnrc.yml for Yarn v3+
echo "Creating .yarnrc.yml..."
cat > "$OUTPUT_DIR/.yarnrc.yml" << 'EOF'
# Yarn v3+ Configuration

# Node Module Resolution
nodeLinker: node-modules
# Alternative: pnp (for zero-install, faster installation)

# Script Execution
enableScripts: true
enableImmutableInstalls: false

# Registry Configuration
registries:
  npm: https://registry.npmjs.org
  "@mycompany": https://npm.mycompany.com

# Global Caches
globalFolder: ~/.yarn/global
cacheFolder: .yarn/cache

# Plugins & Extensions
plugins:
  - path: .yarn/plugins/@yarnpkg/plugin-workspace-tools.cjs
    spec: "@yarnpkg/plugin-workspace-tools"

# Installation State
installStatePath: .yarn/install-state.gz

# Telemetry (set to false to disable)
enableTelemetry: false

# Version Constraints
nodeRange: ">=18.0.0"

# Network Configuration
httpTimeout: 60000
networkConcurrency: 8

# Workspace Configuration (for monorepos)
# workspaceRoot: .
# workspacesEnabled: true

# Constraints File (for monorepo dependency rules)
# constraintsPath: .yarn/constraints.pro
EOF
echo -e "${GREEN}✓ Generated .yarnrc.yml${NC}"

# 3. Generate .pnpmrc for pnpm
echo "Creating .pnpmrc..."
cat > "$OUTPUT_DIR/.pnpmrc" << 'EOF'
# pnpm Configuration

# Registry & Scope Configuration
registry=https://registry.npmjs.org/
@mycompany:registry=https://npm.mycompany.com

# Installation Strategy
node-linker=hoisted
# Alternative: isolated, symlinked

# Performance
store-dir=~/.pnpm-store
shamefully-hoist=false
hoist-pattern[]=*

# Network Configuration
fetch-timeout=60000
fetch-retry-mintimeout=10000
fetch-retry-maxtimeout=60000

# Script Configuration
shell-emulator=true

# Dependency Resolution
strict-peer-dependencies=true
auto-install-peers=true

# Workspace Settings
recursive-install=true

# Lock File
lockfile=true
prefer-frozen-lockfile=true

# Virtual Store
virtual-store-dir=node_modules/.pnpm

# Engine Constraints
engine-strict=false
EOF
echo -e "${GREEN}✓ Generated .pnpmrc${NC}"

# 4. Generate pnpm-workspace.yaml for monorepo
echo "Creating pnpm-workspace.yaml..."
cat > "$OUTPUT_DIR/pnpm-workspace.yaml" << 'EOF'
# pnpm Workspace Configuration for Monorepo

packages:
  # Application packages
  - 'apps/*'

  # Library packages
  - 'packages/*'

  # Tools and utilities
  - 'tools/*'

# Dependency Catalog - Centralized version management
catalog:
  # React ecosystem
  react: ^18.2.0
  react-dom: ^18.2.0
  react-router: ^6.20.0

  # State management
  zustand: ^4.4.0

  # Type system
  typescript: ^5.3.0

  # Build tools
  vite: ^5.0.0
  webpack: ^5.89.0

  # Linting & Formatting
  eslint: ^8.54.0
  prettier: ^3.1.0

  # Testing
  vitest: ^1.0.0
  jest: ^29.7.0
  '@testing-library/react': ^14.1.0

  # Utils
  lodash-es: ^4.17.0
  axios: ^1.6.0

  # Development tools
  '@types/node': ^20.10.0
  '@types/react': ^18.2.0

# Workspace settings
pnpm:
  # Dependency overrides across all packages
  overrides:
    # Enforce specific versions globally
    # "some-package": "1.0.0"

  # Allow peer dependency deduplication
  peerDependencyRules:
    allowedVersions:
      react: ">=16.8.0"
    ignoreMissing:
      - "@babel/core"
EOF
echo -e "${GREEN}✓ Generated pnpm-workspace.yaml${NC}"

# 5. Generate .npmignore template
echo "Creating .npmignore..."
cat > "$OUTPUT_DIR/.npmignore" << 'EOF'
# Development files
.DS_Store
.env
.env.local
.env.*.local

# Build artifacts
dist/
build/
coverage/

# Dependencies
node_modules/
.pnpm-store/

# Package manager locks (if publishing a library)
# package-lock.json
# yarn.lock
# pnpm-lock.yaml

# Testing
*.test.ts
*.spec.ts
jest.config.js
vitest.config.js
__tests__/
test/

# Documentation & IDE
README.md
docs/
.vscode/
.idea/

# Git
.git/
.gitignore

# CI/CD
.github/
.gitlab-ci.yml

# Source maps
*.map

# TypeScript
tsconfig.json
*.d.ts.map
EOF
echo -e "${GREEN}✓ Generated .npmignore${NC}"

# 6. Summary
echo -e "\n${GREEN}=== Configuration Generation Complete ===${NC}\n"
echo "Generated configuration files:"
echo "  ✓ .npmrc - npm package manager config"
echo "  ✓ .yarnrc.yml - Yarn v3+ config"
echo "  ✓ .pnpmrc - pnpm config"
echo "  ✓ pnpm-workspace.yaml - pnpm monorepo setup"
echo "  ✓ .npmignore - publish exclusions"
echo ""
echo "Next steps:"
echo "  1. Review and customize .npmrc, .yarnrc.yml, .pnpmrc"
echo "  2. Update pnpm-workspace.yaml with your actual packages"
echo "  3. Run: npm install / yarn install / pnpm install"
echo "  4. Run validation: ./validate-package-manager.sh"
