#!/bin/bash
# Generate Code-Splitting Configuration for webpack/Vite
# Part of code-splitting-optimization skill - Golden Format E703 Compliant

set -e

OUTPUT_DIR="${1:-.}"
BUNDLER="${2:-webpack}"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Generating code-splitting configuration for $BUNDLER...${NC}\n"

if [ "$BUNDLER" = "webpack" ]; then
    echo "Creating webpack.config.js..."
    cat > "$OUTPUT_DIR/webpack.config.js" << 'EOF'
const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const TerserPlugin = require('terser-webpack-plugin');
const { BundleAnalyzerPlugin } = require('webpack-bundle-analyzer');

module.exports = (env, argv) => {
  const isProduction = argv.mode === 'production';

  return {
    // Entry points
    entry: {
      main: './src/index.js',
      // admin: './src/admin/index.js',  // Multiple entry points
    },

    // Output configuration
    output: {
      path: path.resolve(__dirname, 'dist'),
      filename: isProduction ? '[name].[contenthash:8].js' : '[name].js',
      chunkFilename: isProduction ? '[name].[contenthash:8].chunk.js' : '[name].chunk.js',
      clean: true,
      publicPath: '/',
    },

    // Module resolution
    module: {
      rules: [
        {
          test: /\.(js|jsx|ts|tsx)$/,
          exclude: /node_modules/,
          use: {
            loader: 'babel-loader',
            options: {
              presets: [
                '@babel/preset-env',
                ['@babel/preset-react', { runtime: 'automatic' }],
                '@babel/preset-typescript',
              ],
            },
          },
        },
        {
          test: /\.css$/,
          use: ['style-loader', 'css-loader'],
        },
        {
          test: /\.(png|jpg|jpeg|gif|svg)$/,
          type: 'asset',
          parser: {
            dataUrlCondition: {
              maxSize: 8 * 1024, // 8KB inline limit
            },
          },
          generator: {
            filename: 'images/[name].[hash:8][ext]',
          },
        },
      ],
    },

    // Optimization & Code-Splitting
    optimization: {
      minimize: isProduction,
      minimizer: [
        new TerserPlugin({
          terserOptions: {
            compress: {
              drop_console: isProduction,
              dead_code: true,
            },
            output: {
              comments: false,
            },
          },
          extractComments: false,
        }),
      ],

      // Module ID hashing (deterministic)
      moduleIds: 'deterministic',

      // Runtime chunk separation
      runtimeChunk: {
        name: 'runtime',
      },

      // Code splitting strategy
      splitChunks: {
        chunks: 'all',
        minSize: 20000,
        minRemainingSize: 0,
        maxAsyncRequests: 30,
        maxInitialRequests: 30,
        cacheGroups: {
          // Vendor chunk - all node_modules
          vendor: {
            test: /[\\/]node_modules[\\/]/,
            name: 'vendors',
            priority: 10,
            reuseExistingChunk: true,
            enforce: true,
          },

          // React & React-DOM
          react: {
            test: /[\\/]node_modules[\\/](react|react-dom|react-router|react-router-dom)[\\/]/,
            name: 'react-vendors',
            priority: 20,
            reuseExistingChunk: true,
            enforce: true,
          },

          // UI libraries (Material-UI, Ant Design, etc.)
          ui: {
            test: /[\\/]node_modules[\\/](@mui|antd|bootstrap)[\\/]/,
            name: 'ui-vendors',
            priority: 15,
            reuseExistingChunk: true,
            enforce: true,
          },

          // Common chunk - shared between multiple entry points
          common: {
            minChunks: 2,
            priority: 5,
            reuseExistingChunk: true,
            name: 'common',
          },
        },
      },
    },

    // Plugins
    plugins: [
      new HtmlWebpackPlugin({
        template: './public/index.html',
        minify: isProduction && {
          removeComments: true,
          collapseWhitespace: true,
        },
      }),

      // Uncomment for bundle analysis
      ...(process.env.ANALYZE ? [
        new BundleAnalyzerPlugin({
          analyzerMode: 'static',
          reportFilename: 'bundle-report.html',
          openAnalyzer: true,
        }),
      ] : []),
    ],

    // Development server
    devServer: {
      port: 3000,
      hot: true,
      compress: true,
      historyApiFallback: true,
    },

    // Source maps
    devtool: isProduction ? 'source-map' : 'cheap-module-source-map',

    // Performance budgets
    performance: {
      maxEntrypointSize: 512000,
      maxAssetSize: 512000,
      hints: isProduction ? 'warning' : false,
    },

    // Resolve configuration
    resolve: {
      extensions: ['.js', '.jsx', '.ts', '.tsx', '.json'],
      alias: {
        '@': path.resolve(__dirname, 'src/'),
        '@components': path.resolve(__dirname, 'src/components/'),
        '@utils': path.resolve(__dirname, 'src/utils/'),
        '@hooks': path.resolve(__dirname, 'src/hooks/'),
      },
    },
  };
};
EOF
    echo -e "${GREEN}✓ Generated webpack.config.js${NC}"

elif [ "$BUNDLER" = "vite" ]; then
    echo "Creating vite.config.ts..."
    cat > "$OUTPUT_DIR/vite.config.ts" << 'EOF'
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';
import { visualizer } from 'rollup-plugin-visualizer';
import compression from 'vite-plugin-compression';

