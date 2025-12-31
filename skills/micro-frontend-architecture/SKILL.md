---
name: micro-frontend-architecture
description: Design and implement micro-frontend architecture with Module Federation, shared dependencies, and independent deployment.
sasmp_version: "1.3.0"
version: "2.0.0"
bonded_agent: advanced-topics
bond_type: PRIMARY_BOND
category: architecture
tags: [micro-frontends, module-federation, webpack, monorepo, scalability, team-autonomy]
complexity: expert
estimated_time: 8-12 hours
prerequisites:
  - Webpack configuration
  - Module systems (ESM, CommonJS)
  - Build tools and bundlers
  - Team collaboration patterns
  - Deployment strategies
---

# Micro-Frontend Architecture

Design and implement scalable micro-frontend architectures that enable team autonomy, independent deployment, and technology flexibility.

## Input/Output Schema

### Input Requirements
```yaml
architecture_config:
  type: object
  required:
    - orchestration_type: enum    # shell|router|server-side
    - team_structure: array        # List of team boundaries
    - shared_resources: array      # Common dependencies
    - integration_method: enum     # module-federation|iframe|web-components
  optional:
    - deployment_strategy: enum    # independent|coordinated|canary
    - state_management: enum       # isolated|shared|hybrid
    - routing_strategy: enum       # central|distributed
    - build_tool: enum            # webpack|vite|esbuild

federation_config:
  type: object
  required:
    - host_app: string            # Host application name
    - remote_apps: array          # List of remote applications
    - shared_deps: object         # Shared dependencies config
  optional:
    - runtime_remotes: boolean    # Dynamic remote loading
    - version_strategy: enum      # strict|loose|auto
```

### Output Deliverables
```yaml
architecture:
  - Host/shell application
  - Remote micro-frontends
  - Shared component library
  - Communication layer
  - Deployment configurations

infrastructure:
  - Module federation setup
  - Build configurations
  - CI/CD pipelines
  - Monitoring setup
  - Documentation

metrics:
  - Independent deployment: enabled
  - Build time per MFE: <5min
  - Load time overhead: <500ms
  - Team autonomy: high
  - Code sharing: optimized
```

## MANDATORY

### 1. Module Federation Basics

#### Webpack Module Federation
```javascript
// webpack.config.js (Host Application)
const ModuleFederationPlugin = require('webpack/lib/container/ModuleFederationPlugin');

module.exports = {
  plugins: [
    new ModuleFederationPlugin({
      name: 'host',
      remotes: {
        app1: 'app1@http://localhost:3001/remoteEntry.js',
        app2: 'app2@http://localhost:3002/remoteEntry.js'
      },
      shared: {
        react: {
          singleton: true,
          requiredVersion: '^18.0.0',
          eager: true
        },
        'react-dom': {
          singleton: true,
          requiredVersion: '^18.0.0',
          eager: true
        }
      }
    })
  ]
};

// webpack.config.js (Remote Application)
module.exports = {
  plugins: [
    new ModuleFederationPlugin({
      name: 'app1',
      filename: 'remoteEntry.js',
      exposes: {
        './Header': './src/components/Header',
        './Footer': './src/components/Footer',
        './ProductList': './src/components/ProductList'
      },
      shared: {
        react: { singleton: true, requiredVersion: '^18.0.0' },
        'react-dom': { singleton: true, requiredVersion: '^18.0.0' }
      }
    })
  ]
};
```

### 2. Host/Remote Configuration

#### Host Application
```javascript
// src/App.js (Host)
import React, { lazy, Suspense } from 'react';

// Dynamic imports from remotes
const Header = lazy(() => import('app1/Header'));
const ProductList = lazy(() => import('app1/ProductList'));
const Checkout = lazy(() => import('app2/Checkout'));

function App() {
  return (
    <div className="app">
      <Suspense fallback={<div>Loading Header...</div>}>
        <Header />
      </Suspense>

      <Suspense fallback={<div>Loading Products...</div>}>
        <ProductList />
      </Suspense>

      <Suspense fallback={<div>Loading Checkout...</div>}>
        <Checkout />
      </Suspense>
    </div>
  );
}

export default App;
```

