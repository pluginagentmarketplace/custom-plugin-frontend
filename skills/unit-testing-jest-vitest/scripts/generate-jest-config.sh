#!/bin/bash

# Jest Configuration Generator
# Generates complete Jest setup with config, boilerplate tests, and coverage thresholds
# Usage: ./generate-jest-config.sh [project-name]

set -e

PROJECT_NAME="${1:-my-project}"
PROJECT_DIR="${2:-.}"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Jest Configuration Generator${NC}"
echo "=================================="
echo "Project: $PROJECT_NAME"
echo "Directory: $PROJECT_DIR"
echo ""

# 1. Generate jest.config.js
echo -e "${GREEN}Creating jest.config.js...${NC}"
cat > "$PROJECT_DIR/jest.config.js" << 'EOF'
/**
 * Jest Configuration
 * Comprehensive testing setup with TypeScript, coverage, and mocking support
 */

module.exports = {
  // Test environment (jsdom for DOM testing, node for server-side)
  testEnvironment: 'jsdom',

  // File extensions to look for
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx', 'json'],

  // Module name mapping for path aliases and static assets
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
    '^@components/(.*)$': '<rootDir>/src/components/$1',
    '^@utils/(.*)$': '<rootDir>/src/utils/$1',
    '^@hooks/(.*)$': '<rootDir>/src/hooks/$1',
    '\\.(css|less|scss|sass)$': 'identity-obj-proxy',
    '\\.(gif|ttf|eot|svg|png|jpg|jpeg)$': '<rootDir>/__mocks__/fileMock.js',
  },

  // Transform files with TypeScript/Babel support
  transform: {
    '^.+\\.tsx?$': ['ts-jest', {
      tsconfig: {
        jsx: 'react-jsx',
        esModuleInterop: true,
      }
    }],
    '^.+\\.jsx?$': 'babel-jest',
  },

  // Test match patterns
  testMatch: [
    '**/__tests__/**/*.(test|spec).(js|jsx|ts|tsx)',
    '**/*.(test|spec).(js|jsx|ts|tsx)',
  ],

  // Coverage configuration
  collectCoverageFrom: [
    'src/**/*.{js,jsx,ts,tsx}',
    '!src/index.tsx',
    '!src/**/*.d.ts',
    '!src/**/__tests__/**',
  ],

  // Coverage thresholds (enforce minimum coverage)
  coverageThreshold: {
    global: {
      branches: 75,
      functions: 75,
      lines: 75,
      statements: 75,
    },
    // Component-specific thresholds
    './src/components/': {
      branches: 85,
      functions: 85,
      lines: 85,
      statements: 85,
    },
    // Hooks should have high coverage
    './src/hooks/': {
      branches: 90,
      functions: 90,
      lines: 90,
      statements: 90,
    },
  },

  // Setup files to run before tests
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],

  // Module directories for module resolution
  moduleDirectories: ['node_modules', 'src'],

  // Snapshot resolver for better snapshot organization
  snapshotResolver: '<rootDir>/__snapshots__/resolver.js',

  // Watch plugins for better development experience
  watchPlugins: [
    'jest-watch-typeahead/filename',
    'jest-watch-typeahead/testname',
  ],

  // Test timeout (milliseconds)
  testTimeout: 10000,

  // Verbose output
  verbose: true,

  // Coverage reporter formats
  coverageReporters: [
    'text',
    'text-summary',
    'html',
    'lcov',
    'json',
  ],

  // No coverage for test files
  coveragePathIgnorePatterns: [
    '/node_modules/',
    '/__tests__/',
    '\\.test\\.(js|jsx|ts|tsx)$',
  ],

  // Global setup and teardown
  // globalSetup: '<rootDir>/jest.global-setup.js',
  // globalTeardown: '<rootDir>/jest.global-teardown.js',

  // Bail after N test failures
  bail: 0,

  // Detect open handles
  detectOpenHandles: false,

  // Max workers for parallel testing
  maxWorkers: '50%',

  // Clear mocks between tests
  clearMocks: true,

  // Restore mocks between tests
  restoreMocks: true,

  // Reset mocks between tests
  resetMocks: true,
};
EOF
echo -e "${GREEN}✓ Created jest.config.js${NC}"

