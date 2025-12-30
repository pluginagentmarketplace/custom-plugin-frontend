---
name: bundle-analysis-splitting
description: Analyze and optimize bundle sizes through code splitting, lazy loading, and dependency management.
version: "2.0.0"
sasmp_version: "1.3.0"
bonded_agent: 02-build-tools-agent
bond_type: SECONDARY_BOND
status: production
category: build-optimization
tags:
  - bundle-analysis
  - code-splitting
  - webpack
  - lazy-loading
  - tree-shaking
complexity: advanced
estimated_time: 50-70min
prerequisites:
  - Understanding of module bundlers
  - Knowledge of JavaScript modules
  - Familiarity with build tools
related_skills:
  - core-web-vitals
  - image-optimization
  - asset-optimization
production_config:
  bundle_analysis: true
  size_budgets:
    main_bundle: 250000        # 250KB gzipped
    vendor_bundle: 200000      # 200KB gzipped
    chunk_size: 50000          # 50KB gzipped
  compression: gzip
  source_maps: hidden
---

# Bundle Analysis & Splitting

Optimize bundle sizes for faster loading through analysis and code splitting.

## Input Schema

```yaml
context:
  project_path: string          # Root project directory
  bundler: string               # webpack, vite, rollup, parcel, esbuild
  framework: string             # react, vue, angular, svelte
  build_environment: string     # development, production

config:
  analysis:
    generate_stats: boolean     # Generate bundle stats JSON
    visualize: boolean          # Create visualization
    compare_baseline: boolean   # Compare against baseline
    report_format: string       # treemap, sunburst, json

  splitting:
    strategy: string            # route, vendor, dynamic, hybrid
    chunk_size_limit: number    # Max chunk size in bytes
    min_chunk_size: number      # Min chunk size to create
    max_parallel_requests: number

  optimization:
    tree_shaking: boolean
    minification: boolean
    compression: string         # gzip, brotli, both
    source_maps: string         # inline, separate, hidden

  budgets:
    main_bundle: number         # Bytes (gzipped)
    vendor_bundle: number
    chunk_size: number
    total_size: number

options:
  analyze_dependencies: boolean
  detect_duplicates: boolean
  suggest_lazy_loading: boolean
  generate_report: boolean
```

## Output Schema

```yaml
analysis_results:
  bundle_stats:
    total_size: number
    gzipped_size: number
    brotli_size: number
    chunk_count: number
    asset_count: number

  chunks:
    - name: string
      size: number
      gzipped: number
      modules: array
      imports: array
      imported_by: array

  modules:
    - name: string
      size: number
      chunks: array
      reasons: array            # Why module was included

  dependencies:
    - name: string
      version: string
      size: number
      tree_shakeable: boolean
      duplicates: number

  top_contributors:
    by_size:
      - module: string
        size: number
        percentage: number
    by_count:
      - dependency: string
        count: number
        instances: array

  optimization_opportunities:
    - type: string              # duplicate, unused, large
      severity: string          # critical, high, medium, low
      description: string
      potential_savings: number
      recommendation: string

  code_splitting:
    current_strategy: string
    suggested_splits: array
    estimated_improvement: object

  budget_status:
    - bundle: string
      current: number
      budget: number
      status: string            # passed, warning, failed
      overage: number

report:
  summary: string
  critical_issues: array
  warnings: array
  recommendations: array
  visualization_path: string
```

## Error Handling

| Error Code | Description | Cause | Resolution |
|------------|-------------|-------|------------|
| BA-001 | Bundle stats generation failed | Webpack stats plugin error | Verify webpack config and plugin installation |
| BA-002 | Bundle size exceeds budget | Bundle larger than defined budget | Review and optimize bundle contents |
| BA-003 | Duplicate dependencies detected | Multiple versions of same package | Use dependency resolution or dedupe tool |
| BA-004 | Tree shaking not working | Code not tree-shakeable or misconfigured | Check module format and sideEffects config |
| BA-005 | Code splitting failed | Invalid dynamic import or config | Verify dynamic import syntax and bundler config |
| BA-006 | Circular dependency detected | Modules importing each other | Refactor to break circular dependencies |
| BA-007 | Large vendor chunk | Too many dependencies in vendor bundle | Split vendor chunk or lazy load dependencies |
| BA-008 | Compression failed | Compression plugin error | Check compression settings and plugin config |
| BA-009 | Source map error | Unable to generate source maps | Verify source map configuration |
| BA-010 | Analysis timeout | Bundle too large to analyze | Increase timeout or analyze smaller chunks |

