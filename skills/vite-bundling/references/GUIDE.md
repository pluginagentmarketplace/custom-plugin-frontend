# Vite Modern Bundling Guide

## Introduction to Vite

Vite (French for "fast") is a next-generation frontend build tool that dramatically improves the development experience through native ES modules and optimized production builds. Unlike webpack which bundles the entire application before serving, Vite leverages the browser's native module system during development.

## Development Experience

### Instant Server Start

Vite starts the dev server in milliseconds, not seconds. It only transpiles the currently served module on demand.

```bash
npm run dev  # Starts dev server instantly
# No bundling happens until you request a module
```

### Hot Module Replacement (HMR)

Vite provides blazing-fast HMR that feels instant, preserving application state.

```javascript
// HMR works automatically, but you can customize:
if (import.meta.hot) {
  import.meta.hot.accept(({ data }) => {
    // Custom HMR logic
  })
}
```

### Native ES Modules

Vite serves code exactly as written in development, leveraging native ES module support:

```javascript
// This is served directly to browser in dev
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
```

## Configuration Essentials

### Basic vite.config.ts

```typescript
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    open: true,
  },
  build: {
    outDir: 'dist',
    sourcemap: true,
  },
})
```

### Environment Variables

Vite exposes environment variables prefixed with VITE_ to client code:

```bash
# .env
VITE_API_URL=https://api.example.com

# .env.production
VITE_API_URL=https://prod-api.example.com
```

```javascript
// Access in code
const apiUrl = import.meta.env.VITE_API_URL
console.log(apiUrl) // https://api.example.com (dev) or https://prod-api.example.com (prod)
```

### Path Aliases

Configure convenient import paths:

```typescript
export default defineConfig({
  resolve: {
    alias: {
      '@': '/src',
      '@components': '/src/components',
      '@utils': '/src/utils',
      '@styles': '/src/styles',
    },
  },
})
```

## Plugin System

### Using Official Plugins

```typescript
import react from '@vitejs/plugin-react'
import vue from '@vitejs/plugin-vue'
import svgr from 'vite-plugin-svgr'

export default defineConfig({
  plugins: [
    react(),
    svgr(),
  ],
})
```

### Creating Custom Plugins

```typescript
import type { Plugin } from 'vite'

export function myPlugin(): Plugin {
  return {
    name: 'my-plugin',
    apply: 'serve',  // only apply in dev
    enforce: 'pre',  // apply before core plugins

    configResolved(resolvedConfig) {
      // Store config reference
    },

    transformIndexHtml: {
      order: 'pre',
      handler(html) {
        return html.replace(
          /<title>(.*?)<\/title>/,
          `<title>New Title</title>`
        )
      },
    },

    resolveId(id) {
      if (id === 'virtual-module') {
        return id  // Mark as resolved
      }
    },

    load(id) {
      if (id === 'virtual-module') {
        return 'export const msg = "from virtual module"'
      }
    },
  }
}
```

## Dependency Optimization

### Pre-bundling with esbuild

Vite automatically pre-bundles dependencies during development for faster resolution:

```typescript
export default defineConfig({
  optimizeDeps: {
    include: ['lodash-es', 'react'],
    exclude: ['my-native-module'],
    esbuildOptions: {
      target: 'esnext',
    },
  },
})
```

## Production Builds

### Rollup Configuration

Vite uses Rollup under the hood for production builds:

```typescript
export default defineConfig({
  build: {
    outDir: 'dist',
    sourcemap: 'hidden',  // Source maps for debugging
    minify: 'terser',     // or 'esbuild'
    target: 'esnext',
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          ui: ['antd', '@emotion/react'],
        },
        entryFileNames: 'js/[name].[hash].js',
        chunkFileNames: 'js/[name].[hash].chunk.js',
        assetFileNames: 'assets/[name].[hash][extname]',
      },
    },
  },
})
```

### Code Splitting

Vite automatically splits code based on entry points and manual chunks:

```typescript
// Automatic chunk for shared code
export default defineConfig({
  build: {
    rollupOptions: {
      output: {
        // Vendor chunk
        manualChunks(id) {
          if (id.includes('node_modules')) {
            return id.split('/').pop()
          }
        },
      },
    },
  },
})
```

## Server Configuration

### Dev Server Proxy

```typescript
export default defineConfig({
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:5000',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api/, ''),
      },
    },
  },
})
```

### CORS and Headers

```typescript
export default defineConfig({
  server: {
    cors: true,
    headers: {
      'X-Custom-Header': 'value',
    },
  },
})
```

## Performance Tips

1. **Use Vite's automatic code splitting** - No manual configuration needed for basic splitting
2. **Leverage dynamic imports** - Use top-level await and dynamic imports for lazy loading
3. **Optimize dependencies** - Pre-bundle heavy dependencies with optimizeDeps
4. **Monitor bundle size** - Use rollup-plugin-visualizer for bundle analysis
5. **Cache busting** - Vite automatically handles cache busting with hashes

## Comparison: Dev vs Production

| Aspect | Dev | Production |
|--------|-----|-----------|
| Bundling | None - Uses native modules | Full bundling with Rollup |
| Minification | No | Yes (Terser/esbuild) |
| Code splitting | No | Automatic |
| Speed | Instant | Optimized |
| Source maps | Yes | Optional |

