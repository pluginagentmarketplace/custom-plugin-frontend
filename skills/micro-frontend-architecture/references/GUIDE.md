# Micro-Frontend Architecture Technical Guide

## Micro-Frontend Benefits and Trade-offs

Micro-frontends extend the micro-services philosophy to the frontend, allowing independent teams to develop and deploy parts of a web interface.

### Benefits

**1. Scalability**: Large applications divided into manageable pieces
**2. Team Autonomy**: Different teams own different features
**3. Technology Flexibility**: Mix React, Vue, Angular in one app
**4. Independent Deployment**: Deploy parts without redeploying entire app
**5. Fault Isolation**: One broken micro-frontend doesn't crash everything
**6. Performance Optimization**: Load only needed parts

### Trade-offs

**1. Complexity**: Harder to set up and maintain
**2. Bundle Duplication**: Shared libraries may be duplicated
**3. Communication Overhead**: Inter-micro-frontend communication adds latency
**4. Version Management**: Handling version conflicts of shared dependencies
**5. Testing Complexity**: Integration testing becomes harder
**6. Runtime Coupling**: Despite isolation, still coupled at runtime

## Module Federation (Webpack 5)

Module Federation is Webpack 5's native feature for dynamic code sharing between applications at runtime.

### Architecture: Host and Remote

```
┌─────────────────────────────────────┐
│       HOST APPLICATION              │
│  (Main app, loads micro-frontends)  │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Dashboard (Remote)          │   │
│  │ Loaded at runtime           │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Analytics (Remote)          │   │
│  │ Loaded at runtime           │   │
│  └─────────────────────────────┘   │
│                                     │
│  Shared Dependencies:               │
│  - React, React-DOM                 │
│  - React-Router                     │
└─────────────────────────────────────┘

     Separate Micro-Frontends
         (Deployed independently)
     ┌─────────────────────────────────┐
     │   Dashboard Remote              │
     │   Exposes: Dashboard, Widget    │
     └─────────────────────────────────┘

     ┌─────────────────────────────────┐
     │   Analytics Remote              │
     │   Exposes: Analytics, Chart     │
     └─────────────────────────────────┘
```

### Module Federation Configuration

```javascript
const { ModuleFederationPlugin } = require('webpack').container;

module.exports = {
  plugins: [
    new ModuleFederationPlugin({
      // Application name
      name: 'host',

      // Declare remote micro-frontends
      remotes: {
        dashboard: 'dashboard@http://localhost:3001/remoteEntry.js',
        analytics: 'analytics@http://localhost:3002/remoteEntry.js'
      },

      // Expose components for consumption
      exposes: {
        './Dashboard': './src/components/Dashboard'
      },

      // Shared dependencies (critical!)
      shared: {
        react: {
          singleton: true, // Only one React instance
          requiredVersion: '^18.0.0'
        },
        'react-dom': {
          singleton: true,
          requiredVersion: '^18.0.0'
        }
      }
    })
  ]
};
```

### Host Application

```javascript
// Host loads remote components dynamically
import React, { Suspense } from 'react';

const Dashboard = React.lazy(() => import('dashboard/Dashboard'));

export default function App() {
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <Dashboard />
    </Suspense>
  );
}
```

### Remote Application

```javascript
// Remote exposes components
const { ModuleFederationPlugin } = require('webpack').container;

module.exports = {
  plugins: [
    new ModuleFederationPlugin({
      name: 'dashboard',
      filename: 'remoteEntry.js', // Entry point for host

      // Expose components
      exposes: {
        './Dashboard': './src/components/Dashboard',
        './Widget': './src/components/Widget',
        './useMetrics': './src/hooks/useMetrics'
      },

      // Declare shared dependencies
      shared: {
        react: { singleton: true },
        'react-dom': { singleton: true }
      }
    })
  ]
};
```

## Shared Dependencies Management

### Singleton Pattern

Prevents multiple instances of shared libraries:

```javascript
shared: {
  react: {
    singleton: true, // Only one instance
    strictVersion: false, // Allow version flexibility
    requiredVersion: '^18.0.0'
  }
}
```

### Version Conflict Resolution