## MANDATORY

### Bundle Analyzer Tools Usage
- **Webpack Bundle Analyzer**: Visualize bundle contents
  ```javascript
  // webpack.config.js
  const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin;

  module.exports = {
    plugins: [
      new BundleAnalyzerPlugin({
        analyzerMode: 'static',
        openAnalyzer: false,
        reportFilename: 'bundle-report.html'
      })
    ]
  };
  ```

- **Vite Bundle Visualizer**:
  ```javascript
  // vite.config.js
  import { visualizer } from 'rollup-plugin-visualizer';

  export default {
    plugins: [
      visualizer({
        filename: './dist/stats.html',
        open: true,
        gzipSize: true,
        brotliSize: true
      })
    ]
  };
  ```

### Identifying Large Dependencies
- **Analysis techniques**:
  ```bash
  # Generate webpack stats
  webpack --profile --json > stats.json

  # Analyze with webpack-bundle-analyzer
  npx webpack-bundle-analyzer stats.json

  # Check package sizes before installing
  npx bundle-phobia <package-name>

  # Analyze actual bundle
  npx source-map-explorer dist/main.*.js
  ```

- **Finding alternatives**:
  - Use bundlephobia.com
  - Check package size on npm
  - Consider lighter alternatives
  - Use tree-shakeable versions

### Tree Shaking Verification
- **Ensuring tree shaking works**:
  ```javascript
  // package.json - Mark pure modules
  {
    "sideEffects": false,
    // Or specify files with side effects
    "sideEffects": ["*.css", "*.scss"]
  }

  // Import only what you need
  import { debounce } from 'lodash-es'; // Good (ES modules)
  import debounce from 'lodash/debounce'; // Better
  import _ from 'lodash'; // Bad (imports everything)
  ```

- **Verifying in build output**:
  ```bash
  # Check if unused exports are removed
  webpack --mode production --stats-modules

  # Use terser to see what's being removed
  npx terser input.js --compress --mangle
  ```

### Gzip and Brotli Sizes
- **Compression comparison**:
  ```javascript
  // webpack.config.js
  const CompressionPlugin = require('compression-webpack-plugin');

  module.exports = {
    plugins: [
      // Gzip compression
      new CompressionPlugin({
        filename: '[path][base].gz',
        algorithm: 'gzip',
        test: /\.(js|css|html|svg)$/,
        threshold: 8192,
        minRatio: 0.8
      }),
      // Brotli compression
      new CompressionPlugin({
        filename: '[path][base].br',
        algorithm: 'brotliCompress',
        test: /\.(js|css|html|svg)$/,
        threshold: 8192,
        minRatio: 0.8
      })
    ]
  };
  ```

### Entry Point Analysis
- **Analyzing entry points**:
  ```javascript
  // webpack.config.js
  module.exports = {
    entry: {
      main: './src/index.js',
      vendor: ['react', 'react-dom'],
      admin: './src/admin.js'
    },
    optimization: {
      splitChunks: {
        chunks: 'all',
        cacheGroups: {
          vendor: {
            test: /[\\/]node_modules[\\/]/,
            name: 'vendor',
            priority: 10
          },
          common: {
            minChunks: 2,
            priority: 5,
            reuseExistingChunk: true
          }
        }
      }
    }
  };
  ```

