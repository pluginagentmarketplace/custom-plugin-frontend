# React.lazy() and Suspense Complete Guide

## Introduction to React.lazy()

React.lazy() allows you to code-split your application by lazy loading components. It accepts a function that must call `import()` dynamically:

```jsx
const Dashboard = lazy(() => import('./pages/Dashboard'));
```

## React.lazy() Syntax

```jsx
import { lazy } from 'react';

// Basic syntax
const Component = lazy(() => import('./Component'));

// With webpack magic comments
const Component = lazy(() =>
  import(/* webpackChunkName: "component-name" */ './Component')
);

// Named chunks for better debugging
const Dashboard = lazy(() =>
  import(/* webpackChunkName: "dashboard" */ './pages/Dashboard')
);
```

## Suspense Component Basics

Suspense lets you "suspend" rendering while components are loading. Must wrap lazy components:

```jsx
import { Suspense, lazy } from 'react';

const Dashboard = lazy(() => import('./Dashboard'));

function App() {
  return (
    <Suspense fallback={<LoadingSpinner />}>
      <Dashboard />
    </Suspense>
  );
}
```

### Suspense Fallback Prop

The `fallback` prop specifies UI to display while component loads:

```jsx
<Suspense fallback={<div>Loading...</div>}>
  <Dashboard />
</Suspense>

// With component
<Suspense fallback={<LoadingSpinner />}>
  <Dashboard />
</Suspense>

// With null (not recommended)
<Suspense fallback={null}>
  <Dashboard />
</Suspense>
```

## Error Boundaries for Lazy Components

Error boundaries catch errors during rendering. Use with lazy components:

```jsx
class ErrorBoundary extends React.Component {
  state = { hasError: false };

  static getDerivedStateFromError(error) {
    return { hasError: true };
  }

  componentDidCatch(error, errorInfo) {
    console.error('Component error:', error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return <h2>Component failed to load</h2>;
    }
    return this.props.children;
  }
}

// Usage
<ErrorBoundary>
  <Suspense fallback={<Loading />}>
    <Dashboard />
  </Suspense>
</ErrorBoundary>
```

## Route-Based Lazy Loading

The most common pattern - lazy load page components:

```jsx
import { lazy, Suspense } from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';

const Home = lazy(() => import('./pages/Home'));
const Products = lazy(() => import('./pages/Products'));
const Admin = lazy(() => import('./pages/Admin'));

function App() {
  return (
    <BrowserRouter>
      <Suspense fallback={<PageLoader />}>
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

## Component-Level Lazy Loading

Lazy load heavy components within pages:

```jsx
import { lazy, Suspense } from 'react';

const Chart = lazy(() => import('./Chart'));
const Map = lazy(() => import('./Map'));

function Dashboard() {
  return (
    <div>
      <h1>Dashboard</h1>

      <Suspense fallback={<p>Loading chart...</p>}>
        <Chart data={data} />
      </Suspense>

      <Suspense fallback={<p>Loading map...</p>}>
        <Map location={location} />
      </Suspense>
    </div>
  );
}
```

## Lazy Loading Modals

Load heavy modals on-demand:

```jsx
import { lazy, Suspense, useState } from 'react';

const DeleteModal = lazy(() => import('./modals/DeleteModal'));

function DataTable() {
  const [showDelete, setShowDelete] = useState(false);

  return (
    <>
      <table>
        {/* table content */}
      </table>

      {showDelete && (
        <Suspense fallback={null}>
          <DeleteModal onClose={() => setShowDelete(false)} />
        </Suspense>
      )}

      <button onClick={() => setShowDelete(true)}>Delete</button>
    </>
  );
}
```

## Lazy Loading with Conditionals

```jsx
import { lazy, Suspense } from 'react';

// Create lazy component at module level (not inside function)
const PremiumFeature = lazy(() => import('./PremiumFeature'));

function FeatureGate({ isPremium }) {
  if (!isPremium) {
    return <div>Upgrade to premium</div>;
  }

  return (
    <Suspense fallback={<div>Loading premium feature...</div>}>
      <PremiumFeature />
    </Suspense>
  );
}
```

## Prefetching and Preloading

### Prefetch (Load When Idle)

```jsx
// Webpack magic comment
const Analytics = lazy(() =>
  import(
    /* webpackChunkName: "analytics" */
    /* webpackPrefetch: true */
    './Analytics'
  )
);

// Or programmatically
function Dashboard() {
  useEffect(() => {
    const timer = setTimeout(() => {
      import('./Analytics');
    }, 2000);

    return () => clearTimeout(timer);
  }, []);

  return <div>Dashboard</div>;
}
```

### Preload (Load Immediately in Parallel)

```jsx
const CriticalFeature = lazy(() =>
  import(
    /* webpackChunkName: "critical" */
    /* webpackPreload: true */
    './CriticalFeature'
  )
);
```

## Handling Loading States

### Simple Loading UI

```jsx
function LoadingSpinner() {
  return (
    <div style={{ textAlign: 'center', padding: '2rem' }}>
      <div className="spinner" />
      <p>Loading...</p>
    </div>
  );
}

