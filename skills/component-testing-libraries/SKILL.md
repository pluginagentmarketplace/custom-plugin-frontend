---
name: component-testing-libraries
description: Master React Testing Library, Vue Test Utils, and user-centric testing approaches.
version: "2.0.0"
sasmp_version: "1.3.0"
bonded_agent: 05-testing-agent
bond_type: SECONDARY_BOND
config:
  production:
    test_environment: jsdom
    auto_cleanup: true
    configure_timeout: 5000
    async_timeout: 3000
    query_fallbacks: false
    suggest_queries: true
    debug_options:
      pretty_dom: true
      max_length: 7000
  development:
    watch_mode: true
    verbose: true
    show_debug_info: true
    highlight_matches: true
  accessibility:
    check_aria_roles: true
    check_labels: true
    warn_on_inaccessible: true
    prefer_accessible_queries: true
---

# Component Testing Libraries

User-centric component testing for React, Vue, and modern frameworks with accessibility-first approaches.

## Input/Output Schema

### Input Schema
```yaml
component_test_request:
  type: object
  required:
    - component_path
    - test_type
    - framework
  properties:
    component_path:
      type: string
      description: Path to component file to test
    test_type:
      type: string
      enum: [render, interaction, accessibility, integration]
      description: Type of component test
    framework:
      type: string
      enum: [react, vue, svelte, solid]
      description: UI framework being tested
    props:
      type: object
      description: Props to pass to component
    user_interactions:
      type: array
      items:
        type: object
        properties:
          type:
            type: string
            enum: [click, type, select, hover, focus, blur]
          target:
            type: string
            description: Query selector for element
          value:
            type: string
            description: Value for input events
    assertions:
      type: array
      items:
        type: object
        properties:
          query:
            type: string
            description: Query to find element
          expectation:
            type: string
            description: What to assert about element
    accessibility_checks:
      type: boolean
      default: true
```

### Output Schema
```yaml
component_test_result:
  type: object
  properties:
    status:
      type: string
      enum: [passed, failed, skipped]
    test_file_path:
      type: string
    rendered_output:
      type: string
      description: Debug output of rendered component
    queries_used:
      type: array
      items:
        type: object
        properties:
          query_type: { type: string }
          selector: { type: string }
          found: { type: boolean }
    user_events_executed:
      type: array
      items:
        type: string
    assertions_results:
      type: array
      items:
        type: object
        properties:
          description: { type: string }
          passed: { type: boolean }
          expected: { type: string }
          actual: { type: string }
    accessibility_violations:
      type: array
      items:
        type: object
        properties:
          rule: { type: string }
          severity: { type: string }
          element: { type: string }
          message: { type: string }
    execution_time:
      type: number
      description: Test execution time in milliseconds
```

## Error Handling

| Error Code | Error Type | Description | Resolution |
|------------|------------|-------------|------------|
| `COMP_001` | Element Not Found | Query did not find element | Use screen.debug() to inspect DOM, check selector |
| `COMP_002` | Multiple Elements | Query returned multiple elements | Use more specific query or getAllBy variant |
| `COMP_003` | Timeout Error | Async query timed out waiting | Increase timeout or check if element appears |
| `COMP_004` | User Event Failed | User interaction could not execute | Verify element is visible and not disabled |
| `COMP_005` | Render Error | Component failed to render | Check component props and dependencies |
| `COMP_006` | Accessibility Violation | Element fails accessibility check | Add proper ARIA labels and semantic HTML |
| `COMP_007` | Context Missing | Component requires context provider | Wrap render with necessary providers |
| `COMP_008` | Wrong Query Type | Using incorrect query variant | Use getBy for present, queryBy for absence, findBy for async |
| `COMP_009` | Cleanup Error | Component cleanup failed | Add proper cleanup in afterEach or unmount |
| `COMP_010` | Mock State Error | State management mock failed | Verify store/context mock setup |

## Test Templates

