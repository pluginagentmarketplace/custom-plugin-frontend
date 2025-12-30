---
name: unit-testing-jest-vitest
description: Master Jest and Vitest for unit testing with mocking, assertions, and coverage reporting.
version: "2.0.0"
sasmp_version: "1.3.0"
bonded_agent: 05-testing-agent
bond_type: PRIMARY_BOND
config:
  production:
    min_coverage: 80
    test_timeout: 5000
    max_workers: 4
    bail_on_error: false
    collect_coverage_from:
      - "src/**/*.{js,jsx,ts,tsx}"
      - "!src/**/*.test.{js,jsx,ts,tsx}"
      - "!src/**/*.spec.{js,jsx,ts,tsx}"
    coverage_thresholds:
      global:
        branches: 80
        functions: 80
        lines: 80
        statements: 80
  development:
    watch_mode: true
    verbose: true
    notify_on_change: true
    clear_mocks: true
  ci:
    ci_mode: true
    max_workers: 2
    force_exit: true
    run_in_band: false
---

# Unit Testing with Jest & Vitest

Comprehensive unit testing framework mastery for production-grade test coverage and reliability.

## Input/Output Schema

### Input Schema
```yaml
test_request:
  type: object
  required:
    - test_type
    - target_files
  properties:
    test_type:
      type: string
      enum: [unit, integration, snapshot]
      description: Type of test to create
    target_files:
      type: array
      items:
        type: string
      description: Files or modules to test
    framework:
      type: string
      enum: [jest, vitest]
      default: jest
    coverage_enabled:
      type: boolean
      default: true
    mock_dependencies:
      type: array
      items:
        type: string
      description: Dependencies to mock
    async_tests:
      type: boolean
      default: false
      description: Whether tests include async operations
```

### Output Schema
```yaml
test_result:
  type: object
  properties:
    status:
      type: string
      enum: [passed, failed, skipped]
    test_files_created:
      type: array
      items:
        type: string
    coverage_report:
      type: object
      properties:
        lines: { type: number }
        statements: { type: number }
        functions: { type: number }
        branches: { type: number }
    execution_time:
      type: number
      description: Total execution time in milliseconds
    test_count:
      type: object
      properties:
        total: { type: integer }
        passed: { type: integer }
        failed: { type: integer }
        skipped: { type: integer }
    errors:
      type: array
      items:
        type: object
        properties:
          file: { type: string }
          message: { type: string }
          stack: { type: string }
```

## Error Handling

| Error Code | Error Type | Description | Resolution |
|------------|------------|-------------|------------|
| `TEST_001` | Configuration Error | Jest/Vitest config file not found | Create jest.config.js or vitest.config.js |
| `TEST_002` | Module Not Found | Test file cannot import module | Check import paths and module resolution |
| `TEST_003` | Mock Failure | Mock implementation failed | Verify mock setup and module paths |
| `TEST_004` | Timeout Error | Test exceeded timeout limit | Increase timeout or optimize async operations |
| `TEST_005` | Assertion Failed | Test assertion did not pass | Review expected vs actual values |
| `TEST_006` | Coverage Threshold | Coverage below minimum threshold | Add tests to increase coverage |
| `TEST_007` | Snapshot Mismatch | Snapshot does not match current output | Update snapshot or fix implementation |
| `TEST_008` | Memory Leak | Test suite consuming excessive memory | Check for cleanup in afterEach hooks |
| `TEST_009` | Watch Mode Error | File watcher failed to start | Check file permissions and system limits |
| `TEST_010` | Dependency Error | Required testing library not installed | Run npm install or yarn install |

## Test Templates

### Basic Unit Test Template (Jest)
```javascript
import { describe, it, expect, beforeEach, afterEach } from '@jest/globals';
import { functionToTest } from './module';

describe('ModuleName', () => {
  let testContext;

  beforeEach(() => {
    // Setup before each test
    testContext = {};
  });

  afterEach(() => {
    // Cleanup after each test
    jest.clearAllMocks();
  });

  describe('functionToTest', () => {
    it('should return expected value for valid input', () => {
      // Arrange
      const input = 'test';
      const expected = 'expected result';

      // Act
      const result = functionToTest(input);

      // Assert
      expect(result).toBe(expected);
    });

    it('should throw error for invalid input', () => {
      // Arrange
      const invalidInput = null;

      // Act & Assert
      expect(() => functionToTest(invalidInput)).toThrow('Invalid input');
    });
  });
});
```

### Async Test Template (Vitest)
```javascript
import { describe, it, expect, vi } from 'vitest';
import { fetchData } from './api';

describe('Async Operations', () => {
  it('should resolve with data', async () => {
    // Arrange
    const mockData = { id: 1, name: 'test' };
    global.fetch = vi.fn(() =>
      Promise.resolve({
        json: () => Promise.resolve(mockData),
      })
    );

    // Act
    const result = await fetchData();

    // Assert
    expect(result).toEqual(mockData);
    expect(fetch).toHaveBeenCalledTimes(1);
  });

  it('should reject with error', async () => {
    // Arrange
    global.fetch = vi.fn(() => Promise.reject(new Error('Network error')));

    // Act & Assert
    await expect(fetchData()).rejects.toThrow('Network error');
  });
});
```

