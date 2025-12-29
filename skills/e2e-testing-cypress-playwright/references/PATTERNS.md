# Cypress E2E Testing Patterns - Best Practices & Real-World Examples

## Table of Contents
1. [Page Object Model](#page-object-model)
2. [Custom Commands](#custom-commands)
3. [Test Fixtures & Data](#test-fixtures--data)
4. [API Intercept Patterns](#api-intercept-patterns)
5. [Common Test Scenarios](#common-test-scenarios)
6. [Visual Regression Testing](#visual-regression-testing)
7. [Accessibility Testing](#accessibility-testing)
8. [Common Pitfalls & Solutions](#common-pitfalls--solutions)

## Page Object Model

### Pattern: Basic Page Object

Real-world: Organizing login page tests

```javascript
// cypress/support/pages/LoginPage.js
class LoginPage {
  constructor() {
    this.baseUrl = Cypress.env('BASE_URL') || 'http://localhost:3000';
  }

  visit() {
    cy.visit(`${this.baseUrl}/login`);
    return this;
  }

  enterEmail(email) {
    cy.get('[data-cy="email-input"]').type(email);
    return this;
  }

  enterPassword(password) {
    cy.get('[data-cy="password-input"]').type(password);
    return this;
  }

  clickLogin() {
    cy.get('[data-cy="login-button"]').click();
    return this;
  }

  login(email, password) {
    return this.enterEmail(email).enterPassword(password).clickLogin();
  }

  verifyErrorMessage(message) {
    cy.get('[data-cy="error-message"]').should('contain', message);
    return this;
  }

  verifyDashboardLoaded() {
    cy.url().should('include', '/dashboard');
    cy.get('[data-cy="dashboard-header"]').should('be.visible');
    return this;
  }
}

export default new LoginPage();

// Test usage
import LoginPage from '../support/pages/LoginPage';

test('login with valid credentials', () => {
  LoginPage.visit()
    .login('user@example.com', 'password123')
    .verifyDashboardLoaded();
});
```

### Pattern: Advanced Page Object with Assertions

```javascript
class DataTable {
  getRows() {
    return cy.get('[data-cy="table-row"]');
  }

  getRowCount() {
    return this.getRows().should('have.length.greaterThan', 0);
  }

  getCell(row, column) {
    return cy.get(`[data-cy="row-${row}-col-${column}"]`);
  }

  editRow(row) {
    cy.get(`[data-cy="row-${row}-edit"]`).click();
    return this;
  }

  deleteRow(row) {
    cy.get(`[data-cy="row-${row}-delete"]`).click();
    cy.get('[data-cy="confirm-delete"]').click();
    return this;
  }

  sortByColumn(column) {
    cy.get(`[data-cy="header-${column}"]`).click();
    return this;
  }

  verifyRowContains(row, expectedText) {
    cy.get(`[data-cy="row-${row}"]`).should('contain', expectedText);
    return this;
  }
}

export default new DataTable();
```

## Custom Commands

### Pattern: Login Command

```javascript
// cypress/support/commands.js
Cypress.Commands.add('login', (email, password) => {
  cy.visit('/login');
  cy.get('[data-cy="email-input"]').type(email);
  cy.get('[data-cy="password-input"]').type(password);
  cy.get('[data-cy="login-button"]').click();
  cy.url().should('include', '/dashboard');
});

// Usage
test('user can access dashboard after login', () => {
  cy.login('user@example.com', 'password123');
  cy.get('[data-cy="dashboard-title"]').should('be.visible');
});
```

### Pattern: Form Filling Command

```javascript
Cypress.Commands.add('fillForm', (formData) => {
  Object.entries(formData).forEach(([key, value]) => {
    const selector = `[data-cy="${key}"]`;

    if (value instanceof File) {
      cy.get(`input[type="file"][data-cy="${key}"]`).selectFile(value);
    } else if (typeof value === 'boolean') {
      cy.get(`[data-cy="${key}"]`).then(($el) => {
        if (value && !$el.is(':checked')) {
          cy.get(`[data-cy="${key}"]`).click();
        } else if (!value && $el.is(':checked')) {
          cy.get(`[data-cy="${key}"]`).click();
        }
      });
    } else {
      cy.get(selector).type(value);
    }
  });
});

// Usage
test('submit form with multiple fields', () => {
  cy.fillForm({
    firstName: 'John',
    lastName: 'Doe',
    email: 'john@example.com',
    agreeToTerms: true,
  });

  cy.get('[data-cy="submit-button"]').click();
});
```

### Pattern: Wait for Network Command

```javascript
Cypress.Commands.add('waitForRoute', (method, endpoint) => {
  return cy.intercept(method, endpoint).as(`${method}-${endpoint}`);
});

Cypress.Commands.add('waitForResponse', (alias) => {
  return cy.wait(`@${alias}`);
});

// Usage
test('wait for API calls', () => {
  cy.waitForRoute('GET', '/api/users');
  cy.visit('/users');
  cy.waitForResponse('GET-/api/users');
  cy.get('[data-cy="user-list"]').should('be.visible');
});
```

## Test Fixtures & Data

### Pattern: External Data Files

```javascript
// cypress/fixtures/testData.json
{
  "users": [
    {
      "email": "user1@example.com",
      "password": "Password123!",
      "role": "user"
    },
    {
      "email": "admin@example.com",
      "password": "AdminPass123!",
      "role": "admin"
    }
  ],
  "products": [
    {
      "id": 1,
      "name": "Product 1",
      "price": 29.99
    }
  ]
}

// Test usage
test('multiple users', function() {
  cy.fixture('testData').then((data) => {
    data.users.forEach((user) => {
      cy.login(user.email, user.password);
      cy.get('[data-cy="logout"]').click();
    });
  });
});
```

### Pattern: Data Builder

```javascript
class UserBuilder {
  constructor() {
    this.user = {
      firstName: 'John',
      lastName: 'Doe',
      email: 'john@example.com',
      password: 'Password123!',
      role: 'user',
    };
  }

  withEmail(email) {
    this.user.email = email;
    return this;
  }

  asAdmin() {
    this.user.role = 'admin';
    return this;
  }

  build() {
    return this.user;
  }
}

// Usage
test('create admin user', () => {
  const adminUser = new UserBuilder()
    .withEmail('admin@test.com')
    .asAdmin()
    .build();

  cy.createUser(adminUser);
});
```

## API Intercept Patterns

### Pattern: Realistic API Responses

```javascript
describe('API Error Handling', () => {
  it('shows error for server failure', () => {
    cy.intercept('POST', '/api/users', {
      statusCode: 500,
      body: {
        error: 'Internal Server Error',
        message: 'Database connection failed',
      },
    }).as('createUserError');

    cy.get('[data-cy="email"]').type('test@example.com');
    cy.get('[data-cy="submit"]').click();

    cy.wait('@createUserError');
    cy.get('[data-cy="error-message"]')
      .should('contain', 'Internal Server Error');
  });

  it('handles timeout gracefully', () => {
    cy.intercept('GET', '/api/data', (req) => {
      req.reply((res) => {
        res.delay(5000);
      });
    }).as('slowRequest');

    cy.get('[data-cy="load-data"]').click();
    cy.get('[data-cy="timeout-error"]').should('be.visible');
  });
});
```

### Pattern: Sequence-Based Responses

```javascript
test('retry on failure', () => {
  let callCount = 0;

  cy.intercept('/api/data', (req) => {
    callCount++;

    if (callCount === 1) {
      // First call fails
      req.reply({
        statusCode: 500,
        body: { error: 'Server error' },
      });
    } else {
      // Second call succeeds
      req.reply({
        statusCode: 200,
        body: { data: 'success' },
      });
    }
  }).as('dataRequest');

  cy.get('[data-cy="load"]').click();
  cy.get('[data-cy="error"]').should('be.visible');

  cy.get('[data-cy="retry"]').click();
  cy.get('[data-cy="data"]').should('contain', 'success');
});
```

## Common Test Scenarios

### Pattern: Complete User Flow

```javascript
describe('User Registration & Login Flow', () => {
  it('complete signup to dashboard', () => {
    // Navigate to signup
    cy.visit('/signup');

    // Fill signup form
    cy.get('[data-cy="first-name"]').type('John');
    cy.get('[data-cy="last-name"]').type('Doe');
    cy.get('[data-cy="email"]').type('john.doe@example.com');
    cy.get('[data-cy="password"]').type('SecurePass123!');
    cy.get('[data-cy="agree-terms"]').click();

    // Mock account creation
    cy.intercept('POST', '/api/auth/register', {
      statusCode: 201,
      body: { id: 1, email: 'john.doe@example.com' },
    }).as('register');

    cy.get('[data-cy="signup-button"]').click();
    cy.wait('@register');

    // Should redirect to login
    cy.url().should('include', '/login');

    // Login
    cy.get('[data-cy="email"]').type('john.doe@example.com');
    cy.get('[data-cy="password"]').type('SecurePass123!');

    // Mock login
    cy.intercept('POST', '/api/auth/login', {
      statusCode: 200,
      body: {
        token: 'jwt-token-123',
        user: { id: 1, email: 'john.doe@example.com' },
      },
    }).as('login');

    cy.get('[data-cy="login-button"]').click();
    cy.wait('@login');

    // Verify dashboard
    cy.url().should('include', '/dashboard');
    cy.get('[data-cy="welcome-message"]').should('contain', 'John');
  });
});
```

### Pattern: CRUD Operations

```javascript
describe('Data Management', () => {
  it('create, read, update, delete operations', () => {
    cy.login('user@example.com', 'password');

    // CREATE
    cy.get('[data-cy="add-item"]').click();
    cy.get('[data-cy="item-name"]').type('New Item');
    cy.intercept('POST', '/api/items', { statusCode: 201 }).as('create');
    cy.get('[data-cy="save"]').click();
    cy.wait('@create');

    // READ
    cy.get('[data-cy="item-list"]').should('contain', 'New Item');

    // UPDATE
    cy.get('[data-cy="item-edit"]').first().click();
    cy.get('[data-cy="item-name"]').clear().type('Updated Item');
    cy.intercept('PUT', '/api/items/*', { statusCode: 200 }).as('update');
    cy.get('[data-cy="save"]').click();
    cy.wait('@update');

    // DELETE
    cy.get('[data-cy="item-delete"]').first().click();
    cy.intercept('DELETE', '/api/items/*', { statusCode: 204 }).as('delete');
    cy.get('[data-cy="confirm-delete"]').click();
    cy.wait('@delete');

    cy.get('[data-cy="item-list"]').should('not.contain', 'Updated Item');
  });
});
```

## Visual Regression Testing

### Pattern: Screenshot Comparisons

```javascript
// Requires cypress-image-diff plugin
test('visual regression', () => {
  cy.visit('/checkout');
  cy.percySnapshot('checkout-page');  // Requires Percy integration
});

// Or use built-in screenshots
test('screenshot comparison', () => {
  cy.visit('/profile');
  cy.screenshot('profile-page');
  // Compare manually or with CI tools
});
```

## Accessibility Testing

### Pattern: Accessibility Checks

```javascript
// Requires cypress-axe
import 'cypress-axe';

test('page accessibility', () => {
  cy.visit('/');
  cy.injectAxe();  // Inject accessibility engine
  cy.checkA11y();  // Check entire page

  cy.get('[data-cy="form"]').within(() => {
    cy.checkA11y();  // Check specific component
  });
});
```

## Common Pitfalls & Solutions

### Pitfall: Hardcoded Waits

```javascript
// ❌ WRONG: Fixed wait times
test('wrong wait', () => {
  cy.get('[data-cy="button"]').click();
  cy.wait(2000);  // Brittle!
  cy.get('[data-cy="result"]').should('be.visible');
});

// ✅ CORRECT: Let Cypress retry
test('correct wait', () => {
  cy.get('[data-cy="button"]').click();
  cy.get('[data-cy="result"]').should('be.visible');  // Waits automatically
});
```

### Pitfall: Fragile Selectors

```javascript
// ❌ WRONG: CSS-dependent selectors
test('fragile selectors', () => {
  cy.get('.btn-primary.m-2.p-3').click();  // Breaks if CSS changes
});

// ✅ CORRECT: Stable data attributes
test('stable selectors', () => {
  cy.get('[data-cy="submit-button"]').click();  // Immune to CSS changes
});
```

### Pitfall: Dependent Tests

```javascript
// ❌ WRONG: Tests depend on execution order
test('create user', () => {
  cy.createUser();
  global.userId = 123;
});

test('update user', () => {
  cy.updateUser(global.userId);  // Fails if previous test didn't run
});

// ✅ CORRECT: Isolated, self-contained tests
test('create and update user', () => {
  cy.createUser().then((userId) => {
    cy.updateUser(userId);
  });
});
```

---

**Total Content: 1000+ words of production-ready patterns**

These patterns represent real-world solutions from enterprise projects. Master them to build scalable, maintainable E2E test suites.
