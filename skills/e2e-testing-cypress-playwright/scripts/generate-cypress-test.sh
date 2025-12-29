#!/bin/bash

# Cypress E2E Test Generator
# Generates Cypress test boilerplate with real-world patterns
# Usage: ./generate-cypress-test.sh [test-name]

set -e

TEST_NAME="${1:-login}"
SPEC_FILE="cypress/e2e/${TEST_NAME}.cy.js"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Cypress E2E Test Generator${NC}"
echo "=================================="
echo "Test: $TEST_NAME"
echo ""

# Create directories
mkdir -p cypress/e2e
mkdir -p cypress/support
mkdir -p cypress/fixtures

# Generate test spec
cat > "$SPEC_FILE" << 'EOF'
/**
 * Cypress E2E Test: LOGIN_NAME_PLACEHOLDER
 * Tests the login functionality with various scenarios
 */

describe('LOGIN_NAME_PLACEHOLDER', () => {
  const BASE_URL = Cypress.env('BASE_URL') || 'http://localhost:3000';

  beforeEach(() => {
    // Reset any state and navigate to login page
    cy.visit(`${BASE_URL}/login`);
  });

  describe('Page Rendering', () => {
    it('should render login form', () => {
      cy.get('[data-cy="login-form"]').should('be.visible');
      cy.get('[data-cy="username-input"]').should('be.visible');
      cy.get('[data-cy="password-input"]').should('be.visible');
      cy.get('[data-cy="login-button"]').should('be.visible');
    });

    it('should display login heading', () => {
      cy.contains('h1', /login|sign in/i).should('be.visible');
    });

    it('should have accessible form', () => {
      // Check labels for form inputs
      cy.get('label[for="username"]').should('exist');
      cy.get('label[for="password"]').should('exist');
    });
  });

  describe('User Interactions', () => {
    it('should accept username input', () => {
      cy.get('[data-cy="username-input"]')
        .type('testuser@example.com')
        .should('have.value', 'testuser@example.com');
    });

    it('should accept password input', () => {
      cy.get('[data-cy="password-input"]')
        .type('TestPassword123!')
        .should('have.value', 'TestPassword123!');
    });

    it('should clear form fields', () => {
      const email = 'test@example.com';
      cy.get('[data-cy="username-input"]').type(email);
      cy.get('[data-cy="username-input"]').clear();
      cy.get('[data-cy="username-input"]').should('have.value', '');
    });
  });

  describe('Form Submission', () => {
    it('should submit valid credentials', () => {
      // Mock API response
      cy.intercept('POST', '/api/login', {
        statusCode: 200,
        body: {
          success: true,
          token: 'fake-jwt-token-123',
          user: {
            id: 1,
            email: 'test@example.com',
            name: 'Test User',
          },
        },
      }).as('loginRequest');

      cy.get('[data-cy="username-input"]').type('test@example.com');
      cy.get('[data-cy="password-input"]').type('password123');
      cy.get('[data-cy="login-button"]').click();

      // Verify API was called correctly
      cy.wait('@loginRequest').then((interception) => {
        expect(interception.request.body.email).to.equal('test@example.com');
        expect(interception.request.body.password).to.equal('password123');
      });

      // Verify redirect to dashboard
      cy.url().should('include', '/dashboard');
    });

    it('should handle invalid credentials', () => {
      cy.intercept('POST', '/api/login', {
        statusCode: 401,
        body: {
          error: 'Invalid credentials',
        },
      }).as('loginRequest');

      cy.get('[data-cy="username-input"]').type('wrong@example.com');
      cy.get('[data-cy="password-input"]').type('wrongpassword');
      cy.get('[data-cy="login-button"]').click();

      cy.wait('@loginRequest');
      cy.get('[data-cy="error-message"]').should('contain', 'Invalid credentials');
    });

    it('should handle network errors', () => {
      cy.intercept('POST', '/api/login', { forceNetworkError: true }).as('loginRequest');

      cy.get('[data-cy="username-input"]').type('test@example.com');
      cy.get('[data-cy="password-input"]').type('password123');
      cy.get('[data-cy="login-button"]').click();

      cy.get('[data-cy="error-message"]').should('contain', 'Network error');
    });
  });

  describe('Validation', () => {
    it('should require username', () => {
      cy.get('[data-cy="password-input"]').type('password123');
      cy.get('[data-cy="login-button"]').click();

      cy.get('[data-cy="username-error"]').should('be.visible');
    });

    it('should require password', () => {
      cy.get('[data-cy="username-input"]').type('test@example.com');
      cy.get('[data-cy="login-button"]').click();

      cy.get('[data-cy="password-error"]').should('be.visible');
    });

    it('should validate email format', () => {
      cy.get('[data-cy="username-input"]').type('invalid-email');
      cy.get('[data-cy="password-input"]').type('password123');
      cy.get('[data-cy="login-button"]').click();

      cy.get('[data-cy="username-error"]').should('contain', 'valid email');
    });
  });

  describe('Loading States', () => {
    it('should show loading state during submission', () => {
      // Intercept with delay to see loading state
      cy.intercept('POST', '/api/login', (req) => {
        req.reply((res) => {
          res.delay(2000);
          res.send({
            statusCode: 200,
            body: { success: true, token: 'fake-token' },
          });
        });
      }).as('slowLogin');

      cy.get('[data-cy="username-input"]').type('test@example.com');
      cy.get('[data-cy="password-input"]').type('password123');
      cy.get('[data-cy="login-button"]').click();

      cy.get('[data-cy="login-button"]').should('be.disabled');
      cy.get('[data-cy="loading-spinner"]').should('be.visible');

      cy.wait('@slowLogin');
      cy.get('[data-cy="loading-spinner"]').should('not.exist');
    });
  });

  describe('Accessibility', () => {
    it('should have proper ARIA attributes', () => {
      cy.get('[data-cy="login-form"]').should('have.attr', 'aria-label');
      cy.get('[data-cy="error-message"]')
        .should('have.attr', 'role', 'alert');
    });

    it('should support keyboard navigation', () => {
      cy.get('[data-cy="username-input"]').focus();
      cy.focused().should('have.attr', 'data-cy', 'username-input');

      cy.tab();  // Requires cypress-axe or custom tab command
      cy.focused().should('have.attr', 'data-cy', 'password-input');

      cy.tab();
      cy.focused().should('have.attr', 'data-cy', 'login-button');

      cy.focused().type('{enter}');
      // Login should trigger
    });

    it('should be keyboard accessible', () => {
      // Type username
      cy.get('[data-cy="username-input"]').type('test@example.com');

      // Tab to password
      cy.get('[data-cy="username-input"]').tab();
      cy.get('[data-cy="password-input"]').type('password123');

      // Tab to submit button and press enter
      cy.get('[data-cy="password-input"]').tab();
      cy.get('[data-cy="login-button"]').should('have.focus');
    });
  });

  describe('Remember Me Feature', () => {
    it('should toggle remember me checkbox', () => {
      cy.get('[data-cy="remember-me-checkbox"]').click();
      cy.get('[data-cy="remember-me-checkbox"]').should('be.checked');

      cy.get('[data-cy="remember-me-checkbox"]').click();
      cy.get('[data-cy="remember-me-checkbox"]').should('not.be.checked');
    });

    it('should prefill email on return visit', () => {
      // Login with remember me
      cy.intercept('POST', '/api/login', {
        statusCode: 200,
        body: { success: true, token: 'token' },
      });

      cy.get('[data-cy="username-input"]').type('remembered@example.com');
      cy.get('[data-cy="remember-me-checkbox"]').click();
      cy.get('[data-cy="login-button"]').click();

      // Logout (in real app)
      cy.visit(`${BASE_URL}/logout`);
      cy.visit(`${BASE_URL}/login`);

      // Email should be prefilled
      cy.get('[data-cy="username-input"]')
        .should('have.value', 'remembered@example.com');
    });
  });

  describe('Edge Cases', () => {
    it('should handle very long input', () => {
      const longEmail = 'a'.repeat(255) + '@example.com';
      cy.get('[data-cy="username-input"]').type(longEmail);
      cy.get('[data-cy="username-input"]').should('have.value', longEmail);
    });

    it('should handle special characters in password', () => {
      const specialPassword = '!@#$%^&*()_+-=[]{}|;:,"<>?.>';
      cy.get('[data-cy="password-input"]').type(specialPassword);
      cy.get('[data-cy="password-input"]').should('have.value', specialPassword);
    });

    it('should prevent double submission', () => {
      cy.intercept('POST', '/api/login', {
        delay: 500,
        statusCode: 200,
        body: { success: true, token: 'token' },
      }).as('login');

      cy.get('[data-cy="username-input"]').type('test@example.com');
      cy.get('[data-cy="password-input"]').type('password123');

      // Click rapidly
      cy.get('[data-cy="login-button"]').click();
      cy.get('[data-cy="login-button"]').click();
      cy.get('[data-cy="login-button"]').click();

      // Should only make one request
      cy.wait('@login');
      cy.get('@login.all').should('have.length', 1);
    });
  });
});
EOF

