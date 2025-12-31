---
name: react-fundamentals
description: Master React fundamentals - components, JSX, state, props, and hooks for building modern user interfaces.
sasmp_version: "1.3.0"
bonded_agent: frameworks
bond_type: PRIMARY_BOND

# Production Configuration
validation:
  input_schema: true
  output_schema: true
  type_checking: strict

retry_logic:
  max_attempts: 3
  backoff: exponential
  initial_delay_ms: 1000

logging:
  level: INFO
  observability: true
  performance_tracking: true
---

# React Fundamentals

> **Purpose:** Build modern, performant user interfaces with React's component-based architecture.

## Input/Output Schema

```typescript
interface ReactSkillInput {
  concept: 'components' | 'hooks' | 'state' | 'props' | 'events' | 'lifecycle';
  level: 'beginner' | 'intermediate' | 'advanced';
  codeContext?: string;
}

interface ReactSkillOutput {
  explanation: string;
  codeExample: string;
  bestPractices: string[];
  commonMistakes: string[];
}
```

## MANDATORY
- JSX syntax and expressions
- Functional components with TypeScript
- Props with proper typing (interface/type)
- State with useState hook
- Event handling (onClick, onChange, onSubmit)
- Conditional rendering (ternary, &&, early return)
- Lists and keys (unique, stable keys)

## OPTIONAL
- Class components (legacy migration)
- Context API basics
- Refs and DOM access (useRef)
- Fragments and portals
- Error boundaries
- Higher-order components (HOC)

## ADVANCED
- Custom hooks development
- Performance optimization (useMemo, useCallback, React.memo)
- Concurrent features (useTransition, useDeferredValue)
- Server components (React 19)
- Suspense patterns
- React DevTools profiling

## Error Handling

| Error | Root Cause | Solution |
|-------|------------|----------|
| `Objects not valid as child` | Rendering object directly | Use JSON.stringify or map properties |
| `Each child needs unique key` | Missing/duplicate keys | Use stable unique identifiers |
| `Too many re-renders` | State update in render | Move state update to useEffect |
| `Cannot update unmounted` | Async after unmount | Add cleanup in useEffect |

## Test Template

```typescript
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MyComponent } from './MyComponent';

describe('MyComponent', () => {
  it('renders with default props', () => {
    render(<MyComponent title="Test" />);
    expect(screen.getByText('Test')).toBeInTheDocument();
  });

  it('handles user interaction', async () => {
    const user = userEvent.setup();
    render(<MyComponent />);

    await user.click(screen.getByRole('button'));
    expect(screen.getByText('Clicked')).toBeInTheDocument();
  });
});
```

## Best Practices
- Prefer functional components over class components
- Use TypeScript for type safety
- Keep components small and focused
- Lift state up when needed
- Use composition over inheritance

## Resources
- [React Docs](https://react.dev/)
- [React TypeScript Cheatsheet](https://react-typescript-cheatsheet.netlify.app/)

---
**Status:** Active | **Version:** 2.0.0