<Suspense fallback={<LoadingSpinner />}>
  <Component />
</Suspense>
```

### Advanced Loading UI with Message

```jsx
function LoadingState({ message = 'Loading...' }) {
  return (
    <div className="loading-container">
      <div className="spinner">
        <div className="bounce1" />
        <div className="bounce2" />
        <div className="bounce3" />
      </div>
      <p>{message}</p>
    </div>
  );
}

<Suspense fallback={<LoadingState message="Loading dashboard..." />}>
  <Dashboard />
</Suspense>
```

## Error Handling for Lazy Components

### Complete Error Handling Setup

```jsx
class LazyErrorBoundary extends React.Component {
  state = { hasError: false, error: null };

  static getDerivedStateFromError(error) {
    return { hasError: true, error };
  }

  componentDidCatch(error, errorInfo) {
    console.error('Lazy component error:', error);
    // Send to error tracking
    logErrorToService(error, errorInfo);
  }

  retry = () => {
    this.setState({ hasError: false });
    window.location.reload();
  };

  render() {
    if (this.state.hasError) {
      return (
        <div className="error-container">
          <h2>Failed to Load</h2>
          <p>{this.state.error?.message}</p>
          <button onClick={this.retry}>Retry</button>
        </div>
      );
    }

    return this.props.children;
  }
}

// Usage
<LazyErrorBoundary>
  <Suspense fallback={<Loading />}>
    <Component />
  </Suspense>
</LazyErrorBoundary>
```

## Timeout Handling

Add timeout for stuck loading states:

```jsx
function useLazyComponent(importFn, timeout = 10000) {
  const [Component, setComponent] = useState(null);
  const [error, setError] = useState(null);

  useEffect(() => {
    let timeoutId;
    const abortController = new AbortController();

    const loadComponent = async () => {
      try {
        timeoutId = setTimeout(() => {
          abortController.abort();
          setError(new Error('Component loading timeout'));
        }, timeout);

        const module = await importFn();
        setComponent(module.default);
      } catch (err) {
        if (err.name !== 'AbortError') {
          setError(err);
        }
      } finally {
        clearTimeout(timeoutId);
      }
    };

    loadComponent();

    return () => {
      abortController.abort();
      clearTimeout(timeoutId);
    };
  }, [importFn, timeout]);

  return { Component, error };
}
```

## TypeScript Lazy Loading

```tsx
// Component types
interface DashboardProps {
  userId: string;
}

const Dashboard = lazy(
  () => import('./Dashboard').then(module => ({
    default: module.Dashboard as React.ComponentType<DashboardProps>
  }))
);

// Usage
<Suspense fallback={<div>Loading...</div>}>
  <Dashboard userId="123" />
</Suspense>
```

## Performance Monitoring

### Measure Lazy Component Load Time

```jsx
function MeasuredLazyComponent() {
  const [loadTime, setLoadTime] = useState(0);

  useEffect(() => {
    const start = performance.now();

    return () => {
      const end = performance.now();
      setLoadTime(end - start);
      console.log(`Component loaded in ${loadTime}ms`);
    };
  }, []);

  return (
    <Suspense fallback={<div>Loading...</div>}>
      <Component />
    </Suspense>
  );
}
```

### Monitor with Performance Observer

```jsx
useEffect(() => {
  const observer = new PerformanceObserver((list) => {
    for (const entry of list.getEntries()) {
      if (entry.entryType === 'measure') {
        console.log(`${entry.name}: ${entry.duration}ms`);
      }
    }
  });

  observer.observe({ entryTypes: ['measure'] });

  return () => observer.disconnect();
}, []);
```

## Best Practices

1. **Always wrap lazy components in Suspense** - Required for lazy components
2. **Use error boundaries** - Catch and handle loading errors gracefully
3. **Provide fallback UI** - Show loading state to users
4. **Name chunks** - Use webpackChunkName for debugging
5. **Test lazy loading** - Test in slow network conditions
6. **Monitor performance** - Track chunk loading times
7. **Use prefetch strategically** - Only for non-critical chunks
8. **Handle errors properly** - Show retry UI for failed loads
9. **Don't lazy load synchronously** - Always use dynamic imports
10. **Consider Route vs Component** - Choose appropriate granularity

## Common Mistakes

### Mistake 1: Lazy at Module Level
```javascript
// WRONG
function MyComponent() {
  const Lazy = lazy(() => import('./Component'));
  return <Lazy />;
}

// CORRECT
const Lazy = lazy(() => import('./Component'));

function MyComponent() {
  return <Lazy />;
}
```

### Mistake 2: Missing Suspense
```javascript
// WRONG
const Lazy = lazy(() => import('./Component'));
<Lazy /> // Will error!

// CORRECT
<Suspense fallback={<div>Loading...</div>}>
  <Lazy />
</Suspense>
```

### Mistake 3: No Error Boundary
```javascript
// WRONG
<Suspense fallback={<div>Loading...</div>}>
  <Lazy /> // Error will break app
</Suspense>

// CORRECT
<ErrorBoundary>
  <Suspense fallback={<div>Loading...</div>}>
    <Lazy />
  </Suspense>
</ErrorBoundary>
```