### Chunk Composition Review
- **Understanding chunk contents**:
  ```javascript
  // Check what's in each chunk
  // webpack.config.js
  module.exports = {
    optimization: {
      splitChunks: {
        chunks: 'all',
        minSize: 20000,
        maxSize: 244000,
        cacheGroups: {
          defaultVendors: {
            test: /[\\/]node_modules[\\/]/,
            priority: -10,
            reuseExistingChunk: true
          },
          default: {
            minChunks: 2,
            priority: -20,
            reuseExistingChunk: true
          }
        }
      }
    }
  };
  ```

## OPTIONAL

### Custom Chunk Strategies
- **Route-based splitting**:
  ```javascript
  // React with React Router
  import { lazy, Suspense } from 'react';

  const Home = lazy(() => import('./routes/Home'));
  const About = lazy(() => import('./routes/About'));
  const Dashboard = lazy(() => import('./routes/Dashboard'));

  function App() {
    return (
      <Suspense fallback={<Loading />}>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/about" element={<About />} />
          <Route path="/dashboard" element={<Dashboard />} />
        </Routes>
      </Suspense>
    );
  }
  ```

- **Component-based splitting**:
  ```javascript
  // Lazy load heavy components
  const HeavyChart = lazy(() => import('./components/HeavyChart'));
  const VideoPlayer = lazy(() => import('./components/VideoPlayer'));

  function Dashboard() {
    const [showChart, setShowChart] = useState(false);

    return (
      <div>
        <button onClick={() => setShowChart(true)}>Show Chart</button>
        {showChart && (
          <Suspense fallback={<ChartSkeleton />}>
            <HeavyChart />
          </Suspense>
        )}
      </div>
    );
  }
  ```

### Dependency Deduplication
- **Finding duplicates**:
  ```bash
  # Using npm-check-updates
  npx npm-check-updates

  # Using yarn why
  yarn why <package-name>

  # Using npm ls
  npm ls <package-name>

  # Using webpack-bundle-analyzer to find duplicate modules
  ```

- **Resolving duplicates**:
  ```javascript
  // webpack.config.js
  module.exports = {
    resolve: {
      alias: {
        'react': path.resolve('./node_modules/react'),
        'react-dom': path.resolve('./node_modules/react-dom')
      }
    }
  };

  // Or in package.json with resolutions (yarn)
  {
    "resolutions": {
      "package-a/**/package-b": "1.0.0"
    }
  }
  ```

### Side Effects Configuration
- **Marking side effects**:
  ```json
  // package.json
  {
    "name": "my-library",
    "sideEffects": false  // No side effects, safe to tree shake

    // Or specify files with side effects
    "sideEffects": [
      "*.css",
      "*.scss",
      "./src/polyfills.js"
    ]
  }
  ```

### Import Cost Extensions
- **VS Code Import Cost**: Shows bundle size inline
  ```json
  // .vscode/settings.json
  {
    "importCost.bundleSizeDecoration": "both",
    "importCost.showCalculatingDecoration": true,
    "importCost.debug": false
  }
  ```

### CI/CD Size Tracking
- **GitHub Actions example**:
  ```yaml
  # .github/workflows/bundle-size.yml
  name: Bundle Size Check

  on: [pull_request]

  jobs:
    size-check:
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v2
        - uses: andresz1/size-limit-action@v1
          with:
            github_token: ${{ secrets.GITHUB_TOKEN }}
            skip_step: install
  ```

### Performance Regression Detection
- **Size limit configuration**:
  ```json
  // .size-limit.json
  [
    {
      "path": "dist/main.*.js",
      "limit": "250 KB",
      "gzip": true
    },
    {
      "path": "dist/vendor.*.js",
      "limit": "200 KB",
      "gzip": true
    },
    {
      "path": "dist/**/*.js",
      "limit": "500 KB",
      "gzip": true
    }
  ]
  ```

## ADVANCED

### Source Map Exploration
- **Analyzing with source-map-explorer**:
  ```bash
  # Install
  npm install -g source-map-explorer

  # Analyze
  source-map-explorer dist/main.*.js

  # Compare bundles
  source-map-explorer dist/main.*.js dist/vendor.*.js
  ```