export default defineConfig({
  plugins: [
    react(),
    compression({
      verbose: true,
      disable: false,
      threshold: 10240,
      algorithm: 'brotli',
      ext: '.br',
    }),
    // Uncomment for bundle analysis
    // visualizer({
    //   open: true,
    //   gzipSize: true,
    //   brotliSize: true,
    // }),
  ],

  build: {
    // Output configuration
    outDir: 'dist',
    assetsDir: 'assets',
    sourcemap: true,
    minify: 'terser',

    // Chunk optimization
    rollupOptions: {
      output: {
        // Entry point filename pattern
        entryFileNames: '[name].[hash:8].js',

        // Chunk filename pattern
        chunkFileNames: '[name].[hash:8].chunk.js',

        // Asset filename pattern
        assetFileNames: (assetInfo) => {
          const info = assetInfo.name.split('.');
          const ext = info[info.length - 1];
          if (/png|jpe?g|gif|svg/.test(ext)) {
            return `assets/images/[name].[hash:8][extname]`;
          } else if (/woff|woff2|eot|ttf|otf/.test(ext)) {
            return `assets/fonts/[name].[hash:8][extname]`;
          } else if (ext === 'css') {
            return `assets/css/[name].[hash:8][extname]`;
          }
          return `assets/[name].[hash:8][extname]`;
        },

        // Manual chunk configuration
        manualChunks: {
          // React ecosystem
          react: ['react', 'react-dom', 'react-router-dom'],

          // UI library
          ui: ['@mui/material', '@mui/icons-material'],

          // Utilities
          utils: ['lodash-es', 'axios'],
        },
      },

      // Input configuration
      input: {
        main: path.resolve(__dirname, 'index.html'),
        // admin: path.resolve(__dirname, 'admin.html'),
      },
    },

    // Terser minification options
    terserOptions: {
      compress: {
        drop_console: true,
        drop_debugger: true,
        dead_code: true,
        passes: 2,
      },
      mangle: true,
      output: {
        comments: false,
      },
    },

    // Chunk size warning threshold
    chunkSizeWarningLimit: 500,

    // CSS code-splitting
    cssCodeSplit: true,

    // Reporting
    reportCompressedSize: true,
  },

  // Module resolution
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
      '@components': path.resolve(__dirname, './src/components'),
      '@utils': path.resolve(__dirname, './src/utils'),
      '@hooks': path.resolve(__dirname, './src/hooks'),
      '@types': path.resolve(__dirname, './src/types'),
    },
    extensions: ['.mjs', '.js', '.ts', '.jsx', '.tsx', '.json'],
  },

  // Server configuration
  server: {
    port: 3000,
    strictPort: false,
    open: true,
  },

  // Preview configuration
  preview: {
    port: 4173,
  },
});
EOF
    echo -e "${GREEN}✓ Generated vite.config.ts${NC}"

else
    echo "Unknown bundler: $BUNDLER"
    echo "Supported bundlers: webpack, vite"
    exit 1
fi

# 2. Generate .babelrc for code transformation
echo "Creating .babelrc..."
cat > "$OUTPUT_DIR/.babelrc" << 'EOF'
{
  "presets": [
    [
      "@babel/preset-env",
      {
        "targets": {
          "browsers": [">1%", "last 2 versions", "not dead"]
        },
        "modules": false,
        "useBuiltIns": "usage",
        "corejs": 3
      }
    ],
    [
      "@babel/preset-react",
      {
        "runtime": "automatic"
      }
    ],
    "@babel/preset-typescript"
  ],
  "plugins": [
    "@babel/plugin-proposal-class-properties",
    "@babel/plugin-syntax-dynamic-import"
  ],
  "env": {
    "production": {
      "plugins": [
        ["transform-remove-console", { "exclude": ["error", "warn"] }]
      ]
    }
  }
}
EOF
echo -e "${GREEN}✓ Generated .babelrc${NC}"

# 3. Generate TypeScript config snippet
if [ -f "$OUTPUT_DIR/tsconfig.json" ]; then
    echo -e "${YELLOW}Updating tsconfig.json with path aliases...${NC}"
else
    echo "Creating tsconfig.json..."
    cat > "$OUTPUT_DIR/tsconfig.json" << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,

    /* Bundler mode */
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",

    /* Linting */
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,

    /* Path aliases */
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"],
      "@components/*": ["src/components/*"],
      "@utils/*": ["src/utils/*"],
      "@hooks/*": ["src/hooks/*"],
      "@types/*": ["src/types/*"]
    }
  },
  "include": ["src"],
  "exclude": ["node_modules", "dist"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
EOF
    echo -e "${GREEN}✓ Generated tsconfig.json${NC}"
fi

# Summary
echo -e "\n${GREEN}=== Configuration Generation Complete ===${NC}\n"
echo "Generated files:"
echo "  ✓ $BUNDLER configuration with code-splitting"
echo "  ✓ .babelrc - JavaScript transpilation config"
echo "  ✓ tsconfig.json - TypeScript and path aliases"
echo ""
echo "Key features configured:"
echo "  ✓ Vendor chunk separation (node_modules)"
echo "  ✓ React/UI framework chunk separation"
echo "  ✓ Common code extraction"
echo "  ✓ Asset optimization"
echo "  ✓ Source maps for debugging"
echo "  ✓ Module name hashing for cache-busting"
echo "  ✓ Path aliases for cleaner imports"
echo ""
echo "Next steps:"
echo "  1. Review generated configuration files"
echo "  2. Install required dependencies:"
if [ "$BUNDLER" = "webpack" ]; then
    echo "     npm install --save-dev webpack webpack-cli webpack-dev-server"
    echo "     npm install --save-dev html-webpack-plugin terser-webpack-plugin"
    echo "     npm install --save-dev @babel/core babel-loader"
    echo "     npm install --save-dev webpack-bundle-analyzer (optional)"
else
    echo "     npm install --save-dev vite @vitejs/plugin-react"
    echo "     npm install --save-dev vite-plugin-compression rollup-plugin-visualizer (optional)"
fi
echo "  3. Run build: npm run build"
echo "  4. Validate: ./scripts/validate-splitting.sh"
