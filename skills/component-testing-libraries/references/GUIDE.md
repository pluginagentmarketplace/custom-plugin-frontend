# React Testing Library - Complete Technical Guide

## Table of Contents
1. [Setup & Configuration](#setup--configuration)
2. [Query Methods](#query-methods)
3. [User Event Simulation](#user-event-simulation)
4. [Async Testing](#async-testing)
5. [Accessibility Testing](#accessibility-testing)
6. [Form Testing](#form-testing)
7. [API Mocking with MSW](#api-mocking-with-msw)
8. [Testing Hooks](#testing-hooks)
9. [Testing Context](#testing-context)

## Setup & Configuration

### Installation

```bash
npm install --save-dev @testing-library/react
npm install --save-dev @testing-library/user-event
npm install --save-dev @testing-library/jest-dom
```

### Configuration

Update `jest.config.js`:

```javascript
module.exports = {
  testEnvironment: 'jsdom',
  setupFilesAfterEnv: ['<rootDir>/src/setupTests.js'],
};
```

Create `src/setupTests.js`:

```javascript
import '@testing-library/jest-dom';

// Mock window.matchMedia
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
```

### Basic Test Template

```javascript
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import MyComponent from './MyComponent';

test('renders component', () => {
  render(<MyComponent />);
  expect(screen.getByRole('button')).toBeInTheDocument();
});
```

## Query Methods

### getBy* Queries

Returns element or throws error (fails test):

```javascript
test('get queries throw when not found', () => {
  render(<Button>Click me</Button>);

  // Succeeds - element found
  expect(screen.getByRole('button')).toBeInTheDocument();

  // Throws - element not found
  expect(() => screen.getByRole('button', { name: /nonexistent/ }))
    .toThrow();
});
```

### queryBy* Queries

Returns element or null (use for non-existence):

```javascript
test('query for non-existent elements', () => {
  render(<Component />);

  // Returns null instead of throwing
  const loadingText = screen.queryByText(/loading/i);
  expect(loadingText).not.toBeInTheDocument();
});
```

### findBy* Queries

Async queries that wait for element (use for async content):

```javascript
test('find async elements', async () => {
  render(<AsyncComponent />);

  // Waits for element to appear (default 1000ms timeout)
  const element = await screen.findByText(/loaded/i);
  expect(element).toBeInTheDocument();
});
```

### getAllBy*, queryAllBy*, findAllBy*

Query multiple elements:

```javascript
test('query multiple elements', () => {
  render(<List items={['A', 'B', 'C']} />);

  const items = screen.getAllByRole('listitem');
  expect(items).toHaveLength(3);
});
```

### Query Priority

Use in this order for accessibility:

```javascript
// 1. Preferred: Role-based (most accessible)
screen.getByRole('button', { name: /submit/i })

// 2. Form labels
screen.getByLabelText(/username/i)

// 3. Placeholders
screen.getByPlaceholderText(/email/i)

// 4. Visible text
screen.getByText(/welcome/i)

// 5. Alt text
screen.getByAltText(/logo/i)

// 6. Title attribute
screen.getByTitle(/help/i)

// 7. Test ID (last resort)
screen.getByTestId('component-id')
```

### Role Query Examples

```javascript
// Buttons
screen.getByRole('button', { name: /submit/i })

// Links
screen.getByRole('link', { name: /home/i })

// Inputs
screen.getByRole('textbox', { name: /username/i })
screen.getByRole('checkbox', { name: /agree/i })
screen.getByRole('combobox', { name: /select/i })

// Headers
screen.getByRole('heading', { name: /welcome/i })

// Lists
screen.getByRole('list')
screen.getByRole('listitem')
```

## User Event Simulation

### userEvent Setup

```javascript
import userEvent from '@testing-library/user-event';

test('user events', async () => {
  const user = userEvent.setup();

  render(<Form />);

  const input = screen.getByRole('textbox');
  await user.click(input);
  await user.type(input, 'hello');

  expect(input).toHaveValue('hello');
});
```

### Click Events

```javascript
const user = userEvent.setup();

// Single click
await user.click(button);

// Double click
await user.dblClick(button);

// Triple click (selects text)
await user.tripleClick(input);
```

### Type Events

```javascript
const user = userEvent.setup();
const input = screen.getByRole('textbox');

// Type text
await user.type(input, 'hello world');

// Type with delays
await user.type(input, 'text', { delay: 100 });

// Clear before typing
await user.clear(input);
await user.type(input, 'new text');
```

### Keyboard Events

```javascript
const user = userEvent.setup();

// Press single key
await user.keyboard('{Enter}');

// Press multiple keys
await user.keyboard('{Control>}a{/Control}');  // Ctrl+A

// Common shortcuts
await user.keyboard('{Tab}');       // Tab
await user.keyboard('{ArrowDown}'); // Arrow key
await user.keyboard('{Escape}');    // Escape
```

### Select Options

```javascript
const user = userEvent.setup();
const select = screen.getByRole('combobox');

await user.selectOptions(select, ['option1', 'option2']);
```

### fireEvent (Legacy)

Avoid in favor of userEvent, but still works:

```javascript
import { fireEvent } from '@testing-library/react';

fireEvent.click(button);
fireEvent.change(input, { target: { value: 'text' } });
fireEvent.submit(form);
```

## Async Testing

### waitFor Pattern

Wait for condition to be true:

```javascript
test('wait for state change', async () => {
  render(<AsyncComponent />);

  // Element appears after state update
  await waitFor(() => {
    expect(screen.getByText(/loaded/i)).toBeInTheDocument();
  });
});
```

### findBy Pattern

Cleaner alternative using findBy:

```javascript
test('find async element', async () => {
  render(<AsyncComponent />);

  // findBy waits automatically
  const element = await screen.findByText(/loaded/i);
  expect(element).toBeInTheDocument();
});
```

### Handling Promises

```javascript
test('promise resolution', async () => {
  const mockFn = jest.fn().mockResolvedValue({ data: 'success' });

  render(<Component onLoad={mockFn} />);

  const data = await mockFn();
  expect(data).toEqual({ data: 'success' });
});
```

### waitFor with Custom Timeout

```javascript
await waitFor(
  () => {
    expect(element).toBeInTheDocument();
  },
  { timeout: 3000 }
);
```

## Accessibility Testing

### Semantic HTML Priority

Always use semantic HTML:

```javascript
// ✅ Good: Semantic
<button onClick={handleClick}>Submit</button>

// ❌ Bad: Non-semantic
<div onClick={handleClick}>Submit</div>
```

### ARIA Attributes

```javascript
test('aria attributes', () => {
  render(
    <div aria-label="Loading" role="status" aria-live="polite">
      Loading...
    </div>
  );

  expect(screen.getByRole('status')).toHaveAttribute('aria-live', 'polite');
});
```

### Keyboard Navigation

```javascript
test('keyboard support', async () => {
  const user = userEvent.setup();
  render(<Dialog />);

  const closeButton = screen.getByRole('button', { name: /close/i });
  closeButton.focus();

  expect(closeButton).toHaveFocus();

  await user.keyboard('{Enter}');
  expect(screen.queryByRole('dialog')).not.toBeInTheDocument();
});
```

## Form Testing

### Input Testing

```javascript
test('input text', async () => {
  const user = userEvent.setup();
  render(<Form />);

  const input = screen.getByRole('textbox', { name: /email/i });
  await user.type(input, 'test@example.com');

  expect(input).toHaveValue('test@example.com');
});
```

### Checkbox Testing

```javascript
test('checkbox', async () => {
  const user = userEvent.setup();
  render(<Form />);

  const checkbox = screen.getByRole('checkbox', { name: /agree/i });
  expect(checkbox).not.toBeChecked();

  await user.click(checkbox);
  expect(checkbox).toBeChecked();
});
```

### Form Submission

```javascript
test('form submission', async () => {
  const handleSubmit = jest.fn();
  const user = userEvent.setup();

  render(<Form onSubmit={handleSubmit} />);

  await user.type(screen.getByRole('textbox'), 'input');
  await user.click(screen.getByRole('button', { name: /submit/i }));

  await waitFor(() => {
    expect(handleSubmit).toHaveBeenCalled();
  });
});
```

## API Mocking with MSW

### Setup MSW

```bash
npm install --save-dev msw
```

Create `src/mocks/handlers.js`:

```javascript
import { http, HttpResponse } from 'msw';

export const handlers = [
  http.get('/api/users/:id', ({ params }) => {
    return HttpResponse.json({ id: params.id, name: 'John' });
  }),

  http.post('/api/users', async ({ request }) => {
    const data = await request.json();
    return HttpResponse.json({ id: 1, ...data }, { status: 201 });
  }),

  http.delete('/api/users/:id', () => {
    return new HttpResponse(null, { status: 204 });
  }),
];
```

Create `src/mocks/server.js`:

```javascript
import { setupServer } from 'msw/node';
import { handlers } from './handlers';

export const server = setupServer(...handlers);
```

Update `src/setupTests.js`:

```javascript
import { server } from './mocks/server';

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

### Testing with MSW

```javascript
test('fetch user data', async () => {
  render(<UserProfile userId={1} />);

  const name = await screen.findByText(/John/i);
  expect(name).toBeInTheDocument();
});

test('handle API error', async () => {
  server.use(
    http.get('/api/users/:id', () => {
      return HttpResponse.json(
        { error: 'Not found' },
        { status: 404 }
      );
    })
  );

  render(<UserProfile userId={999} />);

  const error = await screen.findByText(/not found/i);
  expect(error).toBeInTheDocument();
});
```

## Testing Hooks

### useEffect Testing

```javascript
test('effect runs on mount', async () => {
  const mockFetch = jest.fn().mockResolvedValue({ data: 'test' });

  const TestComponent = () => {
    const [data, setData] = React.useState(null);

    React.useEffect(() => {
      mockFetch().then(setData);
    }, []);

    return <div>{data?.data}</div>;
  };

  render(<TestComponent />);

  expect(await screen.findByText('test')).toBeInTheDocument();
  expect(mockFetch).toHaveBeenCalled();
});
```

### useState Testing

```javascript
test('state updates', async () => {
  const user = userEvent.setup();

  const TestComponent = () => {
    const [count, setCount] = React.useState(0);
    return (
      <>
        <div>{count}</div>
        <button onClick={() => setCount(c => c + 1)}>Increment</button>
      </>
    );
  };

  render(<TestComponent />);

  expect(screen.getByText('0')).toBeInTheDocument();

  await user.click(screen.getByRole('button'));

  expect(screen.getByText('1')).toBeInTheDocument();
});
```

## Testing Context

### Context Provider Testing

```javascript
test('context values', () => {
  const TestComponent = () => {
    const value = React.useContext(MyContext);
    return <div>{value.name}</div>;
  };

  render(
    <MyContext.Provider value={{ name: 'Test' }}>
      <TestComponent />
    </MyContext.Provider>
  );

  expect(screen.getByText('Test')).toBeInTheDocument();
});
```

---

**Total Content: 1000+ words covering RTL fundamentals through advanced patterns**

This comprehensive guide covers React Testing Library from basic setup through testing hooks and context. Master these concepts for production-grade component testing.