### Custom Analyzer Plugins
- **Custom webpack plugin**:
  ```javascript
  class BundleSizePlugin {
    apply(compiler) {
      compiler.hooks.done.tap('BundleSizePlugin', (stats) => {
        const assets = stats.toJson().assets;

        assets.forEach(asset => {
          const sizeInKb = (asset.size / 1024).toFixed(2);
          console.log(`${asset.name}: ${sizeInKb} KB`);
        });

        // Check budgets
        const mainAsset = assets.find(a => a.name.includes('main'));
        const budget = 250 * 1024; // 250 KB

        if (mainAsset && mainAsset.size > budget) {
          throw new Error(`Bundle size exceeded: ${mainAsset.size} > ${budget}`);
        }
      });
    }
  }

  module.exports = BundleSizePlugin;
  ```

### Automated Budget Enforcement
- **Webpack performance budgets**:
  ```javascript
  // webpack.config.js
  module.exports = {
    performance: {
      maxEntrypointSize: 250000, // 250 KB
      maxAssetSize: 100000,      // 100 KB
      hints: 'error',            // 'warning' or 'error'
      assetFilter: function(assetFilename) {
        return assetFilename.endsWith('.js');
      }
    }
  };
  ```

### Continuous Monitoring
- **Bundlewatch configuration**:
  ```json
  // bundlewatch.config.json
  {
    "files": [
      {
        "path": "dist/main.*.js",
        "maxSize": "250kb",
        "compression": "gzip"
      },
      {
        "path": "dist/vendor.*.js",
        "maxSize": "200kb",
        "compression": "gzip"
      }
    ],
    "ci": {
      "trackBranches": ["main", "develop"]
    }
  }
  ```

### Historical Trend Analysis
- **Tracking over time**:
  ```javascript
  // save-bundle-stats.js
  const fs = require('fs');
  const path = require('path');

  function saveBundleStats(stats) {
    const timestamp = new Date().toISOString();
    const statsDir = path.join(__dirname, 'bundle-stats');

    if (!fs.existsSync(statsDir)) {
      fs.mkdirSync(statsDir, { recursive: true });
    }

    const assets = stats.toJson().assets.map(asset => ({
      name: asset.name,
      size: asset.size,
      timestamp
    }));

    const filename = path.join(statsDir, `${timestamp}.json`);
    fs.writeFileSync(filename, JSON.stringify(assets, null, 2));
  }
  ```

### Micro-optimization Techniques
- **Advanced splitting strategies**:
  ```javascript
  // Magic comments for webpack
  const component = import(
    /* webpackChunkName: "my-chunk" */
    /* webpackMode: "lazy" */
    /* webpackPrefetch: true */
    './MyComponent'
  );

  // Preload for critical chunks
  const critical = import(
    /* webpackChunkName: "critical" */
    /* webpackPreload: true */
    './CriticalComponent'
  );
  ```

## Test Templates

### Bundle Size Tests
```javascript
// bundle-size.test.js
const fs = require('fs');
const path = require('path');
const zlib = require('zlib');

describe('Bundle Size Tests', () => {
  const distPath = path.join(__dirname, '../dist');

  function getGzipSize(filePath) {
    const content = fs.readFileSync(filePath);
    const gzipped = zlib.gzipSync(content);
    return gzipped.length;
  }

  test('main bundle should be under 250KB gzipped', () => {
    const mainBundle = fs.readdirSync(distPath)
      .find(file => file.startsWith('main.') && file.endsWith('.js'));

    const size = getGzipSize(path.join(distPath, mainBundle));
    expect(size).toBeLessThan(250 * 1024);
  });

  test('vendor bundle should be under 200KB gzipped', () => {
    const vendorBundle = fs.readdirSync(distPath)
      .find(file => file.startsWith('vendor.') && file.endsWith('.js'));

    if (vendorBundle) {
      const size = getGzipSize(path.join(distPath, vendorBundle));
      expect(size).toBeLessThan(200 * 1024);
    }
  });

  test('total bundle size should be under 500KB gzipped', () => {
    const jsFiles = fs.readdirSync(distPath)
      .filter(file => file.endsWith('.js'));

    const totalSize = jsFiles.reduce((sum, file) => {
      return sum + getGzipSize(path.join(distPath, file));
    }, 0);

    expect(totalSize).toBeLessThan(500 * 1024);
  });
});
```

