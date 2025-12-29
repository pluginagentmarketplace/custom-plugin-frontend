# Vite Design Patterns & Best Practices

## Pattern 1: Multi-Environment Configuration

Manage different environments (dev, staging, prod) with Vite:

```typescript
// vite.config.ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig(({ command, mode }) => {
  const isProduction = mode === 'production'

  return {
    plugins: [react()],
    define: {
      __DEV__: !isProduction,
      __VERSION__: JSON.stringify(process.env.npm_package_version),
    },
    server: {
      proxy: mode === 'development' ? {
        '/api': 'http://localhost:3001'
      } : undefined,
    },
    build: {
      sourcemap: !isProduction,
      rollupOptions: {
        output: {
          manualChunks: isProduction ? {
            vendor: ['react', 'react-dom'],
          } : undefined,
        },
      },
    },
  }
})
```

## Pattern 2: Monorepo Configuration

Configure Vite for monorepo workspaces:

```typescript
// packages/app/vite.config.ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@ui': path.resolve(__dirname, '../ui/src'),
      '@utils': path.resolve(__dirname, '../utils/src'),
    },
  },
  optimizeDeps: {
    include: ['@ui', '@utils'],
  },
})
```

## Pattern 3: Custom Plugin for Vue Components

Create a plugin to handle custom component transformations:

```typescript
import type { Plugin } from 'vite'

export function customComponentPlugin(): Plugin {
  return {
    name: 'custom-component',
    apply: 'serve',
    enforce: 'pre',

    async transform(code, id) {
      if (id.endsWith('.component.ts')) {
        return {
          code: `
            import { defineComponent } from 'vue'
            ${code}
            export const metadata = {
              name: '${id}',
              version: '1.0.0'
            }
          `,
          map: null,
        }
      }
    },
  }
}
```

## Pattern 4: Virtual Modules

Create virtual modules for dynamically generated content:

```typescript
import type { Plugin } from 'vite'
import path from 'path'

const virtualModuleId = 'virtual-module'
const resolvedId = '\0' + virtualModuleId

export function virtualModulePlugin(): Plugin {
  const modules: Record<string, string> = {
    'routes': `
      export const routes = [
        { path: '/', component: () => import('@/pages/Home') }
      ]
    `,
  }

  return {
    name: 'virtual-module',

    resolveId(id) {
      if (id === virtualModuleId) return resolvedId
    },

    load(id) {
      if (id === resolvedId) {
        return `export const modules = ${JSON.stringify(modules)}`
      }
    },
  }
}

// Usage: import { modules } from 'virtual-module'
```

## Pattern 5: SSR-Optimized Configuration

Configure Vite for Server-Side Rendering:

```typescript
// vite.config.ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  build: {
    rollupOptions: {
      input: './src/entry-server.tsx',
      output: {
        format: 'esm',
        entryFileNames: '[name].mjs',
      },
    },
  },
  ssr: {
    external: ['react', 'react-dom'],
    noExternal: ['antd', '@mui/material'],
  },
})
```

## Pattern 6: Conditional Imports

Use import.meta.glob for dynamic imports with code splitting:

```typescript
// Load all components from a directory
const componentModules = import.meta.glob('../components/**/*.tsx', { eager: true })

const components: Record<string, any> = {}
for (const [path, module] of Object.entries(componentModules)) {
  const name = path.split('/').pop()?.replace('.tsx', '') || ''
  components[name] = (module as any).default
}

// Use dynamic import for lazy loading
const lazyComponents = import.meta.glob('../components/**/*.tsx', { import: 'default' })
```

## Pattern 7: Image Optimization Plugin

Create a plugin to optimize images:

```typescript
import type { Plugin } from 'vite'
import fs from 'fs'
import path from 'path'

export function imageOptimizationPlugin(): Plugin {
  return {
    name: 'image-optimization',

    async transform(code, id) {
      if (/\.(png|jpg|jpeg|gif)$/.test(id)) {
        const buffer = fs.readFileSync(id)
        const size = buffer.length

        if (size > 100 * 1024) {
          console.warn(`Image ${path.basename(id)} is ${size / 1024}kb`)
        }

        return {
          code: `export default ${JSON.stringify({
            src: id,
            size,
            width: 'auto',
            height: 'auto',
          })}`,
        }
      }
    },
  }
}
```

## Pattern 8: Pre-fetch Dependencies

Optimize dependency pre-bundling for faster builds:

```typescript
export default defineConfig({
  optimizeDeps: {
    include: [
      'react',
      'react-dom',
      'react-router-dom',
      'lodash-es',
      'axios',
    ],
    exclude: [
      '@my-org/local-lib',
      'file-saver', // Has side effects
    ],
    esbuildOptions: {
      target: 'esnext',
      define: {
        global: 'globalThis',
      },
    },
  },
})
```

## Pattern 9: Build Analysis

Analyze bundle composition and size:

```typescript
import { visualizer } from 'rollup-plugin-visualizer'

export default defineConfig({
  plugins: [
    visualizer({
      open: process.env.ANALYZE === 'true',
      gzipSize: true,
      brotliSize: true,
    }),
  ],
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          react: ['react', 'react-dom', 'react-router-dom'],
          ui: ['antd', '@emotion/react', '@emotion/styled'],
          utils: ['lodash-es', 'dayjs'],
        },
      },
    },
  },
})
```

## Pattern 10: CSS-in-JS Integration

Configure Vite with CSS-in-JS libraries:

```typescript
// vite.config.ts for Emotion
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [
    react({
      jsxImportSource: '@emotion/react',
      babel: {
        plugins: ['@emotion/babel-plugin'],
      },
    }),
  ],
})

// vite.config.ts for styled-components
export default defineConfig({
  plugins: [
    react({
      babel: {
        plugins: ['babel-plugin-styled-components'],
      },
    }),
  ],
})
```

## Pattern 11: Module Federation

Share code between Vite applications:

```typescript
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { federation } from '@originjs/vite-plugin-federation'

// Host application
export default defineConfig({
  plugins: [
    react(),
    federation({
      name: 'host',
      remotes: {
        shared: 'http://localhost:3001/assets/remoteEntry.js',
      },
    }),
  ],
})

// Remote application
export default defineConfig({
  plugins: [
    react(),
    federation({
      name: 'shared',
      exposes: {
        './Button': './src/components/Button.tsx',
      },
    }),
  ],
})
```

## Pattern 12: Performance Monitoring

Add performance telemetry to builds:

```typescript
import { defineConfig } from 'vite'

export default defineConfig({
  plugins: [
    {
      name: 'performance-monitor',

      buildStart() {
        this.startTime = performance.now()
      },

      buildEnd() {
        const duration = performance.now() - this.startTime
        console.log(`Build completed in ${duration.toFixed(2)}ms`)
      },
    },
  ],
})
```

