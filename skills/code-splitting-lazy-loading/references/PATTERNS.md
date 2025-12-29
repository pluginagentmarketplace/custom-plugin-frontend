# React.lazy() Design Patterns & Strategies

## Pattern 1: Route-Based Code-Splitting

Load entire routes lazily for better initial load:

```jsx
const Home = lazy(() => import(/* webpackChunkName: "home" */ './pages/Home'));
const Dashboard = lazy(() => import(/* webpackChunkName: "dashboard" */ './pages/Dashboard'));
const Profile = lazy(() => import(/* webpackChunkName: "profile" */ './pages/Profile'));

function App() {
  return (
    <BrowserRouter>
      <Suspense fallback={<PageLoader />}>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/dashboard" element={<Dashboard />} />
          <Route path="/profile" element={<Profile />} />
        </Routes>
      </Suspense>
    </BrowserRouter>
  );
}
```

## Pattern 2: Suspense Boundaries with Error Handling

Wrap lazy components with both Suspense and error boundary:

```jsx
function SafeLazyComponent() {
  return (
    <ErrorBoundary>
      <Suspense fallback={<Loader />}>
        <LazyComponent />
      </Suspense>
    </ErrorBoundary>
  );
}
```

## Pattern 3: Progressive Enhancement

Load critical features immediately, defer others:

```jsx
const CriticalFeature = lazy(() =>
  import(/* webpackChunkName: "critical" */ /* webpackPreload: true */ './Critical')
);

const OptionalFeature = lazy(() =>
  import(/* webpackChunkName: "optional" */ /* webpackPrefetch: true */ './Optional')
);

function App() {
  return (
    <>
      <Suspense fallback={<div>Loading critical...</div>}>
        <CriticalFeature />
      </Suspense>
      <Suspense fallback={<div>Loading optional...</div>}>
        <OptionalFeature />
      </Suspense>
    </>
  );
}
```

## Pattern 4: Modal/Dialog Lazy Loading

Load heavy modals on-demand:

```jsx
const DeleteConfirmModal = lazy(() =>
  import(/* webpackChunkName: "delete-modal" */ './modals/DeleteConfirm')
);

function DataTable({ data }) {
  const [showModal, setShowModal] = useState(false);

  return (
    <>
      <Table data={data} />
      {showModal && (
        <Suspense fallback={null}>
          <DeleteConfirmModal onClose={() => setShowModal(false)} />
        </Suspense>
      )}
      <button onClick={() => setShowModal(true)}>Delete</button>
    </>
  );
}
```

## Pattern 5: Conditional Component Loading

Load components based on feature flags or conditions:

```jsx
const AdminPanel = lazy(() =>
  import(/* webpackChunkName: "admin" */ './AdminPanel')
);

function App({ isAdmin }) {
  return (
    <>
      <Dashboard />
      {isAdmin && (
        <Suspense fallback={<div>Loading admin...</div>}>
          <AdminPanel />
        </Suspense>
      )}
    </>
  );
}
```

## Pattern 6: Nested Suspense Boundaries

Multiple suspense boundaries for granular control:

```jsx
function Page() {
  return (
    <div>
      <header>Content</header>

      <Suspense fallback={<SidebarLoader />}>
        <Sidebar />
      </Suspense>

      <main>
        <Suspense fallback={<ContentLoader />}>
          <Content />
        </Suspense>
      </main>

      <aside>
        <Suspense fallback={<AsideLoader />}>
          <AsidePanel />
        </Suspense>
      </aside>
    </div>
  );
}
```

## Pattern 7: Prefetch on User Interaction

Prefetch chunks when user hovers or focuses:

```jsx
const Settings = lazy(() =>
  import(/* webpackChunkName: "settings" */ './Settings')
);

function Navigation() {
  const handleMouseEnter = () => {
    import(/* webpackChunkName: "settings" */ './Settings');
  };

  return (
    <a href="/settings" onMouseEnter={handleMouseEnter}>
      Settings
    </a>
  );
}
```

## Pattern 8: Tab-Based Lazy Loading

Lazy load tab content:

```jsx
const TabA = lazy(() => import('./TabA'));
const TabB = lazy(() => import('./TabB'));
const TabC = lazy(() => import('./TabC'));

function Tabs() {
  const [active, setActive] = useState('a');

  const renderContent = () => {
    switch (active) {
      case 'a': return <Suspense fallback={<Loader />}><TabA /></Suspense>;
      case 'b': return <Suspense fallback={<Loader />}><TabB /></Suspense>;
      case 'c': return <Suspense fallback={<Loader />}><TabC /></Suspense>;
      default: return null;
    }
  };

  return (
    <>
      <div className="tabs">
        <button onClick={() => setActive('a')}>Tab A</button>
        <button onClick={() => setActive('b')}>Tab B</button>
        <button onClick={() => setActive('c')}>Tab C</button>
      </div>
      {renderContent()}
    </>
  );
}
```

