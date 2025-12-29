/**
 * MVVM: ViewModel Layer
 * Bridges Model and View - Handles presentation logic and state
 * Exposes reactive properties that View binds to
 */

import { UserModel, UserService } from './model';

/**
 * Simple Observable implementation
 * (In production, use RxJS)
 */
export class Observable<T> {
  private value: T;
  private observers: Array<(value: T) => void> = [];

  constructor(initialValue: T) {
    this.value = initialValue;
  }

  getValue(): T {
    return this.value;
  }

  setValue(newValue: T): void {
    this.value = newValue;
    this.notifyObservers();
  }

  subscribe(observer: (value: T) => void): () => void {
    this.observers.push(observer);
    // Return unsubscribe function
    return () => {
      this.observers = this.observers.filter((o) => o !== observer);
    };
  }

  private notifyObservers(): void {
    this.observers.forEach((observer) => observer(this.value));
  }
}

/**
 * User ViewModel
 * Exposes reactive properties and commands
 */
export class UserViewModel {
  // Observable properties (for two-way data binding)
  readonly users$: Observable<UserModel[]>;
  readonly selectedUser$: Observable<UserModel | null>;
  readonly formName$: Observable<string>;
  readonly formEmail$: Observable<string>;
  readonly isLoading$: Observable<boolean>;
  readonly error$: Observable<string | null>;

  private service: UserService;

  constructor(service: UserService) {
    this.service = service;

    // Initialize observables
    this.users$ = new Observable<UserModel[]>(service.getAll());
    this.selectedUser$ = new Observable<UserModel | null>(null);
    this.formName$ = new Observable<string>('');
    this.formEmail$ = new Observable<string>('');
    this.isLoading$ = new Observable<boolean>(false);
    this.error$ = new Observable<string | null>(null);
  }

  /**
   * Commands (Methods that modify state)
   */

  loadUsers(): void {
    this.isLoading$.setValue(true);

    try {
      const users = this.service.getAll();
      this.users$.setValue(users);
      this.error$.setValue(null);
    } catch (error) {
      this.error$.setValue(error instanceof Error ? error.message : 'Error loading users');
    } finally {
      this.isLoading$.setValue(false);
    }
  }

  createUser(): void {
    const name = this.formName$.getValue();
    const email = this.formEmail$.getValue();

    if (!name.trim()) {
      this.error$.setValue('Name is required');
      return;
    }

    if (!email.includes('@')) {
      this.error$.setValue('Invalid email format');
      return;
    }

    if (this.service.exists(email)) {
      this.error$.setValue('Email already exists');
      return;
    }

    try {
      this.isLoading$.setValue(true);
      const user = this.service.create(name, email);

      // Update users list
      this.users$.setValue(this.service.getAll());

      // Reset form
      this.formName$.setValue('');
      this.formEmail$.setValue('');
      this.error$.setValue(null);

      this.selectedUser$.setValue(user);
    } catch (error) {
      this.error$.setValue(error instanceof Error ? error.message : 'Error creating user');
    } finally {
      this.isLoading$.setValue(false);
    }
  }

  selectUser(user: UserModel): void {
    this.selectedUser$.setValue(user);
    this.formName$.setValue(user.name);
    this.formEmail$.setValue(user.email);
    this.error$.setValue(null);
  }

  updateSelectedUser(): void {
    const user = this.selectedUser$.getValue();
    if (!user) return;

    const name = this.formName$.getValue();
    const email = this.formEmail$.getValue();

    if (!name.trim()) {
      this.error$.setValue('Name is required');
      return;
    }

    if (!email.includes('@')) {
      this.error$.setValue('Invalid email format');
      return;
    }

    try {
      this.isLoading$.setValue(true);
      const updated = this.service.update(user.id, name, email);

      if (updated) {
        // Update users list and selected user
        this.users$.setValue(this.service.getAll());
        this.selectedUser$.setValue(updated);
        this.formName$.setValue('');
        this.formEmail$.setValue('');
        this.error$.setValue(null);
      }
    } catch (error) {
      this.error$.setValue(error instanceof Error ? error.message : 'Error updating user');
    } finally {
      this.isLoading$.setValue(false);
    }
  }

  deleteSelectedUser(): void {
    const user = this.selectedUser$.getValue();
    if (!user) return;

    try {
      this.isLoading$.setValue(true);
      this.service.delete(user.id);

      // Update users list
      this.users$.setValue(this.service.getAll());
      this.selectedUser$.setValue(null);
      this.formName$.setValue('');
      this.formEmail$.setValue('');
      this.error$.setValue(null);
    } catch (error) {
      this.error$.setValue(error instanceof Error ? error.message : 'Error deleting user');
    } finally {
      this.isLoading$.setValue(false);
    }
  }

  clearForm(): void {
    this.formName$.setValue('');
    this.formEmail$.setValue('');
    this.selectedUser$.setValue(null);
    this.error$.setValue(null);
  }

  /**
   * Computed properties (Derived from observables)
   */

  get hasUsers(): boolean {
    return this.users$.getValue().length > 0;
  }

  get isUserSelected(): boolean {
    return this.selectedUser$.getValue() !== null;
  }

  get canSave(): boolean {
    const name = this.formName$.getValue().trim();
    const email = this.formEmail$.getValue();
    return name.length > 0 && email.includes('@');
  }
}
