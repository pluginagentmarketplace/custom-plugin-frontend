# code-splitting-lazy-loading References

Comprehensive guides and design patterns for React.lazy() and Suspense-based lazy loading.

## Available References

### GUIDE.md - Complete Technical Guide
600+ lines covering:
- React.lazy() syntax and semantics
- Suspense component and fallback prop
- Error boundaries for lazy components
- Route-based lazy loading patterns
- Component-level lazy loading
- Modal and conditional lazy loading
- Prefetching and preloading strategies
- Loading state implementation
- Error handling and retry logic
- Timeout handling for stuck states
- TypeScript lazy loading
- Performance monitoring and metrics
- Best practices and common mistakes

With comprehensive, production-ready code examples.

### PATTERNS.md - 15 Production Design Patterns
Proven patterns including:

1. **Route-Based Code-Splitting** - Lazy load entire routes
2. **Suspense + Error Boundary** - Safe lazy component setup
3. **Progressive Enhancement** - Load critical vs optional features
4. **Modal/Dialog Lazy Loading** - Load heavy modals on-demand
5. **Conditional Component Loading** - Feature flags and conditions
6. **Nested Suspense Boundaries** - Granular loading control
7. **Prefetch on User Interaction** - Load on hover or focus
8. **Tab-Based Lazy Loading** - Lazy load tab content
9. **Custom Error Boundary with Retry** - Error handling with retry
10. **Timeout Protection** - Handle stuck loading states
11. **Performance Monitoring** - Track chunk loading times
12. **Progressive Image Loading** - Lazy load galleries
13. **SSR-Safe Lazy Components** - Handle server-side rendering
14. **Dynamic Plugin Loading** - Plugin system patterns
15. **Form Wizard with Lazy Steps** - Lazy load form steps

Each pattern with complete code and use cases.

## Quick Navigation

### By Task

**Lazy load entire pages:**
- GUIDE.md - Route-Based Lazy Loading
- PATTERNS.md - Pattern 1 (Route-based splitting)
- Scripts/validate-lazy.sh - Route validation

**Load components on-demand:**
- GUIDE.md - Component-Level Lazy Loading
- PATTERNS.md - Patterns 4-5, 8 (modals, tabs, conditionals)
- Scripts/generate-lazy-component.sh - Component generation

**Handle errors gracefully:**
- GUIDE.md - Error Boundaries for Lazy Components
- GUIDE.md - Timeout Handling
- PATTERNS.md - Patterns 9-10 (error handling)

**Improve performance:**
- GUIDE.md - Prefetching and Preloading
- PATTERNS.md - Pattern 7 (prefetch on interaction)
- GUIDE.md - Performance Monitoring

**Implement advanced patterns:**
- PATTERNS.md - All 15 patterns for reference
- GUIDE.md - TypeScript section for type safety
- PATTERNS.md - Patterns 13-15 (advanced)

### By Use Case

**Multi-page application:**
- GUIDE.md - Route-Based Lazy Loading
- PATTERNS.md - Pattern 1 (routes)
- PATTERNS.md - Pattern 15 (form wizard)

**Complex dashboard:**
- GUIDE.md - Component-Level Lazy Loading
- PATTERNS.md - Patterns 6 (nested boundaries), 8 (tabs)
- PATTERNS.md - Pattern 11 (performance monitoring)

**Modal-heavy application:**
- GUIDE.md - Lazy Loading Modals section
- PATTERNS.md - Pattern 4 (modals)
- GUIDE.md - Error Boundaries section

**Admin panel with feature flags:**
- PATTERNS.md - Pattern 5 (conditional loading)
- GUIDE.md - Error Handling section
- PATTERNS.md - Pattern 14 (plugins)

## Key Concepts

### React.lazy()
Splits code into chunks and loads them on-demand:
```jsx
const Component = lazy(() => import('./Component'));
```

### Suspense
Shows loading UI while chunk loads:
```jsx
<Suspense fallback={<Loading />}>
  <LazyComponent />
</Suspense>
```

### Error Boundary
Catches and handles loading errors:
```jsx
<ErrorBoundary>
  <Suspense fallback={<Loading />}>
    <LazyComponent />
  </Suspense>
</ErrorBoundary>
```

### Prefetch
Load chunk when browser is idle:
```jsx
import(/* webpackPrefetch: true */ './Component')
```

### Preload
Load chunk immediately in parallel:
```jsx
import(/* webpackPreload: true */ './Component')
```

## Tools and Scripts

### Validation
- `scripts/validate-lazy.sh` - Check lazy implementation
  - React.lazy() usage
  - Suspense boundaries
  - Error boundary coverage
  - Dynamic imports

### Generation
- `scripts/generate-lazy-component.sh` - Generate lazy components
  - Route-level lazy components
  - Modal wrappers
  - Feature modules
  - Tab content components

