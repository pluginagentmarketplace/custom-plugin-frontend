/**
 * Bundle Analyzer Configuration
 * Tools and settings for analyzing and optimizing bundle size
 */

const { BundleAnalyzerPlugin } = require('webpack-bundle-analyzer');
const CompressionPlugin = require('compression-webpack-plugin');
const TerserPlugin = require('terser-webpack-plugin');

module.exports = {
  // Webpack plugins for bundle optimization
  plugins: [
    // Bundle analyzer - generates interactive report
    new BundleAnalyzerPlugin({
      analyzerMode: process.env.ANALYZE ? 'server' : 'disabled',
      analyzerHost: '127.0.0.1',
      analyzerPort: 8888,
      reportFilename: 'bundle-report.html',
      defaultSizes: 'parsed',
      openAnalyzer: true,
      generateStatsFile: true,
      statsFilename: 'bundle-stats.json',
      statsOptions: {
        source: false,
        modules: true,
        chunks: true,
        chunkModules: true
      },
      excludeAssets: null,
      logLevel: 'info'
    }),

    // Gzip compression
    new CompressionPlugin({
      filename: '[path][base].gz',
      algorithm: 'gzip',
      test: /\.(js|css|html|svg)$/,
      threshold: 10240,
      minRatio: 0.8
    }),

    // Brotli compression (better than gzip)
    new CompressionPlugin({
      filename: '[path][base].br',
      algorithm: 'brotliCompress',
      test: /\.(js|css|html|svg)$/,
      compressionOptions: { level: 11 },
      threshold: 10240,
      minRatio: 0.8
    })
  ],

  optimization: {
    minimize: true,
    minimizer: [
      new TerserPlugin({
        parallel: true,
        terserOptions: {
          parse: {
            ecma: 2020
          },
          compress: {
            ecma: 5,
            comparisons: false,
            inline: 2,
            drop_console: true,
            drop_debugger: true,
            pure_funcs: ['console.log', 'console.info']
          },
          mangle: {
            safari10: true
          },
          output: {
            ecma: 5,
            comments: false,
            ascii_only: true
          }
        },
        extractComments: false
      })
    ],

    // Split chunks for better caching
    splitChunks: {
      chunks: 'all',
      maxInitialRequests: 25,
      minSize: 20000,
      cacheGroups: {
        default: false,
        vendors: false,

        // Framework bundle
        framework: {
          chunks: 'all',
          name: 'framework',
          test: /[\\/]node_modules[\\/](react|react-dom|scheduler|prop-types)[\\/]/,
          priority: 40,
          enforce: true
        },

        // Library bundle
        lib: {
          test: /[\\/]node_modules[\\/]/,
          name(module) {
            const match = module.context.match(/[\\/]node_modules[\\/](.*?)([\\/]|$)/);
            const packageName = match ? match[1] : 'vendors';
            return `lib.${packageName.replace('@', '')}`;
          },
          priority: 30,
          minChunks: 1,
          reuseExistingChunk: true
        },

        // Common chunks
        commons: {
          name: 'commons',
          minChunks: 2,
          priority: 20
        },

        // Shared chunks
        shared: {
          name: 'shared',
          enforce: true,
          priority: 10,
          reuseExistingChunk: true
        }
      }
    }
  },

  // Performance budgets
  performance: {
    hints: 'error',
    maxEntrypointSize: 250000, // 250kb
    maxAssetSize: 200000, // 200kb
    assetFilter: (assetFilename) => {
      return !(/\.map$/.test(assetFilename));
    }
  }
};

/**
 * Bundle Size Budget Configuration
 * Use with bundlesize or size-limit
 */
const sizeLimitConfig = [
  {
    path: 'dist/main.*.js',
    limit: '150 kB'
  },
  {
    path: 'dist/vendor.*.js',
    limit: '200 kB'
  },
  {
    path: 'dist/*.css',
    limit: '50 kB'
  }
];

module.exports.sizeLimitConfig = sizeLimitConfig;