### Basic Component Render Test (React Testing Library)
```javascript
import { render, screen } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import Button from './Button';

describe('Button Component', () => {
  it('should render with provided text', () => {
    // Arrange
    render(<Button>Click me</Button>);

    // Act
    const button = screen.getByRole('button', { name: /click me/i });

    // Assert
    expect(button).toBeInTheDocument();
    expect(button).toHaveTextContent('Click me');
  });

  it('should apply variant styles', () => {
    // Arrange
    render(<Button variant="primary">Submit</Button>);

    // Act
    const button = screen.getByRole('button', { name: /submit/i });

    // Assert
    expect(button).toHaveClass('btn-primary');
  });
});
```

### User Interaction Test
```javascript
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, it, expect, vi } from 'vitest';
import SearchForm from './SearchForm';

describe('SearchForm Interactions', () => {
  it('should call onSubmit with input value', async () => {
    // Arrange
    const user = userEvent.setup();
    const mockOnSubmit = vi.fn();
    render(<SearchForm onSubmit={mockOnSubmit} />);

    // Act
    const input = screen.getByRole('textbox', { name: /search/i });
    await user.type(input, 'test query');

    const submitButton = screen.getByRole('button', { name: /search/i });
    await user.click(submitButton);

    // Assert
    expect(mockOnSubmit).toHaveBeenCalledWith('test query');
    expect(mockOnSubmit).toHaveBeenCalledTimes(1);
  });

  it('should validate empty input', async () => {
    // Arrange
    const user = userEvent.setup();
    const mockOnSubmit = vi.fn();
    render(<SearchForm onSubmit={mockOnSubmit} />);

    // Act
    const submitButton = screen.getByRole('button', { name: /search/i });
    await user.click(submitButton);

    // Assert
    expect(screen.getByText(/search term is required/i)).toBeInTheDocument();
    expect(mockOnSubmit).not.toHaveBeenCalled();
  });
});
```

### Async Component Test
```javascript
import { render, screen, waitFor } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import UserProfile from './UserProfile';

describe('UserProfile Async Loading', () => {
  it('should display loading state then user data', async () => {
    // Arrange
    const mockUser = { id: 1, name: 'John Doe', email: 'john@example.com' };
    global.fetch = vi.fn(() =>
      Promise.resolve({
        json: () => Promise.resolve(mockUser),
      })
    );

    // Act
    render(<UserProfile userId={1} />);

    // Assert - Loading state
    expect(screen.getByText(/loading/i)).toBeInTheDocument();

    // Assert - Data loaded
    await waitFor(() => {
      expect(screen.getByText('John Doe')).toBeInTheDocument();
    });
    expect(screen.getByText('john@example.com')).toBeInTheDocument();
    expect(screen.queryByText(/loading/i)).not.toBeInTheDocument();
  });

  it('should display error message on fetch failure', async () => {
    // Arrange
    global.fetch = vi.fn(() => Promise.reject(new Error('API Error')));

    // Act
    render(<UserProfile userId={1} />);

    // Assert
    await waitFor(() => {
      expect(screen.getByText(/error loading user/i)).toBeInTheDocument();
    });
  });
});
```

### Context Provider Test
```javascript
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, it, expect } from 'vitest';
import { ThemeProvider } from './ThemeContext';
import ThemedButton from './ThemedButton';

// Custom render with providers
const renderWithTheme = (ui, { theme = 'light', ...options } = {}) => {
  return render(
    <ThemeProvider initialTheme={theme}>
      {ui}
    </ThemeProvider>,
    options
  );
};

describe('ThemedButton with Context', () => {
  it('should render with light theme styles', () => {
    // Arrange & Act
    renderWithTheme(<ThemedButton>Click</ThemedButton>, { theme: 'light' });

    // Assert
    const button = screen.getByRole('button', { name: /click/i });
    expect(button).toHaveClass('theme-light');
  });

  it('should toggle theme on click', async () => {
    // Arrange
    const user = userEvent.setup();
    renderWithTheme(<ThemedButton>Toggle</ThemedButton>, { theme: 'light' });

    // Act
    const button = screen.getByRole('button', { name: /toggle/i });
    await user.click(button);

    // Assert
    expect(button).toHaveClass('theme-dark');
  });
});
```