# Replace placeholder with actual test name
sed -i "s/LOGIN_NAME_PLACEHOLDER/$TEST_NAME/g" "$SPEC_FILE"

echo -e "${GREEN}✓ Created test spec: $SPEC_FILE${NC}"

# Create support file if it doesn't exist
if [ ! -f "cypress/support/commands.js" ]; then
    cat > "cypress/support/commands.js" << 'EOF'
/**
 * Cypress Custom Commands
 * Reusable commands for common test scenarios
 */

// Login command
Cypress.Commands.add('login', (email = 'test@example.com', password = 'password123') => {
  cy.visit('/login');
  cy.get('[data-cy="username-input"]').type(email);
  cy.get('[data-cy="password-input"]').type(password);
  cy.get('[data-cy="login-button"]').click();
  cy.url().should('include', '/dashboard');
});

// Logout command
Cypress.Commands.add('logout', () => {
  cy.get('[data-cy="user-menu"]').click();
  cy.get('[data-cy="logout-button"]').click();
  cy.url().should('include', '/login');
});

// Tab command for keyboard navigation
Cypress.Commands.add('tab', { prevSubject: true }, (subject) => {
  cy.wrap(subject).trigger('keydown', { keyCode: 9, which: 9 });
});

// Get by data-cy attribute
Cypress.Commands.add('getByTestId', (testId) => {
  cy.get(`[data-cy="${testId}"]`);
});
EOF

    echo -e "${GREEN}✓ Created support commands: cypress/support/commands.js${NC}"
