---
name: code-splitting-optimization
description: Advanced code splitting optimization strategies for maximum performance in large-scale frontend applications.
sasmp_version: "1.3.0"
bonded_agent: performance
bond_type: SECONDARY_BOND

# Production Configuration
validation:
  input_schema: true
  output_schema: true

retry_logic:
  max_attempts: 3
  backoff: exponential
  initial_delay_ms: 1000

logging:
  level: INFO
  observability: true
---

# Code Splitting Optimization

> **Purpose:** Advanced optimization techniques for production applications to achieve maximum performance through strategic code splitting.

## Input/Output Schema

```typescript
interface OptimizationInput {
  projectPath: string;
  bundler: 'webpack' | 'rollup' | 'vite' | 'esbuild';
  targetSize: number; // KB
  analysisEnabled: boolean;
  optimizationLevel: 'basic' | 'advanced' | 'aggressive';
  cacheStrategy: 'contenthash' | 'chunkhash' | 'hash';
}

interface OptimizationOutput {
  originalSize: number;
  optimizedSize: number;
  compressionRatio: number;
  chunkDistribution: Array<{
    name: string;
    size: number;
    modules: number;
    cacheable: boolean;
  }>;
  recommendations: string[];
  performanceScore: number;
  criticalPathSize: number;
  warnings: string[];
}

interface BundleAnalysis {
  totalSize: number;
  gzippedSize: number;
  chunks: ChunkInfo[];
  duplicateModules: string[];
  unusedExports: string[];
  largestModules: Array<{
    path: string;
    size: number;
  }>;
}

interface ChunkInfo {
  id: string;
  name: string;
  size: number;
  modules: string[];
  parents: string[];
  children: string[];
  rendered: boolean;
}
```

## MANDATORY
- Bundle analysis and visualization (webpack-bundle-analyzer, rollup-plugin-visualizer)
- Chunk optimization strategies (splitChunks configuration)
- Shared dependencies management
- Runtime chunk configuration
- Cache optimization with hashing (contenthash)
- Production build optimization

## OPTIONAL
- Custom webpack plugins for optimization
- Rollup code splitting configuration
- Vite chunk strategies (manualChunks)
- esbuild optimization options
- SWC integration for faster builds
- Terser configuration for minification

## ADVANCED
- Multi-entry point optimization
- Dynamic chunk loading strategies
- A/B testing with chunks
- Canary deployments with versioned chunks
- Performance regression testing
- CDN optimization and preloading

## Error Handling

| Error | Root Cause | Solution |
|-------|-----------|----------|
| `Chunk size exceeds limit` | Bundle too large | Implement more granular splitting, lazy load modules |
| `Circular dependency in chunks` | Improper chunk configuration | Review splitChunks cacheGroups, avoid circular imports |
| `Hash mismatch on deploy` | Cache invalidation issue | Use contenthash, ensure deterministic builds |
| `Module not found in chunk` | Incorrect chunk splitting | Check manualChunks configuration, verify dependencies |
| `Performance budget exceeded` | Bundle exceeds target size | Analyze with bundle analyzer, remove unused code |
| `Duplicate modules across chunks` | Suboptimal chunk strategy | Configure shared chunks, use optimization.runtimeChunk |
| `Initial load too slow` | Critical path not optimized | Implement route-based splitting, preload critical chunks |
| `Cache invalidation too frequent` | Poor hashing strategy | Use contenthash for long-term caching |

## Test Template

```javascript
// webpack.optimization.config.js
const { BundleAnalyzerPlugin } = require('webpack-bundle-analyzer');
const TerserPlugin = require('terser-webpack-plugin');
const CompressionPlugin = require('compression-webpack-plugin');

module.exports = {
  mode: 'production',
  optimization: {
    minimize: true,
    minimizer: [
      new TerserPlugin({
        terserOptions: {
          compress: {
            drop_console: true,
            drop_debugger: true,
            pure_funcs: ['console.log'],
          },
          format: {
            comments: false,
          },
        },
        extractComments: false,
      }),
    ],
    splitChunks: {
      chunks: 'all',
      maxInitialRequests: 25,
      minSize: 20000,
      cacheGroups: {
        // Vendor chunks
        defaultVendors: {
          test: /[\\/]node_modules[\\/]/,
          priority: -10,
          reuseExistingChunk: true,
          name(module) {
            const packageName = module.context.match(
              /[\\/]node_modules[\\/](.*?)([\\/]|$)/
            )?.[1];
            return `vendor.${packageName.replace('@', '')}`;
          },
        },
        // React vendor
        react: {
          test: /[\\/]node_modules[\\/](react|react-dom)[\\/]/,
          name: 'vendor.react',
          priority: 20,
        },
        // Common chunks
        common: {
          minChunks: 2,
          priority: -20,
          reuseExistingChunk: true,
          name: 'common',
        },
      },
    },
    runtimeChunk: {
      name: 'runtime',
    },
    moduleIds: 'deterministic',
  },
  plugins: [
    new BundleAnalyzerPlugin({
      analyzerMode: 'static',
      reportFilename: 'bundle-report.html',
      openAnalyzer: false,
    }),
    new CompressionPlugin({
      algorithm: 'gzip',
      test: /\.(js|css|html|svg)$/,
      threshold: 8192,
      minRatio: 0.8,
    }),
  ],
  performance: {
    hints: 'warning',
    maxEntrypointSize: 244000,
    maxAssetSize: 244000,
  },
};
```

