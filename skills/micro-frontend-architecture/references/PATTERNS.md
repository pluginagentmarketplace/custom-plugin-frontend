# Micro-Frontend Architecture Patterns

Production patterns for implementing micro-frontend architectures with Module Federation.

## Module Federation Organization Patterns

### Pattern 1: Hub-and-Spoke (Star Topology)

One host application loads multiple remotes:

```javascript
// webpack.config.js (Host)
new ModuleFederationPlugin({
  name: 'host',
  remotes: {
    dashboard: 'dashboard@http://dashboard.app/remote.js',
    analytics: 'analytics@http://analytics.app/remote.js',
    settings: 'settings@http://settings.app/remote.js'
  },
  shared: commonDeps
});

// Each remote exposes independently
// Host orchestrates routing and loading
```

**Best for:**
- Single main application
- Multiple feature modules
- Centralized orchestration

### Pattern 2: Federated Network (Mesh Topology)

Multiple applications sharing dependencies:

```javascript
// Each app can be both host and remote
const config = {
  name: process.env.APP_NAME,
  remotes: process.env.REMOTES ? JSON.parse(process.env.REMOTES) : {},
  exposes: {
    './Components': './src/components',
    './Utils': './src/utils'
  },
  shared: commonDeps
};
```

**Best for:**
- Distributed teams
- Flexible composition
- P2P sharing

## Shared Dependency Strategies

### Strategy 1: Conservative Sharing

```javascript
// Only share core dependencies
shared: {
  react: { singleton: true },
  'react-dom': { singleton: true },
  'react-router-dom': { singleton: true }
}

// Everything else: bundled separately
```

**Pros:** Predictable, fewer version conflicts
**Cons:** Larger total bundle size

### Strategy 2: Aggressive Sharing

```javascript
// Share everything possible
shared: {
  react: { singleton: true },
  'react-dom': { singleton: true },
  'react-query': { singleton: true },
  'zustand': { singleton: true },
  'lodash-es': { singleton: true },
  'axios': { singleton: true },
  'styled-components': { singleton: true }
}
```

**Pros:** Minimal bundle size
**Cons:** More version conflicts, complex management

### Strategy 3: Hybrid Approach

```javascript
// Core framework and essential UI libs shared
const shared = {
  react: { singleton: true },
  'react-dom': { singleton: true },
  'react-router-dom': { singleton: true },
  'react-query': { singleton: true }
};

// Application-specific: bundled separately
// This allows each micro-frontend to use preferred libraries
```

## Dynamic Loading Patterns

### Pattern 1: Lazy Load Remotes

```typescript
// Load remotes only when navigated to
import React, { Suspense } from 'react';

const Dashboard = React.lazy(() =>
  import(/* webpackChunkName: "dashboard" */ 'dashboard/Dashboard')
);

const Analytics = React.lazy(() =>
  import(/* webpackChunkName: "analytics" */ 'analytics/Analytics')
);

export function AppRoutes() {
  return (
    <Routes>
      <Route
        path="/dashboard"
        element={
          <Suspense fallback={<Loader />}>
            <Dashboard />
          </Suspense>
        }
      />
      <Route
        path="/analytics"
        element={
          <Suspense fallback={<Loader />}>
            <Analytics />
          </Suspense>
        }
      />
    </Routes>
  );
}
```

### Pattern 2: Preload Remotes

```javascript
// Preload remotes in background
function preloadRemote(scope, url) {
  const link = document.createElement('link');
  link.rel = 'prefetch';
  link.href = url;
  document.head.appendChild(link);
}

// Preload during idle time
if ('requestIdleCallback' in window) {
  requestIdleCallback(() => {
    preloadRemote('dashboard', 'http://dashboard.app/remote.js');
    preloadRemote('analytics', 'http://analytics.app/remote.js');
  });
}
```

### Pattern 3: Dynamic Remote Registration

```javascript
// Register remotes dynamically based on config
interface RemoteConfig {
  [key: string]: string; // name => URL
}

async function registerRemotes(config: RemoteConfig) {
  const remotes: Record<string, string> = {};

  for (const [name, url] of Object.entries(config)) {
    remotes[name] = `${name}@${url}`;
  }

  // Register with Module Federation
  window.__REMOTES__ = remotes;
}

// Load from API at runtime
const remoteConfig = await fetch('/api/remotes').then(r => r.json());
await registerRemotes(remoteConfig);
```

## Inter-Micro-Frontend Communication

### Pattern 1: Context & Shared Store (Zustand)

```typescript
// shared-store.ts (in shared library)
import create from 'zustand';

interface AppState {
  user: User | null;
  setUser: (user: User) => void;
  theme: 'light' | 'dark';
  setTheme: (theme: string) => void;
}

export const useAppStore = create<AppState>((set) => ({
  user: null,
  setUser: (user) => set({ user }),
  theme: 'light',
  setTheme: (theme) => set({ theme })
}));
```

