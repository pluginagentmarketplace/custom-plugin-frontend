# React Testing Library References

Comprehensive guides for testing React components with a focus on user-centric testing.

## Contents

### GUIDE.md
Complete technical guide covering:
- React Testing Library fundamentals
- Query methods (getBy, queryBy, findBy, getAllBy variants)
- User interaction simulation (userEvent vs fireEvent)
- Async testing patterns (waitFor, findBy)
- Accessibility testing best practices
- Form testing strategies
- API mocking with Mock Service Worker
- Custom hooks testing
- Testing Context providers
- Testing custom React hooks

**Target:** Master RTL fundamentals and advanced patterns
**Read Time:** 25-35 minutes

### PATTERNS.md
Real-world patterns and best practices:
- Component test patterns (render, interact, assert)
- Form testing patterns (inputs, selects, validation)
- Async action testing (API calls, loading states)
- MSW mocking patterns
- React Hooks testing patterns
- Context API testing patterns
- Custom hooks testing patterns
- Common pitfalls and solutions

**Target:** Apply RTL effectively in production
**Read Time:** 25-35 minutes

## Quick Navigation

| Topic | Reference |
|-------|-----------|
| Setting up RTL | GUIDE.md - Setup |
| Query selection | GUIDE.md - Query Methods |
| User interactions | GUIDE.md - User Events |
| Testing async code | GUIDE.md - Async Testing |
| Component patterns | PATTERNS.md - Component Tests |
| Form testing | PATTERNS.md - Form Patterns |
| API mocking | PATTERNS.md - MSW Patterns |
| Testing hooks | PATTERNS.md - Hooks Patterns |

## Key Concepts

### Query Selection Priority
```
1. getByRole()          - Most accessible
2. getByLabelText()     - For form inputs
3. getByPlaceholder()   - For inputs
4. getByText()          - For visible text
5. getByTestId()        - Last resort
```

### User Event Setup
```javascript
const user = userEvent.setup();
await user.click(element);
await user.type(input, 'text');
await user.selectOptions(select, 'option');
```

### Async Patterns
```javascript
const element = await screen.findByRole('button');
await waitFor(() => expect(element).toBeInTheDocument());
await user.click(button);
```

## Files in This Directory

```
references/
├── README.md          (this file)
├── GUIDE.md          (technical guide - 600+ words)
└── PATTERNS.md       (patterns & examples - 600+ words)
```

## Learning Path

1. **Start here:** GUIDE.md - Setup section
2. **Understand queries:** Query Methods section
3. **Learn interactions:** User Events section
4. **Master async:** Async Testing section
5. **Apply patterns:** PATTERNS.md for real scenarios

## Principles

- **User-Centric:** Test from user's perspective, not implementation
- **Accessibility First:** Queries that work with accessibility tools
- **Realistic:** Use userEvent (not fireEvent) for user interactions
- **Async-Aware:** Handle async operations correctly
- **Maintainable:** Avoid brittle tests with testId

## External Resources

- [React Testing Library Official Docs](https://testing-library.com/docs/react-testing-library/intro)
- [Testing Playground](https://testing-playground.com/) - Find the right query
- [Screen Queries Cheatsheet](https://testing-library.com/docs/queries/about)
- [Kent Dodds Testing Principles](https://kentcdodds.com/blog/common-mistakes-with-react-testing-library)

## Related Skills

- jest-unit-testing: Jest framework fundamentals
- code-quality-tools: Quality beyond tests
- e2e-testing-cypress: End-to-end testing

---

**Version:** 2.0.0 | **Last Updated:** 2025-12-28
