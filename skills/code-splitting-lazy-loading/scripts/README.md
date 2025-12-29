# code-splitting-lazy-loading Scripts

Scripts for validating and generating React.lazy() and Suspense patterns with lazy-loaded components and routes.

## Available Scripts

### validate-lazy.sh
Analyzes React codebase for lazy-loading patterns and validates Suspense/error boundary setup.

**Usage:**
```bash
./scripts/validate-lazy.sh [PROJECT_DIR]
```

**Checks:**
- React.lazy() usage detection
- Suspense boundary implementation
- Error boundary coverage for lazy components
- Dynamic import() patterns
- Route lazy loading setup
- Loading indicator components
- Component-level lazy patterns
- Fallback UI presence
- Proper Promise handling
- Error states implementation

**Example:**
```bash
./scripts/validate-lazy.sh /path/to/project
```

### generate-lazy-component.sh
Generates production-ready lazy-loaded React components with error handling and loading states.

**Usage:**
```bash
./scripts/generate-lazy-component.sh [OUTPUT_DIR] [COMPONENT_NAME] [COMPONENT_TYPE]
```

**Component Types:**
- `route` - Route-level lazy component (default)
- `modal` - Modal component with lazy loading
- `feature` - Feature module with lazy loading
- `tab` - Tab content with lazy loading

**Generates:**
- LazyComponent.tsx - Lazy-loaded component wrapper
- ErrorBoundary.tsx - Error handling for lazy components
- Suspense boundary configuration
- Loading state component
- Index exports

**Example:**
```bash
./scripts/generate-lazy-component.sh ./src/pages Dashboard route
./scripts/generate-lazy-component.sh ./src/modals UserProfile modal
./scripts/generate-lazy-component.sh ./src/features Analytics feature
```

## Script Features

### Validation Script
- React.lazy() pattern detection
- Suspense boundary analysis
- Error boundary implementation checking
- Dynamic import counting
- Route configuration validation
- Loading UI component detection
- Promise/async pattern verification
- Error handling setup verification
- Component import organization
- Type checking for TypeScript projects

### Generation Script
- Complete component structure setup
- Error boundary wrapper
- Loading state management
- Fallback UI component
- TypeScript support
- Documentation and usage examples
- Test file generation
- Index exports for clean imports

## Generated Components

### Lazy Component Wrapper
```typescript
// LazyComponent.tsx
const Component = lazy(() => import('./ActualComponent'));

export function LazyComponent(props) {
  return (
    <ErrorBoundary>
      <Suspense fallback={<LoadingState />}>
        <Component {...props} />
      </Suspense>
    </ErrorBoundary>
  );
}
```

### Error Boundary
```typescript
// ErrorBoundary.tsx
class ErrorBoundary extends React.Component {
  state = { hasError: false };

  static getDerivedStateFromError(error) {
    return { hasError: true };
  }

  componentDidCatch(error, errorInfo) {
    // Error handling
  }

  render() {
    // Error UI or children
  }
}
```

### Loading State
```typescript
// LoadingState.tsx
export function LoadingState() {
  return <div className="loading-spinner">Loading...</div>;
}
```

## Component Types

### Route-Level Lazy Loading
For page/route components that are code-split:
- Full page layout
- Route-specific styling
- Integration with React Router
- Analytics tracking

### Modal Lazy Loading
For heavy modal dialogs:
- Modal wrapper component
- Backdrop and animation
- Portal rendering
- Keyboard handling

### Feature Module Lazy Loading
For feature flags and optional modules:
- Feature detection
- Conditional loading
- Enable/disable switching
- Analytics integration

### Tab Content Lazy Loading
For tabbed interfaces:
- Tab content rendering
- Content caching
- Transition effects
- Active state management

## Best Practices

1. Always wrap lazy components in Suspense boundaries
2. Implement error boundaries for all lazy components
3. Provide meaningful loading UI
4. Handle error states gracefully
5. Use named chunks for easier debugging
6. Test lazy loading in slow network conditions
7. Monitor chunk loading performance
8. Document lazy-loaded routes/components
9. Set timeout for stuck loading states
10. Use prefetch for likely-to-be-needed chunks

## Generated File Structure

```
component-name/
├── Lazy${ComponentName}.tsx      # Lazy wrapper component
├── ${ComponentName}.tsx           # Actual component
├── ErrorBoundary.tsx              # Error boundary
├── LoadingState.tsx               # Loading fallback
├── index.ts                       # Exports
├── ${ComponentName}.test.tsx      # Tests
└── ${ComponentName}.types.ts      # TypeScript types
```

## Usage in Application

```typescript
// Import lazy component
import { LazyDashboard } from './pages/LazyDashboard';

// Use in routes
<Route path="/dashboard" element={<LazyDashboard />} />

// Or standalone
<LazyDashboard userId={123} />
```

## Configuration Options

All scripts support:
- TypeScript (.tsx) or JavaScript (.jsx)
- Different CSS processors (CSS, SCSS, Tailwind)
- Testing frameworks (Jest, Vitest)
- Error tracking integration (Sentry, LogRocket)

Pass configuration via environment variables or modify generated files.
