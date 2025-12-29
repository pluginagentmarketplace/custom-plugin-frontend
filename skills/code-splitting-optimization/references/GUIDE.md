# Code-Splitting & Bundle Optimization Guide

## Overview

Code-splitting is a technique to divide your application into smaller chunks that are loaded on-demand, reducing the initial bundle size and improving performance. This guide covers webpack and Vite implementations.

## Dynamic Imports and Chunking

### Basic Dynamic Import

```javascript
// Traditional static import
import Button from './components/Button';

// Dynamic import creates a separate chunk
const ButtonLazy = () => import('./components/Button');

// In code:
const handleClick = async () => {
  const { default: Button } = await import('./components/Button');
  // Use Button...
};
```

### Webpack Magic Comments

Control chunk naming and prefetching:

```javascript
// Named chunk
import(
  /* webpackChunkName: "admin-panel" */
  './admin/AdminPanel'
);

// Prefetch hint - load when browser is idle
import(
  /* webpackChunkName: "analytics" */
  /* webpackPrefetch: true */
  './analytics/Analytics'
);

// Preload hint - load in parallel with current chunk
import(
  /* webpackChunkName: "critical-feature" */
  /* webpackPreload: true */
  './features/Critical'
);

// Combine options
import(
  /* webpackChunkName: "dashboard" */
  /* webpackPrefetch: true */
  /* webpackMode: "eager" */
  './dashboard/Dashboard'
);
```

## Bundle Analysis and Optimization

### Webpack Bundle Structure

```javascript
// webpack.config.js optimization
optimization: {
  splitChunks: {
    chunks: 'all',
    minSize: 20000,
    maxAsyncRequests: 30,
    cacheGroups: {
      // Separate vendor libraries
      vendor: {
        test: /[\\/]node_modules[\\/]/,
        name: 'vendors',
        priority: 10,
      },
      // Extract React separately
      react: {
        test: /[\\/]node_modules[\\/](react|react-dom)[\\/]/,
        name: 'react-vendors',
        priority: 20,
      },
      // Common code shared by multiple chunks
      common: {
        minChunks: 2,
        priority: 5,
        reuseExistingChunk: true,
      },
    },
  },
  // Separate runtime into its own chunk
  runtimeChunk: {
    name: 'runtime',
  },
  // Deterministic module IDs
  moduleIds: 'deterministic',
},
```

### Vite Bundle Configuration

```typescript
// vite.config.ts
build: {
  rollupOptions: {
    output: {
      manualChunks: {
        react: ['react', 'react-dom', 'react-router-dom'],
        ui: ['@mui/material', '@mui/icons-material'],
        utils: ['lodash-es', 'axios'],
      },
    },
  },
  chunkSizeWarningLimit: 500,
  cssCodeSplit: true,
}
```

## Tree-Shaking and Minification

### Enable Tree-Shaking

```javascript
// webpack.config.js
module: {
  rules: [
    {
      test: /\.(js|jsx)$/,
      use: {
        loader: 'babel-loader',
        options: {
          presets: [
            [
              '@babel/preset-env',
              {
                modules: false, // Essential for tree-shaking
              },
            ],
          ],
        },
      },
    },
  ],
},
```

```json
// package.json
{
  "sideEffects": [
    "*.css",
    "src/index.js"
  ]
}
```

### Minification with Terser

```javascript
// webpack.config.js
optimization: {
  minimize: true,
  minimizer: [
    new TerserPlugin({
      terserOptions: {
        compress: {
          drop_console: true,
          dead_code: true,
        },
        mangle: true,
        output: {
          comments: false,
        },
      },
      extractComments: false,
    }),
  ],
},
```

## Source Maps Configuration

### Development Source Maps

```javascript
// webpack.config.js
devtool: 'cheap-module-source-map', // Fast rebuild, good mapping

// Vite (automatic in dev mode)
sourcemap: true, // in vite.config.ts build options
```

### Production Source Maps

```javascript
// webpack.config.js
devtool: isProduction ? 'source-map' : 'cheap-module-source-map'
```

Manage production source maps separately:
- Upload to error tracking service (Sentry, Rollbar)
- Store securely, don't ship with bundle

## Lazy Loading Patterns

### React.lazy() and Suspense

```jsx
import React, { Suspense, lazy } from 'react';

// Create lazy component
const Dashboard = lazy(() => import('./pages/Dashboard'));
const Analytics = lazy(() => import('./pages/Analytics'));

// Loading fallback
function LoadingSpinner() {
  return <div>Loading...</div>;
}

// Use with Suspense
function App() {
  return (
    <Suspense fallback={<LoadingSpinner />}>
      <Dashboard />
    </Suspense>
  );
}
```

### Named Lazy Components

```jsx
const Dashboard = lazy(() =>
  import(/* webpackChunkName: "dashboard" */ './pages/Dashboard')
);

// With webpack preload
const CriticalFeature = lazy(() =>
  import(
    /* webpackChunkName: "critical" */
    /* webpackPreload: true */
    './features/Critical'
  )
);
```

### Error Boundaries for Lazy Components