### Accessibility Test
```javascript
import { render, screen } from '@testing-library/react';
import { axe, toHaveNoViolations } from 'jest-axe';
import { describe, it, expect } from 'vitest';
import FormField from './FormField';

expect.extend(toHaveNoViolations);

describe('FormField Accessibility', () => {
  it('should have no accessibility violations', async () => {
    // Arrange
    const { container } = render(
      <FormField
        label="Email Address"
        id="email"
        type="email"
        required
      />
    );

    // Act
    const results = await axe(container);

    // Assert
    expect(results).toHaveNoViolations();
  });

  it('should have proper ARIA attributes', () => {
    // Arrange
    render(
      <FormField
        label="Password"
        id="password"
        type="password"
        error="Password is required"
      />
    );

    // Act
    const input = screen.getByLabelText(/password/i);

    // Assert
    expect(input).toHaveAttribute('aria-invalid', 'true');
    expect(input).toHaveAttribute('aria-describedby');
    expect(screen.getByRole('alert')).toHaveTextContent('Password is required');
  });

  it('should be keyboard navigable', async () => {
    // Arrange
    const user = userEvent.setup();
    render(<FormField label="Username" id="username" />);

    // Act
    const input = screen.getByLabelText(/username/i);
    await user.tab();

    // Assert
    expect(input).toHaveFocus();
  });
});
```

### Vue Component Test (Vue Test Utils)
```javascript
import { mount } from '@vue/test-utils';
import { describe, it, expect, vi } from 'vitest';
import Counter from './Counter.vue';

describe('Counter Component (Vue)', () => {
  it('should increment count on button click', async () => {
    // Arrange
    const wrapper = mount(Counter, {
      props: { initialCount: 0 }
    });

    // Act
    await wrapper.find('button.increment').trigger('click');

    // Assert
    expect(wrapper.find('.count').text()).toBe('1');
    expect(wrapper.emitted('update')).toBeTruthy();
    expect(wrapper.emitted('update')[0]).toEqual([1]);
  });

  it('should render with slot content', () => {
    // Arrange
    const wrapper = mount(Counter, {
      slots: {
        default: '<span>Custom Label</span>'
      }
    });

    // Assert
    expect(wrapper.html()).toContain('Custom Label');
  });
});
```

## Best Practices

### Query Selection Priority
1. **getByRole**: Most accessible queries (button, textbox, heading, etc.)
2. **getByLabelText**: Form fields with associated labels
3. **getByPlaceholderText**: When label is not available
4. **getByText**: Non-interactive content
5. **getByDisplayValue**: Current value of form element
6. **getByAltText**: Images with alt text
7. **getByTitle**: Elements with title attribute
8. **getByTestId**: Last resort when no semantic query works

### Query Variants
- **getBy**: Throws error if not found (use for elements that should exist)
- **queryBy**: Returns null if not found (use for asserting absence)
- **findBy**: Returns promise, waits for element (use for async elements)
- **getAllBy/queryAllBy/findAllBy**: Return arrays for multiple elements

### User Interaction Best Practices
1. **Use userEvent over fireEvent**: More realistic browser behavior
2. **Setup userEvent per test**: `const user = userEvent.setup()`
3. **Await all interactions**: User events are async
4. **Test keyboard navigation**: Ensure Tab, Enter, Escape work
5. **Test focus management**: Verify focus moves appropriately

### Async Testing
1. **Use waitFor**: For assertions that need to wait
2. **Use findBy queries**: Built-in waiting for elements
3. **Avoid act warnings**: Ensure all state updates are wrapped
4. **Set appropriate timeouts**: Default is 1000ms
5. **Clean up async operations**: Prevent memory leaks

