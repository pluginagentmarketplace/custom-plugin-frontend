# Code-Splitting & Bundle Optimization Design Patterns

## Pattern 1: Vendor Chunk Separation

Isolate all third-party dependencies into a separate vendor chunk for better caching:

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
        enforce: true,
      },
    },
  },
},

// Output:
// - main.a1b2c3d4.js (application code)
// - vendors.e5f6g7h8.js (node_modules)
// Benefits: Vendor rarely changes, stays cached
```

## Pattern 2: React/Framework-Specific Chunk

Separate React and related packages into its own chunk:

```javascript
cacheGroups: {
  react: {
    test: /[\\/]node_modules[\\/](react|react-dom|react-router|react-router-dom)[\\/]/,
    name: 'react-vendors',
    priority: 20,
    enforce: true,
  },
},

// Large frameworks get their own optimized chunk
// Benefit: Framework updates don't invalidate entire vendor cache
```

## Pattern 3: UI Framework Separation

Separate Material-UI, Ant Design, or similar bulky libraries:

```javascript
cacheGroups: {
  ui: {
    test: /[\\/]node_modules[\\/](@mui|antd|bootstrap)[\\/]/,
    name: 'ui-vendors',
    priority: 15,
    enforce: true,
  },
},

// Or custom grouping:
charts: {
  test: /[\\/]node_modules[\\/](recharts|d3|plotly)[\\/]/,
  name: 'chart-libraries',
  priority: 14,
},
```

## Pattern 4: Common Code Extraction

Extract code shared between multiple chunks:

```javascript
cacheGroups: {
  common: {
    minChunks: 2,  // Used by at least 2 chunks
    priority: 5,
    reuseExistingChunk: true,
    name: 'common',
  },
},

// Example: utils, shared components, constants
// Benefit: Avoid duplication across chunks
```

## Pattern 5: Route-Based Code-Splitting with Error Handling

Load routes dynamically with proper error handling:

```jsx
import { lazy, Suspense } from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';

const Home = lazy(() => import(/* webpackChunkName: "home" */ './pages/Home'));
const Dashboard = lazy(() => import(/* webpackChunkName: "dashboard" */ './pages/Dashboard'));
const Admin = lazy(() => import(/* webpackChunkName: "admin" */ './pages/Admin'));
const NotFound = lazy(() => import(/* webpackChunkName: "404" */ './pages/NotFound'));

class RouteErrorBoundary extends React.Component {
  state = { hasError: false };

  static getDerivedStateFromError() {
    return { hasError: true };
  }

  componentDidCatch(error, errorInfo) {
    console.error('Route chunk failed to load:', error);
    // Send to error tracking
  }

  render() {
    if (this.state.hasError) {
      return <ErrorFallback />;
    }
    return this.props.children;
  }
}

function App() {
  return (
    <BrowserRouter>
      <RouteErrorBoundary>
        <Suspense fallback={<PageLoader />}>
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/dashboard" element={<Dashboard />} />
            <Route path="/admin/*" element={<Admin />} />
            <Route path="*" element={<NotFound />} />
          </Routes>
        </Suspense>
      </RouteErrorBoundary>
    </BrowserRouter>
  );
}
```

## Pattern 6: Modal and Feature-Based Chunking

Lazy load heavy modals and features on-demand:

```jsx
const DeleteConfirmModal = lazy(() =>
  import(/* webpackChunkName: "delete-modal" */ './modals/DeleteConfirm')
);

const ReportGenerator = lazy(() =>
  import(/* webpackChunkName: "reports" */ './features/ReportGenerator')
);

function DataTable({ data }) {
  const [showDeleteModal, setShowDeleteModal] = useState(false);

  const handleDelete = async () => {
    const { default: Modal } = await import(
      /* webpackChunkName: "delete-modal" */
      './modals/DeleteConfirm'
    );
    setShowDeleteModal(true);
  };

  return (
    <>
      <table>{/* table content */}</table>
      {showDeleteModal && (
        <Suspense fallback={null}>
          <DeleteConfirmModal onClose={() => setShowDeleteModal(false)} />
        </Suspense>
      )}
    </>
  );
}
```

## Pattern 7: Prefetch Non-Critical Chunks

Prefetch chunks during idle time for better perceived performance:

```jsx
import { useEffect } from 'react';

function HeaderNav() {
  useEffect(() => {
    // Prefetch on hover or route anticipation
    const link = document.createElement('link');
    link.rel = 'prefetch';
    link.href = '/js/dashboard.chunk.js';
    document.head.appendChild(link);

    // Or with import:
    const prefetchChunk = () => {
      import(/* webpackPrefetch: true */ './pages/Dashboard');
    };

    // Prefetch when user hovers dashboard link
    const dashLink = document.querySelector('[href="/dashboard"]');
    if (dashLink) {
      dashLink.addEventListener('mouseenter', prefetchChunk);
    }

    return () => dashLink?.removeEventListener('mouseenter', prefetchChunk);
  }, []);

  return <nav>{/* nav content */}</nav>;
}
```

## Pattern 8: Async Components with Loading States

Wrap lazy components with proper loading and error states:

```jsx
function AsyncBoundary({ children, fallback, error: ErrorComponent }) {
  return (
    <ErrorBoundary fallback={<ErrorComponent />}>
      <Suspense fallback={fallback}>
        {children}
      </Suspense>
    </ErrorBoundary>
  );
}

