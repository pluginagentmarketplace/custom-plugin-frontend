---
name: e2e-testing-cypress-playwright
description: Master end-to-end testing with Cypress and Playwright for complete user journey testing.
version: "2.0.0"
sasmp_version: "1.3.0"
bonded_agent: 05-testing-agent
bond_type: SECONDARY_BOND
config:
  production:
    browsers: [chromium, firefox, webkit]
    viewport:
      width: 1280
      height: 720
    timeout:
      default: 30000
      navigation: 30000
      action: 10000
    screenshot_on_failure: true
    video_on_failure: true
    retry_failed_tests: 2
    parallel_workers: 4
    headless: true
  development:
    headless: false
    slow_mo: 100
    debug_mode: true
    trace: true
    screenshots: always
  ci:
    headless: true
    workers: 2
    retries: 3
    output_folder: test-results
    report_formats: [json, html, junit]
---

# E2E Testing with Cypress & Playwright

Complete user journey automation for end-to-end testing with cross-browser support and advanced debugging.

## Input/Output Schema

### Input Schema
```yaml
e2e_test_request:
  type: object
  required:
    - test_name
    - user_journey
    - framework
  properties:
    test_name:
      type: string
      description: Name of the E2E test
    framework:
      type: string
      enum: [cypress, playwright]
      description: E2E testing framework to use
    user_journey:
      type: array
      description: Sequence of user actions
      items:
        type: object
        properties:
          action:
            type: string
            enum: [navigate, click, type, select, wait, assert]
          selector:
            type: string
            description: Element selector
          value:
            type: string
            description: Value for input actions
          timeout:
            type: number
            description: Custom timeout in milliseconds
    browsers:
      type: array
      items:
        type: string
        enum: [chromium, firefox, webkit, chrome, edge]
      default: [chromium]
    viewport:
      type: object
      properties:
        width: { type: number, default: 1280 }
        height: { type: number, default: 720 }
    authentication:
      type: object
      properties:
        required: { type: boolean }
        method: { type: string, enum: [session, cookies, localStorage] }
    network_conditions:
      type: object
      properties:
        offline: { type: boolean }
        latency: { type: number }
        download: { type: number }
        upload: { type: number }
```

### Output Schema
```yaml
e2e_test_result:
  type: object
  properties:
    status:
      type: string
      enum: [passed, failed, skipped, flaky]
    test_file_path:
      type: string
    execution_time:
      type: number
      description: Total test execution time in milliseconds
    browser_results:
      type: array
      items:
        type: object
        properties:
          browser: { type: string }
          status: { type: string }
          duration: { type: number }
          screenshots: { type: array, items: { type: string } }
          videos: { type: array, items: { type: string } }
    actions_performed:
      type: array
      items:
        type: object
        properties:
          action: { type: string }
          selector: { type: string }
          success: { type: boolean }
          duration: { type: number }
    assertions_results:
      type: array
      items:
        type: object
        properties:
          description: { type: string }
          passed: { type: boolean }
          expected: { type: string }
          actual: { type: string }
    network_requests:
      type: array
      items:
        type: object
        properties:
          url: { type: string }
          method: { type: string }
          status: { type: number }
          duration: { type: number }
    errors:
      type: array
      items:
        type: object
        properties:
          message: { type: string }
          stack: { type: string }
          screenshot: { type: string }
    performance_metrics:
      type: object
      properties:
        dom_content_loaded: { type: number }
        load_complete: { type: number }
        first_paint: { type: number }
        first_contentful_paint: { type: number }
```

## Error Handling

| Error Code | Error Type | Description | Resolution |
|------------|------------|-------------|------------|
| `E2E_001` | Navigation Error | Page navigation failed or timed out | Check URL, increase timeout, verify network |
| `E2E_002` | Element Not Found | Selector did not match any element | Verify selector, wait for element to appear |
| `E2E_003` | Element Not Visible | Element exists but not visible | Wait for visibility, check CSS display/opacity |
| `E2E_004` | Action Timeout | Action exceeded timeout limit | Increase timeout or check element state |
| `E2E_005` | Network Error | Network request failed | Check API endpoint, verify CORS settings |
| `E2E_006` | Authentication Failed | Login or auth setup failed | Verify credentials, check auth flow |
| `E2E_007` | Assertion Failed | Expected condition not met | Review expected vs actual state |
| `E2E_008` | Browser Launch Failed | Could not start browser | Check browser installation and permissions |
| `E2E_009` | Screenshot/Video Error | Media capture failed | Check disk space and permissions |
| `E2E_010` | Flaky Test | Test passed on retry | Investigate timing issues and race conditions |
| `E2E_011` | Interceptor Error | Network intercept failed | Verify route pattern and handler |
| `E2E_012` | File Upload Error | File upload action failed | Check file path and input element |

