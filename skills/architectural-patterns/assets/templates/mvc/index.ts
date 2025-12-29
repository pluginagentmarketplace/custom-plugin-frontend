/**
 * MVC: Complete Example
 * Shows how Model, View, and Controller work together
 */

import { UserModel, UserStore } from './model';
import { UserController, ViewObserver } from './controller';
import { AppView, appStyles } from './view';

/**
 * MVC APPLICATION SETUP
 */
export class MvcApplication {
  private store: UserStore;
  private controller: UserController;

  constructor() {
    // Initialize model layer
    this.store = new UserStore();

    // Initialize controller
    this.controller = new UserController(this.store);
  }

  // Public API
  getController(): UserController {
    return this.controller;
  }

  getStore(): UserStore {
    return this.store;
  }

  // For React integration
  getAppViewComponent() {
    return AppView;
  }
}

/**
 * Example: Vanilla JavaScript Usage
 */
export function runMvcExample() {
  const app = new MvcApplication();
  const controller = app.getController();

  // Observer pattern
  const observer: ViewObserver = {
    onUsersChanged(users: UserModel[]) {
      console.log('Users updated:', users.map((u) => u.toJSON()));
    },
    onError(error: string) {
      console.error('Error:', error);
    },
  };

  controller.subscribe(observer);

  // Simulate user interactions
  console.log('=== MVC Pattern Example ===\n');

  // Create users
  controller.createUser('Alice', 'alice@example.com');
  controller.createUser('Bob', 'bob@example.com');
  controller.createUser('Charlie', 'charlie@example.com');

  console.log('\nTotal users:', controller.getUserCount());

  // Update user
  const users = controller.getAllUsers();
  if (users.length > 0) {
    controller.updateUser(users[0].getId(), 'Alice Updated', 'alice.updated@example.com');
  }

  // Search
  const searchResults = controller.searchUsers('alice');
  console.log('\nSearch results for "alice":', searchResults.map((u) => u.toJSON()));

  // Delete user
  if (users.length > 1) {
    controller.deleteUser(users[1].getId());
  }

  // Export
  console.log('\nExported users:', controller.exportUsers());

  controller.unsubscribe(observer);
}

/**
 * MVC PATTERN EXPLAINED:
 *
 * ┌─────────────────────┐
 * │      VIEW           │
 * │  (React Components) │
 * │                     │
 * └──────────┬──────────┘
 *            │ user interactions
 *            │ displays data
 *            ▼
 * ┌─────────────────────┐
 * │   CONTROLLER        │
 * │  (Business Logic)   │
 * │                     │
 * └──────────┬──────────┘
 *            │ updates/queries
 *            │
 *            ▼
 * ┌─────────────────────┐
 * │      MODEL          │
 * │  (Data & Rules)     │
 * │  (UserModel, Store) │
 * └─────────────────────┘
 *
 * FLOW:
 * 1. User interacts with View (clicks button, submits form)
 * 2. View calls Controller method (createUser, updateUser)
 * 3. Controller modifies Model (creates/updates/deletes users)
 * 4. Model notifies Controller of changes
 * 5. Controller notifies View observers
 * 6. View re-renders with updated data
 *
 * KEY COMPONENTS:
 * - Model: UserModel (entity), UserStore (data storage)
 * - View: React components (AppView, UserListView, UserFormView)
 * - Controller: UserController (orchestrates model/view)
 *
 * BENEFITS:
 * - Separation of concerns
 * - Easy to test (mock view, test controller/model)
 * - Multiple views can use same model/controller
 * - Business logic independent of UI
 *
 * DRAWBACKS:
 * - Tight coupling between Controller and View
 * - Complex for large applications
 * - Difficult data flow in bidirectional scenarios
 *
 * BEST FOR:
 * - Traditional web applications
 * - Simple to medium complexity
 * - Server-rendered applications
 * - Monolithic applications
 */

/**
 * MVC vs Other Patterns:
 *
 * MVC:     Simple, good for traditional apps, tighter coupling
 * MVVM:    Better data binding, rich UIs, more abstraction
 * Clean:   Better for complex domains, more layers, stricter rules
 * DDD:     Business domain focused, enterprise applications
 */
