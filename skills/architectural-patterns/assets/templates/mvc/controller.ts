/**
 * MVC: Controller Layer
 * Coordinates between Model and View
 * Handles user interactions and updates model/view
 */

import { UserModel, UserStore } from './model';

// Observer pattern for view updates
export interface ViewObserver {
  onUsersChanged(users: UserModel[]): void;
  onError(error: string): void;
}

// User Controller
export class UserController {
  private store: UserStore;
  private observers: ViewObserver[] = [];
  private userIdCounter: number = 0;

  constructor(store: UserStore) {
    this.store = store;
  }

  // Register view observers (MVC communication)
  subscribe(observer: ViewObserver): void {
    this.observers.push(observer);
  }

  unsubscribe(observer: ViewObserver): void {
    this.observers = this.observers.filter((obs) => obs !== observer);
  }

  // Notify all observers
  private notifyObservers(): void {
    const users = this.store.getAll();
    this.observers.forEach((observer) => observer.onUsersChanged(users));
  }

  private notifyError(error: string): void {
    this.observers.forEach((observer) => observer.onError(error));
  }

  // User CRUD operations
  createUser(name: string, email: string): void {
    try {
      // Check for duplicate email
      if (this.store.findByEmail(email)) {
        throw new Error('User with this email already exists');
      }

      const id = `user_${++this.userIdCounter}`;
      const user = new UserModel(id, name, email);
      this.store.add(user);

      this.notifyObservers();
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Failed to create user';
      this.notifyError(message);
    }
  }

  getUser(id: string): UserModel | undefined {
    return this.store.get(id);
  }

  getAllUsers(): UserModel[] {
    return this.store.getAll();
  }

  updateUser(id: string, name: string, email: string): void {
    try {
      const user = this.store.get(id);
      if (!user) {
        throw new Error('User not found');
      }

      // Check for duplicate email (excluding current user)
      const existingUser = this.store.findByEmail(email);
      if (existingUser && existingUser.getId() !== id) {
        throw new Error('Email already in use');
      }

      user.setName(name);
      user.setEmail(email);
      this.store.update(user);

      this.notifyObservers();
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Failed to update user';
      this.notifyError(message);
    }
  }

  deleteUser(id: string): void {
    try {
      const deleted = this.store.delete(id);
      if (!deleted) {
        throw new Error('User not found');
      }

      this.notifyObservers();
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Failed to delete user';
      this.notifyError(message);
    }
  }

  // Business logic
  getUserCount(): number {
    return this.store.size();
  }

  getUsersByDomain(domain: string): UserModel[] {
    return this.store.getAll().filter((user) => user.isEmailDomain(domain));
  }

  searchUsers(query: string): UserModel[] {
    const lower = query.toLowerCase();
    return this.store.getAll().filter((user) => {
      const name = user.getName().toLowerCase();
      const email = user.getEmail().toLowerCase();
      return name.includes(lower) || email.includes(lower);
    });
  }

  // Data export
  exportUsers(): object[] {
    return this.store.getAll().map((user) => user.toJSON());
  }
}

// React Hook for MVC integration
export function useMvcController(store: UserStore) {
  const controllerRef = React.useRef<UserController | null>(null);
  const [users, setUsers] = React.useState<UserModel[]>([]);
  const [error, setError] = React.useState<string | null>(null);

  React.useEffect(() => {
    const controller = new UserController(store);

    const observer: ViewObserver = {
      onUsersChanged(users: UserModel[]) {
        setUsers([...users]); // Create new array for React re-render
        setError(null);
      },
      onError(error: string) {
        setError(error);
      },
    };

    controller.subscribe(observer);
    setUsers(controller.getAllUsers());

    controllerRef.current = controller;

    return () => {
      controller.unsubscribe(observer);
    };
  }, [store]);

  return {
    controller: controllerRef.current!,
    users,
    error,
  };
}

// Alternative: Plain object approach for non-React usage
export interface IMvcModel {
  data: UserModel[];
  error: string | null;
}

export class SimpleMvcController {
  private model: IMvcModel = { data: [], error: null };
  private store: UserStore;

  constructor(store: UserStore) {
    this.store = store;
    this.model.data = store.getAll();
  }

  getModel(): IMvcModel {
    return this.model;
  }

  updateModel(): void {
    this.model.data = this.store.getAll();
  }

  handleCreateUser(name: string, email: string): void {
    try {
      const id = `user_${Date.now()}`;
      const user = new UserModel(id, name, email);
      this.store.add(user);
      this.updateModel();
      this.model.error = null;
    } catch (error) {
      this.model.error = error instanceof Error ? error.message : 'Error creating user';
    }
  }

  handleUpdateUser(id: string, name: string, email: string): void {
    try {
      const user = this.store.get(id);
      if (!user) {
        throw new Error('User not found');
      }

      user.setName(name);
      user.setEmail(email);
      this.store.update(user);
      this.updateModel();
      this.model.error = null;
    } catch (error) {
      this.model.error = error instanceof Error ? error.message : 'Error updating user';
    }
  }

  handleDeleteUser(id: string): void {
    try {
      this.store.delete(id);
      this.updateModel();
      this.model.error = null;
    } catch (error) {
      this.model.error = error instanceof Error ? error.message : 'Error deleting user';
    }
  }
}