#### Remote Application
```javascript
// src/bootstrap.js (Remote)
import React from 'react';
import ReactDOM from 'react-dom/client';
import Header from './components/Header';

// Standalone mode
if (process.env.NODE_ENV === 'development') {
  const root = ReactDOM.createRoot(document.getElementById('root'));
  root.render(<Header />);
}

export { Header };
```

### 3. Shared Dependencies Management

```javascript
// Advanced shared configuration
const sharedDependencies = {
  react: {
    singleton: true,              // Only one version across all MFEs
    strictVersion: true,          // Enforce exact version match
    requiredVersion: '^18.2.0',   // Minimum required version
    eager: true                   // Load immediately
  },
  'react-dom': {
    singleton: true,
    strictVersion: true,
    requiredVersion: '^18.2.0',
    eager: true
  },
  'react-router-dom': {
    singleton: true,
    requiredVersion: '^6.0.0',
    eager: false                  // Lazy load
  },
  lodash: {
    singleton: false,             // Allow multiple versions
    requiredVersion: false,
    eager: false
  }
};

// Webpack config with shared dependencies
new ModuleFederationPlugin({
  name: 'app',
  shared: sharedDependencies
});
```

### 4. Component Isolation

```javascript
// Scoped CSS approach
// app1/src/components/Header.module.css
.header {
  background: #333;
  color: white;
  padding: 1rem;
}

// app1/src/components/Header.jsx
import styles from './Header.module.css';

export function Header() {
  return (
    <header className={styles.header}>
      <h1>App 1 Header</h1>
    </header>
  );
}

// Shadow DOM approach
class MicroFrontendElement extends HTMLElement {
  connectedCallback() {
    const shadow = this.attachShadow({ mode: 'open' });

    shadow.innerHTML = `
      <style>
        :host {
          display: block;
        }
        h1 { color: blue; }
      </style>
      <h1>Isolated Component</h1>
    `;
  }
}

customElements.define('mfe-header', MicroFrontendElement);
```

### 5. Routing Integration

#### Shared Router Approach
```javascript
// host/src/App.js
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { lazy, Suspense } from 'react';

const ProductsApp = lazy(() => import('products/App'));
const CheckoutApp = lazy(() => import('checkout/App'));

function App() {
  return (
    <BrowserRouter>
      <Suspense fallback={<div>Loading...</div>}>
        <Routes>
          <Route path="/products/*" element={<ProductsApp />} />
          <Route path="/checkout/*" element={<CheckoutApp />} />
        </Routes>
      </Suspense>
    </BrowserRouter>
  );
}

// products/src/App.js
import { Routes, Route } from 'react-router-dom';

function ProductsApp() {
  return (
    <Routes>
      <Route path="/" element={<ProductList />} />
      <Route path="/:id" element={<ProductDetail />} />
    </Routes>
  );
}
```

#### URL-based Routing
```javascript
// Routing coordinator
class MicroFrontendRouter {
  constructor() {
    this.routes = new Map();
  }

  register(pattern, loadApp) {
    this.routes.set(pattern, loadApp);
  }

  async route(path) {
    for (const [pattern, loadApp] of this.routes) {
      const match = new RegExp(pattern).exec(path);
      if (match) {
        await loadApp(match);
        break;
      }
    }
  }
}

const router = new MicroFrontendRouter();
router.register('^/products', () => import('products/App'));
router.register('^/checkout', () => import('checkout/App'));

window.addEventListener('popstate', () => {
  router.route(window.location.pathname);
});
```

### 6. Basic Deployment Strategies

#### Independent Deployment
```yaml
# products-mfe/deploy.yml
name: Deploy Products MFE
on:
  push:
    branches: [main]
    paths:
      - 'apps/products/**'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build
        run: npm run build
        working-directory: apps/products
      - name: Deploy to CDN
        run: aws s3 sync dist/ s3://cdn.example.com/products/
```

#### Versioned Deployment
```javascript
// Dynamic remote loading with versioning
const remoteUrl = `https://cdn.example.com/products/${version}/remoteEntry.js`;