## Test Templates

### Basic E2E Test (Playwright)
```javascript
import { test, expect } from '@playwright/test';

test.describe('Login Flow', () => {
  test('should successfully log in user', async ({ page }) => {
    // Navigate
    await page.goto('https://example.com/login');

    // Fill form
    await page.fill('input[name="email"]', 'user@example.com');
    await page.fill('input[name="password"]', 'securePassword123');

    // Submit
    await page.click('button[type="submit"]');

    // Wait for navigation
    await page.waitForURL('**/dashboard');

    // Assert
    await expect(page.locator('h1')).toContainText('Dashboard');
    await expect(page.locator('.user-name')).toContainText('user@example.com');
  });

  test('should show error for invalid credentials', async ({ page }) => {
    await page.goto('https://example.com/login');

    await page.fill('input[name="email"]', 'invalid@example.com');
    await page.fill('input[name="password"]', 'wrongpassword');
    await page.click('button[type="submit"]');

    // Assert error message
    await expect(page.locator('.error-message')).toBeVisible();
    await expect(page.locator('.error-message')).toContainText('Invalid credentials');
  });
});
```

### Basic E2E Test (Cypress)
```javascript
describe('Login Flow', () => {
  beforeEach(() => {
    cy.visit('/login');
  });

  it('should successfully log in user', () => {
    // Fill form
    cy.get('input[name="email"]').type('user@example.com');
    cy.get('input[name="password"]').type('securePassword123');

    // Submit
    cy.get('button[type="submit"]').click();

    // Assert
    cy.url().should('include', '/dashboard');
    cy.get('h1').should('contain', 'Dashboard');
    cy.get('.user-name').should('contain', 'user@example.com');
  });

  it('should show error for invalid credentials', () => {
    cy.get('input[name="email"]').type('invalid@example.com');
    cy.get('input[name="password"]').type('wrongpassword');
    cy.get('button[type="submit"]').click();

    cy.get('.error-message').should('be.visible');
    cy.get('.error-message').should('contain', 'Invalid credentials');
  });
});
```

### Network Interception (Playwright)
```javascript
import { test, expect } from '@playwright/test';

test('should intercept and mock API response', async ({ page }) => {
  // Intercept API call
  await page.route('**/api/users', async (route) => {
    const json = {
      users: [
        { id: 1, name: 'John Doe', email: 'john@example.com' },
        { id: 2, name: 'Jane Smith', email: 'jane@example.com' },
      ],
    };
    await route.fulfill({ json });
  });

  // Navigate and wait for request
  await page.goto('/users');

  // Assert mocked data appears
  await expect(page.locator('.user-list')).toContainText('John Doe');
  await expect(page.locator('.user-list')).toContainText('Jane Smith');
});

test('should wait for and verify API call', async ({ page }) => {
  // Start waiting for request
  const requestPromise = page.waitForRequest('**/api/save');

  // Trigger action that makes request
  await page.goto('/form');
  await page.fill('#name', 'Test User');
  await page.click('button[type="submit"]');

  // Wait for and verify request
  const request = await requestPromise;
  expect(request.postDataJSON()).toEqual({
    name: 'Test User',
  });
});
```

