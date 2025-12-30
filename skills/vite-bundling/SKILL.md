---
name: vite-bundling
description: Master Vite's modern bundling approach with ESM, HMR, and native performance optimizations.
sasmp_version: "1.3.0"
bonded_agent: 02-build-tools-agent
bond_type: SECONDARY_BOND

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

# Vite Modern Bundling

> **Purpose:** Experience next-generation build tooling with Vite's lightning-fast development server and optimized production builds.

## Input/Output Schema

```typescript
interface ViteInput {
  projectPath: string;
  framework: 'react' | 'vue' | 'svelte' | 'vanilla';
  root?: string;
  buildMode: 'development' | 'production';
  serverPort?: number;
  enableSSR?: boolean;
  libraryMode?: boolean;
}

interface ViteOutput {
  configPath: string;
  buildSuccess: boolean;
  buildStats: {
    totalSize: number;
    assets: Array<{
      name: string;
      size: number;
      type: string;
    }>;
    chunks: Array<{
      name: string;
      size: number;
    }>;
  };
  serverUrl?: string;
  buildTime: number;
  warnings: string[];
  errors: string[];
}

interface ViteConfig {
  root: string;
  base: string;
  publicDir: string;
  resolve: {
    alias: Record<string, string>;
    extensions: string[];
  };
  server: {
    port: number;
    host: string | boolean;
    https: boolean;
    proxy: Record<string, any>;
  };
  build: {
    outDir: string;
    assetsDir: string;
    sourcemap: boolean;
    minify: boolean | 'esbuild' | 'terser';
  };
}
```

## MANDATORY
- Native ES modules in development
- Vite project creation and setup (`npm create vite@latest`)
- Configuration with vite.config.ts
- Hot Module Replacement (HMR)
- Framework plugins (@vitejs/plugin-react, @vitejs/plugin-vue)
- Production builds with Rollup

## OPTIONAL
- Environment variables (.env files, import.meta.env)
- CSS preprocessors (Sass, Less, Stylus)
- Path aliases configuration (@/ for src)
- Proxy configuration for APIs
- Multi-page applications
- Library mode builds

## ADVANCED
- SSR configuration (Server-Side Rendering)
- Custom plugins development
- Build optimization strategies
- Pre-bundling configuration (optimizeDeps)
- Worker threads support
- Advanced Rollup configuration (rollupOptions)

## Error Handling

| Error | Root Cause | Solution |
|-------|-----------|----------|
| `Failed to resolve import` | Missing module or incorrect path | Check import path, install dependency, configure alias |
| `The requested module does not provide an export` | Import/export mismatch | Verify named vs default exports |
| `Transform failed` | Syntax error or unsupported feature | Check file syntax, add plugin for feature support |
| `EADDRINUSE: Port already in use` | Port conflict | Change port in vite.config.ts or kill process on port |
| `Pre-transform error` | Dependency optimization issue | Clear .vite cache: `rm -rf node_modules/.vite` |
| `Cannot find module '@/'` | Alias not configured | Add resolve.alias in vite.config.ts |
| `Plugin [name] error` | Plugin configuration issue | Review plugin setup, check compatibility |
| `Build failed with chunk size warnings` | Large chunks exceeding limits | Configure build.rollupOptions.output.manualChunks |

## Test Template

```typescript
// vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
      '@components': path.resolve(__dirname, './src/components'),
      '@utils': path.resolve(__dirname, './src/utils'),
    },
  },
  server: {
    port: 3000,
    host: true,
    proxy: {
      '/api': {
        target: 'http://localhost:8080',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api/, ''),
      },
    },
  },
  build: {
    outDir: 'dist',
    sourcemap: true,
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          utils: ['lodash', 'axios'],
        },
      },
    },
    chunkSizeWarningLimit: 1000,
  },
  optimizeDeps: {
    include: ['react', 'react-dom'],
    exclude: ['@your/large-dep'],
  },
});

// Test script (package.json)
{
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "test:build": "vite build && vite preview"
  }
}
```

```javascript
// Environment variable usage
// .env.development
VITE_API_URL=http://localhost:8080
VITE_APP_TITLE=My App Dev

// .env.production
VITE_API_URL=https://api.production.com
VITE_APP_TITLE=My App

// Usage in code
const apiUrl = import.meta.env.VITE_API_URL;
const title = import.meta.env.VITE_APP_TITLE;
```

## Best Practices

1. **Use Native ESM**: Leverage Vite's native ES module support for faster dev server
2. **Environment Variables**: Prefix with `VITE_` to expose to client-side code
3. **Path Aliases**: Configure aliases for cleaner imports and better refactoring
4. **Pre-bundling**: Optimize dependencies with optimizeDeps for faster startup
5. **Production Builds**: Use esbuild for fast minification, terser for smaller bundles
6. **Source Maps**: Enable in production for debugging, disable for final builds
7. **Chunk Splitting**: Use manualChunks for strategic code splitting
8. **CSS Code Splitting**: Vite automatically splits CSS per component
9. **Asset Handling**: Use `?url` suffix for asset URLs, `?raw` for raw strings
10. **Plugin Order**: Place framework plugins before other plugins

## Assets
- See `assets/vite-config.yaml` for configuration patterns

## Resources
- [Vite Documentation](https://vitejs.dev/)
- [Vite Plugins](https://vitejs.dev/plugins/)
- [Vite Guide](https://vitejs.dev/guide/)
- [Vite Config Reference](https://vitejs.dev/config/)
- [Awesome Vite](https://github.com/vitejs/awesome-vite)

---
**Status:** Active | **Version:** 2.0.0
