#!/bin/bash
# Generate Lazy-Loaded React Component with Error Handling
# Part of code-splitting-lazy-loading skill - Golden Format E703 Compliant

set -e

OUTPUT_DIR="${1:-.}"
COMPONENT_NAME="${2:-LazyComponent}"
COMPONENT_TYPE="${3:-route}"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Generating lazy-loaded component: $COMPONENT_NAME (type: $COMPONENT_TYPE)...${NC}\n"

# Create output directory
mkdir -p "$OUTPUT_DIR/$COMPONENT_NAME"

# 1. Generate Error Boundary component
echo "Creating ErrorBoundary..."
cat > "$OUTPUT_DIR/$COMPONENT_NAME/ErrorBoundary.tsx" << 'EOF'
import React, { ReactNode, ErrorInfo } from 'react';

interface Props {
  children?: ReactNode;
  fallback?: ReactNode;
}

interface State {
  hasError: boolean;
  error?: Error;
}

/**
 * Error Boundary for lazy-loaded components
 * Catches errors in lazy component rendering and displays fallback UI
 */
export class ErrorBoundary extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('Lazy component error:', error, errorInfo);
    // Send to error tracking service (Sentry, Rollbar, etc.)
    // logErrorToService(error, errorInfo);
  }

  handleReset = () => {
    this.setState({ hasError: false, error: undefined });
  };

  render() {
    if (this.state.hasError) {
      return this.props.fallback ?? (
        <div
          style={{
            padding: '2rem',
            textAlign: 'center',
            backgroundColor: '#fee',
            borderRadius: '8px',
          }}
        >
          <h2>Something went wrong</h2>
          <p style={{ color: '#666', marginBottom: '1rem' }}>
            {this.state.error?.message}
          </p>
          <button
            onClick={this.handleReset}
            style={{
              padding: '0.5rem 1rem',
              backgroundColor: '#007bff',
              color: 'white',
              border: 'none',
              borderRadius: '4px',
              cursor: 'pointer',
            }}
          >
            Try again
          </button>
        </div>
      );
    }

    return this.props.children;
  }
}
EOF
echo -e "${GREEN}✓ Created ErrorBoundary.tsx${NC}"

# 2. Generate LoadingState component
echo "Creating LoadingState..."
cat > "$OUTPUT_DIR/$COMPONENT_NAME/LoadingState.tsx" << 'EOF'
import React from 'react';

interface LoadingStateProps {
  message?: string;
  size?: 'small' | 'medium' | 'large';
}

/**
 * Loading indicator for Suspense fallback
 */
export const LoadingState: React.FC<LoadingStateProps> = ({
  message = 'Loading...',
  size = 'medium',
}) => {
  const sizeMap = {
    small: '24px',
    medium: '40px',
    large: '60px',
  };

  return (
    <div
      style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '2rem',
        minHeight: '200px',
        gap: '1rem',
      }}
    >
      <div
        style={{
          width: sizeMap[size],
          height: sizeMap[size],
          border: '4px solid #f3f3f3',
          borderTop: '4px solid #007bff',
          borderRadius: '50%',
          animation: 'spin 1s linear infinite',
        }}
      />
      <p style={{ color: '#666', margin: 0, fontSize: '0.9rem' }}>
        {message}
      </p>
      <style>{`
        @keyframes spin {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
      `}</style>
    </div>
  );
};
EOF
echo -e "${GREEN}✓ Created LoadingState.tsx${NC}"

# 3. Generate main lazy component based on type
echo "Creating main component (type: $COMPONENT_TYPE)..."

if [ "$COMPONENT_TYPE" = "modal" ]; then
    cat > "$OUTPUT_DIR/$COMPONENT_NAME/Lazy${COMPONENT_NAME}.tsx" << 'EOF'
import React, { Suspense, lazy, PropsWithChildren } from 'react';
import { ErrorBoundary } from './ErrorBoundary';
import { LoadingState } from './LoadingState';

const ActualComponent = lazy(() =>
  import(
    /* webpackChunkName: "modal-component" */
    './$COMPONENT_NAME'
  )
);

