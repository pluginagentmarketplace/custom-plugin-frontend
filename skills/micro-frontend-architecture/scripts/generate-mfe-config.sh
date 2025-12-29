#!/bin/bash
# Micro-Frontend Config Generator - Creates production-ready Module Federation setup

set -e

PROJECT_PATH="${1:-.}"
mkdir -p "$PROJECT_PATH/config"

echo "Module Federation Config Generator"
echo "==================================="
echo ""

# 1. Generate webpack.config.js with Module Federation
echo "📝 Generating webpack Module Federation config..."
cat > "$PROJECT_PATH/webpack.config.js" << 'EOF'
/**
 * Webpack 5 Module Federation Configuration
 * Enables dynamic micro-frontend loading and shared dependencies
 */

const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const { ModuleFederationPlugin } = require('webpack').container;

const isHost = process.env.ROLE === 'host' || !process.env.ROLE;
const PORT = process.env.PORT || 3000;

module.exports = {
  mode: 'development',
  entry: './src/index',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: '[name].[contenthash].js',
    chunkFilename: '[name].[contenthash].js',
    // Critical for Module Federation
    publicPath: `http://localhost:${PORT}/`,
    // Avoid filename conflicts
    uniqueName: isHost ? 'host' : 'remote'
  },

  devServer: {
    port: PORT,
    historyApiFallback: true,
    headers: {
      'Access-Control-Allow-Origin': '*'
    }
  },

  resolve: {
    extensions: ['.ts', '.tsx', '.js', '.jsx', '.json'],
    alias: {
      '@': path.resolve(__dirname, 'src/')
    }
  },

  module: {
    rules: [
      // TypeScript
      {
        test: /\.tsx?$/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-react', '@babel/preset-typescript']
          }
        },
        exclude: /node_modules/
      },
      // CSS Modules
      {
        test: /\.module\.css$/,
        use: [
          'style-loader',
          {
            loader: 'css-loader',
            options: { modules: true }
          }
        ]
      },
      // Regular CSS
      {
        test: /\.css$/,
        exclude: /\.module\.css$/,
        use: ['style-loader', 'css-loader']
      }
    ]
  },

  plugins: [
    new HtmlWebpackPlugin({
      template: './src/index.html',
      favicon: './src/favicon.ico'
    }),

    new ModuleFederationPlugin(getModuleFederationConfig(isHost))
  ],

  optimization: {
    runtimeChunk: 'single',
    // Prevent duplicate shared dependencies
    splitChunks: {
      chunks: 'all'
    }
  }
};

/**
 * Module Federation Configuration
 * HOST: Application loading micro-frontends
 * REMOTE: Micro-frontend exposing components
 */
function getModuleFederationConfig(isHost) {
  const shared = {
    react: {
      singleton: true, // Only one React instance
      requiredVersion: '^18.0.0'
    },
    'react-dom': {
      singleton: true,
      requiredVersion: '^18.0.0'
    },
    'react-router-dom': {
      singleton: true,
      requiredVersion: '^6.0.0'
    }
  };

  if (isHost) {
    // HOST APPLICATION - loads remotes
    return {
      name: 'host',
      remotes: {
        // Point to deployed micro-frontends
        dashboard: 'dashboard@http://localhost:3001/remoteEntry.js',
        analytics: 'analytics@http://localhost:3002/remoteEntry.js',
        settings: 'settings@http://localhost:3003/remoteEntry.js'
      },
      shared
    };
  } else {
    // REMOTE MICRO-FRONTEND - exposes components
    return {
      name: process.env.APP_NAME || 'remote',
      filename: 'remoteEntry.js',
      exposes: {
        './Dashboard': './src/components/Dashboard',
        './DashboardWidget': './src/components/DashboardWidget',
        './useMetrics': './src/hooks/useMetrics'
      },
      shared
    };
  }
}
EOF
echo "✓ Created: webpack.config.js"