### Tree Shaking Tests
```javascript
// tree-shaking.test.js
describe('Tree Shaking', () => {
  test('should not include unused exports', () => {
    const bundle = fs.readFileSync(
      path.join(__dirname, '../dist/main.js'),
      'utf-8'
    );

    // Check that unused function is not in bundle
    expect(bundle).not.toContain('unusedFunction');
    expect(bundle).not.toContain('UnusedComponent');
  });

  test('should tree shake lodash imports', () => {
    const bundle = fs.readFileSync(
      path.join(__dirname, '../dist/main.js'),
      'utf-8'
    );

    // If only using debounce, shouldn't include other lodash functions
    expect(bundle).toContain('debounce');
    expect(bundle).not.toContain('throttle');
    expect(bundle).not.toContain('memoize');
  });
});
```

### Code Splitting Tests
```javascript
// code-splitting.test.js
describe('Code Splitting', () => {
  test('should create separate chunks for routes', () => {
    const distFiles = fs.readdirSync(path.join(__dirname, '../dist'));

    // Verify route chunks exist
    expect(distFiles.some(f => f.includes('home'))).toBe(true);
    expect(distFiles.some(f => f.includes('dashboard'))).toBe(true);
    expect(distFiles.some(f => f.includes('settings'))).toBe(true);
  });

  test('should lazy load heavy components', async () => {
    const { render, waitFor } = require('@testing-library/react');
    const App = require('../src/App').default;

    const { getByText } = render(<App />);

    // Component shouldn't be loaded initially
    expect(document.querySelector('.heavy-chart')).toBeNull();

    // Click to load component
    getByText('Show Chart').click();

    // Wait for lazy loaded component
    await waitFor(() => {
      expect(document.querySelector('.heavy-chart')).toBeTruthy();
    });
  });
});
```

## Best Practices

### 1. Implement Code Splitting

**Route-based splitting:**
```javascript
// App.js
import { lazy, Suspense } from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';

const Home = lazy(() => import('./pages/Home'));
const Dashboard = lazy(() => import('./pages/Dashboard'));
const Profile = lazy(() => import('./pages/Profile'));
const Settings = lazy(() => import('./pages/Settings'));

function App() {
  return (
    <BrowserRouter>
      <Suspense fallback={<PageLoader />}>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/dashboard" element={<Dashboard />} />
          <Route path="/profile" element={<Profile />} />
          <Route path="/settings" element={<Settings />} />
        </Routes>
      </Suspense>
    </BrowserRouter>
  );
}
```

**Component-based splitting:**
```javascript
// Use lazy loading for components that:
// 1. Are large (>20KB)
// 2. Are not immediately visible
// 3. Are conditionally rendered

const MarkdownEditor = lazy(() => import('./MarkdownEditor'));
const VideoPlayer = lazy(() => import('./VideoPlayer'));
const DataGrid = lazy(() => import('./DataGrid'));

function Editor() {
  const [showPreview, setShowPreview] = useState(false);

  return (
    <div>
      <MarkdownEditor />
      {showPreview && (
        <Suspense fallback={<Spinner />}>
          <Preview />
        </Suspense>
      )}
    </div>
  );
}
```

### 2. Optimize Dependencies

**Use tree-shakeable versions:**
```javascript
// Bad: Imports entire library
import _ from 'lodash';
import moment from 'moment';

// Good: Import only what you need
import debounce from 'lodash-es/debounce';
import dayjs from 'dayjs';

// Better: Use native alternatives when possible
const debounce = (fn, ms) => {
  let timer;
  return (...args) => {
    clearTimeout(timer);
    timer = setTimeout(() => fn(...args), ms);
  };
};
```