## Learning Path

### Beginner
1. GUIDE.md - React.lazy() Syntax section
2. GUIDE.md - Suspense Component Basics
3. GUIDE.md - Error Boundaries section
4. PATTERNS.md - Pattern 2 (Suspense + Error Boundary)

### Intermediate
1. GUIDE.md - Route-Based Lazy Loading
2. PATTERNS.md - Patterns 1, 4, 5 (routes, modals, conditional)
3. GUIDE.md - Loading States section
4. Run generate-lazy-component.sh to create components

### Advanced
1. GUIDE.md - All sections for deep understanding
2. PATTERNS.md - All 15 patterns
3. GUIDE.md - TypeScript Lazy Loading
4. GUIDE.md - Performance Monitoring section
5. Implement custom patterns for your use cases

## Common Implementation Patterns

### Route Lazy Loading (Most Common)
```jsx
const Page = lazy(() => import('./pages/Page'));

<Routes>
  <Route path="/page" element={<Page />} />
</Routes>
```

### Component Lazy Loading (Within Pages)
```jsx
const Chart = lazy(() => import('./Chart'));

<Suspense fallback={<ChartLoader />}>
  <Chart />
</Suspense>
```

### Modal Lazy Loading (On Demand)
```jsx
const Modal = lazy(() => import('./Modal'));

{isOpen && (
  <Suspense fallback={null}>
    <Modal />
  </Suspense>
)}
```

### Error Safe Lazy Loading (Production Ready)
```jsx
<ErrorBoundary>
  <Suspense fallback={<Loading />}>
    <LazyComponent />
  </Suspense>
</ErrorBoundary>
```

## Performance Goals

After implementing lazy loading:
- Initial bundle: < 50KB
- Route chunk: < 200KB
- Modal chunk: < 100KB
- Time to Interactive: < 2s
- Parallel chunk loading: 3-5 chunks simultaneously

## Troubleshooting

**Component doesn't load:**
- Ensure lazy() at module level
- Verify Suspense boundary
- Check browser console for errors

**Error boundary not catching errors:**
- Ensure proper getDerivedStateFromError
- Verify componentDidCatch is implemented
- Check error handler logic

**Chunks not loading:**
- Verify webpack/Vite config
- Check network tab for 404s
- Validate chunk names with magic comments

**Performance issues:**
- Monitor chunk sizes
- Check for duplicate chunks
- Implement prefetch strategically
- Avoid excessive nesting

## File Structure

```
code-splitting-lazy-loading/
├── scripts/
│   ├── README.md                    # Script documentation
│   ├── validate-lazy.sh             # Validation script
│   └── generate-lazy-component.sh   # Component generator
└── references/
    ├── README.md                    # This file
    ├── GUIDE.md                     # Technical guide (600+ lines)
    └── PATTERNS.md                  # 15 design patterns
```

## Real-World Example: E-Commerce Site

```jsx
import { lazy, Suspense } from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';

// Lazy load pages
const HomePage = lazy(() => import('./pages/Home'));
const ProductList = lazy(() => import('./pages/ProductList'));
const ProductDetail = lazy(() => import('./pages/ProductDetail'));
const Checkout = lazy(() => import('./pages/Checkout'));
const Admin = lazy(() => import('./pages/Admin'));

function App() {
  return (
    <BrowserRouter>
      <Suspense fallback={<PageLoader />}>
        <Routes>
          <Route path="/" element={<HomePage />} />
          <Route path="/products" element={<ProductList />} />
          <Route path="/products/:id" element={<ProductDetail />} />
          <Route path="/checkout" element={<Checkout />} />
          <Route path="/admin/*" element={<Admin />} />
        </Routes>
      </Suspense>
    </BrowserRouter>
  );
}

export default App;
```

## Best Practices Summary

1. Always wrap lazy components in Suspense
2. Use error boundaries for error handling
3. Provide meaningful loading UI
4. Name chunks with webpackChunkName
5. Test in slow network conditions
6. Monitor chunk loading performance
7. Use prefetch for non-critical chunks
8. Implement proper error recovery
9. Don't lazy load synchronously
10. Document lazy loading behavior

## Further Learning

- React Docs: https://react.dev/reference/react/lazy
- React.lazy Blog: https://react.dev/blog
- Code-Splitting Guide: https://webpack.js.org/guides/code-splitting/
- Suspense Guide: https://react.dev/reference/react/Suspense
- Web Vitals: https://web.dev/vitals/

## Quick Start

1. Generate component: `./scripts/generate-lazy-component.sh ./src HomePage route`
2. Import: `import { LazyHomePage } from './HomePage'`
3. Use in route: `<Route path="/" element={<LazyHomePage />} />`
4. Validate: `./scripts/validate-lazy.sh`
5. Test and monitor performance
