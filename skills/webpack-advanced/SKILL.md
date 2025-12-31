---
name: webpack-advanced
description: Master Webpack configuration, loaders, plugins, code splitting, and production optimization.
sasmp_version: "1.3.0"
bonded_agent: frontend-build-tools
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

# Webpack Advanced Configuration

> **Purpose:** Master the industry-standard module bundler with advanced configuration techniques for production-grade applications.

## Input/Output Schema

```typescript
interface WebpackInput {
  projectPath: string;
  entryPoints: string | string[] | Record<string, string>;
  outputPath: string;
  mode: 'development' | 'production';
  enableHMR?: boolean;
  sourceMap?: boolean | string;
  targetBrowsers?: string[];
}

interface WebpackOutput {
  configPath: string;
  buildSuccess: boolean;
  bundleStats: {
    totalSize: number;
    chunks: Array<{
      name: string;
      size: number;
      modules: number;
    }>;
  };
  warnings: string[];
  errors: string[];
  buildTime: number;
}

interface LoaderConfig {
  test: RegExp;
  loader: string;
  options?: Record<string, any>;
  include?: string[];
  exclude?: string[];
}

interface PluginConfig {
  name: string;
  options: Record<string, any>;
  stage?: string;
}
```

## MANDATORY
- Entry points and output configuration
- Loaders for file transformations (babel-loader, css-loader, style-loader)
- Plugins for extended functionality (HtmlWebpackPlugin, MiniCssExtractPlugin)
- Development vs production modes
- Source maps configuration
- Hot Module Replacement (HMR)

## OPTIONAL
- Code splitting strategies (splitChunks, dynamic imports)
- Tree shaking and dead code elimination
- Asset modules (images, fonts)
- Environment variables (DefinePlugin, dotenv-webpack)
- Multiple configurations (webpack.dev.js, webpack.prod.js)
- Webpack Dev Server configuration

## ADVANCED
- Module Federation for micro-frontends
- Custom loaders and plugins development
- Advanced caching strategies (contenthash, chunkhash)
- Parallel builds with thread-loader
- Persistent caching (filesystem cache)
- Build analysis and optimization (webpack-bundle-analyzer)

## Error Handling

| Error | Root Cause | Solution |
|-------|-----------|----------|
| `Module not found` | Incorrect path or missing dependency | Verify import paths, check node_modules, run npm install |
| `Loader not found` | Missing loader package | Install required loader: `npm install -D [loader-name]` |
| `Plugin initialization failed` | Invalid plugin configuration | Check plugin options against documentation |
| `Out of memory` | Large bundle or insufficient heap | Increase Node memory: `NODE_OPTIONS=--max-old-space-size=4096` |
| `Circular dependency detected` | Import cycle in modules | Refactor code to break circular references |
| `Asset size limit exceeded` | Bundle too large | Enable code splitting, optimize images, review dependencies |
| `Invalid configuration object` | Syntax error in webpack.config.js | Validate config against schema, check for typos |
| `HMR not working` | Incorrect dev server setup | Enable hot: true, configure target: 'web' |

## Test Template

```javascript
// webpack.config.test.js
const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

module.exports = {
  mode: 'production',
  entry: './src/index.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: '[name].[contenthash].js',
    clean: true,
  },
  module: {
    rules: [
      {
        test: /\.(js|jsx)$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-env', '@babel/preset-react'],
          },
        },
      },
      {
        test: /\.css$/,
        use: [MiniCssExtractPlugin.loader, 'css-loader'],
      },
      {
        test: /\.(png|jpg|gif|svg)$/,
        type: 'asset/resource',
      },
    ],
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: './public/index.html',
    }),
    new MiniCssExtractPlugin({
      filename: '[name].[contenthash].css',
    }),
  ],
  optimization: {
    splitChunks: {
      chunks: 'all',
      cacheGroups: {
        vendor: {
          test: /[\\/]node_modules[\\/]/,
          name: 'vendors',
          priority: 10,
        },
      },
    },
  },
  devServer: {
    hot: true,
    port: 3000,
    historyApiFallback: true,
  },
};

// Validation test
console.log('Testing webpack configuration...');
const webpack = require('webpack');
const config = require('./webpack.config.test.js');

webpack(config, (err, stats) => {
  if (err || stats.hasErrors()) {
    console.error('Build failed:', err || stats.toString());
    process.exit(1);
  }
  console.log('Build successful!');
  console.log(stats.toString({ colors: true }));
});
```

## Best Practices

1. **Separation of Configs**: Maintain separate webpack.dev.js and webpack.prod.js files
2. **Content Hashing**: Use `[contenthash]` for cache busting in production
3. **Source Maps**: Use `source-map` in production, `eval-source-map` in development
4. **Code Splitting**: Configure splitChunks for vendor and common code separation
5. **Tree Shaking**: Set `sideEffects: false` in package.json for libraries
6. **Bundle Analysis**: Regularly analyze bundles with webpack-bundle-analyzer
7. **Caching**: Enable persistent caching in webpack 5 for faster rebuilds
8. **Environment Variables**: Use DefinePlugin or dotenv-webpack for env management
9. **Minimize Assets**: Use TerserPlugin and CssMinimizerPlugin in production
10. **Performance Budgets**: Set maxAssetSize and maxEntrypointSize warnings

## Assets
- See `assets/webpack-config.yaml` for configuration patterns

## Resources
- [Webpack Official Docs](https://webpack.js.org/)
- [Webpack Configuration](https://webpack.js.org/configuration/)
- [Webpack Loaders](https://webpack.js.org/loaders/)
- [Webpack Plugins](https://webpack.js.org/plugins/)
- [Webpack Performance Guide](https://webpack.js.org/guides/build-performance/)

---
**Status:** Active | **Version:** 2.0.0