# 2. Generate Host App component
echo "📝 Generating Host application..."
cat > "$PROJECT_PATH/src/App.host.tsx" << 'EOF'
/**
 * Host Application - Loads and integrates micro-frontends
 */

import React, { Suspense, useState } from 'react';
import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom';

// Dynamic imports of remote micro-frontends
const Dashboard = React.lazy(() => import('dashboard/Dashboard'));
const Analytics = React.lazy(() => import('analytics/Analytics'));
const Settings = React.lazy(() => import('settings/Settings'));

const LoadingFallback = () => (
  <div style={{ padding: '20px' }}>
    <p>Loading micro-frontend...</p>
  </div>
);

export default function App() {
  const [loading, setLoading] = useState(false);

  return (
    <Router>
      <div className="app">
        <header className="header">
          <h1>Main Application</h1>
          <nav>
            <Link to="/" onClick={() => setLoading(true)}>Home</Link>
            <Link to="/dashboard" onClick={() => setLoading(true)}>Dashboard</Link>
            <Link to="/analytics" onClick={() => setLoading(true)}>Analytics</Link>
            <Link to="/settings" onClick={() => setLoading(true)}>Settings</Link>
          </nav>
        </header>

        <main className="main">
          {loading && <p>Loading...</p>}
          <Suspense fallback={<LoadingFallback />}>
            <Routes>
              <Route path="/" element={<Home />} />
              <Route path="/dashboard" element={<Dashboard />} />
              <Route path="/analytics" element={<Analytics />} />
              <Route path="/settings" element={<Settings />} />
            </Routes>
          </Suspense>
        </main>
      </div>
    </Router>
  );
}

function Home() {
  return (
    <div>
      <h2>Welcome to Host Application</h2>
      <p>This application loads micro-frontends dynamically via Module Federation.</p>
    </div>
  );
}
EOF
echo "✓ Created: src/App.host.tsx"

# 3. Generate Remote App
echo "📝 Generating Remote micro-frontend..."
cat > "$PROJECT_PATH/src/App.remote.tsx" << 'EOF'
/**
 * Remote Micro-Frontend - Exposes components for host
 */

import React from 'react';
import Dashboard from './components/Dashboard';

export default function App() {
  return (
    <div className="remote-app">
      <Dashboard />
    </div>
  );
}
EOF
echo "✓ Created: src/App.remote.tsx"

# 4. Generate container component
echo "📝 Generating remote container..."
cat > "$PROJECT_PATH/src/RemoteContainer.tsx" << 'EOF'
/**
 * Dynamic Remote Container
 * Safely loads and renders remote components
 */

import React, { Suspense, useState, useEffect } from 'react';

interface RemoteContainerProps {
  scope: string;
  module: string;
  fallback?: React.ReactNode;
  onError?: (error: Error) => void;
}

export function RemoteContainer({
  scope,
  module,
  fallback = <div>Loading...</div>,
  onError
}: RemoteContainerProps) {
  const [Component, setComponent] = useState<React.ComponentType<any> | null>(null);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    loadRemoteComponent();
  }, [scope, module]);

  const loadRemoteComponent = async () => {
    try {
      // Share scope must be initialized
      await __webpack_share_scopes__.default.init({
        singleton: true
      });

      // Get the remote container
      const container = window[scope];
      if (!container) {
        throw new Error(`Remote ${scope} not found`);
      }

      // Initialize the container
      await container.init(__webpack_share_scopes__.default);

      // Get the factory
      const factory = await container.get(module);
      const Module = factory().default;

      setComponent(() => Module);
      setError(null);
    } catch (err) {
      const error = err instanceof Error ? err : new Error(String(err));
      setError(error);
      onError?.(error);
    }
  };

  if (error) {
    return (
      <div style={{ color: 'red', padding: '20px' }}>
        Error loading remote: {error.message}
      </div>
    );
  }

  if (!Component) {
    return <>{fallback}</>;
  }

  return (
    <Suspense fallback={fallback}>
      <Component />
    </Suspense>
  );
}
EOF
echo "✓ Created: src/RemoteContainer.tsx"

