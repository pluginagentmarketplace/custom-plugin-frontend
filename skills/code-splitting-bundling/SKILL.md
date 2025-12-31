---
name: code-splitting-bundling
description: Implement route-based and component-based code splitting for optimal bundle sizes and load performance.
sasmp_version: "1.3.0"
bonded_agent: frontend-build-tools
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

# Code Splitting & Advanced Bundling

> **Purpose:** Optimize bundle sizes with strategic code splitting for faster load times and better user experience.

## Input/Output Schema

```typescript
interface CodeSplittingInput {
  projectPath: string;
  splittingStrategy: 'route' | 'component' | 'hybrid';
  bundler: 'webpack' | 'vite' | 'rollup';
  framework: 'react' | 'vue' | 'svelte' | 'angular';
  enablePrefetch?: boolean;
  enablePreload?: boolean;
  chunkNaming?: 'hash' | 'named';
}

interface CodeSplittingOutput {
  totalChunks: number;
  entryChunks: string[];
  asyncChunks: string[];
  vendorChunks: string[];
  chunkSizes: Record<string, number>;
  loadingStrategy: {
    eager: string[];
    lazy: string[];
    prefetch: string[];
    preload: string[];
  };
  optimizationScore: number;
}

interface RouteConfig {
  path: string;
  component: string;
  lazy: boolean;
  preload?: boolean;
  prefetch?: boolean;
  chunkName?: string;
}

interface ChunkStrategy {
  vendor: {
    include: string[];
    priority: number;
  };
  common: {
    minChunks: number;
    minSize: number;
  };
  async: {
    minSize: number;
    maxSize: number;
  };
}
```

## MANDATORY
- Route-based code splitting
- Dynamic imports syntax (`import()`)
- React.lazy and Suspense
- Webpack code splitting (splitChunks)
- Vite automatic splitting
- Loading states and fallbacks

## OPTIONAL
- Component-based lazy loading
- Prefetching and preloading strategies
- Named chunks configuration
- Shared dependencies extraction
- Vendor splitting configuration
- Common chunks extraction

## ADVANCED
- Module Federation for micro-frontends
- Granular chunk optimization
- Custom splitting strategies
- Performance budgets enforcement
- Bundle analysis tools integration
- Tree shaking verification

## Error Handling

| Error | Root Cause | Solution |
|-------|-----------|----------|
| `ChunkLoadError` | Failed to load dynamic chunk | Implement error boundary, retry logic, check network |
| `Module not found` | Incorrect import path | Verify path, check file existence, review aliases |
| `Suspense boundary not found` | Missing Suspense wrapper | Wrap lazy components with React.Suspense |
| `Maximum call stack exceeded` | Circular imports | Refactor to break circular dependencies |
| `Chunk split failed` | Invalid splitChunks config | Review webpack config, check syntax |
| `Prefetch ignored` | Incorrect link syntax | Use proper `<link rel="prefetch">` syntax |
| `Chunk name collision` | Duplicate chunk names | Use unique webpackChunkName comments |
| `Bundle size exceeded` | Too many modules in chunk | Implement more granular splitting |

## Test Template

```typescript
// React Route-based Code Splitting
import { lazy, Suspense } from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import LoadingSpinner from './components/LoadingSpinner';
import ErrorBoundary from './components/ErrorBoundary';

// Lazy load route components
const Home = lazy(() => import(/* webpackChunkName: "home" */ './pages/Home'));
const Dashboard = lazy(() => import(/* webpackChunkName: "dashboard" */ './pages/Dashboard'));
const Profile = lazy(() => import(/* webpackChunkName: "profile" */ './pages/Profile'));

// Prefetch on hover
const prefetchDashboard = () => {
  import(/* webpackPrefetch: true */ './pages/Dashboard');
};

function App() {
  return (
    <ErrorBoundary>
      <BrowserRouter>
        <Suspense fallback={<LoadingSpinner />}>
          <Routes>
            <Route path="/" element={<Home />} />
            <Route
              path="/dashboard"
              element={<Dashboard />}
              onMouseEnter={prefetchDashboard}
            />
            <Route path="/profile" element={<Profile />} />
          </Routes>
        </Suspense>
      </BrowserRouter>
    </ErrorBoundary>
  );
}

export default App;
```

