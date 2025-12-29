/**
 * MVVM: Complete Example
 * Model-View-ViewModel architectural pattern
 */

import { UserModel, UserService } from './model';
import { UserViewModel } from './viewmodel';

/**
 * MVVM Application Setup
 */
export class MvvmApplication {
  private service: UserService;
  private viewModel: UserViewModel;

  constructor() {
    this.service = new UserService();
    this.viewModel = new UserViewModel(this.service);
  }

  getViewModel(): UserViewModel {
    return this.viewModel;
  }

  getService(): UserService {
    return this.service;
  }
}

/**
 * Example Usage
 */
export function runMvvmExample() {
  console.log('=== MVVM Pattern Example ===\n');

  const app = new MvvmApplication();
  const vm = app.getViewModel();

  // Subscribe to observable changes
  vm.users$.subscribe((users) => {
    console.log('Users changed:', users.map((u) => u.toJSON()));
  });

  vm.error$.subscribe((error) => {
    if (error) {
      console.error('Error:', error);
    }
  });

  // Load users
  vm.loadUsers();
  console.log('Users loaded\n');

  // Create user
  vm.formName$.setValue('Alice Johnson');
  vm.formEmail$.setValue('alice@example.com');
  vm.createUser();
  console.log('User created\n');

  // Create another user
  vm.formName$.setValue('Bob Smith');
  vm.formEmail$.setValue('bob@example.com');
  vm.createUser();
  console.log('Second user created\n');

  // Select and update user
  const users = vm.users$.getValue();
  if (users.length > 0) {
    vm.selectUser(users[0]);
    vm.formName$.setValue('Alice Updated');
    vm.updateSelectedUser();
    console.log('User updated\n');
  }

  // Delete user
  if (users.length > 1) {
    vm.selectUser(users[1]);
    vm.deleteSelectedUser();
    console.log('User deleted\n');
  }
}

/**
 * MVVM PATTERN EXPLAINED:
 *
 * ┌─────────────────────┐
 * │      VIEW           │
 * │  (Pure Rendering)   │
 * │   (React/Angular)   │
 * └──────────┬──────────┘
 *            │ Binds to properties
 *            │ Calls commands
 *            ▼
 * ┌─────────────────────┐
 * │   VIEWMODEL         │
 * │  (Presentation Logic)
 * │  Observable Properties
 * │  Commands/Methods   │
 * └──────────┬──────────┘
 *            │ Uses/Updates
 *            │
 *            ▼
 * ┌─────────────────────┐
 * │      MODEL          │
 * │  (Data & Business)  │
 * │                     │
 * └─────────────────────┘
 *
 * KEY DIFFERENCES FROM MVC:
 * 1. ViewModel (not Controller) coordinates View and Model
 * 2. Two-way data binding: View ↔ ViewModel
 * 3. ViewModel exposes Observable properties
 * 4. View is completely passive (no logic)
 *
 * FLOW:
 * 1. User interacts with View (types in input, clicks button)
 * 2. View updates ViewModel observable (binding)
 * 3. ViewModel commands process business logic
 * 4. ViewModel notifies observers of state changes
 * 5. View re-renders automatically (binding)
 *
 * DATA BINDING:
 * Two-Way Binding:
 *   View ← → ViewModel Property
 *   When view changes, ViewModel updates
 *   When ViewModel changes, View updates
 *
 * One-Way Binding:
 *   View ← ViewModel Property (read-only)
 *
 * BENEFITS:
 * - Clear separation: View has NO logic
 * - Automatic two-way synchronization
 * - Easy to test (test ViewModel in isolation)
 * - Reusable ViewModels with different Views
 * - Better for rich UI applications
 *
 * DRAWBACKS:
 * - More boilerplate than MVC
 * - Observable setup overhead
 * - Steeper learning curve
 * - Data binding can hide complexity
 *
 * BEST FOR:
 * - Rich client applications (SPA, Desktop)
 * - Complex user interactions
 * - Real-time data synchronization
 * - MVVM frameworks: Angular, WPF, Vue.js
 *
 * COMPARISON:
 * MVC:   Controller ← → Model & View
 * MVVM:  ViewModel ← → View (two-way binding)
 *        Model ← ViewModel
 */
