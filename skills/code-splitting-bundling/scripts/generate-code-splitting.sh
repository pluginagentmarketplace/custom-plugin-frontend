#!/bin/bash
# Generate code splitting configuration

cat > splitChunks.config.js << 'EOF'
module.exports = {
  splitChunks: {
    chunks: 'all',
    minSize: 20000,
    maxAsyncRequests: 30,
    maxInitialRequests: 30,
    cacheGroups: {
      vendor: {
        test: /[\\/]node_modules[\\/]/,
        name: 'vendors',
        priority: 10,
        reuseExistingChunk: true,
      },
      common: {
        minChunks: 2,
        priority: 5,
        reuseExistingChunk: true,
      },
      react: {
        test: /[\\/]node_modules[\\/](react|react-dom)[\\/]/,
        name: 'react-vendors',
        priority: 20,
      },
    },
  },
  runtimeChunk: {
    name: 'runtime',
  },
}
EOF

echo "✓ Generated splitChunks.config.js"
