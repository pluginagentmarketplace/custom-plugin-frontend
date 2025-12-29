/**
 * Webpack Code Splitting Configuration
 * Production-ready configuration for optimal bundle splitting
 */

const path = require('path');

module.exports = {
  // Entry points for multi-page applications
  entry: {
    main: './src/index.js',
    vendor: './src/vendor.js'
  },

  output: {
    filename: '[name].[contenthash].js',
    chunkFilename: '[name].[contenthash].chunk.js',
    path: path.resolve(__dirname, 'dist'),
    clean: true
  },

  optimization: {
    // Enable runtime chunk for better caching
    runtimeChunk: 'single',

    // Module IDs for stable chunk hashes
    moduleIds: 'deterministic',

    // Split chunks configuration
    splitChunks: {
      chunks: 'all',

      // Minimum size for a chunk (in bytes)
      minSize: 20000,

      // Minimum size reduction for splitting
      minRemainingSize: 0,

      // Minimum number of chunks that share a module
      minChunks: 1,

      // Maximum async requests at entry point
      maxAsyncRequests: 30,

      // Maximum initial requests at entry point
      maxInitialRequests: 30,

      // Enforce size threshold
      enforceSizeThreshold: 50000,

      // Cache groups for specific splitting rules
      cacheGroups: {
        // Default vendor splitting
        defaultVendors: {
          test: /[\\/]node_modules[\\/]/,
          priority: -10,
          reuseExistingChunk: true,
          name(module) {
            // Get the name from node_modules folder
            const packageName = module.context.match(
              /[\\/]node_modules[\\/](.*?)([\\/]|$)/
            )[1];
            // Return sanitized package name
            return `vendor.${packageName.replace('@', '')}`;
          }
        },

        // Framework-specific chunks
        react: {
          test: /[\\/]node_modules[\\/](react|react-dom|react-router)[\\/]/,
          name: 'vendor.react',
          chunks: 'all',
          priority: 20
        },

        // Common utilities
        commons: {
          name: 'commons',
          minChunks: 2,
          priority: -20,
          reuseExistingChunk: true
        },

        // Styles
        styles: {
          name: 'styles',
          type: 'css/mini-extract',
          chunks: 'all',
          enforce: true
        }
      }
    }
  },

  // Performance hints
  performance: {
    hints: 'warning',
    maxEntrypointSize: 250000,
    maxAssetSize: 250000
  }
};

/**
 * Dynamic Import Examples
 *
 * // Basic dynamic import
 * const module = await import('./module.js');
 *
 * // With magic comments for chunk naming
 * const Chart = await import(
 *   /* webpackChunkName: "chart" *\/
 *   './components/Chart'
 * );
 *
 * // Prefetch for future navigation
 * import(
 *   /* webpackPrefetch: true *\/
 *   /* webpackChunkName: "about" *\/
 *   './pages/About'
 * );
 *
 * // Preload for current navigation
 * import(
 *   /* webpackPreload: true *\/
 *   /* webpackChunkName: "critical" *\/
 *   './components/CriticalComponent'
 * );
 */
