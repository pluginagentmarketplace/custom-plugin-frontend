# Micro-Frontend Architecture Scripts

Module Federation and micro-frontend implementation scripts.

## Scripts

### `validate-mfe.sh`
Validates micro-frontend implementation:
- Webpack Module Federation configuration
- Component isolation and dependencies
- Version management and compatibility
- Iframe implementations (if used)
- Shared dependencies configuration
- Remote app registration

Usage:
```bash
./scripts/validate-mfe.sh /path/to/project
```

### `generate-mfe-config.sh`
Generates Module Federation setup:
- Webpack Module Federation configuration
- Host application configuration
- Remote micro-frontend setup
- Shared dependencies definition
- Dynamic loading configuration
- Version conflict resolution

Usage:
```bash
./scripts/generate-mfe-config.sh /path/to/project
```

## Micro-Frontend Approaches

| Approach | Tech | Pros | Cons |
|----------|------|------|------|
| Module Federation | Webpack 5 | Dynamic, integrated | Complex setup |
| iFrames | Any | Total isolation | Slow, limited sharing |
| Web Components | Browser API | Framework agnostic | Browser support |
| Monorepo | Yarn/PNPM | Shared code | Large builds |

## Key Concepts

- **Host**: Main application loading remotes
- **Remote**: Micro-frontend exposing components
- **Shared Dependencies**: Common libraries (React, Vue, etc.)
- **Dynamic Loading**: Load at runtime, not build time
- **Version Management**: Handle version conflicts gracefully
- **CSS Isolation**: Prevent style leakage between apps
