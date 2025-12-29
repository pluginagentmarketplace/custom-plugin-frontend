# React Testing Library Scripts

This directory contains scripts for validating and generating React Testing Library test files.

## Available Scripts

### validate-rtl.sh
Validates React Testing Library setup and test patterns:
- Checks for RTL queries (getByRole, queryByText, findByTestId)
- Validates proper async patterns (waitFor, findBy)
- Verifies user-centric testing principles
- Checks for accessibility queries (getByRole preferred over getByTestId)
- Reports on test file structure and patterns

**Usage:**
```bash
./scripts/validate-rtl.sh [path-to-project]
```

### generate-rtl-test.sh
Generates React Testing Library test boilerplate:
- Creates component test file with RTL setup
- Includes query examples (getByRole, queryByText, findByTestId)
- Adds user event patterns
- Sets up async waiting patterns (waitFor, findBy)
- Includes accessibility testing examples

**Usage:**
```bash
./scripts/generate-rtl-test.sh [component-name]
```

## Examples

```bash
# Validate existing React project
./scripts/validate-rtl.sh ~/my-react-app

# Generate test for Button component
./scripts/generate-rtl-test.sh Button

# Generate test for Form component
./scripts/generate-rtl-test.sh Form
```

## Dependencies

- `@testing-library/react` - Core RTL library
- `@testing-library/jest-dom` - Custom matchers
- `@testing-library/user-event` - User interaction simulation
- `jest` - Test runner

## Common Patterns

### Query Selection
- `getByRole()` - Preferred, most accessible
- `getByLabelText()` - For form inputs
- `getByText()` - For text content
- `getByTestId()` - Last resort, use sparingly
- `queryBy*()` - For non-existence assertions
- `findBy*()` - For async/appearing elements

### User Interactions
- `userEvent.click()` - Click events
- `userEvent.type()` - Text input
- `userEvent.keyboard()` - Keyboard events
- `userEvent.selectOptions()` - Select dropdowns

### Async Waiting
- `waitFor()` - Wait for condition
- `findBy*()` - Query that waits
- `screen.findByRole()` - Async role query