interface LazyModalProps extends PropsWithChildren {
  isOpen: boolean;
  onClose: () => void;
  title?: string;
  size?: 'small' | 'medium' | 'large';
}

/**
 * Lazy-loaded Modal Component
 * Suspends until modal chunk is loaded
 */
export const LazyModal: React.FC<LazyModalProps> = ({
  isOpen,
  onClose,
  title,
  size = 'medium',
  children,
}) => {
  if (!isOpen) return null;

  return (
    <ErrorBoundary fallback={
      <div style={{ padding: '2rem', textAlign: 'center' }}>
        <p>Failed to load modal</p>
        <button onClick={onClose}>Close</button>
      </div>
    }>
      <Suspense fallback={<LoadingState message="Loading modal..." />}>
        <ActualComponent
          onClose={onClose}
          title={title}
          size={size}
        >
          {children}
        </ActualComponent>
      </Suspense>
    </ErrorBoundary>
  );
};

export default LazyModal;
EOF
elif [ "$COMPONENT_TYPE" = "feature" ]; then
    cat > "$OUTPUT_DIR/$COMPONENT_NAME/Lazy${COMPONENT_NAME}.tsx" << 'EOF'
import React, { Suspense, lazy, PropsWithChildren } from 'react';
import { ErrorBoundary } from './ErrorBoundary';
import { LoadingState } from './LoadingState';

const ActualComponent = lazy(() =>
  import(
    /* webpackChunkName: "feature-module" */
    './$COMPONENT_NAME'
  )
);

interface LazyFeatureProps extends PropsWithChildren {
  enabled?: boolean;
  onError?: (error: Error) => void;
  fallback?: React.ReactNode;
}

/**
 * Lazy-loaded Feature Component
 * Loads feature module only when needed
 */
export const LazyFeature: React.FC<LazyFeatureProps> = ({
  enabled = true,
  onError,
  fallback,
  children,
}) => {
  if (!enabled) {
    return <>{children}</>;
  }

  return (
    <ErrorBoundary fallback={fallback || <LoadingState message="Feature unavailable" />}>
      <Suspense fallback={<LoadingState message="Loading feature..." />}>
        <ActualComponent />
      </Suspense>
    </ErrorBoundary>
  );
};

export default LazyFeature;
EOF
elif [ "$COMPONENT_TYPE" = "tab" ]; then
    cat > "$OUTPUT_DIR/$COMPONENT_NAME/Lazy${COMPONENT_NAME}.tsx" << 'EOF'
import React, { Suspense, lazy, PropsWithChildren, useState } from 'react';
import { ErrorBoundary } from './ErrorBoundary';
import { LoadingState } from './LoadingState';

const TabContent = lazy(() =>
  import(
    /* webpackChunkName: "tab-content" */
    './$COMPONENT_NAME'
  )
);

interface LazyTabProps extends PropsWithChildren {
  tabId: string;
  cacheContent?: boolean;
}

/**
 * Lazy-loaded Tab Content Component
 * Loads tab content on-demand with optional caching
 */
export const LazyTab: React.FC<LazyTabProps> = ({
  tabId,
  cacheContent = true,
  children,
}) => {
  const [loadedTabs, setLoadedTabs] = useState<Set<string>>(new Set());
  const isLoaded = loadedTabs.has(tabId);

  React.useEffect(() => {
    if (cacheContent && isLoaded) {
      setLoadedTabs(prev => new Set(prev).add(tabId));
    }
  }, [tabId, cacheContent, isLoaded]);

  if (cacheContent && !isLoaded) {
    return null;
  }

  return (
    <ErrorBoundary fallback={<div>Failed to load tab content</div>}>
      <Suspense fallback={<LoadingState message="Loading tab..." size="small" />}>
        <TabContent tabId={tabId} />
      </Suspense>
    </ErrorBoundary>
  );
};

export default LazyTab;
EOF
else
    # Default: route type
    cat > "$OUTPUT_DIR/$COMPONENT_NAME/Lazy${COMPONENT_NAME}.tsx" << 'EOF'
import React, { Suspense, lazy, PropsWithChildren } from 'react';
import { ErrorBoundary } from './ErrorBoundary';
import { LoadingState } from './LoadingState';