```typescript
// Component-based Code Splitting
import { lazy, Suspense, ComponentType } from 'react';

// HOC for lazy loading with retry logic
function lazyWithRetry<T extends ComponentType<any>>(
  componentImport: () => Promise<{ default: T }>,
  componentName: string
) {
  return lazy(() =>
    componentImport().catch((error) => {
      console.error(`Failed to load ${componentName}:`, error);
      // Retry once after 1 second
      return new Promise((resolve) => {
        setTimeout(() => {
          resolve(componentImport());
        }, 1000);
      });
    })
  );
}

// Usage
const HeavyChart = lazyWithRetry(
  () => import(/* webpackChunkName: "chart" */ './components/HeavyChart'),
  'HeavyChart'
);

const DataTable = lazyWithRetry(
  () => import(/* webpackChunkName: "table" */ './components/DataTable'),
  'DataTable'
);

function Dashboard() {
  return (
    <div>
      <h1>Dashboard</h1>
      <Suspense fallback={<div>Loading chart...</div>}>
        <HeavyChart />
      </Suspense>
      <Suspense fallback={<div>Loading table...</div>}>
        <DataTable />
      </Suspense>
    </div>
  );
}
```

```javascript
// Webpack splitChunks Configuration
module.exports = {
  optimization: {
    splitChunks: {
      chunks: 'all',
      cacheGroups: {
        // Vendor chunk for React
        react: {
          test: /[\\/]node_modules[\\/](react|react-dom|react-router-dom)[\\/]/,
          name: 'vendor-react',
          priority: 30,
        },
        // Vendor chunk for UI libraries
        ui: {
          test: /[\\/]node_modules[\\/](@mui|antd|bootstrap)[\\/]/,
          name: 'vendor-ui',
          priority: 20,
        },
        // Common chunks
        commons: {
          name: 'commons',
          minChunks: 2,
          priority: 10,
          reuseExistingChunk: true,
        },
        // Default vendor
        vendors: {
          test: /[\\/]node_modules[\\/]/,
          name: 'vendors',
          priority: 5,
        },
      },
    },
    runtimeChunk: 'single',
  },
};
```

```typescript
// Vite manualChunks Configuration
export default defineConfig({
  build: {
    rollupOptions: {
      output: {
        manualChunks: (id) => {
          // Route chunks
          if (id.includes('/pages/')) {
            const match = id.match(/\/pages\/(.+?)\//);
            return match ? `route-${match[1]}` : undefined;
          }

          // Component library chunk
          if (id.includes('node_modules/@mui')) {
            return 'vendor-mui';
          }

          // React vendor
          if (id.includes('node_modules/react') ||
              id.includes('node_modules/react-dom')) {
            return 'vendor-react';
          }

          // Other vendors
          if (id.includes('node_modules')) {
            return 'vendor-libs';
          }
        },
      },
    },
  },
});
```

```typescript
// ErrorBoundary for Chunk Loading
import { Component, ReactNode } from 'react';

interface Props {
  children: ReactNode;
}

interface State {
  hasError: boolean;
  error: Error | null;
}

class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error: Error) {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: any) {
    // Check if it's a ChunkLoadError
    if (error.name === 'ChunkLoadError') {
      console.error('Chunk failed to load, reloading page...');
      window.location.reload();
      return;
    }
    console.error('Error:', error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return (
        <div>
          <h2>Something went wrong.</h2>
          <button onClick={() => window.location.reload()}>
            Reload Page
          </button>
        </div>
      );
    }
    return this.props.children;
  }
}

export default ErrorBoundary;
```

## Best Practices

1. **Route-First Splitting**: Always split at route boundaries for maximum impact
2. **Suspense Boundaries**: Use multiple Suspense boundaries for granular loading
3. **Error Boundaries**: Wrap lazy components with error boundaries for ChunkLoadError
4. **Named Chunks**: Use webpackChunkName for easier debugging
5. **Prefetch Strategy**: Prefetch routes likely to be visited next
6. **Preload Critical**: Preload chunks needed for critical user paths
7. **Vendor Splitting**: Separate vendor code for better caching
8. **Runtime Chunk**: Extract webpack runtime to separate chunk
9. **Loading States**: Provide meaningful loading indicators
10. **Retry Logic**: Implement retry mechanism for failed chunk loads

## Assets
- See `assets/code-splitting-patterns.yaml` for implementation patterns

## Resources
- [Webpack Code Splitting](https://webpack.js.org/guides/code-splitting/)
- [Vite Code Splitting](https://vitejs.dev/guide/features.html#dynamic-import)
- [React.lazy Documentation](https://react.dev/reference/react/lazy)
- [Route-based Code Splitting](https://reactrouter.com/en/main/route/lazy)
- [Web.dev Code Splitting Guide](https://web.dev/code-splitting-suspense/)

---
**Status:** Active | **Version:** 2.0.0
