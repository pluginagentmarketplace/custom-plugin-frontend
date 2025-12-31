---
name: code-splitting-lazy-loading
description: Master code splitting and lazy loading techniques for optimal frontend performance and faster initial load times.
sasmp_version: "1.3.0"
bonded_agent: performance
bond_type: PRIMARY_BOND

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

# Code Splitting & Lazy Loading

> **Purpose:** Optimize application loading with advanced splitting and lazy loading techniques for faster initial load times and better user experience.

## Input/Output Schema

```typescript
interface LazyLoadingInput {
  projectPath: string;
  framework: 'react' | 'vue' | 'svelte' | 'angular';
  loadingStrategy: 'eager' | 'lazy' | 'predictive';
  prefetchEnabled: boolean;
  preloadEnabled: boolean;
  intersectionObserver?: boolean;
  suspenseEnabled: boolean;
}

interface LazyLoadingOutput {
  initialBundleSize: number;
  lazyChunks: Array<{
    name: string;
    size: number;
    loadTime: number;
    triggerType: 'route' | 'interaction' | 'viewport' | 'idle';
  }>;
  performanceMetrics: {
    fcp: number; // First Contentful Paint
    lcp: number; // Largest Contentful Paint
    tti: number; // Time to Interactive
  };
  loadingEfficiency: number;
  recommendations: string[];
}

interface LazyComponent {
  componentPath: string;
  chunkName: string;
  loadStrategy: 'immediate' | 'viewport' | 'interaction' | 'idle';
  priority: 'high' | 'medium' | 'low';
  fallback?: string;
}

interface SplitChunksConfig {
  vendor: boolean;
  common: boolean;
  runtime: boolean;
  async: boolean;
  maxInitialRequests: number;
  maxAsyncRequests: number;
}
```

## MANDATORY
- Dynamic imports with `import()`
- Route-based code splitting
- Component lazy loading
- Webpack splitChunks configuration
- React.lazy and Suspense
- Vue async components

## OPTIONAL
- Vendor bundle optimization
- Prefetching and preloading strategies
- Module federation basics
- Critical CSS extraction
- Tree shaking optimization
- Bundle analysis tools (webpack-bundle-analyzer)

## ADVANCED
- Micro-frontend code splitting
- Server-side code splitting (SSR)
- Progressive loading strategies
- Predictive prefetching with ML
- Custom chunk naming strategies
- Build-time optimization

## Error Handling

| Error | Root Cause | Solution |
|-------|-----------|----------|
| `Loading chunk failed` | Network error or missing chunk | Implement retry logic, check build output |
| `Suspense boundary not defined` | Missing Suspense wrapper | Add Suspense component with fallback |
| `Hydration mismatch` | SSR/CSR content mismatch | Ensure consistent lazy loading on server/client |
| `Memory leak in lazy component` | Component not unmounting | Add cleanup in useEffect, check event listeners |
| `Infinite loading state` | Import path error | Verify import path, check file exists |
| `ChunkLoadError` | Failed dynamic import | Add error boundary, implement fallback |
| `Maximum update depth exceeded` | Lazy load in render | Move lazy load outside component render |
| `Cannot read property of undefined` | Component not loaded | Add null check, use optional chaining |

## Test Template

```typescript
// React Lazy Loading with Suspense
import { lazy, Suspense } from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';

// Loading component
const LoadingFallback = () => (
  <div className="loading-container">
    <div className="spinner" />
    <p>Loading...</p>
  </div>
);

// Lazy load routes
const Home = lazy(() => import('./pages/Home'));
const About = lazy(() => import('./pages/About'));
const Dashboard = lazy(() =>
  import(/* webpackChunkName: "dashboard" */ './pages/Dashboard')
);

// Lazy load with error retry
const lazyWithRetry = (componentImport: () => Promise<any>) =>
  lazy(async () => {
    const pageHasAlreadyBeenForceRefreshed = JSON.parse(
      window.localStorage.getItem('page-has-been-force-refreshed') || 'false'
    );

    try {
      const component = await componentImport();
      window.localStorage.setItem('page-has-been-force-refreshed', 'false');
      return component;
    } catch (error) {
      if (!pageHasAlreadyBeenForceRefreshed) {
        window.localStorage.setItem('page-has-been-force-refreshed', 'true');
        return window.location.reload();
      }
      throw error;
    }
  });

const Settings = lazyWithRetry(() => import('./pages/Settings'));

function App() {
  return (
    <BrowserRouter>
      <Suspense fallback={<LoadingFallback />}>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/about" element={<About />} />
          <Route path="/dashboard" element={<Dashboard />} />
          <Route path="/settings" element={<Settings />} />
        </Routes>
      </Suspense>
    </BrowserRouter>
  );
}

export default App;
```