### Network Interception (Cypress)
```javascript
describe('API Mocking', () => {
  it('should intercept and mock API response', () => {
    // Setup intercept
    cy.intercept('GET', '/api/users', {
      statusCode: 200,
      body: {
        users: [
          { id: 1, name: 'John Doe', email: 'john@example.com' },
          { id: 2, name: 'Jane Smith', email: 'jane@example.com' },
        ],
      },
    }).as('getUsers');

    // Navigate
    cy.visit('/users');

    // Wait for request
    cy.wait('@getUsers');

    // Assert mocked data
    cy.get('.user-list').should('contain', 'John Doe');
    cy.get('.user-list').should('contain', 'Jane Smith');
  });

  it('should verify request payload', () => {
    cy.intercept('POST', '/api/save').as('saveRequest');

    cy.visit('/form');
    cy.get('#name').type('Test User');
    cy.get('button[type="submit"]').click();

    cy.wait('@saveRequest').its('request.body').should('deep.equal', {
      name: 'Test User',
    });
  });
});
```

### Page Object Model (Playwright)
```javascript
// pages/LoginPage.js
export class LoginPage {
  constructor(page) {
    this.page = page;
    this.emailInput = page.locator('input[name="email"]');
    this.passwordInput = page.locator('input[name="password"]');
    this.submitButton = page.locator('button[type="submit"]');
    this.errorMessage = page.locator('.error-message');
  }

  async goto() {
    await this.page.goto('/login');
  }

  async login(email, password) {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.submitButton.click();
  }

  async getErrorMessage() {
    return await this.errorMessage.textContent();
  }
}

// test file
import { test, expect } from '@playwright/test';
import { LoginPage } from './pages/LoginPage';

test('should login with page object', async ({ page }) => {
  const loginPage = new LoginPage(page);

  await loginPage.goto();
  await loginPage.login('user@example.com', 'password123');

  await expect(page).toHaveURL(/.*dashboard/);
});
```

### Custom Commands (Cypress)
```javascript
// cypress/support/commands.js
Cypress.Commands.add('login', (email, password) => {
  cy.session([email, password], () => {
    cy.visit('/login');
    cy.get('input[name="email"]').type(email);
    cy.get('input[name="password"]').type(password);
    cy.get('button[type="submit"]').click();
    cy.url().should('include', '/dashboard');
  });
});

Cypress.Commands.add('createUser', (userData) => {
  cy.request('POST', '/api/users', userData).then((response) => {
    expect(response.status).to.eq(201);
    return response.body;
  });
});

// test file
describe('Dashboard Tests', () => {
  beforeEach(() => {
    cy.login('user@example.com', 'password123');
    cy.visit('/dashboard');
  });

  it('should display user dashboard', () => {
    cy.get('h1').should('contain', 'Dashboard');
  });
});
```

### Visual Regression Test (Playwright)
```javascript
import { test, expect } from '@playwright/test';

test('should match screenshot', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveScreenshot('homepage.png');
});

test('should match element screenshot', async ({ page }) => {
  await page.goto('/components');
  const button = page.locator('.primary-button');
  await expect(button).toHaveScreenshot('primary-button.png');
});

test('should match with custom options', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveScreenshot('homepage-full.png', {
    fullPage: true,
    mask: [page.locator('.dynamic-content')],
    maxDiffPixels: 100,
  });
});
```

### File Upload Test
```javascript
// Playwright
import { test, expect } from '@playwright/test';
import path from 'path';

test('should upload file', async ({ page }) => {
  await page.goto('/upload');

  const fileInput = page.locator('input[type="file"]');
  const filePath = path.join(__dirname, 'fixtures', 'sample.pdf');

  await fileInput.setInputFiles(filePath);

  await page.click('button[type="submit"]');

  await expect(page.locator('.success-message')).toContainText('File uploaded');
});

// Cypress
describe('File Upload', () => {
  it('should upload file', () => {
    cy.visit('/upload');

    cy.get('input[type="file"]').selectFile('cypress/fixtures/sample.pdf');

    cy.get('button[type="submit"]').click();

    cy.get('.success-message').should('contain', 'File uploaded');
  });
});
```

## Best Practices

### Test Organization
1. **Group Related Tests**: Use describe blocks for logical grouping
2. **One Assertion Per Test**: Keep tests focused and maintainable
3. **Descriptive Test Names**: Clearly describe what is being tested
4. **Use beforeEach for Setup**: Avoid duplication in test setup
5. **Clean Up After Tests**: Reset state between tests

### Selector Strategy
1. **Prefer Data Attributes**: Use data-testid for stable selectors
2. **Use Semantic Selectors**: Role-based selectors when possible
3. **Avoid CSS Selectors**: Less brittle than class or ID selectors
4. **Use Accessible Queries**: getByRole, getByLabelText
5. **Chain Selectors Carefully**: Balance specificity with maintainability