const script = document.createElement('script');
script.src = remoteUrl;
script.onload = () => {
  const container = window.products;
  container.init(__webpack_share_scopes__.default);
  const module = await container.get('./App');
  const Component = module().default;
};
document.head.appendChild(script);
```

## OPTIONAL

### 1. Cross-App Communication

#### Event Bus Pattern
```javascript
// shared/eventBus.js
class EventBus {
  constructor() {
    this.events = new Map();
  }

  subscribe(event, callback) {
    if (!this.events.has(event)) {
      this.events.set(event, []);
    }
    this.events.get(event).push(callback);

    // Return unsubscribe function
    return () => {
      const callbacks = this.events.get(event);
      const index = callbacks.indexOf(callback);
      if (index > -1) {
        callbacks.splice(index, 1);
      }
    };
  }

  publish(event, data) {
    const callbacks = this.events.get(event) || [];
    callbacks.forEach(callback => callback(data));
  }
}

export const eventBus = new EventBus();

// Usage in MFE 1
import { eventBus } from '@shared/eventBus';

eventBus.publish('cart:updated', { items: 3, total: 150 });

// Usage in MFE 2
import { eventBus } from '@shared/eventBus';

eventBus.subscribe('cart:updated', (data) => {
  console.log('Cart updated:', data);
});
```

#### Custom Events API
```javascript
// Dispatch custom event from MFE
const event = new CustomEvent('mfe:navigation', {
  detail: { path: '/products/123' },
  bubbles: true,
  composed: true
});
window.dispatchEvent(event);

// Listen in host or other MFEs
window.addEventListener('mfe:navigation', (event) => {
  console.log('Navigate to:', event.detail.path);
  router.push(event.detail.path);
});
```

### 2. Shared State Management

#### Context Provider Pattern
```javascript
// host/src/App.js
import { createContext, useState } from 'react';

export const AppContext = createContext();

export function AppProvider({ children }) {
  const [user, setUser] = useState(null);
  const [cart, setCart] = useState([]);

  return (
    <AppContext.Provider value={{ user, setUser, cart, setCart }}>
      {children}
    </AppContext.Provider>
  );
}

// Expose context through Module Federation
// host/webpack.config.js
new ModuleFederationPlugin({
  name: 'host',
  exposes: {
    './AppContext': './src/AppContext'
  }
});

// Use in remote MFE
import { useContext } from 'react';
import { AppContext } from 'host/AppContext';

function ProductList() {
  const { cart, setCart } = useContext(AppContext);
  // Use shared state
}
```

#### Redux Store Sharing
```javascript
// shared/store.js
import { configureStore } from '@reduxjs/toolkit';

let store;

export function initStore(preloadedState) {
  if (!store) {
    store = configureStore({
      reducer: {
        user: userReducer,
        cart: cartReducer
      },
      preloadedState
    });
  }
  return store;
}

export function getStore() {
  return store;
}

// Host initializes store
import { initStore } from '@shared/store';
const store = initStore();

// Remote MFEs use existing store
import { getStore } from '@shared/store';
const store = getStore();
```

### 3. Error Boundaries

```javascript
// shared/ErrorBoundary.jsx
import React from 'react';

export class MicroFrontendErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error) {
    return { hasError: true, error };
  }

  componentDidCatch(error, errorInfo) {
    // Log to monitoring service
    console.error('MFE Error:', error, errorInfo);

    // Report to analytics
    analytics.track('mfe_error', {
      mfe: this.props.mfeName,
      error: error.message,
      stack: error.stack
    });
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="mfe-error">
          <h2>Something went wrong in {this.props.mfeName}</h2>
          <button onClick={() => this.setState({ hasError: false })}>
            Retry
          </button>
        </div>
      );
    }

    return this.props.children;
  }
}

// Usage
<MicroFrontendErrorBoundary mfeName="Products">
  <Suspense fallback={<Loading />}>
    <ProductsApp />
  </Suspense>
</MicroFrontendErrorBoundary>
```

### 4. Version Management

```javascript
// Version compatibility checker
class VersionManager {
  constructor() {
    this.versions = new Map();
  }