```typescript
// Component-level Lazy Loading with Intersection Observer
import { lazy, Suspense, useEffect, useRef, useState } from 'react';

const HeavyComponent = lazy(() => import('./HeavyComponent'));

function LazyLoadOnView() {
  const [shouldLoad, setShouldLoad] = useState(false);
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          setShouldLoad(true);
          observer.disconnect();
        }
      },
      { threshold: 0.1 }
    );

    if (ref.current) {
      observer.observe(ref.current);
    }

    return () => observer.disconnect();
  }, []);

  return (
    <div ref={ref}>
      {shouldLoad ? (
        <Suspense fallback={<div>Loading component...</div>}>
          <HeavyComponent />
        </Suspense>
      ) : (
        <div style={{ height: '300px' }}>Scroll to load...</div>
      )}
    </div>
  );
}
```

```typescript
// Vue 3 Async Components
import { defineAsyncComponent } from 'vue';

const AsyncDashboard = defineAsyncComponent({
  loader: () => import('./components/Dashboard.vue'),
  loadingComponent: LoadingSpinner,
  errorComponent: ErrorDisplay,
  delay: 200,
  timeout: 3000,
});

// Vue Router with lazy loading
const routes = [
  {
    path: '/',
    component: () => import('./views/Home.vue'),
  },
  {
    path: '/dashboard',
    component: () => import(/* webpackChunkName: "dashboard" */ './views/Dashboard.vue'),
  },
];
```

```javascript
// Webpack Configuration for Code Splitting
module.exports = {
  optimization: {
    splitChunks: {
      chunks: 'all',
      minSize: 20000,
      minRemainingSize: 0,
      minChunks: 1,
      maxAsyncRequests: 30,
      maxInitialRequests: 30,
      enforceSizeThreshold: 50000,
      cacheGroups: {
        defaultVendors: {
          test: /[\\/]node_modules[\\/]/,
          priority: -10,
          reuseExistingChunk: true,
        },
        default: {
          minChunks: 2,
          priority: -20,
          reuseExistingChunk: true,
        },
        react: {
          test: /[\\/]node_modules[\\/](react|react-dom)[\\/]/,
          name: 'vendor-react',
          priority: 10,
        },
      },
    },
    runtimeChunk: 'single',
  },
};
```

```typescript
// Predictive Prefetching
import { useEffect } from 'react';
import { useLocation } from 'react-router-dom';

const routePrefetchMap: Record<string, () => Promise<any>> = {
  '/': () => import('./pages/Dashboard'),
  '/profile': () => import('./pages/Settings'),
  '/dashboard': () => import('./pages/Analytics'),
};

function usePredictivePrefetch() {
  const location = useLocation();

  useEffect(() => {
    // Prefetch likely next route
    const nextRoute = routePrefetchMap[location.pathname];
    if (nextRoute) {
      // Prefetch on idle
      if ('requestIdleCallback' in window) {
        requestIdleCallback(() => nextRoute());
      } else {
        setTimeout(() => nextRoute(), 1000);
      }
    }
  }, [location.pathname]);
}

// Usage
function App() {
  usePredictivePrefetch();
  return <Routes>{/* routes */}</Routes>;
}
```

```typescript
// Performance Monitoring
import { useEffect } from 'react';

function useChunkLoadMonitoring() {
  useEffect(() => {
    const observer = new PerformanceObserver((list) => {
      for (const entry of list.getEntries()) {
        if (entry.initiatorType === 'script') {
          console.log(`Chunk loaded: ${entry.name} in ${entry.duration}ms`);

          // Send to analytics
          if (entry.duration > 3000) {
            console.warn(`Slow chunk load detected: ${entry.name}`);
          }
        }
      }
    });

    observer.observe({ entryTypes: ['resource'] });

    return () => observer.disconnect();
  }, []);
}
```

## Best Practices

1. **Route-Based Splitting**: Always split at route level as the first optimization
2. **Suspense Boundaries**: Use granular Suspense boundaries for better UX
3. **Error Handling**: Implement error boundaries for failed chunk loads
4. **Loading States**: Provide meaningful loading indicators, avoid empty states
5. **Retry Logic**: Implement automatic retry for failed dynamic imports
6. **Prefetch Wisely**: Prefetch likely next routes during idle time
7. **Preload Critical**: Preload chunks for critical user journeys
8. **Monitor Performance**: Track chunk load times and bundle sizes
9. **Chunk Size Budgets**: Set and enforce maximum chunk sizes
10. **Progressive Enhancement**: Ensure app works even if chunks fail to load

## Security
- Secure dynamic imports: Validate import paths, avoid user input
- CSP with code splitting: Configure Content Security Policy for dynamic chunks
- Integrity checks for chunks: Use Subresource Integrity (SRI) for chunk verification

## Resources
- [React.lazy Documentation](https://react.dev/reference/react/lazy)
- [Webpack Code Splitting](https://webpack.js.org/guides/code-splitting/)
- [Vue Async Components](https://vuejs.org/guide/components/async.html)
- [Web.dev Lazy Loading](https://web.dev/lazy-loading/)
- [MDN Dynamic Imports](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/import)
- [Intersection Observer API](https://developer.mozilla.org/en-US/docs/Web/API/Intersection_Observer_API)

---
**Status:** Active | **Version:** 2.0.0
