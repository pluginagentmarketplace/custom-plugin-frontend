# Code Splitting & Optimization Guide

## What is Code Splitting?

Code splitting divides your application bundle into smaller chunks that are loaded on demand. Instead of shipping one large bundle, the browser downloads only the code needed for the current page or interaction.

## Entry Point Splitting

Create separate bundles for different entry points:

```javascript
// webpack.config.js
module.exports = {
  entry: {
    main: './src/index.js',
    admin: './src/admin/index.js',
    checkout: './src/checkout/index.js'
  },
  output: {
    filename: '[name].[contenthash].js'
  }
}
```

## Dynamic Import (Lazy Loading)

Use dynamic imports to load code on demand:

```javascript
// Before: Synchronous import
import { HeavyComponent } from './components/HeavyComponent'

// After: Dynamic import for lazy loading
const HeavyComponent = lazy(() => import('./components/HeavyComponent'))

// In React
import { Suspense } from 'react'

function App() {
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <HeavyComponent />
    </Suspense>
  )
}
```

## Route-Based Code Splitting

Split code based on application routes:

```javascript
// React Router v6
import { lazy, Suspense } from 'react'

const Home = lazy(() => import('./pages/Home'))
const About = lazy(() => import('./pages/About'))
const Dashboard = lazy(() => import('./pages/Dashboard'))

function App() {
  return (
    <Routes>
      <Route
        path="/"
        element={
          <Suspense fallback={<Spinner />}>
            <Home />
          </Suspense>
        }
      />
      <Route
        path="/about"
        element={
          <Suspense fallback={<Spinner />}>
            <About />
          </Suspense>
        }
      />
    </Routes>
  )
}
```

## Vendor Code Splitting

Separate third-party libraries from application code:

```javascript
// webpack.config.js
optimization: {
  splitChunks: {
    chunks: 'all',
    cacheGroups: {
      vendor: {
        test: /[\\/]node_modules[\\/]/,
        name: 'vendors',
        priority: 10,
        reuseExistingChunk: true,
      },
      react: {
        test: /[\\/]node_modules[\\/](react|react-dom)[\\/]/,
        name: 'react-vendor',
        priority: 20,
      },
    },
  },
}
```

## Webpack Magic Comments

Control chunk names and preloading behavior:

```javascript
// Named chunk with magic comment
const module = import(
  /* webpackChunkName: "module-name" */
  /* webpackPrefetch: true */
  './heavy-module'
)

// Preload critical chunk
const critical = import(
  /* webpackChunkName: "critical" */
  /* webpackPreload: true */
  './critical-module'
)

// Exclude from loading
const optional = import(
  /* webpackIgnore: true */
  'https://external-lib.com/lib.js'
)
```

## Reducing Initial Bundle Size

### Analyze Bundle

```javascript
// webpack.config.js
const { BundleAnalyzerPlugin } = require('webpack-bundle-analyzer')

plugins: process.env.ANALYZE ? [
  new BundleAnalyzerPlugin()
] : []

// Run with: ANALYZE=true npm run build
```

### Tree Shaking

Enable tree shaking to remove unused code:

```javascript
// webpack.config.js
mode: 'production',
optimization: {
  usedExports: true,
  sideEffects: false,
}

// package.json
{
  "sideEffects": false  // Mark module as side-effect free
}
```

### Minification

```javascript
// webpack.config.js
optimization: {
  minimize: true,
  minimizer: [
    new TerserPlugin({
      terserOptions: {
        compress: {
          drop_console: true
        }
      }
    })
  ]
}
```

## Performance Metrics

### Monitoring Split Chunks

```javascript
// Measure chunk loading performance
window.performance.addEventListener('measure', (e) => {
  if (e.detail.name.startsWith('chunk-')) {
    console.log(`Chunk ${e.detail.name}: ${e.detail.duration}ms`)
  }
})
```

### Bundle Size Budgets

```javascript
// webpack.config.js
performance: {
  hints: 'warning',
  maxEntrypointSize: 512000,
  maxAssetSize: 512000,
}
```

## Vite Code Splitting

```javascript
// vite.config.js
export default {
  build: {
    rollupOptions: {
      output: {
        manualChunks(id) {
          if (id.includes('node_modules')) {
            return 'vendor'
          }
        },
      },
    },
  },
}
```

## Best Practices

1. **Split by Route**: Code split major application routes
2. **Vendor Separation**: Keep third-party code separate for better caching
3. **Analyze Regularly**: Monitor bundle size in CI/CD
4. **Prefetch/Preload**: Use magic comments for critical chunks
5. **Lazy Load Heavy Components**: Components with large dependencies should be lazy loaded
6. **Monitor Performance**: Track chunk loading times in production