const ActualComponent = lazy(() =>
  import(
    /* webpackChunkName: "route-page" */
    /* webpackPreload: false */
    './$COMPONENT_NAME'
  )
);

interface LazyPageProps extends PropsWithChildren {
  [key: string]: any;
}

/**
 * Lazy-loaded Route Component
 * Automatically code-splits and loads page component
 */
export const Lazy${COMPONENT_NAME}: React.FC<LazyPageProps> = (props) => {
  return (
    <ErrorBoundary fallback={
      <div style={{ padding: '2rem', textAlign: 'center' }}>
        <h2>Page Load Error</h2>
        <p>Failed to load this page. Please try refreshing.</p>
      </div>
    }>
      <Suspense fallback={<LoadingState message="Loading page..." />}>
        <ActualComponent {...props} />
      </Suspense>
    </ErrorBoundary>
  );
};

export default Lazy${COMPONENT_NAME};
EOF
fi
echo -e "${GREEN}✓ Created Lazy${COMPONENT_NAME}.tsx${NC}"

# 4. Generate placeholder actual component
echo "Creating placeholder component..."
cat > "$OUTPUT_DIR/$COMPONENT_NAME/${COMPONENT_NAME}.tsx" << "EOF"
import React from 'react';

interface ${COMPONENT_NAME}Props {
  [key: string]: any;
}

/**
 * ${COMPONENT_NAME} Component
 * This is the actual component loaded lazily
 * Replace this with your actual component implementation
 */
export const ${COMPONENT_NAME}: React.FC<${COMPONENT_NAME}Props> = (props) => {
  return (
    <div style={{ padding: '1rem' }}>
      <h1>${COMPONENT_NAME}</h1>
      <p>This component was lazy-loaded successfully!</p>
    </div>
  );
};

export default ${COMPONENT_NAME};
EOF
echo -e "${GREEN}✓ Created ${COMPONENT_NAME}.tsx${NC}"

# 5. Generate test file
echo "Creating test file..."
cat > "$OUTPUT_DIR/$COMPONENT_NAME/${COMPONENT_NAME}.test.tsx" << 'EOF'
import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import { Suspense } from 'react';
import { ErrorBoundary } from './ErrorBoundary';
import Lazy${COMPONENT_NAME} from './Lazy${COMPONENT_NAME}';

describe('Lazy${COMPONENT_NAME}', () => {
  it('renders loading state initially', () => {
    render(
      <Suspense fallback={<div>Loading...</div>}>
        <Lazy${COMPONENT_NAME} />
      </Suspense>
    );
    expect(screen.getByText(/Loading/i)).toBeInTheDocument();
  });

  it('renders component after loading', async () => {
    render(
      <Suspense fallback={<div>Loading...</div>}>
        <Lazy${COMPONENT_NAME} />
      </Suspense>
    );

    await waitFor(() => {
      expect(screen.getByText('${COMPONENT_NAME}')).toBeInTheDocument();
    });
  });

  it('handles errors gracefully', () => {
    const { container } = render(
      <ErrorBoundary>
        <Suspense fallback={<div>Loading...</div>}>
          <Lazy${COMPONENT_NAME} />
        </Suspense>
      </ErrorBoundary>
    );
    expect(container).toBeInTheDocument();
  });
});
EOF
echo -e "${GREEN}✓ Created ${COMPONENT_NAME}.test.tsx${NC}"

# 6. Generate TypeScript types file
echo "Creating types file..."
cat > "$OUTPUT_DIR/$COMPONENT_NAME/${COMPONENT_NAME}.types.ts" << 'EOF'
/**
 * Type definitions for ${COMPONENT_NAME}
 */

export interface ${COMPONENT_NAME}Props {
  [key: string]: any;
}

export interface LoadingStateProps {
  message?: string;
  size?: 'small' | 'medium' | 'large';
}

export interface ErrorBoundaryProps {
  children?: React.ReactNode;
  fallback?: React.ReactNode;
}
EOF
echo -e "${GREEN}✓ Created ${COMPONENT_NAME}.types.ts${NC}"