```javascript
shared: {
  react: {
    singleton: true,
    strictVersion: true, // Require exact version
    requiredVersion: '^18.2.0'
  },
  'react-router': {
    singleton: true,
    requiredVersion: '^6.0.0'
  }
}
```

### Strategy: Shared Scope Initialization

```javascript
// Remote component initialization
export async function loadRemote(scope, module, shareScope) {
  // Initialize share scope before loading remote
  await __webpack_share_scopes__.default.init(shareScope);

  const container = window[scope];
  await container.init(shareScope);

  const factory = await container.get(module);
  return factory();
}
```

## Version Management Strategies

### Strategy 1: Flexible Version Ranges

```javascript
shared: {
  react: {
    singleton: true,
    requiredVersion: '>=16.0.0 <19.0.0'
  }
}
```

### Strategy 2: Major Version Isolation

```javascript
// Create separate remotes for different major versions
remotes: {
  'dashboard-v1': 'dashboard@http://legacy.app/remoteEntry.js',
  'dashboard-v2': 'dashboard@http://app.example.com/remoteEntry.js'
}
```

### Strategy 3: Package Manager Compatibility

```javascript
// In remote webpack config
exposes: {
  './Button': './src/components/Button'
},
shared: {
  react: {
    requiredVersion: require('./package.json').peerDependencies.react,
    singleton: true
  }
}
```

## CSS Isolation

Prevent style conflicts between micro-frontends:

### Approach 1: CSS Modules

```css
/* Dashboard.module.css */
.container {
  padding: 20px;
}

.title {
  color: #333;
}
```

```javascript
import styles from './Dashboard.module.css';

export default function Dashboard() {
  return (
    <div className={styles.container}>
      <h1 className={styles.title}>Dashboard</h1>
    </div>
  );
}
```

### Approach 2: CSS-in-JS (Styled-Components)

```javascript
import styled from 'styled-components';

const Container = styled.div`
  padding: 20px;
`;

const Title = styled.h1`
  color: #333;
`;

export default function Dashboard() {
  return (
    <Container>
      <Title>Dashboard</Title>
    </Container>
  );
}
```

### Approach 3: BEM Naming Convention

```css
/* No isolation, but avoids conflicts with naming */
.dashboard__container {
  padding: 20px;
}

.dashboard__title {
  color: #333;
}
```

## Polyrepo vs Monorepo Architecture

### Polyrepo (Separate Repositories)

```
github.com/company/host-app
github.com/company/dashboard-micro
github.com/company/analytics-micro

✓ True independence
✓ Separate CI/CD pipelines
✓ Different deployment schedules
✗ Harder to share code
✗ Dependency management complexity
✗ More operational overhead
```

### Monorepo (Single Repository)

```
/host-app
/dashboard-micro
/analytics-micro
/shared-components
/shared-utils

✓ Easier code sharing
✓ Atomic commits
✓ Simplified testing
✗ Tightly coupled
✗ Shared deployment
✗ Larger repository
```

### Hybrid Approach

```
Main Repository (Monorepo):
  - Host application
  - Shared design system
  - Core utilities

Separate Repositories:
  - Large feature modules
  - Third-party integrations
```

## Performance Considerations

### Bundle Size Impact

```javascript
// Without Module Federation (all in one bundle)
Bundle size: 2.5MB

// With Module Federation
Host: 500KB
Dashboard Remote: 800KB
Analytics Remote: 600KB
Shared: 400KB (loaded once)

Total initial load: 500KB + 400KB = 900KB
Much better than 2.5MB!
```

### Code Splitting Strategy

```javascript
// Load remotes only when needed
const Dashboard = React.lazy(() =>
  import(/* webpackChunkName: "dashboard" */ 'dashboard/Dashboard')
);

// Prefetch optional remotes
const prefetchRemote = (scope, url) => {
  const link = document.createElement('link');
  link.rel = 'prefetch';
  link.href = url;
  document.head.appendChild(link);
};

prefetchRemote('dashboard', 'http://localhost:3001/remoteEntry.js');
```

This architecture enables building scalable, maintainable frontend applications where teams can work independently while sharing common dependencies.