# 2. Generate jest.setup.js
echo -e "${GREEN}Creating jest.setup.js...${NC}"
cat > "$PROJECT_DIR/jest.setup.js" << 'EOF'
/**
 * Jest Setup File
 * Runs before all tests - configure global test utilities here
 */

// Import testing library matchers
import '@testing-library/jest-dom';

// Global test timeout
jest.setTimeout(10000);

// Mock window.matchMedia
Object.defineProperty(window, 'matchMedia', {
  writable: true,
  value: jest.fn().mockImplementation(query => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: jest.fn(),
    removeListener: jest.fn(),
    addEventListener: jest.fn(),
    removeEventListener: jest.fn(),
    dispatchEvent: jest.fn(),
  })),
});

// Mock IntersectionObserver
global.IntersectionObserver = class IntersectionObserver {
  constructor() {}
  disconnect() {}
  observe() {}
  takeRecords() {
    return [];
  }
  unobserve() {}
};

// Mock window.scrollTo
window.scrollTo = jest.fn();

// Suppress console errors in tests (optional)
const originalError = console.error;
beforeAll(() => {
  console.error = (...args) => {
    if (
      typeof args[0] === 'string' &&
      args[0].includes('Warning: ReactDOM.render')
    ) {
      return;
    }
    originalError.call(console, ...args);
  };
});

afterAll(() => {
  console.error = originalError;
});

// Global test utilities
global.renderDelay = (ms) => new Promise(resolve => setTimeout(resolve, ms));
EOF
echo -e "${GREEN}✓ Created jest.setup.js${NC}"

# 3. Create mock files directory
echo -e "${GREEN}Creating __mocks__ directory...${NC}"
mkdir -p "$PROJECT_DIR/__mocks__"

# Create file mock
cat > "$PROJECT_DIR/__mocks__/fileMock.js" << 'EOF'
module.exports = 'test-file-stub';
EOF
echo -e "${GREEN}✓ Created __mocks__/fileMock.js${NC}"

# 4. Create example test files
echo -e "${GREEN}Creating example test structure...${NC}"
mkdir -p "$PROJECT_DIR/src/__tests__/unit"
mkdir -p "$PROJECT_DIR/src/__tests__/integration"

# Create unit test example
cat > "$PROJECT_DIR/src/__tests__/unit/math.test.js" << 'EOF'
/**
 * Unit Test Example
 * Tests basic math utilities
 */

describe('Math Utilities', () => {
  describe('Addition', () => {
    test('should add two positive numbers', () => {
      const add = (a, b) => a + b;
      expect(add(2, 3)).toBe(5);
    });

    test('should add negative numbers', () => {
      const add = (a, b) => a + b;
      expect(add(-2, -3)).toBe(-5);
    });

    test('should add mixed sign numbers', () => {
      const add = (a, b) => a + b;
      expect(add(10, -5)).toBe(5);
    });
  });

  describe('Multiplication', () => {
    test('should multiply two numbers', () => {
      const multiply = (a, b) => a * b;
      expect(multiply(4, 5)).toBe(20);
    });

    test('should handle zero', () => {
      const multiply = (a, b) => a * b;
      expect(multiply(10, 0)).toBe(0);
    });
  });

  describe('Division', () => {
    test('should divide two numbers', () => {
      const divide = (a, b) => a / b;
      expect(divide(10, 2)).toBe(5);
    });

    test('should throw on division by zero', () => {
      const divide = (a, b) => {
        if (b === 0) throw new Error('Division by zero');
        return a / b;
      };
      expect(() => divide(10, 0)).toThrow('Division by zero');
    });
  });
});
EOF
echo -e "${GREEN}✓ Created example unit test${NC}"

# Create integration test example
cat > "$PROJECT_DIR/src/__tests__/integration/api.test.js" << 'EOF'
/**
 * Integration Test Example
 * Tests async API interactions and promises
 */