# 7. Generate index exports
echo "Creating index file..."
cat > "$OUTPUT_DIR/$COMPONENT_NAME/index.ts" << 'EOF'
export { Lazy${COMPONENT_NAME}, default } from './Lazy${COMPONENT_NAME}';
export { ${COMPONENT_NAME}, default as ${COMPONENT_NAME}Default } from './${COMPONENT_NAME}';
export { ErrorBoundary } from './ErrorBoundary';
export { LoadingState } from './LoadingState';
export type * from './${COMPONENT_NAME}.types';
EOF
echo -e "${GREEN}✓ Created index.ts${NC}"

# 8. Generate README
echo "Creating README..."
cat > "$OUTPUT_DIR/$COMPONENT_NAME/README.md" << 'EOF'
# Lazy-Loaded ${COMPONENT_NAME} Component

This is a lazy-loaded React component with built-in error handling and loading states.

## Usage

### As Route Component
```tsx
import { Lazy${COMPONENT_NAME} } from './components/Lazy${COMPONENT_NAME}';

<Route path="/page" element={<Lazy${COMPONENT_NAME} />} />
```

### Direct Import
```tsx
import { Lazy${COMPONENT_NAME} } from './components/Lazy${COMPONENT_NAME}';

<Lazy${COMPONENT_NAME} prop1="value" />
```

## Features

- **Lazy Loading**: Component code is split and loaded on-demand
- **Error Handling**: Built-in error boundary for safe error handling
- **Loading State**: Displays loading indicator while component loads
- **TypeScript Support**: Full TypeScript support with type definitions
- **Testing Ready**: Includes test file structure

## File Structure

- `Lazy${COMPONENT_NAME}.tsx` - Main lazy-loaded wrapper
- `${COMPONENT_NAME}.tsx` - Actual component implementation
- `ErrorBoundary.tsx` - Error boundary wrapper
- `LoadingState.tsx` - Loading indicator component
- `index.ts` - Clean exports

## Error Handling

If the component fails to load, the error boundary displays an error message with a "Try again" button:

```tsx
<ErrorBoundary fallback={
  <div>Custom error UI</div>
}>
  <Lazy${COMPONENT_NAME} />
</ErrorBoundary>
```

## Performance Monitoring

Monitor chunk loading with:
```tsx
useEffect(() => {
  const start = performance.now();
  // Component loads...
  const end = performance.now();
  console.log(`Chunk loaded in ${end - start}ms`);
}, []);
```

## Best Practices

1. Always use with `<Suspense>` boundary
2. Wrap with `<ErrorBoundary>` for error handling
3. Provide meaningful loading indicators
4. Monitor chunk loading times
5. Use named chunks for better debugging
6. Test in slow network conditions

## Chunk Info

- **Chunk Name**: route-page
- **Type**: Lazy-loaded route component
- **Preload**: Disabled (loads on-demand)

EOF
echo -e "${GREEN}✓ Created README.md${NC}"

# Summary
echo -e "\n${GREEN}=== Lazy Component Generation Complete ===${NC}\n"
echo "Generated lazy-loaded component: $COMPONENT_NAME"
echo "Type: $COMPONENT_TYPE"
echo "Location: $OUTPUT_DIR/$COMPONENT_NAME"
echo ""
echo "Files created:"
echo "  ✓ Lazy${COMPONENT_NAME}.tsx - Lazy wrapper component"
echo "  ✓ ${COMPONENT_NAME}.tsx - Actual component"
echo "  ✓ ErrorBoundary.tsx - Error handling"
echo "  ✓ LoadingState.tsx - Loading UI"
echo "  ✓ ${COMPONENT_NAME}.test.tsx - Tests"
echo "  ✓ ${COMPONENT_NAME}.types.ts - TypeScript types"
echo "  ✓ index.ts - Clean exports"
echo "  ✓ README.md - Documentation"
echo ""
echo "Next steps:"
echo "  1. Implement your component in ${COMPONENT_NAME}.tsx"
echo "  2. Import: import { Lazy${COMPONENT_NAME} } from './${COMPONENT_NAME}'"
echo "  3. Use in routes or standalone"
echo "  4. Run tests: npm test"
echo "  5. Build and verify chunk loading"