## Pattern 9: Custom Error Boundary with Retry

Error boundary with retry functionality:

```jsx
class RetryErrorBoundary extends React.Component {
  state = { hasError: false, retryCount: 0 };

  static getDerivedStateFromError() {
    return { hasError: true };
  }

  componentDidCatch(error) {
    console.error('Load error:', error);
  }

  retry = () => {
    this.setState(s => ({
      hasError: false,
      retryCount: s.retryCount + 1
    }));
  };

  render() {
    if (this.state.hasError) {
      return (
        <div className="error">
          <h3>Failed to load component</h3>
          <button onClick={this.retry}>
            Retry (Attempt {this.state.retryCount})
          </button>
        </div>
      );
    }
    return this.props.children;
  }
}

// Usage
<RetryErrorBoundary>
  <Suspense fallback={<Loader />}>
    <LazyComponent />
  </Suspense>
</RetryErrorBoundary>
```

## Pattern 10: Timeout Protection

Add timeout for stuck loading states:

```jsx
function TimeoutSuspense({ children, fallback, timeout = 5000 }) {
  const [timedOut, setTimedOut] = useState(false);

  useEffect(() => {
    const timer = setTimeout(() => setTimedOut(true), timeout);
    return () => clearTimeout(timer);
  }, [timeout]);

  if (timedOut) {
    return <div>Loading took too long. Please refresh.</div>;
  }

  return <Suspense fallback={fallback}>{children}</Suspense>;
}
```

## Pattern 11: Performance Monitoring

Monitor lazy component performance:

```jsx
function MonitoredLazyComponent() {
  useEffect(() => {
    const startTime = performance.now();
    const handleLoad = () => {
      const loadTime = performance.now() - startTime;
      // Send to analytics
      analytics.track('component_loaded', { duration: loadTime });
    };

    window.addEventListener('load', handleLoad);
    return () => window.removeEventListener('load', handleLoad);
  }, []);

  return (
    <Suspense fallback={<Loader />}>
      <LazyComponent />
    </Suspense>
  );
}
```

## Pattern 12: Progressive Image Loading with Lazy

Load images lazily with components:

```jsx
const ImageGallery = lazy(() => import('./ImageGallery'));

function Gallery() {
  return (
    <section>
      <h2>Image Gallery</h2>
      <Suspense fallback={<SkeletonGallery />}>
        <ImageGallery />
      </Suspense>
    </section>
  );
}
```

## Pattern 13: SSR-Safe Lazy Components

Handle SSR safely with lazy components:

```jsx
import { lazy } from 'react';

const ClientOnlyComponent = lazy(() =>
  import(/* webpackChunkName: "client-only" */ './ClientOnly')
);

function SSRSafeComponent() {
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  if (!mounted) return null;

  return (
    <Suspense fallback={<Placeholder />}>
      <ClientOnlyComponent />
    </Suspense>
  );
}
```

## Pattern 14: Dynamic Plugin Loading

Load plugins dynamically:

```jsx
function PluginSystem() {
  const [plugins, setPlugins] = useState([]);

  useEffect(() => {
    loadPlugins().then(setPlugins);
  }, []);

  return (
    <div className="plugins">
      {plugins.map(plugin => (
        <Suspense key={plugin.id} fallback={<Loader />}>
          <plugin.Component />
        </Suspense>
      ))}
    </div>
  );
}

async function loadPlugins() {
  return [
    {
      id: 'stats',
      Component: lazy(() => import('./plugins/Stats')),
    },
    {
      id: 'charts',
      Component: lazy(() => import('./plugins/Charts')),
    },
  ];
}
```

## Pattern 15: Form Wizard with Lazy Steps

Lazy load form steps:

```jsx
const Step1 = lazy(() => import('./form/Step1'));
const Step2 = lazy(() => import('./form/Step2'));
const Step3 = lazy(() => import('./form/Step3'));

function FormWizard() {
  const [step, setStep] = useState(1);

  const renderStep = () => {
    switch (step) {
      case 1: return <Suspense fallback={<Loader />}><Step1 /></Suspense>;
      case 2: return <Suspense fallback={<Loader />}><Step2 /></Suspense>;
      case 3: return <Suspense fallback={<Loader />}><Step3 /></Suspense>;
    }
  };

  return (
    <form>
      {renderStep()}
      <button onClick={() => setStep(s => s + 1)}>Next</button>
    </form>
  );
}
```

## Implementation Checklist

- [ ] Create lazy component with lazy()
- [ ] Wrap with Suspense boundary
- [ ] Wrap with error boundary
- [ ] Provide fallback UI
- [ ] Add error handling
- [ ] Name chunks with webpackChunkName
- [ ] Use prefetch/preload appropriately
- [ ] Test loading states
- [ ] Monitor performance
- [ ] Document lazy behavior
- [ ] Test error scenarios
- [ ] Verify chunk loads correctly