function Dashboard() {
  const AdminPanel = lazy(() =>
    import(/* webpackChunkName: "admin" */ './AdminPanel')
  );

  return (
    <AsyncBoundary
      fallback={<SkeletonLoader />}
      error={<ErrorMessage msg="Failed to load admin panel" />}
    >
      <AdminPanel />
    </AsyncBoundary>
  );
}
```

## Pattern 9: Tree-Shaking with Side Effects

Configure proper side effects handling for optimal tree-shaking:

```json
// package.json
{
  "sideEffects": [
    "*.css",
    "*.scss",
    "src/index.js",
    "src/polyfills.js"
  ]
}
```

```javascript
// webpack.config.js
mode: 'production', // Enables tree-shaking by default

module: {
  rules: [
    {
      test: /\.js$/,
      use: {
        loader: 'babel-loader',
        options: {
          presets: [
            [
              '@babel/preset-env',
              {
                modules: false, // Keep ES modules for tree-shaking
              },
            ],
          ],
        },
      },
    },
  ],
},
```

## Pattern 10: Deterministic Chunk IDs

Ensure stable chunk hashes for long-term caching:

```javascript
optimization: {
  moduleIds: 'deterministic',
  runtimeChunk: 'single',
  splitChunks: {
    cacheGroups: {
      vendor: {
        test: /[\\/]node_modules[\\/]/,
        name: 'vendors',
        priority: 10,
        reuseExistingChunk: true,
        enforce: true,
      },
    },
  },
},

// Benefits:
// - Same code = same hash
// - Changes only affect modified chunks
// - Better long-term browser caching
```

## Pattern 11: Dynamic Component Loading by Feature Flag

Load components conditionally based on feature flags:

```jsx
function FeatureGate({ feature, children, fallback }) {
  const isEnabled = useFeatureFlag(feature);
  const Component = lazy(() =>
    isEnabled
      ? import(/* webpackChunkName: "feature-x" */ './FeatureX')
      : Promise.resolve(() => fallback || null)
  );

  return (
    <Suspense fallback={null}>
      <Component />
    </Suspense>
  );
}

// Usage
<FeatureGate feature="new-ui">
  <NewUIVersion />
</FeatureGate>
```

## Pattern 12: Critical vs Non-Critical Chunks

Separate critical chunks (preload) from non-critical (prefetch):

```javascript
// Critical chunks needed immediately
const Dashboard = lazy(() =>
  import(/* webpackChunkName: "dashboard" */ /* webpackPreload: true */ './Dashboard')
);

// Non-critical, nice-to-have chunks
const Analytics = lazy(() =>
  import(/* webpackChunkName: "analytics" */ /* webpackPrefetch: true */ './Analytics')
);

// Regular async chunks (loaded when needed)
const Reports = lazy(() =>
  import(/* webpackChunkName: "reports" */ './Reports')
);
```

## Pattern 13: Bundle Size Monitoring

Track and alert on bundle size increases:

```javascript
// webpack.config.js with size limits
performance: {
  maxEntrypointSize: 512000, // 500KB
  maxAssetSize: 512000,
  hints: process.env.NODE_ENV === 'production' ? 'error' : 'warning',
},

// Or with custom plugin:
class BudgetPlugin {
  apply(compiler) {
    compiler.hooks.done.tap('BudgetPlugin', (stats) => {
      const assets = stats.compilation.assets;
      Object.entries(assets).forEach(([name, source]) => {
        const size = source.size();
        if (size > 512000) {
          console.warn(`${name} exceeds budget: ${size / 1024}KB`);
        }
      });
    });
  }
}
```

## Pattern 14: Analyzing Chunk Dependencies

Visualize and optimize chunk dependencies:

```bash
# Generate bundle report
webpack-bundle-analyzer dist/stats.json

# Or with Vite
npm run build -- --analyze
```

```javascript
// Review build stats
const stats = require('./dist/stats.json');

stats.chunks.forEach(chunk => {
  console.log(`Chunk: ${chunk.name}`);
  console.log(`  Size: ${chunk.size / 1024}KB`);
  console.log(`  Modules: ${chunk.modules.length}`);
  console.log(`  Entry: ${chunk.entry}`);
});
```

## Pattern 15: Progressive Enhancement with Vite

Use Vite's automatic code-splitting for progressive loading:

```typescript
// vite.config.ts
export default {
  build: {
    rollupOptions: {
      output: {
        manualChunks(id) {
          // Vendor libraries
          if (id.includes('node_modules')) {
            if (id.includes('react')) return 'react';
            if (id.includes('@mui')) return 'ui';
            return 'vendor';
          }
          // App code by feature
          if (id.includes('/features/')) {
            const match = id.match(/\/features\/([^/]+)/);
            if (match) return `feature-${match[1]}`;
          }
        },
      },
    },
    chunkSizeWarningLimit: 1000,
    cssCodeSplit: true,
  },
};
```

## Optimization Checklist

- [ ] Vendor chunks separated from application code
- [ ] Route-based code-splitting implemented
- [ ] Lazy loading with Suspense boundaries
- [ ] Error boundaries for failed chunk loads
- [ ] Tree-shaking enabled in production
- [ ] Source maps generated for debugging
- [ ] Bundle size monitored and budgeted
- [ ] Named chunks with webpackChunkName
- [ ] Prefetch/preload hints strategically placed
- [ ] Bundle analysis performed regularly
- [ ] Performance metrics tracked
- [ ] Deterministic module IDs configured