### Waiting Strategies
1. **Implicit Waits**: Built-in waiting in Playwright and Cypress
2. **Explicit Waits**: waitFor, waitForSelector for specific conditions
3. **Avoid Fixed Delays**: Don't use arbitrary wait times
4. **Wait for Network**: Use route/intercept to wait for API calls
5. **Wait for Animations**: Consider animation durations

### Network Management
1. **Mock External APIs**: Use route/intercept for predictable tests
2. **Test Error States**: Mock failed API responses
3. **Verify Requests**: Assert request payload and headers
4. **Control Timing**: Delay responses to test loading states
5. **Isolate Tests**: Don't depend on external services

### Authentication
1. **Use Sessions**: Reuse auth state across tests (Cypress sessions)
2. **Store Auth Tokens**: Save and reuse authentication
3. **Skip Login UI**: Use API calls for faster authentication
4. **Test Auth Flows**: Have dedicated tests for login/logout
5. **Handle Expired Sessions**: Test session timeout scenarios

### Performance
1. **Parallel Execution**: Run tests concurrently when possible
2. **Minimize Navigation**: Reuse pages when safe
3. **Optimize Waits**: Use efficient waiting strategies
4. **Reduce Video Recording**: Only record on failure
5. **Cache Dependencies**: Speed up test setup

## MANDATORY

- Test automation and scripting fundamentals
- Element selection strategies (CSS, XPath, role-based)
- User interactions (click, type, select, hover)
- Assertions and waits (implicit and explicit)
- Test organization with describe/test blocks
- Running tests locally in headed and headless modes
- Basic debugging with screenshots
- Form filling and submission

## OPTIONAL

- Cross-browser testing (Chromium, Firefox, WebKit)
- Network interception and mocking
- Visual regression testing with screenshots
- Test recording and debugging tools
- Custom commands and utilities
- Page Object Model pattern
- Authentication state management
- File upload and download testing

## ADVANCED

- CI/CD integration with GitHub Actions, Jenkins
- Parallel test execution for speed optimization
- API testing within E2E suite
- Performance testing and metrics collection
- Accessibility testing with axe integration
- Mobile device emulation and testing
- Advanced debugging with traces and videos
- Flaky test detection and handling
- Custom reporters and test analytics

## Configuration Examples

### Playwright Configuration (playwright.config.js)
```javascript
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  timeout: 30000,
  expect: {
    timeout: 5000,
  },
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 2 : undefined,
  reporter: [
    ['html'],
    ['json', { outputFile: 'test-results.json' }],
    ['junit', { outputFile: 'junit-results.xml' }],
  ],
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },
    {
      name: 'Mobile Chrome',
      use: { ...devices['Pixel 5'] },
    },
  ],
  webServer: {
    command: 'npm run start',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
```

### Cypress Configuration (cypress.config.js)
```javascript
import { defineConfig } from 'cypress';

export default defineConfig({
  e2e: {
    baseUrl: 'http://localhost:3000',
    viewportWidth: 1280,
    viewportHeight: 720,
    video: false,
    screenshotOnRunFailure: true,
    defaultCommandTimeout: 10000,
    requestTimeout: 10000,
    responseTimeout: 30000,
    retries: {
      runMode: 2,
      openMode: 0,
    },
    setupNodeEvents(on, config) {
      // implement node event listeners here
    },
  },
  component: {
    devServer: {
      framework: 'react',
      bundler: 'vite',
    },
  },
});
```

## Assets

- See `assets/e2e-testing-config.yaml` for test patterns
- See `assets/page-objects/` for POM examples
- See `assets/test-fixtures/` for sample test data

## Resources

- [Cypress Documentation](https://docs.cypress.io/)
- [Playwright Documentation](https://playwright.dev/)
- [E2E Testing Best Practices](https://docs.cypress.io/guides/references/best-practices)
- [Playwright Best Practices](https://playwright.dev/docs/best-practices)
- [Page Object Model Guide](https://playwright.dev/docs/pom)

---
**Status:** Active | **Version:** 2.0.0 | **Production-Ready**
