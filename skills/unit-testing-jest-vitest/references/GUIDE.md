# Jest Unit Testing - Complete Technical Guide

## Table of Contents
1. [Setup & Configuration](#setup--configuration)
2. [Test Structure](#test-structure)
3. [Assertion Matchers](#assertion-matchers)
4. [Mocking Functions](#mocking-functions)
5. [Snapshot Testing](#snapshot-testing)
6. [Async Testing](#async-testing)
7. [Coverage Reporting](#coverage-reporting)
8. [Debugging Tests](#debugging-tests)

## Setup & Configuration

### Installation

Jest requires Node.js 14.15+ and npm 5.6+. Install with:

```bash
npm install --save-dev jest
npm install --save-dev @types/jest  # For TypeScript
npm install --save-dev babel-jest @babel/preset-env  # For ES6+
npm install --save-dev ts-jest  # For TypeScript projects
```

### Configuration File

Create `jest.config.js` in your project root:

```javascript
module.exports = {
  testEnvironment: 'jsdom',  // or 'node' for server-side
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
    '\\.(css|less)$': 'identity-obj-proxy',
  },
  transform: {
    '^.+\\.tsx?$': 'ts-jest',
    '^.+\\.jsx?$': 'babel-jest',
  },
  testMatch: ['**/__tests__/**/*.test.(js|ts)'],
  collectCoverageFrom: ['src/**/*.{js,ts}'],
  coverageThreshold: {
    global: {
      branches: 75,
      functions: 75,
      lines: 75,
    },
  },
};
```

### Setup File

Create `jest.setup.js` for global test utilities:

```javascript
// Import testing library matchers
import '@testing-library/jest-dom';

// Mock window APIs
Object.defineProperty(window, 'matchMedia', {
  writable: true,
  value: jest.fn().mockImplementation(query => ({
    matches: false,
    media: query,
    addEventListener: jest.fn(),
    removeEventListener: jest.fn(),
    dispatchEvent: jest.fn(),
  })),
});

// Global test utilities
global.sleep = (ms) => new Promise(r => setTimeout(r, ms));
```

### Package.json Scripts

Add test scripts to `package.json`:

```json
{
  "scripts": {
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "test:debug": "node --inspect-brk node_modules/.bin/jest --runInBand"
  }
}
```

## Test Structure

### Basic Test Organization

Tests use three main functions:

```javascript
describe('Feature Name', () => {
  // Setup before all tests
  beforeAll(() => {
    console.log('Before all tests in this suite');
  });

  // Setup before each test
  beforeEach(() => {
    console.log('Before each test');
  });

  // Individual test
  test('should do something', () => {
    expect(true).toBe(true);
  });

  // Alternative syntax
  it('should also work', () => {
    expect(1 + 1).toBe(2);
  });

  // Cleanup after each test
  afterEach(() => {
    console.log('After each test');
  });

  // Cleanup after all tests
  afterAll(() => {
    console.log('After all tests');
  });

  // Skip this test
  test.skip('pending test', () => {
    expect(true).toBe(false);
  });

  // Run only this test
  test.only('focused test', () => {
    expect(true).toBe(true);
  });
});
```

### Nested Suites

Organize complex tests with nested `describe` blocks:

```javascript
describe('User Service', () => {
  describe('createUser', () => {
    test('should create valid user', () => { /* ... */ });
    test('should validate email', () => { /* ... */ });
  });

  describe('deleteUser', () => {
    test('should delete existing user', () => { /* ... */ });
    test('should handle non-existent user', () => { /* ... */ });
  });
});
```

### Test Scoping with Hooks

Use hooks effectively for test isolation:

```javascript
describe('Authentication', () => {
  let user;

  beforeEach(() => {
    // Fresh user for each test
    user = {
      id: 1,
      email: 'test@example.com',
      authenticated: false,
    };
  });

  test('should authenticate user', () => {
    user.authenticated = true;
    expect(user.authenticated).toBe(true);
  });

  test('each test gets fresh user', () => {
    // This user is reset, not affected by previous test
    expect(user.authenticated).toBe(false);
  });
});
```

## Assertion Matchers

### Equality Matchers

```javascript
// Exact equality (===)
expect(4).toBe(4);
expect(true).toBe(true);

// Deep equality (for objects/arrays)
expect({ a: 1 }).toEqual({ a: 1 });
expect([1, 2, 3]).toEqual([1, 2, 3]);

// NOT matchers
expect(1).not.toBe(2);
expect(x).not.toEqual(y);
```

### Truthiness Matchers

```javascript
test('truthiness', () => {
  expect(true).toBeTruthy();
  expect(false).toBeFalsy();
  expect(null).toBeNull();
  expect(undefined).toBeUndefined();
  expect(value).toBeDefined();
});
```

### Number Matchers

```javascript
test('numbers', () => {
  expect(4).toBeGreaterThan(3);
  expect(3).toBeLessThan(4);
  expect(3.14).toBeCloseTo(3.1, 1);  // 1 decimal place
  expect(0.1 + 0.2).toBeCloseTo(0.3);
});
```

### String Matchers

```javascript
test('strings', () => {
  expect('hello world').toMatch(/world/);
  expect('hello').toMatch('hello');
  expect('hello').toHaveLength(5);
});
```

### Array/Object Matchers

```javascript
test('arrays and objects', () => {
  const array = [1, 2, 3];
  expect(array).toContain(2);
  expect(array).toHaveLength(3);

  const obj = { a: 1, b: 2 };
  expect(obj).toHaveProperty('a');
  expect(obj).toHaveProperty('a', 1);

  expect(array).toMatchObject([1, 2]);
});
```

### Exception Matchers

```javascript
function throwError() {
  throw new Error('Boom!');
}

test('exceptions', () => {
  expect(throwError).toThrow();
  expect(throwError).toThrow(Error);
  expect(throwError).toThrow('Boom');
  expect(throwError).toThrow(/Boom/);
});
```

## Mocking Functions

### Basic Function Mocking

```javascript
test('mock function', () => {
  const mockFn = jest.fn();

  mockFn();
  mockFn('arg1', 'arg2');

  expect(mockFn).toHaveBeenCalled();
  expect(mockFn).toHaveBeenCalledTimes(2);
  expect(mockFn).toHaveBeenCalledWith('arg1', 'arg2');
  expect(mockFn).toHaveBeenLastCalledWith('arg1', 'arg2');
  expect(mockFn.mock.calls).toHaveLength(2);
});
```

### Return Values

```javascript
test('mock return values', () => {
  const mockFn = jest.fn()
    .mockReturnValue('success')
    .mockReturnValueOnce('first call');

  expect(mockFn()).toBe('first call');
  expect(mockFn()).toBe('success');
  expect(mockFn()).toBe('success');
});
```

### Implementations

```javascript
test('mock implementation', () => {
  const mockFn = jest.fn((a, b) => a + b);

  expect(mockFn(1, 2)).toBe(3);
  expect(mockFn).toHaveBeenCalledWith(1, 2);
});
```

### Module Mocking

```javascript
jest.mock('./api', () => ({
  fetchUser: jest.fn().mockResolvedValue({ id: 1, name: 'John' }),
  fetchPosts: jest.fn().mockRejectedValue(new Error('Network error')),
}));

import { fetchUser, fetchPosts } from './api';

test('mocked API', async () => {
  const user = await fetchUser(1);
  expect(user.name).toBe('John');
  expect(fetchUser).toHaveBeenCalledWith(1);
});
```

### Spying on Methods

```javascript
test('spy on method', () => {
  const obj = {
    method: () => 'original',
  };

  const spy = jest.spyOn(obj, 'method');
  spy.mockReturnValue('mocked');

  expect(obj.method()).toBe('mocked');
  expect(spy).toHaveBeenCalled();

  spy.mockRestore();
  expect(obj.method()).toBe('original');
});
```

## Snapshot Testing

### Basic Snapshots

```javascript
test('object snapshot', () => {
  const user = {
    id: 1,
    name: 'John Doe',
    created: new Date('2024-01-01'),
  };

  expect(user).toMatchSnapshot();
});

// First run: creates __snapshots__/test.test.js.snap
// Subsequent runs: compares against snapshot
```

### Snapshot Output Format

Generated `__snapshots__/test.test.js.snap`:

```javascript
exports[`object snapshot 1`] = `
{
  "created": 2024-01-01T00:00:00.000Z,
  "id": 1,
  "name": "John Doe",
}
`;
```

### Inline Snapshots

```javascript
test('inline snapshot', () => {
  expect({ a: 1 }).toMatchInlineSnapshot(`
    {
      "a": 1,
    }
  `);
});
```

### Snapshot Updates

When intentionally changing behavior:

```bash
jest --updateSnapshot
# or
jest -u
```

### Partial Snapshots

Compare only specific properties:

```javascript
test('partial snapshot', () => {
  const user = {
    id: 1,
    name: 'John',
    created: new Date(),
  };

  expect(user).toMatchSnapshot({
    created: expect.any(Date),
  });
});
```

## Async Testing

### Promises

```javascript
test('promise resolves', () => {
  const promise = Promise.resolve('success');
  return expect(promise).resolves.toBe('success');
});

test('promise rejects', () => {
  const promise = Promise.reject(new Error('fail'));
  return expect(promise).rejects.toThrow('fail');
});
```

### Async/Await

```javascript
test('async function', async () => {
  const result = await fetchData();
  expect(result).toEqual({ id: 1 });
});

test('async error handling', async () => {
  await expect(fetchData()).rejects.toThrow('Network error');
});
```

### Done Callback

```javascript
test('callback done', (done) => {
  fetchData((err, data) => {
    expect(data).toEqual({ id: 1 });
    done();
  });
});
```

### Timing Out

```javascript
test('timeout', async () => {
  jest.useFakeTimers();
  setTimeout(() => {
    expect(true).toBe(true);
  }, 1000);
  jest.runOnlyPendingTimers();
  jest.useRealTimers();
});
```

## Coverage Reporting

### Running Coverage

```bash
npm test -- --coverage
```

### Coverage Thresholds

Set in `jest.config.js`:

```javascript
coverageThreshold: {
  global: {
    branches: 80,      // if statements
    functions: 80,     // function declarations
    lines: 80,         // executed lines
    statements: 80,    // all statements
  },
  './src/components/': {
    lines: 90,  // Higher threshold for critical code
  },
}
```

### Coverage Output

```
-------------------------|---------|---------|---------|---------|
File                      | % Stmts | % Branch | % Funcs | % Lines |
-------------------------|---------|---------|---------|---------|
All files                 |   82.35 |   80.00 |   90.00 |   82.50 |
 src/                     |   85.71 |   83.33 |   90.00 |   85.71 |
  index.js               |   80.00 |   75.00 |   85.00 |   80.00 |
  utils.js               |   90.00 |   90.00 |  100.00 |   90.00 |
-------------------------|---------|---------|---------|---------|
```

### Excluding from Coverage

```javascript
// In jest.config.js
collectCoverageFrom: [
  'src/**/*.{js,ts}',
  '!src/index.ts',
  '!src/**/*.d.ts',
  '!src/**/__mocks__/**',
],
```

## Debugging Tests

### Debug Mode

```bash
npm run test:debug
```

Then open `chrome://inspect` in Chrome DevTools.

### console.log in Tests

```javascript
test('debug output', () => {
  const value = calculateSomething();
  console.log('Debug:', value);  // Will print when tests fail
  expect(value).toBe(expected);
});
```

### Focused Tests

Run specific test:

```bash
jest --testNamePattern="should validate email"
jest -t "validate email"
```

### Verbose Output

```bash
jest --verbose
```

### Bail on First Failure

```bash
jest --bail
jest -b
```

---

**Total Content: 850+ words covering all Jest fundamentals**

This guide provides comprehensive coverage of Jest unit testing from basic setup through advanced debugging techniques. For production projects, combine these patterns with react-testing-library for component-specific assertions.