  register(mfeName, version) {
    this.versions.set(mfeName, version);
  }

  checkCompatibility(required) {
    for (const [mfe, version] of Object.entries(required)) {
      const current = this.versions.get(mfe);

      if (!current) {
        throw new Error(`Required MFE ${mfe} not found`);
      }

      if (!this.isCompatible(current, version)) {
        throw new Error(
          `Version mismatch: ${mfe} requires ${version}, got ${current}`
        );
      }
    }
  }

  isCompatible(current, required) {
    // Semver comparison
    const [currMajor, currMinor] = current.split('.').map(Number);
    const [reqMajor, reqMinor] = required.split('.').map(Number);

    return currMajor === reqMajor && currMinor >= reqMinor;
  }
}

const versionManager = new VersionManager();
versionManager.register('products', '2.1.0');
versionManager.register('checkout', '1.5.0');

// Check before loading
versionManager.checkCompatibility({
  products: '2.0.0',  // Compatible
  checkout: '1.4.0'   // Compatible
});
```

### 5. Lazy Loading Remotes

```javascript
// Dynamic remote loading
function loadRemoteComponent(scope, module) {
  return async () => {
    // Initialize the shared scope
    await __webpack_init_sharing__('default');

    const container = window[scope];
    await container.init(__webpack_share_scopes__.default);

    const factory = await container.get(module);
    const Module = factory();

    return Module;
  };
}

// Usage with React
const RemoteComponent = React.lazy(
  loadRemoteComponent('products', './ProductList')
);

function App() {
  return (
    <Suspense fallback={<Loading />}>
      <RemoteComponent />
    </Suspense>
  );
}
```

### 6. CSS Isolation Strategies

#### CSS Modules
```javascript
// Automatic CSS scoping
import styles from './Component.module.css';

export function Component() {
  return <div className={styles.container}>Content</div>;
}
```

#### CSS-in-JS
```javascript
import styled from 'styled-components';

const Container = styled.div`
  background: #f0f0f0;
  padding: 1rem;
`;

export function Component() {
  return <Container>Content</Container>;
}
```

#### Shadow DOM
```javascript
class IsolatedComponent extends HTMLElement {
  connectedCallback() {
    const shadow = this.attachShadow({ mode: 'open' });

    const style = document.createElement('style');
    style.textContent = `
      .container { background: #f0f0f0; }
    `;

    const container = document.createElement('div');
    container.className = 'container';
    container.textContent = 'Isolated Content';

    shadow.appendChild(style);
    shadow.appendChild(container);
  }
}

customElements.define('isolated-component', IsolatedComponent);
```

## ADVANCED

### 1. Dynamic Remote Loading

```javascript
// Runtime remote configuration
class RemoteLoader {
  constructor() {
    this.remotes = new Map();
    this.loaded = new Set();
  }

  async loadRemote(url, scope) {
    if (this.loaded.has(scope)) {
      return window[scope];
    }

    return new Promise((resolve, reject) => {
      const script = document.createElement('script');
      script.src = url;
      script.type = 'text/javascript';
      script.async = true;

      script.onload = () => {
        const proxy = {
          get: (request) => window[scope].get(request),
          init: (arg) => {
            try {
              return window[scope].init(arg);
            } catch (e) {
              console.error('Remote container init failed:', e);
            }
          }
        };

        this.loaded.add(scope);
        this.remotes.set(scope, proxy);
        resolve(proxy);
      };

      script.onerror = reject;
      document.head.appendChild(script);
    });
  }

  async getComponent(scope, module) {
    const remote = await this.loadRemote(
      `https://cdn.example.com/${scope}/remoteEntry.js`,
      scope
    );

    await remote.init(__webpack_share_scopes__.default);
    const factory = await remote.get(module);

    return factory();
  }
}

const loader = new RemoteLoader();

// Usage
const ProductList = await loader.getComponent('products', './ProductList');
```

### 2. A/B Testing Architecture

```javascript
// Feature flag based routing
class ABTestRouter {
  constructor(featureFlags) {
    this.flags = featureFlags;
  }

