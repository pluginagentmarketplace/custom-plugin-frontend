# Cypress E2E Testing - Complete Technical Guide

## Table of Contents
1. [Setup & Configuration](#setup--configuration)
2. [Selectors](#selectors)
3. [Commands](#commands)
4. [Assertions](#assertions)
5. [Waiting Strategies](#waiting-strategies)
6. [API Intercepts](#api-intercepts)
7. [Navigation & Routing](#navigation--routing)
8. [Debugging Tests](#debugging-tests)

## Setup & Configuration

### Installation

```bash
npm install --save-dev cypress
```

### Create cypress.config.js

```javascript
const { defineConfig } = require('cypress');

module.exports = defineConfig({
  e2e: {
    baseUrl: 'http://localhost:3000',
    supportFile: 'cypress/support/e2e.js',
    specPattern: 'cypress/e2e/**/*.cy.js',
    viewportWidth: 1280,
    viewportHeight: 720,
    defaultCommandTimeout: 10000,
    pageLoadTimeout: 10000,
    requestTimeout: 10000,
    setupNodeEvents(on, config) {
      // Event listeners
    },
  },
});
```

### Create Support File

Create `cypress/support/e2e.js`:

```javascript
// Import custom commands
import './commands';

// Handle uncaught exceptions
Cypress.on('uncaught:exception', (err, runnable) => {
  // Ignore specific errors (e.g., ResizeObserver)
  if (err.message.includes('ResizeObserver')) {
    return false;
  }
  return true;
});
```

### Package.json Scripts

```json
{
  "scripts": {
    "cypress:open": "cypress open",
    "cypress:run": "cypress run",
    "cypress:run:headless": "cypress run --headless",
    "cypress:run:chrome": "cypress run --browser chrome"
  }
}
```

## Selectors

### Data-CY Attributes (Recommended)

HTML:
```html
<button data-cy="login-button">Login</button>
<input data-cy="email-input" placeholder="Email" />
<form data-cy="login-form"></form>
```

Test:
```javascript
cy.get('[data-cy="login-button"]').click();
cy.get('[data-cy="email-input"]').type('test@example.com');
```

**Advantages:**
- Stable (not affected by CSS changes)
- Explicit and clear intent
- Separate from styling/functionality

### CSS Selectors

```javascript
// Class selectors (less stable)
cy.get('.submit-btn').click();

// ID selectors
cy.get('#login-button').click();

// Attribute selectors
cy.get('button[type="submit"]').click();

// Pseudo-selectors
cy.get('input:first').type('text');
```

### Text Content Selectors

```javascript
// Find by text (exact match)
cy.contains('Submit').click();

// Find by partial text
cy.contains(/login/i).click();

// Within a parent
cy.get('[data-cy="form"]').contains('Submit').click();
```

### Query Chaining

```javascript
// Chain queries for more specific selection
cy.get('[data-cy="modal"]')
  .find('[data-cy="submit-button"]')
  .should('be.visible');

// Using within for scoped queries
cy.get('[data-cy="form"]').within(() => {
  cy.get('[data-cy="email"]').type('test@example.com');
  cy.get('[data-cy="password"]').type('password');
});
```

### Best Practices for Selectors

```javascript
// ✅ Good: Explicit data attributes
cy.get('[data-cy="submit-button"]');

// ✅ Good: Text content for visible text
cy.contains('Welcome to Dashboard');

// ❌ Bad: CSS classes (fragile)
cy.get('.btn-primary.btn-lg');

// ❌ Bad: Index-based (unstable)
cy.get('button').first();
```

## Commands

### Navigation

```javascript
// Visit a page
cy.visit('/login');
cy.visit('/admin/users?tab=active');

// Go back/forward
cy.go('back');
cy.go('forward');

// Reload
cy.reload();
```

### Element Interaction

```javascript
// Click
cy.get('[data-cy="button"]').click();
cy.get('[data-cy="button"]').click({ force: true });

// Double click
cy.get('[data-cy="element"]').dblclick();

// Right click
cy.get('[data-cy="menu"]').rightclick();

// Type
cy.get('[data-cy="input"]').type('text', { delay: 100 });

// Clear
cy.get('[data-cy="input"]').clear();

// Select option
cy.get('[data-cy="select"]').select('option-value');

// Check/uncheck
cy.get('[data-cy="checkbox"]').check();
cy.get('[data-cy="checkbox"]').uncheck();
cy.get('[data-cy="checkbox"]').click();
```

### Form Commands

```javascript
// Focus
cy.get('[data-cy="input"]').focus();

// Blur
cy.get('[data-cy="input"]').blur();

// Submit form
cy.get('[data-cy="form"]').submit();

// Get form data
cy.get('[data-cy="form"]').then(($form) => {
  const data = new FormData($form[0]);
});
```

### Window & Document

```javascript
// Get window object
cy.window().then((win) => {
  expect(win.localStorage.getItem('token')).to.exist;
});

// Set localStorage
cy.window().then((win) => {
  win.localStorage.setItem('token', 'test-token');
});

// Get document
cy.document().then((doc) => {
  expect(doc.title).to.equal('Page Title');
});
```

### Special Commands

```javascript
// Scrolling
cy.get('[data-cy="element"]').scrollIntoView();
cy.scrollTo(0, 500);
cy.scrollTo('bottom');

// Hover
cy.get('[data-cy="menu"]').realHover();  // Requires cypress-real-events

// File upload
cy.get('input[type="file"]').selectFile('path/to/file.txt');

// Trigger events
cy.get('[data-cy="input"]').trigger('change');
cy.get('[data-cy="link"]').trigger('mouseover');
```

## Assertions

### Should Assertions

```javascript
// Visibility
cy.get('[data-cy="element"]').should('be.visible');
cy.get('[data-cy="element"]').should('not.be.visible');

// Existence
cy.get('[data-cy="element"]').should('exist');
cy.get('[data-cy="element"]').should('not.exist');

// Content
cy.get('[data-cy="text"]').should('contain', 'welcome');
cy.get('[data-cy="text"]').should('have.text', 'exact text');

// Form elements
cy.get('[data-cy="input"]').should('have.value', 'text');
cy.get('[data-cy="input"]').should('be.enabled');
cy.get('[data-cy="checkbox"]').should('be.checked');

// Classes & Attributes
cy.get('[data-cy="element"]').should('have.class', 'active');
cy.get('[data-cy="element"]').should('have.attr', 'href', '/path');

// Length
cy.get('[data-cy="item"]').should('have.length', 3);

// CSS properties
cy.get('[data-cy="element"]').should('have.css', 'color', 'rgb(0, 0, 0)');
```

### Expect Assertions

```javascript
// Direct assertions
cy.get('[data-cy="element"]').then(($el) => {
  expect($el).to.be.visible;
  expect($el.text()).to.contain('text');
  expect($el.prop('value')).to.equal('expected');
});

// Array assertions
cy.get('[data-cy="items"]').then(($items) => {
  expect($items).to.have.length(3);
  expect(Cypress._.map($items, 'innerText')).to.include('Item 1');
});
```

## Waiting Strategies

### Implicit Waits (Recommended)

Cypress retries automatically:

```javascript
// Waits for element to exist (default: 4s)
cy.get('[data-cy="loading-done"]').should('be.visible');

// Waits for assertion to pass
cy.get('[data-cy="count"]').should('have.text', '5');

// Waits for element to become enabled
cy.get('[data-cy="button"]').should('be.enabled');
```

### Explicit Waits

```javascript
// Wait for intercepted request
cy.intercept('POST', '/api/login').as('login');
// ... user action ...
cy.wait('@login');

// Custom timeout
cy.get('[data-cy="element"]', { timeout: 15000 }).should('be.visible');
```

### Contains Command

```javascript
// Auto-waits for element containing text
cy.contains('[data-cy="button"]', 'Submit').click();

// Text matching
cy.contains(/welcome/i).should('be.visible');
```

## API Intercepts

### Basic Intercept

```javascript
// Mock GET request
cy.intercept('GET', '/api/users', {
  statusCode: 200,
  body: [
    { id: 1, name: 'John' },
    { id: 2, name: 'Jane' },
  ],
}).as('getUsers');

// Verify request
cy.wait('@getUsers').then((interception) => {
  expect(interception.request.query).to.have.property('page', '1');
});
```

### POST Intercept

```javascript
cy.intercept('POST', '/api/login', (req) => {
  req.reply({
    statusCode: 200,
    body: { token: 'fake-jwt', user: { id: 1 } },
  });
}).as('login');
```

### Error Handling

```javascript
// Return error status
cy.intercept('GET', '/api/data', {
  statusCode: 404,
  body: { error: 'Not found' },
}).as('notFound');

// Network error
cy.intercept('POST', '/api/submit', { forceNetworkError: true }).as('networkError');
```

### Conditional Intercepts

```javascript
cy.intercept('/api/data', (req) => {
  if (req.query.status === 'pending') {
    req.reply({
      statusCode: 200,
      body: { items: [] },
    });
  } else {
    req.reply({
      statusCode: 400,
      body: { error: 'Invalid status' },
    });
  }
});
```

## Navigation & Routing

### URL Management

```javascript
// Check current URL
cy.url().should('include', '/dashboard');
cy.url().should('eq', 'http://localhost:3000/users');

// Extract URL components
cy.url().then((url) => {
  const params = new URL(url).searchParams;
  expect(params.get('id')).to.equal('123');
});
```

### Hash Routing

```javascript
cy.visit('/#/users/123');
cy.location('hash').should('include', '/users/123');
```

### Redirect Testing

```javascript
cy.visit('/old-path');
cy.url().should('include', '/new-path');
```

## Debugging Tests

### Console Output

```javascript
test('debug test', () => {
  cy.get('[data-cy="element"]').then(($el) => {
    console.log($el);  // Logs to console
  });
});
```

### Cypress UI

- Open Cypress with `npx cypress open`
- Step through tests interactively
- View console output for each command
- Inspect network requests

### Debugger

```javascript
test('debug with debugger', () => {
  cy.visit('/');
  debugger;  // Pauses test execution
  cy.get('[data-cy="button"]').click();
});
```

### Screenshots & Videos

```bash
# Take screenshot on failure
cypress run --screenshot

# Record video
cypress run --record

# Disable video
cypress run --no-video
```

---

**Total Content: 900+ words covering Cypress fundamentals**

Master these core concepts to build reliable, maintainable E2E tests that catch real user-facing bugs.
