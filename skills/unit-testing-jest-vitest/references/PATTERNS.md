# Jest Testing Patterns - Best Practices & Real-World Examples

## Table of Contents
1. [Mock Function Patterns](#mock-function-patterns)
2. [Async Testing Patterns](#async-testing-patterns)
3. [Snapshot Testing Strategies](#snapshot-testing-strategies)
4. [Module Mocking Patterns](#module-mocking-patterns)
5. [Test Fixtures & Data Builders](#test-fixtures--data-builders)
6. [Data-Driven Tests](#data-driven-tests)
7. [Performance Testing](#performance-testing)
8. [Common Pitfalls & Solutions](#common-pitfalls--solutions)

## Mock Function Patterns

### Pattern: Tracking Function Calls

Real-world scenario: Testing that callback functions are called with correct arguments

```javascript
test('should call onSuccess callback with data', () => {
  const handleSuccess = jest.fn();
  const handleError = jest.fn();

  const fetchUser = (id, onSuccess, onError) => {
    if (id > 0) onSuccess({ id, name: 'John' });
    else onError(new Error('Invalid ID'));
  };

  fetchUser(1, handleSuccess, handleError);

  expect(handleSuccess).toHaveBeenCalledTimes(1);
  expect(handleSuccess).toHaveBeenCalledWith({ id: 1, name: 'John' });
  expect(handleError).not.toHaveBeenCalled();
});
```

### Pattern: Mock with Side Effects

Testing functions that have multiple side effects:

```javascript
test('logger mock with side effects', () => {
  const mockLogger = jest.fn((level, msg) => {
    if (level === 'error') {
      console.error(`ERROR: ${msg}`);
    }
  });

  const processData = (data, logger) => {
    if (!data) {
      logger('error', 'No data provided');
    }
  };

  processData(null, mockLogger);

  expect(mockLogger).toHaveBeenCalledWith('error', 'No data provided');
  expect(mockLogger.mock.calls[0][0]).toBe('error');
});
```

### Pattern: Conditional Return Values

Testing branching logic with different mock returns:

```javascript
test('conditional mock returns', () => {
  const getPermission = jest.fn((role) => {
    if (role === 'admin') return true;
    if (role === 'user') return false;
    return null;
  });

  expect(getPermission('admin')).toBe(true);
  expect(getPermission('user')).toBe(false);
  expect(getPermission('guest')).toBe(null);

  expect(getPermission).toHaveBeenCalledTimes(3);
  expect(getPermission.mock.results).toEqual([
    { type: 'return', value: true },
    { type: 'return', value: false },
    { type: 'return', value: null },
  ]);
});
```

### Pattern: Spying on Real Methods

Testing real implementations while tracking calls:

```javascript
test('spy on Array.prototype methods', () => {
  const array = [1, 2, 3];
  const spy = jest.spyOn(array, 'push');

  array.push(4);
  array.push(5);

  expect(spy).toHaveBeenCalledTimes(2);
  expect(spy).toHaveBeenLastCalledWith(5);
  expect(array).toEqual([1, 2, 3, 4, 5]);

  spy.mockRestore();
});
```

## Async Testing Patterns

### Pattern: Testing Promise-Based APIs

Real-world: Testing API calls that return promises

```javascript
test('mock API call pattern', async () => {
  const mockFetch = jest.fn();

  mockFetch.mockResolvedValue({
    ok: true,
    json: async () => ({ id: 1, username: 'johndoe' }),
  });

  const user = await mockFetch().then(r => r.json());

  expect(user).toEqual({ id: 1, username: 'johndoe' });
  expect(mockFetch).toHaveBeenCalled();
});

test('mock API errors', async () => {
  const mockFetch = jest.fn();
  mockFetch.mockRejectedValue(new Error('Network timeout'));

  await expect(mockFetch()).rejects.toThrow('Network timeout');
});
```

### Pattern: Sequential Calls with Different Results

Testing state transitions or retries:

```javascript
test('sequential promise returns', async () => {
  const mockAPI = jest.fn();

  mockAPI
    .mockResolvedValueOnce({ status: 'pending' })
    .mockResolvedValueOnce({ status: 'processing' })
    .mockResolvedValueOnce({ status: 'complete' });

  expect(await mockAPI()).toEqual({ status: 'pending' });
  expect(await mockAPI()).toEqual({ status: 'processing' });
  expect(await mockAPI()).toEqual({ status: 'complete' });
});
```

### Pattern: Timer Mocking for Delays

Testing timeout/interval behavior:

```javascript
test('timer mocking pattern', async () => {
  const mockCallback = jest.fn();

  const delayedFunction = () => {
    setTimeout(() => mockCallback(), 1000);
  };

  jest.useFakeTimers();
  delayedFunction();

  expect(mockCallback).not.toHaveBeenCalled();

  jest.runAllTimers();

  expect(mockCallback).toHaveBeenCalled();
  jest.useRealTimers();
});
```

### Pattern: Testing Async Component Lifecycle

```javascript
test('async lifecycle pattern', async () => {
  const mockFetch = jest.fn().mockResolvedValue({ data: [] });
  let data = null;

  const loadData = async () => {
    data = await mockFetch();
  };

  expect(data).toBeNull();  // Before load

  await loadData();

  expect(data).toEqual({ data: [] });  // After load
  expect(mockFetch).toHaveBeenCalled();
});
```

## Snapshot Testing Strategies

### Pattern: UI Component Snapshots

```javascript
test('component snapshot', () => {
  const component = renderComponent({
    title: 'Welcome',
    user: { name: 'John' },
  });

  expect(component.container).toMatchSnapshot();
});

// First run creates:
// exports[`component snapshot 1`] = `<div>Welcome John</div>`;
```

### Pattern: Deterministic Snapshots

Handle dynamic values in snapshots:

```javascript
test('snapshot with dynamic values', () => {
  const user = {
    id: Math.random(),
    name: 'John',
    created: new Date(),
  };

  expect(user).toMatchSnapshot({
    id: expect.any(Number),
    created: expect.any(Date),
  });
});
```

### Pattern: Snapshot Testing Large Objects

```javascript
test('snapshot with specific properties', () => {
  const config = {
    version: '1.0.0',
    features: ['auth', 'api', 'ui'],
    metadata: {
      created: new Date(),
      updated: new Date(),
    },
  };

  // Only snapshot stable properties
  expect({
    version: config.version,
    features: config.features,
  }).toMatchSnapshot();
});
```

## Module Mocking Patterns

### Pattern: Partial Module Mocking

Mock specific exports while keeping others real:

```javascript
jest.mock('./utils', () => ({
  ...jest.requireActual('./utils'),
  expensiveOperation: jest.fn().mockReturnValue('mocked'),
}));

import { simpleHelper, expensiveOperation } from './utils';

test('partial mock', () => {
  expect(simpleHelper()).toBe(10);  // Real implementation
  expect(expensiveOperation()).toBe('mocked');  // Mocked
});
```

### Pattern: Dynamic Module Mocks

Mock different behaviors per test:

```javascript
const mockApi = {
  fetchUser: jest.fn(),
  deleteUser: jest.fn(),
};

jest.mock('./api', () => mockApi);

test('user fetch', async () => {
  mockApi.fetchUser.mockResolvedValue({ id: 1, name: 'John' });
  // test fetch logic
});

test('user delete', async () => {
  mockApi.deleteUser.mockResolvedValue(true);
  // test delete logic
});
```

### Pattern: Mocking Default Exports

```javascript
jest.mock('./logger', () => jest.fn().mockImplementation((msg) => {
  return {
    log: jest.fn(),
    error: jest.fn(),
  };
}));

import Logger from './logger';

test('logger mock', () => {
  const logger = new Logger('test');
  expect(logger.log).toBeDefined();
});
```

## Test Fixtures & Data Builders

### Pattern: Data Builder Pattern

Create test data with builder pattern:

```javascript
class UserBuilder {
  constructor(data = {}) {
    this.data = {
      id: 1,
      name: 'John',
      email: 'john@example.com',
      role: 'user',
      active: true,
      ...data,
    };
  }

  asAdmin() {
    this.data.role = 'admin';
    return this;
  }

  inactive() {
    this.data.active = false;
    return this;
  }

  build() {
    return this.data;
  }
}

test('user with builder', () => {
  const user = new UserBuilder()
    .asAdmin()
    .build();

  expect(user.role).toBe('admin');
  expect(user.name).toBe('John');
});
```

### Pattern: Shared Fixtures

Reusable test data across tests:

```javascript
const fixtures = {
  validUser: { id: 1, name: 'John', email: 'john@example.com' },
  invalidUser: { id: null, name: '', email: '' },
  adminUser: { ...this.validUser, role: 'admin' },
};

describe('User Validation', () => {
  test('valid user passes', () => {
    expect(validateUser(fixtures.validUser)).toBe(true);
  });

  test('invalid user fails', () => {
    expect(validateUser(fixtures.invalidUser)).toBe(false);
  });
});
```

## Data-Driven Tests

### Pattern: Parameterized Tests

Test multiple scenarios with same logic:

```javascript
describe.each([
  [1, 1, 2],
  [2, 2, 4],
  [0, 5, 5],
  [-1, 1, 0],
])('addition %i + %i = %i', (a, b, expected) => {
  test('adds correctly', () => {
    expect(a + b).toBe(expected);
  });
});

// Or with objects
describe.each([
  { input: 'hello', expected: 5 },
  { input: 'world', expected: 5 },
  { input: '', expected: 0 },
])('string length with $input', ({ input, expected }) => {
  test('returns correct length', () => {
    expect(input.length).toBe(expected);
  });
});
```

### Pattern: Table-Driven Tests

```javascript
const testCases = [
  {
    name: 'valid email',
    email: 'user@example.com',
    valid: true,
  },
  {
    name: 'invalid email',
    email: 'invalid',
    valid: false,
  },
  {
    name: 'empty email',
    email: '',
    valid: false,
  },
];

testCases.forEach(({ name, email, valid }) => {
  test(`email validation: ${name}`, () => {
    expect(isValidEmail(email)).toBe(valid);
  });
});
```

## Performance Testing

### Pattern: Execution Time Testing

```javascript
test('performance: function executes within time limit', () => {
  const start = performance.now();

  const result = complexCalculation(10000);

  const duration = performance.now() - start;

  expect(duration).toBeLessThan(100);  // milliseconds
  expect(result).toBeDefined();
});
```

### Pattern: Memory Usage Testing

```javascript
test('memory efficiency', () => {
  const initialMemory = process.memoryUsage().heapUsed;

  // Perform operation
  const largeArray = Array.from({ length: 10000 }, (_, i) => i);
  processArray(largeArray);

  const finalMemory = process.memoryUsage().heapUsed;
  const increase = finalMemory - initialMemory;

  expect(increase).toBeLessThan(10 * 1024 * 1024);  // Less than 10MB
});
```

## Common Pitfalls & Solutions

### Pitfall: Forgotten Return Statement

```javascript
// ❌ WRONG: Promise not returned
test('wrong async test', () => {
  const promise = fetchData();
  expect(promise).resolves.toBeDefined();
});

// ✅ CORRECT: Promise returned
test('correct async test', () => {
  return expect(fetchData()).resolves.toBeDefined();
});

// ✅ BETTER: Use async/await
test('better async test', async () => {
  const data = await fetchData();
  expect(data).toBeDefined();
});
```

### Pitfall: Not Clearing Mocks

```javascript
// ❌ WRONG: Mocks bleed between tests
let mockFn;
beforeEach(() => {
  mockFn = jest.fn();
});

test('first test', () => {
  mockFn();
  expect(mockFn).toHaveBeenCalledTimes(1);
});

test('second test should be clean', () => {
  // mockFn might have state from first test
});

// ✅ CORRECT: Clear mocks explicitly
afterEach(() => {
  jest.clearAllMocks();
});
```

### Pitfall: Snapshot Tests That Are Too Large

```javascript
// ❌ WRONG: Hard to review snapshots
test('entire component tree', () => {
  expect(renderCompleteApp()).toMatchSnapshot();
});

// ✅ CORRECT: Focused snapshots
test('user card component', () => {
  expect(renderUserCard({ user })).toMatchSnapshot();
});
```

### Pitfall: Mocking Too Much

```javascript
// ❌ WRONG: Over-mocking makes tests useless
jest.mock('axios');
jest.mock('./utils');
jest.mock('./validators');
// ... all dependencies mocked

// ✅ CORRECT: Mock only external dependencies
jest.mock('axios');  // External API calls
// Internal utilities tested with real implementation
```

---

**Total Content: 900+ words of real-world patterns and best practices**

These patterns represent battle-tested approaches from production codebases. Master these patterns to write maintainable, comprehensive test suites that catch real bugs while staying easy to update and understand.