**Analyze before adding dependencies:**
```bash
# Check bundle size before installing
npx bundle-phobia lodash
npx bundle-phobia moment
npx bundle-phobia date-fns

# Compare alternatives
npx bundle-phobia react-icons
npx bundle-phobia heroicons
```

### 3. Configure Bundle Splitting

**Optimal webpack configuration:**
```javascript
// webpack.config.js
module.exports = {
  optimization: {
    splitChunks: {
      chunks: 'all',
      cacheGroups: {
        // Vendor chunk for stable dependencies
        vendor: {
          test: /[\\/]node_modules[\\/]/,
          name: 'vendor',
          priority: 10,
          reuseExistingChunk: true
        },
        // Common chunk for shared code
        common: {
          minChunks: 2,
          priority: 5,
          reuseExistingChunk: true,
          enforce: true
        },
        // React chunk (frequently updated)
        react: {
          test: /[\\/]node_modules[\\/](react|react-dom|react-router-dom)[\\/]/,
          name: 'react',
          priority: 20
        }
      }
    },
    runtimeChunk: {
      name: 'runtime'
    }
  }
};
```

### 4. Monitor Bundle Size

**Continuous monitoring:**
```json
// package.json
{
  "scripts": {
    "build": "webpack --mode production",
    "analyze": "webpack-bundle-analyzer dist/stats.json",
    "size": "size-limit",
    "size:why": "npm run size -- --why"
  },
  "size-limit": [
    {
      "path": "dist/main.*.js",
      "limit": "250 KB"
    },
    {
      "path": "dist/vendor.*.js",
      "limit": "200 KB"
    }
  ]
}
```

## Production Configuration

### Webpack Production Config
```javascript
// webpack.prod.js
const TerserPlugin = require('terser-webpack-plugin');
const CompressionPlugin = require('compression-webpack-plugin');
const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin;

module.exports = {
  mode: 'production',

  optimization: {
    minimize: true,
    minimizer: [
      new TerserPlugin({
        terserOptions: {
          compress: {
            drop_console: true,
            passes: 2
          },
          mangle: true,
          output: {
            comments: false
          }
        },
        extractComments: false
      })
    ],

    splitChunks: {
      chunks: 'all',
      maxInitialRequests: 25,
      minSize: 20000,
      cacheGroups: {
        vendor: {
          test: /[\\/]node_modules[\\/]/,
          name: 'vendor',
          priority: 10
        },
        common: {
          minChunks: 2,
          priority: 5,
          reuseExistingChunk: true
        }
      }
    }
  },

  plugins: [
    new CompressionPlugin({
      filename: '[path][base].gz',
      algorithm: 'gzip',
      test: /\.(js|css|html|svg)$/,
      threshold: 8192
    }),

    new BundleAnalyzerPlugin({
      analyzerMode: 'static',
      openAnalyzer: false,
      reportFilename: '../reports/bundle-report.html'
    })
  ]
};
```

## Assets

See `assets/bundle-analysis-config.yaml` for analyzer configurations and optimization patterns.

## Resources

### Official Documentation
- [Webpack Bundle Analysis](https://webpack.js.org/guides/code-splitting/) - Code splitting guide
- [Bundle Analyzer Tools](https://www.npmjs.com/package/webpack-bundle-analyzer) - Visualization tool
- [Vite Build Optimizations](https://vitejs.dev/guide/build.html) - Vite optimization guide

### Tools
- [webpack-bundle-analyzer](https://github.com/webpack-contrib/webpack-bundle-analyzer) - Interactive treemap
- [source-map-explorer](https://github.com/danvk/source-map-explorer) - Source map analysis
- [bundlephobia](https://bundlephobia.com/) - Package size checker
- [size-limit](https://github.com/ai/size-limit) - Size limit enforcement

### Learning Resources
- [Web.dev Code Splitting](https://web.dev/code-splitting-with-dynamic-imports-in-nextjs/) - Best practices
- [Optimizing Bundle Size](https://web.dev/reduce-javascript-payloads-with-code-splitting/) - Optimization techniques

---
**Status:** Active | **Version:** 2.0.0 | **Last Updated:** 2025-12-30