# 5. Generate shared utilities
echo "📝 Generating shared utilities..."
cat > "$PROJECT_PATH/src/shared/context.tsx" << 'EOF'
/**
 * Shared Context for Micro-Frontends
 * Enables communication between host and remotes
 */

import React, { createContext, ReactNode } from 'react';

interface SharedContextType {
  user?: { id: string; name: string };
  theme?: 'light' | 'dark';
  onNavigate?: (path: string) => void;
}

export const SharedContext = createContext<SharedContextType>({});

export function SharedProvider({
  children,
  value
}: {
  children: ReactNode;
  value: SharedContextType;
}) {
  return (
    <SharedContext.Provider value={value}>
      {children}
    </SharedContext.Provider>
  );
}

export function useShared() {
  return React.useContext(SharedContext);
}
EOF
echo "✓ Created: src/shared/context.tsx"

# 6. Generate package.json scripts
echo "📝 Generating package.json scripts..."
cat > "$PROJECT_PATH/package.scripts.json" << 'EOF'
{
  "scripts": {
    "start:host": "ROLE=host webpack serve --mode development",
    "start:dashboard": "APP_NAME=dashboard PORT=3001 webpack serve --mode development",
    "start:analytics": "APP_NAME=analytics PORT=3002 webpack serve --mode development",
    "start:settings": "APP_NAME=settings PORT=3003 webpack serve --mode development",
    "build:host": "ROLE=host webpack --mode production",
    "build:dashboard": "APP_NAME=dashboard webpack --mode production",
    "build:analytics": "APP_NAME=analytics webpack --mode production",
    "build:settings": "APP_NAME=settings webpack --mode production",
    "start:all": "npm run start:host & npm run start:dashboard & npm run start:analytics & npm run start:settings"
  }
}
EOF
echo "✓ Created: package.scripts.json (add to package.json)"

# 7. Generate deployment manifest
echo "📝 Generating deployment configuration..."
cat > "$PROJECT_PATH/mfe.config.json" << 'EOF'
{
  "version": "1.0.0",
  "host": {
    "name": "host",
    "port": 3000,
    "remotes": {
      "dashboard": {
        "url": "${DASHBOARD_URL}/remoteEntry.js",
        "scope": "dashboard",
        "module": "./Dashboard"
      },
      "analytics": {
        "url": "${ANALYTICS_URL}/remoteEntry.js",
        "scope": "analytics",
        "module": "./Analytics"
      },
      "settings": {
        "url": "${SETTINGS_URL}/remoteEntry.js",
        "scope": "settings",
        "module": "./Settings"
      }
    }
  },
  "remotes": [
    {
      "name": "dashboard",
      "port": 3001,
      "exposes": ["./Dashboard", "./DashboardWidget"]
    },
    {
      "name": "analytics",
      "port": 3002,
      "exposes": ["./Analytics", "./Chart"]
    },
    {
      "name": "settings",
      "port": 3003,
      "exposes": ["./Settings", "./Profile"]
    }
  ],
  "shared": {
    "react": "^18.0.0",
    "react-dom": "^18.0.0",
    "react-router-dom": "^6.0.0"
  }
}
EOF
echo "✓ Created: mfe.config.json"

echo ""
echo "==================================="
echo "✓ Module Federation Setup Complete!"
echo "==================================="
echo ""
echo "Next steps:"
echo "1. Install dependencies: npm install"
echo "2. Update remotes URLs in webpack.config.js"
echo "3. Configure shared dependencies"
echo "4. Merge scripts from package.scripts.json into package.json"
echo "5. For development:"
echo "   npm run start:host (in terminal 1)"
echo "   npm run start:dashboard (in terminal 2)"
echo "   npm run start:analytics (in terminal 3)"
echo "6. Open http://localhost:3000"
echo ""