  async loadVariant(feature, defaultModule, variants) {
    const variant = this.flags.getVariant(feature);

    if (variant && variants[variant]) {
      try {
        return await variants[variant]();
      } catch (error) {
        console.error(`Failed to load variant ${variant}:`, error);
      }
    }

    return await defaultModule();
  }
}

// Usage
const router = new ABTestRouter(featureFlags);

const CheckoutComponent = await router.loadVariant(
  'checkout-redesign',
  () => import('checkout/CheckoutV1'),
  {
    'variant-a': () => import('checkout/CheckoutV2'),
    'variant-b': () => import('checkout/CheckoutV3')
  }
);
```

### 3. Orchestration Patterns

#### Shell Pattern
```javascript
// Shell application orchestrates all MFEs
class ShellOrchestrator {
  constructor() {
    this.mfes = new Map();
    this.activeRegions = new Map();
  }

  registerRegion(regionId, element) {
    this.activeRegions.set(regionId, element);
  }

  async mountMFE(regionId, mfeName, props = {}) {
    const region = this.activeRegions.get(regionId);
    if (!region) {
      throw new Error(`Region ${regionId} not found`);
    }

    // Load MFE
    const MFE = await this.loadMFE(mfeName);

    // Mount to region
    const root = ReactDOM.createRoot(region);
    root.render(<MFE {...props} />);

    this.mfes.set(regionId, { mfeName, root });
  }

  unmountMFE(regionId) {
    const mfe = this.mfes.get(regionId);
    if (mfe) {
      mfe.root.unmount();
      this.mfes.delete(regionId);
    }
  }

  async loadMFE(mfeName) {
    // Dynamic import logic
    const module = await import(`${mfeName}/App`);
    return module.default;
  }
}

const orchestrator = new ShellOrchestrator();
orchestrator.registerRegion('header', document.getElementById('header'));
orchestrator.mountMFE('header', 'navigation', { user: currentUser });
```

#### Client-Side Composition
```javascript
// Layout-based composition
function AppShell() {
  return (
    <div className="app-shell">
      <aside className="sidebar">
        <Suspense fallback={<div>Loading...</div>}>
          <RemoteComponent
            scope="navigation"
            module="./Sidebar"
          />
        </Suspense>
      </aside>

      <main className="content">
        <Suspense fallback={<div>Loading...</div>}>
          <Routes>
            <Route path="/products/*" element={
              <RemoteComponent scope="products" module="./App" />
            } />
            <Route path="/checkout/*" element={
              <RemoteComponent scope="checkout" module="./App" />
            } />
          </Routes>
        </Suspense>
      </main>
    </div>
  );
}
```

### 4. Monitoring and Observability

```javascript
// MFE Performance Monitoring
class MFEMonitor {
  constructor() {
    this.metrics = new Map();
  }

  trackLoad(mfeName, startTime) {
    const loadTime = performance.now() - startTime;

    this.metrics.set(`${mfeName}_load_time`, loadTime);

    // Send to analytics
    analytics.track('mfe_loaded', {
      mfe: mfeName,
      loadTime,
      timestamp: Date.now()
    });
  }

  trackError(mfeName, error) {
    analytics.track('mfe_error', {
      mfe: mfeName,
      error: error.message,
      stack: error.stack,
      timestamp: Date.now()
    });
  }

  trackInteraction(mfeName, action, metadata) {
    analytics.track('mfe_interaction', {
      mfe: mfeName,
      action,
      metadata,
      timestamp: Date.now()
    });
  }

  getMetrics() {
    return Object.fromEntries(this.metrics);
  }
}

const monitor = new MFEMonitor();

// Track MFE load
const startTime = performance.now();
await loadMFE('products');
monitor.trackLoad('products', startTime);

// Track errors
try {
  await loadMFE('checkout');
} catch (error) {
  monitor.trackError('checkout', error);
}
```

### 5. Multi-Framework Integration

```javascript
// React + Vue + Angular MFEs
class MultiFrameworkHost {
  async mountReact(containerId, scope, module) {
    const Component = await this.loadComponent(scope, module);
    const root = ReactDOM.createRoot(document.getElementById(containerId));
    root.render(<Component />);
  }

