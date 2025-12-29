# Webpack Design Patterns & Best Practices

## Pattern 1: Monolithic Configuration

Single webpack.config.js for all environments, using environment variables to switch behavior.

```javascript
const isProduction = process.env.NODE_ENV === 'production';

module.exports = {
  mode: isProduction ? 'production' : 'development',
  devtool: isProduction ? 'source-map' : 'eval-source-map',
  optimization: {
    minimize: isProduction,
    runtimeChunk: isProduction ? 'single' : false,
    splitChunks: isProduction ? { chunks: 'all' } : false
  }
};
```

## Pattern 2: Environment-Specific Configurations

Separate config files for dev, prod, and common configurations merged with webpack-merge.

```javascript
// webpack.common.js
const path = require('path');

module.exports = {
  entry: './src/index.js',
  module: {
    rules: [{ test: /\.js$/, use: 'babel-loader' }]
  }
};

// webpack.dev.js
const merge = require('webpack-merge');
const common = require('./webpack.common');

module.exports = merge(common, {
  mode: 'development',
  devtool: 'eval-source-map',
  devServer: { port: 3000, hot: true }
});

// webpack.prod.js
const merge = require('webpack-merge');
const common = require('./webpack.common');
const TerserPlugin = require('terser-webpack-plugin');

module.exports = merge(common, {
  mode: 'production',
  optimization: {
    minimizer: [new TerserPlugin()],
    splitChunks: { chunks: 'all' }
  }
});
```

## Pattern 3: Plugin Configuration by Environment

Conditionally apply plugins based on build environment.

```javascript
const HtmlWebpackPlugin = require('html-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const { BundleAnalyzerPlugin } = require('webpack-bundle-analyzer');

const plugins = [
  new HtmlWebpackPlugin({ template: './public/index.html' })
];

if (process.env.NODE_ENV === 'production') {
  plugins.push(new MiniCssExtractPlugin({ filename: 'css/[name].[contenthash].css' }));
}

if (process.env.ANALYZE === 'true') {
  plugins.push(new BundleAnalyzerPlugin());
}

module.exports = { plugins };
```

## Pattern 4: Dynamic Entry Points

Create entry points dynamically based on directory structure.

```javascript
const glob = require('glob');
const path = require('path');

// Automatically find all pages and create entry points
const entries = glob.sync('./src/pages/*/index.js').reduce((entries, file) => {
  const match = file.match(/pages\/(\w+)\/index\.js/);
  if (match) entries[match[1]] = file;
  return entries;
}, {});

module.exports = {
  entry: entries,
  output: {
    filename: 'pages/[name].[contenthash].js',
    path: path.resolve(__dirname, 'dist')
  }
};
```

## Pattern 5: Vendor Chunk Extraction

Separate vendor code from application code for better caching.

```javascript
optimization: {
  splitChunks: {
    chunks: 'all',
    cacheGroups: {
      // Vendor libraries
      vendor: {
        test: /[\\/]node_modules[\\/]/,
        name: 'vendors',
        priority: 10
      },
      // Shared code between entry points
      common: {
        minChunks: 2,
        priority: 5,
        reuseExistingChunk: true
      }
    }
  },
  runtimeChunk: 'single'  // Separate runtime chunk
}
```

## Pattern 6: Custom Loader Development

Create reusable custom loaders for specialized asset handling.

```javascript
// custom-markdown-loader.js
module.exports = function(source) {
  const { marked } = require('marked');
  const json = JSON.stringify(marked(source));
  return `export default ${json}`;
};

// webpack.config.js
module: {
  rules: [
    {
      test: /\.md$/,
      use: [
        { loader: 'raw-loader' },
        { loader: require.resolve('./custom-markdown-loader') }
      ]
    }
  ]
}
```

## Pattern 7: Lazy Loading Code Splitting

Use dynamic imports to create chunks that load on demand.

```javascript
// Dynamic import syntax creates separate chunk
button.addEventListener('click', () => {
  import('./heavy-module').then(({ default: HeavyModule }) => {
    const instance = new HeavyModule();
    instance.initialize();
  });
});

// Webpack configuration
optimization: {
  splitChunks: {
    chunks: 'all',
    maxInitialRequests: 30,
    maxAsyncRequests: 30,
    minSize: 20000,
    maxSize: 244000
  }
}
```

## Pattern 8: Multi-target Configuration

Build for multiple targets (browser, Node.js, web workers) from single source.

```javascript
module.exports = [
  {
    name: 'browser',
    target: 'web',
    entry: './src/index.js',
    output: { filename: 'browser.js', path: path.resolve(__dirname, 'dist') }
  },
  {
    name: 'node',
    target: 'node',
    entry: './src/server.js',
    output: { filename: 'server.js', path: path.resolve(__dirname, 'dist') }
  }
];
```

## Pattern 9: Module Federation (Micro-frontends)

Share modules between separate webpack builds at runtime.

```javascript
const { ModuleFederationPlugin } = require('webpack').container;

// Host application
plugins: [
  new ModuleFederationPlugin({
    name: 'host',
    remotes: {
      mfeApp: 'mfeApp@http://localhost:3001/remoteEntry.js'
    },
    shared: ['react', 'react-dom']
  })
]

// Remote application
plugins: [
  new ModuleFederationPlugin({
    name: 'mfeApp',
    filename: 'remoteEntry.js',
    exposes: {
      './Button': './src/components/Button'
    },
    shared: ['react', 'react-dom']
  })
]
```

## Pattern 10: Asset Optimization Pipeline

Comprehensive optimization for images, fonts, and other assets.

```javascript
module: {
  rules: [
    {
      test: /\.(png|jpg|jpeg|gif)$/i,
      type: 'asset',
      parser: { dataUrlCondition: { maxSize: 8 * 1024 } },
      generator: { filename: 'images/[name].[hash][ext]' }
    },
    {
      test: /\.(woff|woff2|eot|ttf|otf)$/i,
      type: 'asset/resource',
      generator: { filename: 'fonts/[name].[hash][ext]' }
    },
    {
      test: /\.svg$/,
      type: 'asset',
      parser: { dataUrlCondition: { maxSize: 4 * 1024 } }
    }
  ]
}
```

## Pattern 11: Hot Module Replacement (HMR)

Enable live updates during development without full page reload.

```javascript
// webpack.config.js
devServer: {
  hot: true,
  hotOnly: false,  // Allow fallback to full reload
  port: 3000
},

// Application code
if (module.hot) {
  module.hot.accept('./components/App', () => {
    const newApp = require('./components/App').default;
    ReactDOM.render(newApp, document.getElementById('root'));
  });
}
```

## Pattern 12: Environment Variables Integration

Safely pass environment variables to browser code.

```javascript
const webpack = require('webpack');

plugins: [
  new webpack.DefinePlugin({
    'process.env.REACT_APP_API_URL': JSON.stringify(process.env.REACT_APP_API_URL),
    'process.env.REACT_APP_VERSION': JSON.stringify(process.env.npm_package_version)
  })
],

// Usage in code
const apiUrl = process.env.REACT_APP_API_URL;  // Safe to use in bundles
```

