# E2E Testing with Cypress & Playwright Scripts

This directory contains scripts for validating and generating end-to-end test configurations and tests.

## Available Scripts

### validate-cypress.sh
Validates Cypress setup and test configuration:
- Checks for `cypress.config.js` or `cypress.config.ts`
- Verifies spec files structure (`cypress/e2e/*.cy.js`)
- Validates selector patterns (data-cy, role-based)
- Checks for API intercepts setup
- Verifies test discovery
- Reports on configuration standards

**Usage:**
```bash
./scripts/validate-cypress.sh [path-to-project]
```

### generate-cypress-test.sh
Generates Cypress test boilerplate:
- Creates spec file with real test scenarios
- Includes selector patterns (data-cy attributes)
- Adds command examples (cy.get, cy.contains)
- Sets up API intercepts for mocking
- Includes assertion examples
- Implements page object pattern

**Usage:**
```bash
./scripts/generate-cypress-test.sh [test-name]
```

## Examples

```bash
# Validate existing Cypress setup
./scripts/validate-cypress.sh ~/my-app

# Generate login test
./scripts/generate-cypress-test.sh login

# Generate checkout flow test
./scripts/generate-cypress-test.sh checkout-flow
```

## Dependencies

- `cypress` - E2E testing framework
- `@cypress/webpack-dev-server` - Dev server integration
- `cypress-axe` - Accessibility testing

## Key Cypress Concepts

### Selectors
- `cy.get('[data-cy="button"]')` - Recommended (explicit, stable)
- `cy.get('button:contains("Click")` - Text selector
- `cy.contains('Submit')` - Content matching
- `cy.get('.css-class')` - CSS class (less stable)

### Common Commands
- `cy.visit()` - Navigate to URL
- `cy.get()` - Select elements
- `cy.type()` - Type text
- `cy.click()` - Click element
- `cy.intercept()` - Mock API responses

### Assertions
- `cy.get().should('be.visible')`
- `cy.get().should('have.value', 'text')`
- `cy.get().should('contain', 'text')`

## Best Practices

1. Use `data-cy` attributes instead of class names
2. Implement Page Object Model for maintainability
3. Use API intercepts for external service mocking
4. Avoid hardcoded waits - use implicit waits
5. Keep tests focused and independent