  async mountVue(containerId, scope, module) {
    const Component = await this.loadComponent(scope, module);
    const app = createApp(Component);
    app.mount(`#${containerId}`);
  }

  async mountAngular(containerId, scope, module) {
    const Component = await this.loadComponent(scope, module);
    platformBrowserDynamic()
      .bootstrapModule(Component)
      .catch(err => console.error(err));
  }

  async loadComponent(scope, module) {
    const container = window[scope];
    await container.init(__webpack_share_scopes__.default);
    const factory = await container.get(module);
    return factory().default;
  }
}

const host = new MultiFrameworkHost();

// Mount different frameworks
await host.mountReact('header', 'react-mfe', './Header');
await host.mountVue('sidebar', 'vue-mfe', './Sidebar');
await host.mountAngular('content', 'angular-mfe', './ContentModule');
```

### 6. Build-Time vs Runtime Federation

#### Build-Time Federation
```javascript
// Static configuration at build time
new ModuleFederationPlugin({
  name: 'host',
  remotes: {
    app1: 'app1@http://localhost:3001/remoteEntry.js',
    app2: 'app2@http://localhost:3002/remoteEntry.js'
  }
});

// Import at build time
import RemoteComponent from 'app1/Component';
```

#### Runtime Federation
```javascript
// Dynamic configuration at runtime
const remoteConfig = await fetch('/api/mfe-config');
const { remotes } = await remoteConfig.json();

for (const [name, url] of Object.entries(remotes)) {
  await loadRemoteEntry(url, name);
}

// Import at runtime
const Component = await loadRemoteComponent('app1', './Component');
```

## Error Handling

| Error Type | Cause | Solution | Recovery Strategy |
|-----------|-------|----------|-------------------|
| `ChunkLoadError` | Remote not accessible | Check network/URL | Fallback component |
| `Module Not Found` | Exposed module missing | Verify expose config | Show error message |
| `Version Mismatch` | Incompatible shared deps | Align versions | Force reload |
| `Shared Scope Error` | Init failure | Check shared config | Retry initialization |
| `Circular Dependency` | MFEs depend on each other | Refactor dependencies | Break circular refs |
| `Memory Leak` | Unmounted MFE not cleaned | Implement cleanup | Use WeakMap/WeakSet |
| `CORS Error` | Cross-origin restriction | Configure headers | Use same origin |
| `Hydration Error` | SSR/CSR mismatch | Fix rendering logic | Client-only render |

### Error Handling Implementation
```javascript
// Comprehensive error handling
class MFEErrorHandler {
  static async loadWithFallback(loader, fallback) {
    try {
      return await loader();
    } catch (error) {
      console.error('Failed to load MFE:', error);

      if (error.name === 'ChunkLoadError') {
        // Retry once
        try {
          return await loader();
        } catch (retryError) {
          return fallback;
        }
      }

      return fallback;
    }
  }

  static createErrorBoundary(mfeName) {
    return class extends React.Component {
      state = { hasError: false };

      static getDerivedStateFromError(error) {
        return { hasError: true };
      }

      componentDidCatch(error, errorInfo) {
        console.error(`${mfeName} error:`, error, errorInfo);
        monitor.trackError(mfeName, error);
      }

      render() {
        if (this.state.hasError) {
          return <div>Error loading {mfeName}</div>;
        }
        return this.props.children;
      }
    };
  }
}

// Usage
const ProductsApp = await MFEErrorHandler.loadWithFallback(
  () => import('products/App'),
  () => <div>Products temporarily unavailable</div>
);

const ErrorBoundary = MFEErrorHandler.createErrorBoundary('Products');

<ErrorBoundary>
  <Suspense fallback={<Loading />}>
    <ProductsApp />
  </Suspense>
