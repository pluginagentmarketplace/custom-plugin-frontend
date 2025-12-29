# React Testing Library Patterns - Best Practices & Real-World Examples

## Table of Contents
1. [Component Test Patterns](#component-test-patterns)
2. [Form Testing Patterns](#form-testing-patterns)
3. [Async Action Testing](#async-action-testing)
4. [MSW Mocking Patterns](#msw-mocking-patterns)
5. [React Hooks Testing](#react-hooks-testing)
6. [Context API Testing](#context-api-testing)
7. [Custom Hooks Testing](#custom-hooks-testing)
8. [Common Pitfalls & Solutions](#common-pitfalls--solutions)

## Component Test Patterns

### Pattern: Three-Step Testing (Render, Act, Assert)

Real-world: Testing a button component with callback:

```javascript
test('button click callback', async () => {
  const handleClick = jest.fn();
  const user = userEvent.setup();

  // Step 1: Render
  render(<Button onClick={handleClick}>Click me</Button>);

  // Step 2: Act (user interaction)
  await user.click(screen.getByRole('button'));

  // Step 3: Assert
  expect(handleClick).toHaveBeenCalledTimes(1);
});
```

### Pattern: Props Variation Testing

Test component behavior with different props:

```javascript
test('component variants', () => {
  const { rerender } = render(<Card variant="primary" />);
  expect(screen.getByRole('article')).toHaveClass('card--primary');

  rerender(<Card variant="secondary" />);
  expect(screen.getByRole('article')).toHaveClass('card--secondary');
});
```

### Pattern: Conditional Rendering

```javascript
test('conditional content', () => {
  const { rerender } = render(<Alert isVisible={false} />);
  expect(screen.queryByText(/alert message/i)).not.toBeInTheDocument();

  rerender(<Alert isVisible={true} />);
  expect(screen.getByText(/alert message/i)).toBeInTheDocument();
});
```

### Pattern: State Changes

```javascript
test('state-driven UI', async () => {
  const user = userEvent.setup();
  render(<Counter initialCount={0} />);

  expect(screen.getByText('0')).toBeInTheDocument();

  await user.click(screen.getByRole('button', { name: /increment/i }));
  expect(screen.getByText('1')).toBeInTheDocument();
});
```

### Pattern: Error Boundaries

```javascript
test('error boundary', () => {
  const consoleError = jest.spyOn(console, 'error').mockImplementation();

  const BadComponent = () => {
    throw new Error('Component error');
  };

  expect(() => {
    render(
      <ErrorBoundary>
        <BadComponent />
      </ErrorBoundary>
    );
  }).toThrow();

  consoleError.mockRestore();
});
```

## Form Testing Patterns

### Pattern: Complete Form Submission

Real-world scenario: User registration form

```javascript
test('user registration form', async () => {
  const handleSubmit = jest.fn();
  const user = userEvent.setup();

  render(<RegistrationForm onSubmit={handleSubmit} />);

  // Fill form fields
  await user.type(
    screen.getByRole('textbox', { name: /username/i }),
    'johndoe'
  );

  await user.type(
    screen.getByRole('textbox', { name: /email/i }),
    'john@example.com'
  );

  await user.type(
    screen.getByLabelText(/password/i),
    'SecurePassword123'
  );

  // Accept terms
  await user.click(
    screen.getByRole('checkbox', { name: /agree to terms/i })
  );

  // Submit
  await user.click(
    screen.getByRole('button', { name: /register/i })
  );

  expect(handleSubmit).toHaveBeenCalledWith({
    username: 'johndoe',
    email: 'john@example.com',
    password: 'SecurePassword123',
    agreedToTerms: true,
  });
});
```

### Pattern: Form Validation

```javascript
test('form validation', async () => {
  const user = userEvent.setup();
  render(<LoginForm />);

  const submitButton = screen.getByRole('button', { name: /login/i });
  await user.click(submitButton);

  // Shows validation errors
  expect(screen.getByText(/email is required/i)).toBeInTheDocument();
  expect(screen.getByText(/password is required/i)).toBeInTheDocument();

  // Fill form
  await user.type(screen.getByRole('textbox'), 'test@example.com');
  await user.type(screen.getByLabelText(/password/i), 'password123');

  // Errors disappear
  await waitFor(() => {
    expect(screen.queryByText(/email is required/i)).not.toBeInTheDocument();
  });
});
```

### Pattern: Select/Dropdown

```javascript
test('dropdown selection', async () => {
  const user = userEvent.setup();
  render(<CountrySelector onChange={jest.fn()} />);

  const select = screen.getByRole('combobox', { name: /country/i });

  // Select multiple options
  await user.selectOptions(select, ['USA', 'Canada']);

  // Verify selections
  const options = select.querySelectorAll('option:checked');
  expect(options).toHaveLength(2);
});
```

### Pattern: Radio Buttons

```javascript
test('radio selection', async () => {
  const user = userEvent.setup();
  render(<ShippingMethod />);

  const standardRadio = screen.getByRole('radio', { name: /standard/i });
  const expressRadio = screen.getByRole('radio', { name: /express/i });

  expect(standardRadio).toBeChecked();
  expect(expressRadio).not.toBeChecked();

  await user.click(expressRadio);

  expect(standardRadio).not.toBeChecked();
  expect(expressRadio).toBeChecked();
});
```

## Async Action Testing

### Pattern: Loading States

```javascript
test('loading state transitions', async () => {
  const user = userEvent.setup();
  render(<DataLoader />);

  // Initial state
  expect(screen.getByText(/click to load/i)).toBeInTheDocument();

  // Click to load
  await user.click(screen.getByRole('button'));

  // Loading state appears
  expect(screen.getByText(/loading/i)).toBeInTheDocument();
  expect(screen.queryByText(/data:/i)).not.toBeInTheDocument();

  // Data appears after loading
  const data = await screen.findByText(/data: success/i);
  expect(data).toBeInTheDocument();
  expect(screen.queryByText(/loading/i)).not.toBeInTheDocument();
});
```

### Pattern: Error Handling

```javascript
test('async error handling', async () => {
  const user = userEvent.setup();
  render(<FileUpload />);

  const file = new File(['content'], 'test.txt', { type: 'text/plain' });
  const input = screen.getByRole('textbox');

  await user.upload(input, file);
  await user.click(screen.getByRole('button', { name: /upload/i }));

  // Error message appears
  const error = await screen.findByText(/invalid file type/i);
  expect(error).toBeInTheDocument();
  expect(error).toHaveClass('error');
});
```

### Pattern: Polling/Retry

```javascript
test('retry on failure', async () => {
  const mockFetch = jest.fn();
  mockFetch
    .mockRejectedValueOnce(new Error('Network error'))
    .mockResolvedValueOnce({ data: 'success' });

  render(<RetryComponent onFetch={mockFetch} />);

  await user.click(screen.getByRole('button', { name: /fetch/i }));

  // Initial failure
  expect(screen.getByText(/error/i)).toBeInTheDocument();

  // Click retry
  await user.click(screen.getByRole('button', { name: /retry/i }));

  // Success after retry
  const success = await screen.findByText(/success/i);
  expect(success).toBeInTheDocument();
  expect(mockFetch).toHaveBeenCalledTimes(2);
});
```

## MSW Mocking Patterns

### Pattern: Mocking GET Request

```javascript
import { http, HttpResponse } from 'msw';
import { setupServer } from 'msw/node';

const server = setupServer(
  http.get('/api/users/:id', ({ params }) => {
    return HttpResponse.json({
      id: params.id,
      name: 'John Doe',
      email: 'john@example.com',
    });
  })
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

test('fetch user', async () => {
  render(<UserProfile userId="1" />);

  const name = await screen.findByText('John Doe');
  expect(name).toBeInTheDocument();
});
```

### Pattern: Mocking POST Request

```javascript
http.post('/api/users', async ({ request }) => {
  const body = await request.json();

  // Validate request
  if (!body.email) {
    return HttpResponse.json(
      { error: 'Email required' },
      { status: 400 }
    );
  }

  return HttpResponse.json(
    { id: 1, ...body },
    { status: 201 }
  );
});

test('create user', async () => {
  const user = userEvent.setup();
  render(<CreateUserForm />);

  await user.type(screen.getByRole('textbox', { name: /email/i }), 'test@example.com');
  await user.click(screen.getByRole('button', { name: /create/i }));

  const success = await screen.findByText(/user created/i);
  expect(success).toBeInTheDocument();
});
```

### Pattern: Request Interception

```javascript
test('intercept and override handler', async () => {
  server.use(
    http.get('/api/users/:id', () => {
      return HttpResponse.json({ name: 'Mocked User' });
    })
  );

  render(<UserProfile userId="1" />);

  const name = await screen.findByText('Mocked User');
  expect(name).toBeInTheDocument();
});
```

## React Hooks Testing

### Pattern: useState Hook

```javascript
test('usestate hook', async () => {
  const user = userEvent.setup();

  const Component = () => {
    const [count, setCount] = React.useState(0);
    return (
      <>
        <div>Count: {count}</div>
        <button onClick={() => setCount(c => c + 1)}>+</button>
        <button onClick={() => setCount(c => c - 1)}>-</button>
      </>
    );
  };

  render(<Component />);

  expect(screen.getByText('Count: 0')).toBeInTheDocument();

  await user.click(screen.getByRole('button', { name: '+' }));
  expect(screen.getByText('Count: 1')).toBeInTheDocument();

  await user.click(screen.getByRole('button', { name: '-' }));
  expect(screen.getByText('Count: 0')).toBeInTheDocument();
});
```

### Pattern: useEffect Hook

```javascript
test('useeffect hook', async () => {
  const mockFetch = jest.fn().mockResolvedValue({ data: 'loaded' });

  const Component = () => {
    const [data, setData] = React.useState(null);

    React.useEffect(() => {
      mockFetch().then(setData);
    }, []);

    return <div>{data?.data || 'loading...'}</div>;
  };

  render(<Component />);

  expect(screen.getByText('loading...')).toBeInTheDocument();

  const loaded = await screen.findByText('loaded');
  expect(loaded).toBeInTheDocument();
  expect(mockFetch).toHaveBeenCalledTimes(1);
});
```

### Pattern: useReducer Hook

```javascript
test('usereducer hook', async () => {
  const user = userEvent.setup();

  const Component = () => {
    const [state, dispatch] = React.useReducer(
      (s, a) => ({ ...s, [a.type]: a.payload }),
      { count: 0 }
    );

    return (
      <>
        <div>Count: {state.count}</div>
        <button onClick={() => dispatch({ type: 'increment', payload: 1 })}>+</button>
      </>
    );
  };

  render(<Component />);

  await user.click(screen.getByRole('button'));

  expect(screen.getByText('Count: 1')).toBeInTheDocument();
});
```

## Context API Testing

### Pattern: Provider Wrapper

```javascript
test('context provider', () => {
  const TestComponent = () => {
    const value = React.useContext(ThemeContext);
    return <div style={{ color: value.color }}>Themed</div>;
  };

  const wrapper = ({ children }) => (
    <ThemeContext.Provider value={{ color: 'blue' }}>
      {children}
    </ThemeContext.Provider>
  );

  render(<TestComponent />, { wrapper });

  const element = screen.getByText('Themed');
  expect(element).toHaveStyle('color: blue');
});
```

## Common Pitfalls & Solutions

### Pitfall: Forgetting to await userEvent

```javascript
// ❌ WRONG: Not awaiting user interaction
test('wrong timing', () => {
  const user = userEvent.setup();
  render(<Form />);

  user.click(screen.getByRole('button'));
  expect(mockFn).toHaveBeenCalled();  // May fail!
});

// ✅ CORRECT: Await user interactions
test('correct timing', async () => {
  const user = userEvent.setup();
  render(<Form />);

  await user.click(screen.getByRole('button'));
  expect(mockFn).toHaveBeenCalled();
});
```

### Pitfall: Using testId Everywhere

```javascript
// ❌ WRONG: Over-relying on testId
test('testid overuse', () => {
  render(<Button>Click</Button>);
  expect(screen.getByTestId('btn-123')).toBeInTheDocument();
});

// ✅ CORRECT: Use accessible queries
test('accessible queries', () => {
  render(<Button>Click</Button>);
  expect(screen.getByRole('button', { name: /click/i })).toBeInTheDocument();
});
```

### Pitfall: Missing waitFor for Async

```javascript
// ❌ WRONG: Not waiting for async content
test('missing wait', async () => {
  render(<AsyncComponent />);
  expect(screen.getByText(/loaded/i)).toBeInTheDocument();  // May fail!
});

// ✅ CORRECT: Using findBy or waitFor
test('correct wait', async () => {
  render(<AsyncComponent />);
  expect(await screen.findByText(/loaded/i)).toBeInTheDocument();
});
```

### Pitfall: Not Cleaning Between Tests

```javascript
// ❌ WRONG: State leaks between tests
let count = 0;
test('first', () => {
  count++;
  expect(count).toBe(1);
});

test('second', () => {
  expect(count).toBe(1);  // count is 1, not 0!
});

// ✅ CORRECT: Reset state
let count;
beforeEach(() => {
  count = 0;
});

test('first', () => {
  count++;
  expect(count).toBe(1);
});

test('second', () => {
  expect(count).toBe(0);
});
```

---

**Total Content: 1000+ words of real-world patterns**

These patterns represent solutions to common testing scenarios. Master them to write robust, maintainable React component tests that catch real bugs and stay readable as components evolve.