```jsx
class ErrorBoundary extends React.Component {
  state = { hasError: false };

  static getDerivedStateFromError(error) {
    return { hasError: true };
  }

  componentDidCatch(error, errorInfo) {
    console.error('Chunk loading failed:', error);
  }

  render() {
    if (this.state.hasError) {
      return <h2>Failed to load component</h2>;
    }
    return this.props.children;
  }
}

function App() {
  return (
    <ErrorBoundary>
      <Suspense fallback={<Loading />}>
        <Dashboard />
      </Suspense>
    </ErrorBoundary>
  );
}
```

## Route-Based Code-Splitting

### React Router v6 Setup

```jsx
import { lazy, Suspense } from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';

// Lazy load route components
const Home = lazy(() => import('./pages/Home'));
const Products = lazy(() =>
  import(/* webpackChunkName: "products" */ './pages/Products')
);
const Admin = lazy(() =>
  import(/* webpackChunkName: "admin" */ './pages/Admin')
);

function App() {
  return (
    <BrowserRouter>
      <Suspense fallback={<LoadingPage />}>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/products" element={<Products />} />
          <Route path="/admin/*" element={<Admin />} />
        </Routes>
      </Suspense>
    </BrowserRouter>
  );
}
```

## Chunk Prefetching and Preloading

### Link Prefetch

```html
<!-- Hint browser to prefetch chunk when idle -->
<link rel="prefetch" href="/js/dashboard.abc123.js" />

<!-- Or preload (fetch immediately) -->
<link rel="preload" href="/js/critical.def456.js" as="script" />
```

### Programmatic Prefetch

```javascript
// Prefetch chunk when user hovers over a link
function ProductLink() {
  const handleMouseEnter = () => {
    import(/* webpackPrefetch: true */ './pages/Product');
  };

  return (
    <a href="/products" onMouseEnter={handleMouseEnter}>
      Products
    </a>
  );
}
```

## Asset Optimization

### Image Optimization

```javascript
// webpack.config.js
{
  test: /\.(png|jpg|jpeg|gif|webp)$/,
  type: 'asset',
  parser: {
    dataUrlCondition: {
      maxSize: 8 * 1024, // Inline small images
    },
  },
  generator: {
    filename: 'images/[name].[hash:8][ext]',
  },
}
```

### CSS Code-Splitting

```javascript
// webpack.config.js
plugins: [
  new MiniCssExtractPlugin({
    filename: '[name].[contenthash:8].css',
    chunkFilename: '[name].[contenthash:8].chunk.css',
  }),
],
```

```typescript
// vite.config.ts
build: {
  cssCodeSplit: true, // Automatic CSS chunk splitting
}
```

## Bundle Analysis Tools

### Webpack Bundle Analyzer

```javascript
// webpack.config.js
const { BundleAnalyzerPlugin } = require('webpack-bundle-analyzer');

plugins: [
  process.env.ANALYZE && new BundleAnalyzerPlugin(),
].filter(Boolean),

// Run: ANALYZE=true npm run build
```

### Vite Visualizer

```bash
npm install --save-dev rollup-plugin-visualizer
```

```typescript
// vite.config.ts
import { visualizer } from 'rollup-plugin-visualizer';

plugins: [
  visualizer({
    open: true,
    gzipSize: true,
    brotliSize: true,
  }),
]
```

## Performance Metrics

### Measuring Chunk Loading

```javascript
// Measure dynamic import time
async function loadFeature() {
  const start = performance.now();

  const module = await import('./features/Heavy');

  const duration = performance.now() - start;
  console.log(`Chunk loaded in ${duration}ms`);

  return module;
}
```

### Monitoring with Web Vitals

```javascript
import { getCLS, getFID, getFCP, getLCP, getTTFB } from 'web-vitals';

// Track Core Web Vitals
getCLS(console.log); // Cumulative Layout Shift
getFID(console.log); // First Input Delay
getFCP(console.log); // First Contentful Paint
getLCP(console.log); // Largest Contentful Paint
getTTFB(console.log); // Time to First Byte
```

## Performance Budget

### Setting Size Limits

```javascript
// webpack.config.js
performance: {
  maxEntrypointSize: 512000, // 500KB
  maxAssetSize: 512000,
  hints: 'warning', // or 'error'
},
```

```typescript
// vite.config.ts
build: {
  chunkSizeWarningLimit: 500, // 500KB
  rollupOptions: {
    output: {
      // Custom chunk size tracking
      manualChunks(id) {
        if (id.includes('node_modules')) {
          return 'vendor';
        }
      },
    },
  },
}
```

## Best Practices Summary

1. **Separate vendor libraries** into their own chunks
2. **Extract common code** that's shared across multiple chunks
3. **Use named chunks** with webpackChunkName comments
4. **Implement error boundaries** for lazy-loaded components
5. **Add loading indicators** for better UX
6. **Prefetch non-critical chunks** when appropriate
7. **Analyze bundle regularly** with bundle analyzer
8. **Set performance budgets** and monitor them
9. **Use deterministic module IDs** for stable hashes
10. **Enable source maps** in staging/production for debugging