```typescript
// Used in both host and remotes
export function Dashboard() {
  const { user, theme } = useAppStore();

  return (
    <div data-theme={theme}>
      <h1>Hello, {user?.name}</h1>
    </div>
  );
}
```

### Pattern 2: Event Bus

```typescript
// event-bus.ts
class EventBus {
  private listeners: Map<string, Function[]> = new Map();

  subscribe(event: string, callback: Function) {
    if (!this.listeners.has(event)) {
      this.listeners.set(event, []);
    }
    this.listeners.get(event)!.push(callback);

    return () => {
      const cbs = this.listeners.get(event)!;
      cbs.splice(cbs.indexOf(callback), 1);
    };
  }

  emit(event: string, data: any) {
    const callbacks = this.listeners.get(event) || [];
    callbacks.forEach(cb => cb(data));
  }
}

export const eventBus = new EventBus();
```

```typescript
// Usage in different micro-frontends
// Dashboard
eventBus.subscribe('userLoggedIn', (user) => {
  console.log('User logged in:', user);
});

// Analytics
eventBus.emit('userLoggedIn', { id: '123', name: 'John' });
```

### Pattern 3: Window Messaging

```typescript
// Cross-origin communication between micro-frontends
class MicroFrontendBridge {
  static send(target: Window, message: any) {
    target.postMessage(
      { source: 'mfe', ...message },
      location.origin
    );
  }

  static listen(callback: (message: any) => void) {
    window.addEventListener('message', (event) => {
      if (event.data?.source === 'mfe') {
        callback(event.data);
      }
    });
  }
}

// In Dashboard micro-frontend
MicroFrontendBridge.listen((message) => {
  if (message.type === 'userChanged') {
    updateDashboard(message.user);
  }
});

// In Host application
MicroFrontendBridge.send(dashboardWindow, {
  type: 'userChanged',
  user: newUser
});
```

## CSS Isolation Patterns

### Pattern 1: CSS Module Scoping

```typescript
// styles/dashboard.module.css
.container {
  padding: 20px;
}

.title {
  font-size: 24px;
  color: var(--primary-color);
}

// components/Dashboard.tsx
import styles from '../styles/dashboard.module.css';

export function Dashboard() {
  return (
    <div className={styles.container}>
      <h1 className={styles.title}>Dashboard</h1>
    </div>
  );
}
```

### Pattern 2: CSS-in-JS with Theme

```typescript
import styled from 'styled-components';

const DashboardContainer = styled.div`
  padding: 20px;
  background: ${props => props.theme.backgroundColor};
  color: ${props => props.theme.textColor};
`;

const Title = styled.h1`
  font-size: 24px;
  margin-bottom: 20px;
`;

export function Dashboard() {
  return (
    <DashboardContainer>
      <Title>Dashboard</Title>
    </DashboardContainer>
  );
}
```

## Testing Patterns

### Pattern: Integration Testing Micro-Frontends

```typescript
// test/integration.test.ts
import { render, screen } from '@testing-library/react';
import { RemoteContainer } from '@shared/RemoteContainer';

describe('Dashboard Micro-Frontend Integration', () => {
  test('loads and renders dashboard', async () => {
    render(
      <RemoteContainer
        scope="dashboard"
        module="./Dashboard"
      />
    );

    // Wait for remote to load
    const dashboard = await screen.findByText(/dashboard/i);
    expect(dashboard).toBeInTheDocument();
  });

  test('handles loading errors', async () => {
    render(
      <RemoteContainer
        scope="invalid-scope"
        module="./Component"
        onError={(error) => {
          expect(error.message).toContain('not found');
        }}
      />
    );
  });
});
```

## Deployment Pattern

### Pattern: Independent Deployment

```bash
# Dashboard team
npm run build
aws s3 sync dist/ s3://microfrontends/dashboard/

# Analytics team
npm run build
aws s3 sync dist/ s3://microfrontends/analytics/

# Host application (references stable URLs)
# No redeploy needed!
```

## Error Handling and Fallback

### Pattern: Graceful Degradation

```typescript
class MicroFrontendLoader {
  static async load(scope: string, module: string) {
    try {
      return await import(`${scope}/${module}`);
    } catch (error) {
      console.error(`Failed to load ${scope}/${module}`, error);

      // Return fallback component
      return {
        default: ErrorFallback
      };
    }
  }
}

function ErrorFallback() {
  return (
    <div style={{ padding: '20px', color: 'red' }}>
      Failed to load this component. Please try again later.
    </div>
  );
}
```

These patterns provide production-ready approaches for managing complex micro-frontend architectures with proper isolation, communication, and scalability.
