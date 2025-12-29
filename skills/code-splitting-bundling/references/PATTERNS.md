# Code Splitting Patterns & Strategies

## Pattern 1: Route-Based Splitting with React Router

```javascript
import { lazy, Suspense } from 'react'
import { BrowserRouter, Routes, Route } from 'react-router-dom'

const Home = lazy(() => import('./pages/Home'))
const Products = lazy(() => import('./pages/Products'))
const Admin = lazy(() => import('./pages/Admin'))

function App() {
  return (
    <BrowserRouter>
      <Suspense fallback={<LoadingSpinner />}>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/products" element={<Products />} />
          <Route path="/admin/*" element={<Admin />} />
        </Routes>
      </Suspense>
    </BrowserRouter>
  )
}
```

## Pattern 2: Component-Level Code Splitting

```javascript
import { lazy, Suspense } from 'react'

const DataGrid = lazy(() => import('./components/DataGrid'))
const Chart = lazy(() => import('./components/Chart'))

function Dashboard() {
  return (
    <>
      <Suspense fallback={<GridSkeleton />}>
        <DataGrid />
      </Suspense>
      <Suspense fallback={<ChartSkeleton />}>
        <Chart />
      </Suspense>
    </>
  )
}
```

## Pattern 3: Modal/Dialog Code Splitting

```javascript
import { lazy, useState, Suspense } from 'react'

const AdvancedSettings = lazy(() => import('./modals/AdvancedSettings'))

function Settings() {
  const [showAdvanced, setShowAdvanced] = useState(false)

  return (
    <>
      <button onClick={() => setShowAdvanced(true)}>Advanced</button>
      {showAdvanced && (
        <Suspense fallback={<LoadingModal />}>
          <AdvancedSettings onClose={() => setShowAdvanced(false)} />
        </Suspense>
      )}
    </>
  )
}
```

## Pattern 4: Performance Monitoring

```javascript
import { startMeasure, stopMeasure } from './perf-utils'

// Wrap lazy import with performance tracking
const lazyWithMetrics = (importFunc, componentName) => {
  return lazy(async () => {
    startMeasure(`load-${componentName}`)
    try {
      const module = await importFunc()
      stopMeasure(`load-${componentName}`)
      return module
    } catch (error) {
      stopMeasure(`load-${componentName}`)
      throw error
    }
  })
}

const Home = lazyWithMetrics(() => import('./pages/Home'), 'Home')
```

## Pattern 5: Prefetch & Preload Strategy

```javascript
// Prefetch chunks on route hover
const prefetchComponent = async (componentPath) => {
  const { default: Component } = await import(componentPath)
  return Component
}

function Navigation() {
  const onAboutHover = () => {
    prefetchComponent('./pages/About')
  }

  return (
    <nav>
      <Link to="/" >Home</Link>
      <Link to="/about" onMouseEnter={onAboutHover}>About</Link>
    </nav>
  )
}

// Preload critical components
window.addEventListener('load', () => {
  import('./pages/Dashboard')
})
```

## Pattern 6: Webpack Chunk Name Strategy

```javascript
// Organize chunks by feature
const Home = lazy(() =>
  import(
    /* webpackChunkName: "feature-home" */
    /* webpackPrefetch: true */
    './pages/home'
  )
)

const Analytics = lazy(() =>
  import(
    /* webpackChunkName: "feature-analytics" */
    /* webpackPreload: true */
    './pages/analytics'
  )
)

const Export = lazy(() =>
  import(
    /* webpackChunkName: "feature-export" */
    './utils/exporters'
  )
)
```

## Pattern 7: Conditional Chunk Loading

```javascript
const HeavyComponent = lazy(() => {
  if (process.env.REACT_APP_FULL_FEATURES === 'true') {
    return import(/* webpackChunkName: "full-component" */ './FullComponent')
  } else {
    return import(/* webpackChunkName: "lite-component" */ './LiteComponent')
  }
})
```

## Pattern 8: Error Boundary with Code Splitting

```javascript
class ErrorBoundary extends React.Component {
  state = { hasError: false }

  static getDerivedStateFromError(error) {
    return { hasError: true }
  }

  render() {
    if (this.state.hasError) {
      return <ErrorFallback onRetry={() => this.setState({ hasError: false })} />
    }
    return this.props.children
  }
}

function App() {
  return (
    <ErrorBoundary>
      <Suspense fallback={<Spinner />}>
        <LazyComponent />
      </Suspense>
    </ErrorBoundary>
  )
}
```

## Pattern 9: Vendor Optimization

```javascript
// webpack.config.js
optimization: {
  splitChunks: {
    chunks: 'all',
    cacheGroups: {
      // Separate critical vendor libraries
      react: {
        test: /[\\/]node_modules[\\/](react|react-dom|react-router)[\\/]/,
        name: 'react-vendors',
        priority: 30,
        minChunks: 1,
      },
      // UI library chunk
      ui: {
        test: /[\\/]node_modules[\\/](antd|material-ui)[\\/]/,
        name: 'ui-vendors',
        priority: 20,
      },
      // All other vendors
      vendor: {
        test: /[\\/]node_modules[\\/]/,
        name: 'vendors',
        priority: 10,
      },
      // Common code used in multiple chunks
      common: {
        minChunks: 2,
        priority: 5,
        reuseExistingChunk: true,
      },
    },
  },
  runtimeChunk: 'single',
}
```

## Pattern 10: Feature Flag Based Splitting

```javascript
const features = {
  analytics: process.env.REACT_APP_FEATURE_ANALYTICS === 'true',
  reporting: process.env.REACT_APP_FEATURE_REPORTING === 'true',
}

const Analytics = features.analytics
  ? lazy(() => import('./features/Analytics'))
  : () => <FeatureDisabled name="Analytics" />

const Reporting = features.reporting
  ? lazy(() => import('./features/Reporting'))
  : () => <FeatureDisabled name="Reporting" />
```

## Pattern 11: Dynamic Module Federation

```javascript
// Share chunks between micro-frontends
const remoteModule = lazy(() =>
  import(
    /* webpackChunkName: "remote-module" */
    'mfe-remote/Component'
  )
)

function App() {
  return (
    <Suspense fallback={<Loading />}>
      <remoteModule />
    </Suspense>
  )
}
```

## Pattern 12: Lazy Load Heavy Utils

```javascript
// Don't include heavy utilities in main bundle
export const lazyImport = (importPath) => {
  let cached = null

  return async () => {
    if (!cached) {
      cached = await import(importPath)
    }
    return cached
  }
}

// Usage
const heavyUtils = lazyImport('./utils/analytics')

// Load only when needed
button.addEventListener('click', async () => {
  const { trackEvent } = await heavyUtils()
  trackEvent('button-clicked')
})
```