### Accessibility Testing
1. **Query by role first**: Ensures semantic HTML
2. **Add jest-axe**: Automated accessibility testing
3. **Test keyboard navigation**: Tab, Space, Enter, Escape
4. **Check ARIA attributes**: Required, invalid, describedby
5. **Test screen reader experience**: Use accessible queries

### Component Isolation
1. **Mock external dependencies**: APIs, contexts, routers
2. **Use custom render functions**: Include necessary providers
3. **Mock child components**: Test one component at a time
4. **Control component state**: Set predictable initial states
5. **Clean up after tests**: Prevent test pollution

## MANDATORY

- Rendering components with proper setup
- Querying elements (getBy, queryBy, findBy variants)
- User events simulation (click, type, select)
- Async assertions with waitFor
- Testing Library principles (test user behavior, not implementation)
- Accessibility-first testing with semantic queries
- Basic form and interaction testing
- Debug utilities for troubleshooting

## OPTIONAL

- Testing React hooks with renderHook
- Testing context providers and custom providers
- Complex form testing with validation
- Custom render functions with providers
- Debug utilities (screen.debug, logRoles)
- Snapshot testing for components
- Testing error boundaries
- Testing with React Router or Vue Router

## ADVANCED

- Testing complex user interactions and flows
- Component performance testing
- Testing with Mock Service Worker (MSW)
- Custom queries and matchers
- Testing portals and modals
- Testing drag-and-drop interactions
- Migration from Enzyme to Testing Library
- Visual regression testing integration
- Testing with WebSockets and real-time data

## Configuration Examples

### React Testing Library Setup
```javascript
// vitest.setup.js
import '@testing-library/jest-dom';
import { cleanup } from '@testing-library/react';
import { afterEach } from 'vitest';

// Cleanup after each test
afterEach(() => {
  cleanup();
});

// Mock window.matchMedia
Object.defineProperty(window, 'matchMedia', {
  writable: true,
  value: vi.fn().mockImplementation(query => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: vi.fn(),
    removeListener: vi.fn(),
    addEventListener: vi.fn(),
    removeEventListener: vi.fn(),
    dispatchEvent: vi.fn(),
  })),
});
```

### Vue Test Utils Configuration
```javascript
// vitest.config.js
import { defineConfig } from 'vitest/config';
import vue from '@vitejs/plugin-vue';

export default defineConfig({
  plugins: [vue()],
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./vitest.setup.js'],
  },
});
```

### Custom Render Function
```javascript
// test-utils.jsx
import { render } from '@testing-library/react';
import { BrowserRouter } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ThemeProvider } from './ThemeContext';

const AllTheProviders = ({ children }) => {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: { retry: false },
    },
  });

  return (
    <BrowserRouter>
      <QueryClientProvider client={queryClient}>
        <ThemeProvider>
          {children}
        </ThemeProvider>
      </QueryClientProvider>
    </BrowserRouter>
  );
};

const customRender = (ui, options) =>
  render(ui, { wrapper: AllTheProviders, ...options });

export * from '@testing-library/react';
export { customRender as render };
```

## Assets

- See `assets/component-testing-config.yaml` for patterns
- See `assets/custom-render-examples/` for provider setups
- See `assets/accessibility-tests/` for a11y test examples

## Resources

- [React Testing Library](https://testing-library.com/react)
- [Vue Test Utils](https://test-utils.vuejs.org/)
- [Testing Library Cheat Sheet](https://testing-library.com/docs/react-testing-library/cheatsheet)
- [Common Mistakes](https://kentcdodds.com/blog/common-mistakes-with-react-testing-library)
- [jest-axe for Accessibility](https://github.com/nickcolley/jest-axe)

---
**Status:** Active | **Version:** 2.0.0 | **Production-Ready**