describe('API Integration Tests', () => {
  // Mock fetch for testing
  beforeEach(() => {
    global.fetch = jest.fn();
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  test('should fetch user data successfully', async () => {
    const mockUser = {
      id: 1,
      name: 'John Doe',
      email: 'john@example.com',
    };

    global.fetch.mockResolvedValueOnce({
      ok: true,
      json: async () => mockUser,
    });

    const response = await fetch('/api/users/1').then(r => r.json());
    expect(response).toEqual(mockUser);
    expect(global.fetch).toHaveBeenCalledWith('/api/users/1');
  });

  test('should handle API errors', async () => {
    global.fetch.mockResolvedValueOnce({
      ok: false,
      status: 404,
      statusText: 'Not Found',
    });

    const response = await fetch('/api/users/999');
    expect(response.ok).toBe(false);
    expect(response.status).toBe(404);
  });

  test('should handle network errors', async () => {
    const error = new Error('Network error');
    global.fetch.mockRejectedValueOnce(error);

    await expect(fetch('/api/users/1')).rejects.toThrow('Network error');
  });
});
EOF
echo -e "${GREEN}✓ Created example integration test${NC}"

# 5. Create .babelrc if not exists
if [ ! -f "$PROJECT_DIR/.babelrc" ]; then
    echo -e "${GREEN}Creating .babelrc...${NC}"
    cat > "$PROJECT_DIR/.babelrc" << 'EOF'
{
  "presets": [
    ["@babel/preset-env", { "targets": { "node": "current" } }],
    ["@babel/preset-react", { "runtime": "automatic" }],
    "@babel/preset-typescript"
  ],
  "env": {
    "test": {
      "presets": [
        ["@babel/preset-env", { "targets": { "node": "current" } }],
        ["@babel/preset-react", { "runtime": "automatic" }],
        "@babel/preset-typescript"
      ]
    }
  }
}
EOF
    echo -e "${GREEN}✓ Created .babelrc${NC}"
fi

# 6. Create tsconfig.json if TypeScript project
if [ ! -f "$PROJECT_DIR/tsconfig.json" ]; then
    echo -e "${GREEN}Creating tsconfig.json...${NC}"
    cat > "$PROJECT_DIR/tsconfig.json" << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "esModuleInterop": true,
    "strict": true,
    "noEmit": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "jsx": "react-jsx",
    "paths": {
      "@/*": ["./src/*"],
      "@components/*": ["./src/components/*"],
      "@utils/*": ["./src/utils/*"],
      "@hooks/*": ["./src/hooks/*"]
    }
  },
  "include": ["src"],
  "exclude": ["node_modules", "dist", "build"]
}
EOF
    echo -e "${GREEN}✓ Created tsconfig.json${NC}"
fi

# 7. Display instructions
echo ""
echo -e "${BLUE}================================"
echo "✅ Jest Configuration Complete!"
echo "================================${NC}"
echo ""
echo "📋 Generated Files:"
echo "  • jest.config.js         - Main Jest configuration"
echo "  • jest.setup.js          - Test setup and globals"
echo "  • __mocks__/fileMock.js  - File mock"
echo "  • .babelrc               - Babel configuration"
echo "  • tsconfig.json          - TypeScript configuration"
echo ""
echo "📝 Example Files:"
echo "  • src/__tests__/unit/math.test.js"
echo "  • src/__tests__/integration/api.test.js"
echo ""
echo "📦 Required Dependencies:"
echo "  npm install --save-dev jest ts-jest jest-environment-jsdom"
echo "  npm install --save-dev @testing-library/jest-dom"
echo "  npm install --save-dev @babel/preset-env @babel/preset-react"
echo "  npm install --save-dev babel-jest"
echo "  npm install --save-dev @types/jest"
echo "  npm install --save-dev jest-watch-typeahead"
echo "  npm install --save-dev identity-obj-proxy"
echo ""
echo "🚀 Next Steps:"
echo "  1. npm install (install dependencies)"
echo "  2. npm test (run tests)"
echo "  3. npm test -- --coverage (generate coverage report)"
echo "  4. Update src/tsconfig.json paths to match your project"
echo ""
