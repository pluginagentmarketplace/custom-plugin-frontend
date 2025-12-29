# code-splitting-optimization References

Comprehensive guides and design patterns for bundle optimization and code-splitting strategies.

## Available References

### GUIDE.md - Complete Technical Guide
600+ lines covering:
- Dynamic imports and chunking basics
- Webpack bundle structure and optimization
- Vite bundle configuration
- Tree-shaking and minification strategies
- Source maps for development and production
- Lazy loading patterns with React
- Route-based code-splitting
- Chunk prefetching and preloading
- Asset optimization (images, CSS)
- Bundle analysis tools (webpack-bundle-analyzer, Vite visualizer)
- Performance metrics and monitoring
- Performance budgets and limits

All with real, production-ready code examples.

### PATTERNS.md - 15 Production Design Patterns
Proven patterns including:

1. **Vendor Chunk Separation** - Isolate node_modules for better caching
2. **React/Framework-Specific Chunk** - Separate React and related packages
3. **UI Framework Separation** - Extract Material-UI, Ant Design separately
4. **Common Code Extraction** - Share code across multiple chunks
5. **Route-Based Code-Splitting** - Lazy load routes with error handling
6. **Modal and Feature-Based Chunking** - Load heavy modals on-demand
7. **Prefetch Non-Critical Chunks** - Prefetch during idle time
8. **Async Components with Loading States** - Wrap with proper error boundaries
9. **Tree-Shaking with Side Effects** - Configure proper module cleanup
10. **Deterministic Chunk IDs** - Stable hashes for long-term caching
11. **Dynamic Component Loading** - Conditional feature-based loading
12. **Critical vs Non-Critical Chunks** - Preload vs prefetch strategies
13. **Bundle Size Monitoring** - Track and alert on size increases
14. **Chunk Dependencies Analysis** - Visualize and optimize relationships
15. **Progressive Enhancement** - Vite's automatic code-splitting

Each pattern includes:
- Real code examples
- Use case scenarios
- Benefits and trade-offs
- Best practices

## Quick Navigation

### By Bundler

**Webpack:**
- GUIDE.md - Webpack Bundle Structure section
- GUIDE.md - Split Chunks Configuration
- PATTERNS.md - Patterns 1-10 (webpack focus)

**Vite:**
- GUIDE.md - Vite Bundle Configuration
- GUIDE.md - Asset Optimization
- PATTERNS.md - Pattern 15 (Vite progressive enhancement)

**Both:**
- GUIDE.md - Dynamic Imports
- GUIDE.md - Lazy Loading Patterns
- GUIDE.md - Performance Metrics

### By Task

**Reduce initial bundle size:**
- GUIDE.md - Dynamic Imports & Chunking
- GUIDE.md - Tree-Shaking & Minification
- PATTERNS.md - Patterns 1-4 (chunk separation)

**Improve performance:**
- GUIDE.md - Route-Based Code-Splitting
- GUIDE.md - Chunk Prefetching
- PATTERNS.md - Patterns 5-7 (lazy loading strategies)

**Debug production issues:**
- GUIDE.md - Source Maps Configuration
- GUIDE.md - Error Boundaries for Lazy Components
- PATTERNS.md - Pattern 8 (async error handling)

**Monitor and maintain:**
- GUIDE.md - Bundle Analysis Tools
- GUIDE.md - Performance Metrics
- PATTERNS.md - Patterns 13-14 (monitoring)

**Setup and configuration:**
- Scripts/generate-split-config.sh - Auto-generate config
- GUIDE.md - Webpack Configuration Examples
- GUIDE.md - Vite Configuration Examples

## Key Concepts Explained

### Code-Splitting
Dividing your application bundle into smaller chunks that are loaded on-demand rather than all upfront.

**Benefits:**
- Smaller initial bundle size
- Faster Time to Interactive (TTI)
- Parallel chunk loading
- Better browser caching

### Dynamic Imports
Using `import()` instead of static imports to create separate chunks:

```javascript
// Static import (included in main bundle)
import Button from './Button';

// Dynamic import (separate chunk)
const Button = () => import('./Button');
```

### Tree-Shaking
Removing unused code from bundles during minification.

**Requirements:**
- ES6 module syntax (not CommonJS)
- Configured as side-effect free
- Terser or similar minifier

### Lazy Loading
Loading components/routes only when needed.

```jsx
const Dashboard = lazy(() => import('./Dashboard'));

<Suspense fallback={<Loading />}>
  <Dashboard />
</Suspense>
```