</ErrorBoundary>
```

## Test Templates

### Unit Tests
```javascript
describe('Module Federation', () => {
  it('should load remote component', async () => {
    const Component = await loadRemoteComponent('app1', './Header');
    expect(Component).toBeDefined();
  });

  it('should share dependencies correctly', () => {
    const shared = __webpack_share_scopes__.default;
    expect(shared.react).toBeDefined();
    expect(shared['react-dom']).toBeDefined();
  });
});
```

### Integration Tests
```javascript
describe('MFE Integration', () => {
  it('should communicate via event bus', async () => {
    const callback = jest.fn();

    eventBus.subscribe('test:event', callback);
    eventBus.publish('test:event', { data: 'test' });

    expect(callback).toHaveBeenCalledWith({ data: 'test' });
  });

  it('should share state between MFEs', () => {
    const { result } = renderHook(() => useContext(AppContext));

    act(() => {
      result.current.setCart([{ id: 1, name: 'Product' }]);
    });

    expect(result.current.cart).toHaveLength(1);
  });
});
```

### E2E Tests
```javascript
test('MFE loads and renders', async ({ page }) => {
  await page.goto('/');

  // Wait for remote to load
  await page.waitForSelector('[data-mfe="products"]');

  // Verify content
  await expect(page.locator('[data-mfe="products"] h1')).toContainText('Products');
});

test('Navigation between MFEs works', async ({ page }) => {
  await page.goto('/');
  await page.click('[data-testid="products-link"]');

  await expect(page).toHaveURL('/products');
  await expect(page.locator('[data-mfe="products"]')).toBeVisible();
});
```

## Best Practices

### Architecture
- Define clear bounded contexts
- Minimize inter-MFE dependencies
- Use shared libraries judiciously
- Implement proper error boundaries
- Design for independent deployment

### Performance
- Lazy load MFEs when possible
- Optimize shared dependencies
- Implement code splitting
- Monitor bundle sizes
- Use CDN for static assets

### Team Collaboration
- Establish clear contracts between MFEs
- Document exposed modules
- Version MFEs appropriately
- Implement integration testing
- Regular sync meetings

### Deployment
- Automate deployment pipelines
- Implement feature flags
- Use canary deployments
- Monitor production errors
- Have rollback strategy

## Production Configuration

### Webpack Config (Production)
```javascript
const ModuleFederationPlugin = require('webpack/lib/container/ModuleFederationPlugin');

module.exports = {
  mode: 'production',
  optimization: {
    splitChunks: false,
    minimize: true
  },
  plugins: [
    new ModuleFederationPlugin({
      name: 'products',
      filename: 'remoteEntry.js',
      exposes: {
        './App': './src/App'
      },
      shared: {
        react: { singleton: true, eager: true },
        'react-dom': { singleton: true, eager: true }
      }
    })
  ],
  output: {
    publicPath: 'auto',
    clean: true
  }
};
```

### Environment Configuration
```bash
# .env.production
REMOTE_PRODUCTS_URL=https://cdn.example.com/products/remoteEntry.js
REMOTE_CHECKOUT_URL=https://cdn.example.com/checkout/remoteEntry.js
MONITORING_ENABLED=true
FEATURE_FLAGS_API=https://api.example.com/flags
```

### CI/CD Pipeline
```yaml
# .github/workflows/deploy-mfe.yml
name: Deploy MFE
on:
  push:
    branches: [main]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install dependencies
        run: npm ci

      - name: Build
        run: npm run build
        env:
          NODE_ENV: production

      - name: Run tests
        run: npm test

      - name: Deploy to CDN
        run: |
          aws s3 sync dist/ s3://cdn.example.com/${{ github.event.repository.name }}/
          aws cloudfront create-invalidation --distribution-id $DIST_ID --paths "/*"
```

## Assets
- See `assets/micro-frontend-config.yaml` for architecture patterns

## Resources
- [Module Federation](https://webpack.js.org/concepts/module-federation/)
- [Micro Frontends](https://micro-frontends.org/)
- [Single-SPA](https://single-spa.js.org/)
- [Martin Fowler - Micro Frontends](https://martinfowler.com/articles/micro-frontends.html)

---
**Status:** Active | **Version:** 2.0.0 | **Complexity:** Expert | **Estimated Time:** 8-12 hours
