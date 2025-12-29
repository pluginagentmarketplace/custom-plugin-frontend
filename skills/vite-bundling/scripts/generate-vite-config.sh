#!/bin/bash
# Generate vite.config.ts with production-ready setup

cat > vite.config.ts << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { visualizer } from 'rollup-plugin-visualizer'

export default defineConfig({
  plugins: [
    react({
      jsxRuntime: 'automatic',
      jsxImportSource: '@emotion/react',
    }),
    visualizer({ open: process.env.ANALYZE === 'true' }),
  ],
  server: {
    port: 3000,
    open: false,
    cors: true,
  },
  build: {
    outDir: 'dist',
    sourcemap: true,
    minify: 'terser',
    target: 'esnext',
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          ui: ['antd'],
        },
        entryFileNames: 'js/[name].[hash].js',
        chunkFileNames: 'js/[name].[hash].chunk.js',
        assetFileNames: ({ name }) => {
          if (/\.(gif|jpe?g|png|svg)$/.test(name ?? '')) {
            return 'images/[name].[hash][extname]'
          } else if (/\.css$/.test(name ?? '')) {
            return 'css/[name].[hash][extname]'
          }
          return 'assets/[name].[hash][extname]'
        },
      },
    },
  },
  optimizeDeps: {
    include: ['react', 'react-dom', 'antd'],
    esbuildOptions: {
      target: 'esnext',
    },
  },
  resolve: {
    alias: {
      '@': '/src',
      '@components': '/src/components',
      '@utils': '/src/utils',
    },
  },
})
EOF

echo "✓ Generated vite.config.ts"