### Cache Busting
Using content hashes in filenames to invalidate old caches:

```
main.a1b2c3d4.js (hash changes when content changes)
```

## Tools Used

### Generation Tools
- `scripts/generate-split-config.sh` - Auto-generate webpack/Vite config

### Validation Tools
- `scripts/validate-splitting.sh` - Analyze existing setup

### Bundle Analysis
- webpack-bundle-analyzer - Visualize webpack bundles
- rollup-plugin-visualizer - Visualize Vite bundles
- source-map-explorer - Analyze source maps

### Performance Monitoring
- web-vitals - Core Web Vitals
- Lighthouse - Performance auditing
- DevTools Network tab - Chunk loading analysis

## Learning Path

### Beginner
1. GUIDE.md - Dynamic Imports section
2. GUIDE.md - Lazy Loading Patterns (React.lazy & Suspense)
3. PATTERNS.md - Pattern 5 (Route-based splitting)
4. Try: generate-split-config.sh for initial setup

### Intermediate
1. GUIDE.md - Bundle Analysis section
2. PATTERNS.md - Patterns 1-4 (chunk optimization)
3. GUIDE.md - Tree-Shaking & Minification
4. Analyze your bundle with webpack-bundle-analyzer

### Advanced
1. GUIDE.md - All sections for deep understanding
2. PATTERNS.md - All 15 patterns for production optimization
3. PATTERNS.md - Pattern 13-14 for monitoring
4. Implement performance budgets and tracking

## Common Scenarios

### New Webpack Project
1. Use `generate-split-config.sh webpack`
2. Read GUIDE.md - Webpack Bundle Structure
3. Implement PATTERNS.md - Pattern 1-5
4. Run `validate-splitting.sh` to verify

### Convert to Code-Splitting
1. Run `validate-splitting.sh` on existing project
2. Read GUIDE.md - Route-Based Code-Splitting
3. Apply PATTERNS.md - Pattern 5 to routes
4. Monitor with GUIDE.md - Bundle Analysis Tools

### Optimize Large Bundle
1. Analyze with webpack-bundle-analyzer
2. Read GUIDE.md - Bundle Analysis section
3. Implement PATTERNS.md - Pattern 1-4 (separation)
4. Monitor chunk sizes with PATTERNS.md - Pattern 13

### Production Optimization
1. Implement GUIDE.md - Source Maps
2. Configure PATTERNS.md - Pattern 10 (deterministic IDs)
3. Monitor with PATTERNS.md - Pattern 13 (size budgets)
4. Set up performance tracking - GUIDE.md - Performance Metrics

## Configuration Examples

All examples in this guide are production-ready and tested with:
- webpack 5.x
- Vite 4.x - 5.x
- React 18.x
- Node.js 18+

## File Structure

```
code-splitting-optimization/
├── scripts/
│   ├── README.md                    # Script documentation
│   ├── validate-splitting.sh        # Validation script
│   └── generate-split-config.sh     # Configuration generator
└── references/
    ├── README.md                    # This file
    ├── GUIDE.md                     # Technical guide (600+ lines)
    └── PATTERNS.md                  # 15 design patterns
```

## Performance Goals

After implementing code-splitting:
- Initial bundle: < 100KB
- Largest chunk: < 500KB
- Time to Interactive: < 3s on 4G
- Chunks load in parallel
- Cache efficiency: 80%+

## Further Reading

- webpack Code Splitting: https://webpack.js.org/guides/code-splitting/
- Vite Pre-Bundling: https://vitejs.dev/guide/dep-pre-bundling.html
- React.lazy: https://react.dev/reference/react/lazy
- Web Vitals: https://web.dev/vitals/
- Bundle Analyzer: https://github.com/webpack-contrib/webpack-bundle-analyzer

## Quick Reference

**Dynamic import:**
```javascript
const Component = () => import('./Component');
```

**React lazy:**
```jsx
const Component = lazy(() => import('./Component'));
```

**Named chunk:**
```javascript
import(/* webpackChunkName: "name" */ './file')
```

**Prefetch:**
```javascript
import(/* webpackPrefetch: true */ './file')
```

**Webpack split:**
```javascript
cacheGroups: {
  vendor: { test: /node_modules/, name: 'vendors' }
}
```

**Vite manual chunks:**
```typescript
manualChunks: { react: ['react', 'react-dom'] }
```