fi

# Create e2e config in support
if [ ! -f "cypress/support/e2e.js" ]; then
    cat > "cypress/support/e2e.js" << 'EOF'
// Support file for E2E tests
import './commands';

// Disable uncaught exception handling for specific errors
Cypress.on('uncaught:exception', (err, runnable) => {
  // Ignore ResizeObserver errors
  if (err.message.includes('ResizeObserver loop limit exceeded')) {
    return false;
  }
  // Return true to fail the test
  return true;
});
EOF

    echo -e "${GREEN}✓ Created support file: cypress/support/e2e.js${NC}"
fi

# Create fixtures directory with sample data
if [ ! -f "cypress/fixtures/users.json" ]; then
    cat > "cypress/fixtures/users.json" << 'EOF'
{
  "validUser": {
    "email": "test@example.com",
    "password": "TestPassword123!"
  },
  "adminUser": {
    "email": "admin@example.com",
    "password": "AdminPassword123!"
  },
  "invalidUser": {
    "email": "invalid@example.com",
    "password": "wrong"
  }
}
EOF

    echo -e "${GREEN}✓ Created fixtures: cypress/fixtures/users.json${NC}"
fi

# Create cypress.config.js if it doesn't exist
if [ ! -f "cypress.config.js" ]; then
    cat > "cypress.config.js" << 'EOF'
const { defineConfig } = require('cypress');

module.exports = defineConfig({
  e2e: {
    baseUrl: 'http://localhost:3000',
    supportFile: 'cypress/support/e2e.js',
    specPattern: 'cypress/e2e/**/*.cy.{js,jsx,ts,tsx}',
    viewportWidth: 1280,
    viewportHeight: 720,
    defaultCommandTimeout: 10000,
    requestTimeout: 10000,
    responseTimeout: 10000,
    setupNodeEvents(on, config) {
      // Implement node event listeners here
    },
  },
  env: {
    BASE_URL: 'http://localhost:3000',
  },
});
EOF

    echo -e "${GREEN}✓ Created cypress.config.js${NC}"
fi

echo ""
echo -e "${BLUE}=================================="
echo "✅ Cypress Test Generation Complete!"
echo "==========================================${NC}"
echo ""
echo "📝 Generated Files:"
echo "  • $SPEC_FILE"
echo "  • cypress/support/commands.js (if new)"
echo "  • cypress/support/e2e.js (if new)"
echo "  • cypress/fixtures/users.json (if new)"
echo "  • cypress.config.js (if new)"
echo ""
echo "📦 Required Dependencies:"
echo "  npm install --save-dev cypress"
echo "  npm install --save-dev @cypress/webpack-dev-server"
echo "  npm install --save-dev cypress-axe  # For accessibility"
echo ""
echo "🚀 Next Steps:"
echo "  1. Review generated test: $SPEC_FILE"
echo "  2. Update BASE_URL in cypress.config.js"
echo "  3. Customize data-cy selectors in your app"
echo "  4. Run tests: npx cypress open"
echo "  5. Or headless: npx cypress run"
echo ""
echo "📚 Key Cypress Concepts:"
echo "  • Use data-cy attributes for stable selectors"
echo "  • Implement cy.intercept() for API mocking"
echo "  • Create custom commands in cypress/support/commands.js"
echo "  • Use Page Object Model for maintainability"
echo "  • Avoid hardcoded waits - let Cypress retry"
echo ""