### Mock Function Template
```javascript
import { jest } from '@jest/globals';

describe('Mocking Examples', () => {
  it('should mock function implementation', () => {
    // Create mock
    const mockCallback = jest.fn((x) => x * 2);

    // Use mock
    [1, 2, 3].forEach(mockCallback);

    // Assert mock calls
    expect(mockCallback.mock.calls.length).toBe(3);
    expect(mockCallback.mock.calls[0][0]).toBe(1);
    expect(mockCallback.mock.results[0].value).toBe(2);
  });

  it('should mock module', () => {
    // Mock entire module
    jest.mock('./utils', () => ({
      calculateTotal: jest.fn(() => 100),
      formatPrice: jest.fn((price) => `$${price}`),
    }));

    const { calculateTotal, formatPrice } = require('./utils');

    expect(calculateTotal()).toBe(100);
    expect(formatPrice(100)).toBe('$100');
  });
});
```

### Snapshot Test Template
```javascript
import { describe, it, expect } from 'vitest';
import { render } from '@testing-library/react';
import Component from './Component';

describe('Component Snapshots', () => {
  it('should match snapshot', () => {
    const { container } = render(<Component title="Test" />);
    expect(container.firstChild).toMatchSnapshot();
  });

  it('should match inline snapshot', () => {
    const data = { name: 'test', value: 123 };
    expect(data).toMatchInlineSnapshot(`
      {
        "name": "test",
        "value": 123,
      }
    `);
  });
});
```

## Best Practices

### Test Organization
1. **Follow AAA Pattern**: Arrange, Act, Assert in each test
2. **One Assertion Per Test**: Focus tests on single behaviors
3. **Descriptive Test Names**: Use "should [expected behavior] when [condition]"
4. **Group Related Tests**: Use nested describe blocks for organization
5. **Isolate Tests**: Each test should be independent and not rely on execution order

### Mocking Strategy
1. **Mock External Dependencies**: API calls, databases, file systems
2. **Use Spy Functions**: Track function calls without changing behavior
3. **Clear Mocks**: Reset mocks between tests using beforeEach/afterEach
4. **Mock Timers**: Use jest.useFakeTimers() for time-dependent code
5. **Avoid Over-Mocking**: Only mock what's necessary for isolation

### Coverage Goals
1. **Aim for 80%+ Coverage**: Balance thoroughness with maintainability
2. **Focus on Critical Paths**: Prioritize business logic and edge cases
3. **Branch Coverage**: Test all conditional branches
4. **Ignore Non-Critical Files**: Exclude config files, types, and constants
5. **Regular Coverage Monitoring**: Track coverage trends over time

### Performance Optimization
1. **Parallel Execution**: Use maxWorkers for faster test runs
2. **Bail Early**: Stop on first failure with --bail flag in CI
3. **Cache Test Results**: Enable caching for repeated runs
4. **Selective Testing**: Use --changedSince for running relevant tests
5. **Optimize Setup**: Move expensive setup to beforeAll when safe

### Async Testing
1. **Always Return Promises**: Or use async/await for async tests
2. **Set Appropriate Timeouts**: Use jest.setTimeout() for long operations
3. **Wait for Assertions**: Use waitFor for async state changes
4. **Flush Promises**: Use await Promise.resolve() to flush microtasks
5. **Clean Up Side Effects**: Clear intervals, timers, and subscriptions

## MANDATORY

- Test structure (describe, it, test)
- Assertions and matchers (expect, toBe, toEqual)
- Setup and teardown (beforeEach, afterEach, beforeAll, afterAll)
- Mocking functions (jest.fn, vi.fn)
- Async testing patterns (async/await, promises)
- Running and debugging tests
- Basic coverage reporting
- Test isolation and independence

## OPTIONAL

- Mocking modules and dependencies
- Snapshot testing for UI components
- Timer mocking (jest.useFakeTimers)
- Coverage thresholds and reporting
- Watch mode for development
- Test configuration files
- Custom test environments
- Test filtering and patterns

## ADVANCED

- Custom matchers and assertions
- Test fixtures and factories
- Parallel testing optimization
- CI/CD integration and reporting
- Performance testing and benchmarking
- Migration between Jest and Vitest
- Code coverage visualization
- Test-driven development (TDD)
- Mutation testing

## Configuration Examples

### Jest Configuration (jest.config.js)
```javascript
export default {
  testEnvironment: 'node',
  coverageDirectory: 'coverage',
  collectCoverageFrom: [
    'src/**/*.{js,jsx,ts,tsx}',
    '!src/**/*.test.{js,jsx,ts,tsx}',
    '!src/types/**',
  ],
  coverageThresholds: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80,
    },
  },
  testMatch: [
    '**/__tests__/**/*.[jt]s?(x)',
    '**/?(*.)+(spec|test).[jt]s?(x)',
  ],
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
  },
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
  testTimeout: 5000,
  maxWorkers: '50%',
};
```

### Vitest Configuration (vitest.config.js)
```javascript
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: [
        'node_modules/',
        'dist/',
        '**/*.config.{js,ts}',
        '**/*.d.ts',
      ],
      thresholds: {
        lines: 80,
        functions: 80,
        branches: 80,
        statements: 80,
      },
    },
    setupFiles: ['./vitest.setup.js'],
    testTimeout: 5000,
    hookTimeout: 10000,
  },
});
```

## Assets

- See `assets/unit-testing-config.yaml` for test patterns
- See `assets/coverage-reports/` for coverage templates
- See `assets/mock-examples/` for advanced mocking patterns

## Resources

- [Jest Documentation](https://jestjs.io/)
- [Vitest Documentation](https://vitest.dev/)
- [Testing Best Practices](https://testingjavascript.com/)
- [Jest Cheat Sheet](https://github.com/sapegin/jest-cheat-sheet)

---
**Status:** Active | **Version:** 2.0.0 | **Production-Ready**