```typescript
// vite.optimization.config.ts
import { defineConfig } from 'vite';
import { visualizer } from 'rollup-plugin-visualizer';

export default defineConfig({
  build: {
    rollupOptions: {
      output: {
        manualChunks: (id) => {
          // React vendor chunk
          if (id.includes('node_modules/react') ||
              id.includes('node_modules/react-dom')) {
            return 'vendor-react';
          }
          // UI library chunk
          if (id.includes('node_modules/@mui') ||
              id.includes('node_modules/antd')) {
            return 'vendor-ui';
          }
          // Utilities chunk
          if (id.includes('node_modules/lodash') ||
              id.includes('node_modules/date-fns')) {
            return 'vendor-utils';
          }
          // Other vendors
          if (id.includes('node_modules')) {
            return 'vendor-misc';
          }
        },
        chunkFileNames: 'assets/[name].[hash].js',
        assetFileNames: 'assets/[name].[hash].[ext]',
      },
    },
    chunkSizeWarningLimit: 500,
    minify: 'terser',
    terserOptions: {
      compress: {
        drop_console: true,
        drop_debugger: true,
      },
    },
  },
  plugins: [
    visualizer({
      filename: 'dist/stats.html',
      open: false,
      gzipSize: true,
      brotliSize: true,
    }),
  ],
});
```

```javascript
// Performance budget test
const fs = require('fs');
const path = require('path');

const BUDGETS = {
  initialBundle: 200 * 1024, // 200KB
  vendor: 150 * 1024,        // 150KB
  total: 500 * 1024,         // 500KB
};

function checkBudgets(distPath) {
  const files = fs.readdirSync(distPath);
  const stats = {};
  let totalSize = 0;

  files.forEach(file => {
    if (file.endsWith('.js')) {
      const filePath = path.join(distPath, file);
      const size = fs.statSync(filePath).size;
      stats[file] = size;
      totalSize += size;
    }
  });

  console.log('Bundle sizes:', stats);
  console.log('Total size:', totalSize);

  if (totalSize > BUDGETS.total) {
    console.error(`❌ Total bundle size (${totalSize}) exceeds budget (${BUDGETS.total})`);
    process.exit(1);
  }

  console.log('✅ All budgets passed!');
}

checkBudgets('./dist');
```

## Best Practices

1. **Performance Budgets**: Set and enforce strict size limits for bundles
2. **Bundle Analysis**: Regularly analyze bundles to identify optimization opportunities
3. **Vendor Splitting**: Separate vendor code for better caching
4. **Content Hashing**: Use contenthash for long-term caching strategies
5. **Tree Shaking**: Enable and verify tree shaking is working effectively
6. **Compression**: Enable gzip/brotli compression for production assets
7. **Lazy Loading**: Load non-critical code only when needed
8. **Preloading**: Use `<link rel="preload">` for critical chunks
9. **Monitoring**: Track bundle sizes in CI/CD pipeline
10. **CDN Optimization**: Serve chunks from CDN with proper cache headers

## Security
- Source map security (avoid exposing source maps in production)
- Dependency auditing (npm audit, yarn audit)
- Supply chain security (verify package integrity)

## Resources
- [Webpack Optimization Guide](https://webpack.js.org/guides/build-performance/)
- [Webpack Bundle Analyzer](https://github.com/webpack-contrib/webpack-bundle-analyzer)
- [Vite Build Optimizations](https://vitejs.dev/guide/build.html)
- [Web.dev Code Splitting](https://web.dev/reduce-javascript-payloads-with-code-splitting/)
- [Chrome DevTools Performance](https://developer.chrome.com/docs/devtools/performance/)

---
**Status:** Active | **Version:** 2.0.0
