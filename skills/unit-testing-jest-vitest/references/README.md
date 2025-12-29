# Jest Unit Testing References

Comprehensive guides and patterns for mastering Jest unit testing framework.

## Contents

### GUIDE.md
Complete technical guide covering:
- Jest installation and setup
- Test structure (describe, it, test blocks)
- Assertion matchers (toBe, toEqual, toMatch, toThrow, etc.)
- Mocking functions, modules, and timers
- Snapshot testing and comparisons
- Async testing patterns (promises, async/await)
- Coverage reporting and thresholds
- Debugging and troubleshooting tests

**Target:** Understanding Jest fundamentals and advanced features
**Read Time:** 20-30 minutes

### PATTERNS.md
Real-world patterns and best practices including:
- Mock function patterns (jest.fn, jest.spyOn)
- Async test patterns (promises, async/await, callbacks)
- Snapshot testing strategies
- Module mocking patterns (default exports, named exports)
- Test fixtures and data builders
- Data-driven tests and parameterization
- Performance testing patterns
- Common pitfalls and solutions

**Target:** Applying Jest effectively in production code
**Read Time:** 20-30 minutes

## Quick Navigation

| Topic | Reference |
|-------|-----------|
| Setting up Jest | GUIDE.md - Setup & Configuration |
| Writing first test | GUIDE.md - Test Structure |
| Understanding matchers | GUIDE.md - Assertion Matchers |
| Mocking in tests | PATTERNS.md - Mock Patterns |
| Testing async code | GUIDE.md - Async Testing |
| Organizing tests | PATTERNS.md - Test Fixtures |
| Coverage requirements | GUIDE.md - Coverage Reporting |

## Key Concepts

### Test Structure
```javascript
describe('Feature', () => {
  beforeEach(() => { /* setup */ });
  test('should do something', () => { /* assertion */ });
  afterEach(() => { /* cleanup */ });
});
```

### Common Matchers
- `expect(value).toBe(expected)` - Exact equality
- `expect(obj).toEqual(expected)` - Deep equality
- `expect(text).toMatch(/regex/)` - String/regex matching
- `expect(fn).toThrow()` - Exception testing
- `expect(fn).toHaveBeenCalled()` - Mock assertions

### Mocking
```javascript
const mock = jest.fn().mockReturnValue('value');
jest.mock('./module'); // Module mocking
jest.spyOn(obj, 'method'); // Spy on existing method
```

## Files in This Directory

```
references/
├── README.md          (this file)
├── GUIDE.md          (technical guide - 600+ words)
└── PATTERNS.md       (patterns & examples - 600+ words)
```

## Learning Path

1. **Start here:** GUIDE.md - Setup & Configuration section
2. **First test:** Follow test structure examples
3. **Learn matchers:** Study assertion matcher examples
4. **Master mocking:** PATTERNS.md - Mock Patterns
5. **Real projects:** Apply patterns to your code

## Related Skills

- react-testing-library: Testing React components
- component-testing-libraries: Testing strategies
- code-quality-linting: Code quality beyond tests

## External Resources

- [Jest Official Documentation](https://jestjs.io/)
- [Testing Library Patterns](https://testing-library.com/docs/queries/about)
- [Common Testing Mistakes](https://kentcdodds.com/blog/common-mistakes-with-react-testing-library)

---

**Version:** 2.0.0 | **Last Updated:** 2025-12-28
