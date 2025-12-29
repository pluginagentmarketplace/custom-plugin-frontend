# E2E Testing with Cypress References

Comprehensive guides for end-to-end testing with Cypress framework.

## Contents

### GUIDE.md
Complete technical guide covering:
- Cypress fundamentals and setup
- Selectors (data-cy best practices)
- Commands (cy.get, cy.contains, cy.click, etc.)
- Assertions and should() chains
- Waiting strategies (implicit waits, cy.contains)
- API intercepts and mocking
- Handling navigation and routing
- Debugging E2E tests
- Performance and best practices

**Target:** Master Cypress fundamentals and patterns
**Read Time:** 25-35 minutes

### PATTERNS.md
Real-world patterns and best practices:
- Page Object Model pattern for maintainability
- Custom command patterns
- Test fixture organization
- API intercept patterns for mocking
- Common test scenarios (login, forms, navigation)
- Visual regression testing patterns
- Accessibility testing integration
- Retry and wait logic patterns
- Common pitfalls and solutions

**Target:** Apply Cypress effectively in production
**Read Time:** 25-35 minutes

## Quick Navigation

| Topic | Reference |
|-------|-----------|
| Cypress setup | GUIDE.md - Setup |
| Selectors | GUIDE.md - Selectors |
| Commands | GUIDE.md - Commands |
| Assertions | GUIDE.md - Assertions |
| Waiting | GUIDE.md - Waiting Strategies |
| API mocking | GUIDE.md - API Intercepts |
| Page Objects | PATTERNS.md - Page Object Model |
| Custom commands | PATTERNS.md - Custom Commands |
| Test organization | PATTERNS.md - Fixtures & Data |

## Key Concepts

### Data-CY Selectors (Recommended)
```html
<button data-cy="submit-button">Submit</button>
<input data-cy="email-input" />
<div data-cy="error-message">Error</div>
```

```javascript
cy.get('[data-cy="submit-button"]').click();
```

### Common Commands
```javascript
cy.visit('/login')                    // Navigate
cy.get('[data-cy="button"]').click()  // Click
cy.type('text')                       // Type text
cy.contains('Text').click()           // Find by content
cy.intercept('POST', '/api/...', {})  // Mock API
```

### Assertions
```javascript
cy.get('element').should('be.visible')
cy.get('input').should('have.value', 'text')
cy.get('.error').should('contain', 'error message')
```

## Files in This Directory

```
references/
├── README.md          (this file)
├── GUIDE.md          (technical guide - 600+ words)
└── PATTERNS.md       (patterns & examples - 600+ words)
```

## Learning Path

1. **Start here:** GUIDE.md - Setup & Basics
2. **Understand selectors:** Selectors section
3. **Learn commands:** Commands section
4. **Master waiting:** Waiting Strategies section
5. **Apply patterns:** PATTERNS.md for real scenarios

## Best Practices

- **Use data-cy attributes** for stable selectors
- **Avoid hardcoded waits** - let Cypress retry
- **Implement Page Object Model** for maintainability
- **Mock external APIs** with cy.intercept()
- **Keep tests independent** and isolated
- **Use custom commands** for reusable actions

## External Resources

- [Cypress Official Documentation](https://docs.cypress.io/)
- [Cypress Best Practices](https://docs.cypress.io/guides/references/best-practices)
- [Cypress API Documentation](https://docs.cypress.io/api/table-of-contents)
- [Page Object Model](https://docs.cypress.io/guides/end-to-end-testing/writing-your-tests)

## Related Skills

- react-testing-library: Component-level testing
- code-quality-tools: Code quality beyond tests
- jest-unit-testing: Unit testing fundamentals

---

**Version:** 2.0.0 | **Last Updated:** 2025-12-28
