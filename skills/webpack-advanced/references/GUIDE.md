# Webpack Advanced Configuration Guide

## Core Concepts

Webpack is a static module bundler that transforms your source code into optimized assets for production. It processes JavaScript, CSS, images, and other assets through a pipeline called the module dependency graph.

### Entry Points

Entry points tell webpack where to start the bundling process. A webpack configuration can have one or multiple entry points.

```javascript
// Single entry point (object notation recommended)
entry: {
  main: './src/index.js'
}

// Multiple entry points for different pages
entry: {
  pageA: './src/pages/a.js',
  pageB: './src/pages/b.js'
}

// Shorthand syntax for single entry
entry: './src/index.js'
```

### Output Configuration

The output configuration specifies where bundled files should be saved and how they should be named.

```javascript
output: {
  path: path.resolve(__dirname, 'dist'),
  filename: '[name].[contenthash].js',  // [name] = entry point name
  chunkFilename: '[name].[contenthash].chunk.js',
  publicPath: '/assets/',
  clean: true,  // Clean dist folder before build
}
```

### Loaders

Loaders transform source files during the build process. They tell webpack how to process non-JavaScript files.

```javascript
module: {
  rules: [
    // Babel loader for JavaScript transpilation
    {
      test: /\.jsx?$/,
      exclude: /node_modules/,
      use: {
        loader: 'babel-loader',
        options: { presets: ['@babel/preset-env', '@babel/preset-react'] }
      }
    },
    // CSS loader
    {
      test: /\.css$/,
      use: ['style-loader', 'css-loader', 'postcss-loader']
    },
    // Image optimization with asset module
    {
      test: /\.(png|jpg|gif)$/i,
      type: 'asset',
      parser: { dataUrlCondition: { maxSize: 8 * 1024 } }
    }
  ]
}
```

### Plugins

Plugins perform actions at specific stages of the webpack compilation. Unlike loaders which transform individual files, plugins can hook into the entire compilation lifecycle.

```javascript
const HtmlWebpackPlugin = require('html-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

plugins: [
  new HtmlWebpackPlugin({
    template: './public/index.html',
    minify: { removeComments: true, collapseWhitespace: true }
  }),
  new MiniCssExtractPlugin({
    filename: 'css/[name].[contenthash].css'
  })
]
```

## Optimization Techniques

### Code Splitting

Code splitting breaks your bundle into smaller chunks that can be loaded on demand, reducing initial load time.

```javascript
optimization: {
  splitChunks: {
    chunks: 'all',
    cacheGroups: {
      vendor: {
        test: /[\\/]node_modules[\\/]/,
        name: 'vendors',
        priority: 10,
        reuseExistingChunk: true
      },
      common: {
        minChunks: 2,
        priority: 5,
        reuseExistingChunk: true
      }
    }
  }
}
```

### Tree Shaking

Tree shaking removes unused code from the final bundle. It requires ES6 module syntax and works best with libraries that support it.

```javascript
// webpack.config.js
optimization: {
  usedExports: true,  // Mark unused exports
}

// .babelrc - keep modules as ES6
{
  "presets": [["@babel/preset-env", { "modules": false }]]
}
```

### Minification

Webpack minifies code in production mode automatically. For advanced options:

```javascript
const TerserPlugin = require('terser-webpack-plugin');

optimization: {
  minimize: true,
  minimizer: [
    new TerserPlugin({
      terserOptions: {
        compress: {
          drop_console: true,  // Remove console statements
          drop_debugger: true
        }
      }
    })
  ]
}
```

### Source Maps

Source maps help debug minified code by mapping back to original source files.

```javascript
// Development: Fast rebuilds, good debugging
devtool: 'eval-source-map',

// Production: Smaller but slower to generate
devtool: 'source-map',

// Fastest for dev, but no source map
devtool: false
```

## Development Workflow

### Dev Server

The webpack dev server provides live reloading and hot module replacement during development.

```javascript
devServer: {
  port: 3000,
  hot: true,  // Hot Module Replacement
  historyApiFallback: true,  // SPA routing support
  compress: true,
  proxy: {
    '/api': {
      target: 'http://localhost:5000',
      changeOrigin: true
    }
  }
}
```

### Asset Modules

Webpack 5 introduced asset modules as a built-in alternative to file-loader and url-loader.

```javascript
{
  test: /\.(png|jpg|svg)$/,
  type: 'asset',
  parser: {
    dataUrlCondition: {
      maxSize: 8 * 1024  // Inline small files as data URLs
    }
  },
  generator: {
    filename: 'images/[name].[hash][ext]'
  }
}
```

## Performance Monitoring

### Bundle Analysis

Analyze your bundle size to identify large dependencies.

```javascript
const { BundleAnalyzerPlugin } = require('webpack-bundle-analyzer');

plugins: process.env.ANALYZE ? [
  new BundleAnalyzerPlugin()
] : []

// Run with: ANALYZE=true npm run build
```

### Build Performance

```javascript
// Cache builds for faster subsequent builds
cache: {
  type: 'filesystem',
  cacheDirectory: path.resolve(__dirname, '.webpack_cache')
}
```

## Production Best Practices

1. **Use Content Hashes**: Enable cache busting with `[contenthash]` in filenames
2. **Separate CSS**: Use MiniCssExtractPlugin to separate CSS from JavaScript
3. **Compress Assets**: Configure image optimization and minification
4. **Set Correct Mode**: Always set `mode: 'production'` for optimizations
5. **Monitor Bundle Size**: Use bundle analyzer to track size trends
6. **Configure publicPath**: Set correct path for CDN or subdirectory deployment

