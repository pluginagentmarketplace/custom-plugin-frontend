#!/bin/bash

################################################################################
# generate-architecture.sh
# Generate Clean Architecture or MVC project scaffold
################################################################################

OUTPUT_DIR="${1:-.}"
PATTERN="${2:-clean}" # clean or mvc
FILENAME="${3:-architecture-scaffold.ts}"

echo "Generating $PATTERN Architecture scaffold..."

if [ "$PATTERN" = "clean" ]; then
  cat > "${OUTPUT_DIR}/${FILENAME}" << 'CLEAN_ARCH_EOF'
/**
 * Clean Architecture Structure
 * 4 layers: Entities, Use Cases, Interface Adapters, Frameworks
 */

// ============================================================================
// LAYER 1: ENTITIES (Business Logic)
// ============================================================================

export interface User {
  id: string;
  name: string;
  email: string;
  createdAt: Date;
}

export interface Product {
  id: string;
  name: string;
  price: number;
  inventory: number;
}

// ============================================================================
// LAYER 2: USE CASES (Application Business Rules)
// ============================================================================

export interface IUserRepository {
  getById(id: string): Promise<User | null>;
  save(user: User): Promise<void>;
  delete(id: string): Promise<void>;
}

export class CreateUserUseCase {
  constructor(private repository: IUserRepository) {}

  async execute(name: string, email: string): Promise<User> {
    const user: User = {
      id: Math.random().toString(),
      name,
      email,
      createdAt: new Date(),
    };

    await this.repository.save(user);
    return user;
  }
}

export class GetUserUseCase {
  constructor(private repository: IUserRepository) {}

  async execute(id: string): Promise<User | null> {
    return this.repository.getById(id);
  }
}

// ============================================================================
// LAYER 3: INTERFACE ADAPTERS (Controllers, Gateways, Presenters)
// ============================================================================

export class UserController {
  constructor(
    private createUserUseCase: CreateUserUseCase,
    private getUserUseCase: GetUserUseCase
  ) {}

  async handleCreateUser(req: CreateUserRequest): Promise<CreateUserResponse> {
    try {
      const user = await this.createUserUseCase.execute(req.name, req.email);
      return {
        success: true,
        data: user,
      };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
      };
    }
  }

  async handleGetUser(req: GetUserRequest): Promise<GetUserResponse> {
    const user = await this.getUserUseCase.execute(req.id);
    return {
      success: user !== null,
      data: user || undefined,
    };
  }
}

export interface CreateUserRequest {
  name: string;
  email: string;
}

export interface CreateUserResponse {
  success: boolean;
  data?: User;
  error?: string;
}

export interface GetUserRequest {
  id: string;
}

export interface GetUserResponse {
  success: boolean;
  data?: User;
}

// ============================================================================
// LAYER 4: FRAMEWORKS & DRIVERS (External Interfaces)
// ============================================================================

// API Gateway / Express Route Handler
export class UserAPI {
  constructor(private controller: UserController) {}

  async createUser(name: string, email: string) {
    return this.controller.handleCreateUser({ name, email });
  }

  async getUser(id: string) {
    return this.controller.handleGetUser({ id });
  }
}

// Database Implementation
export class UserRepositoryImpl implements IUserRepository {
  private db = new Map<string, User>();

  async getById(id: string): Promise<User | null> {
    return this.db.get(id) || null;
  }

  async save(user: User): Promise<void> {
    this.db.set(user.id, user);
  }

  async delete(id: string): Promise<void> {
    this.db.delete(id);
  }
}

// ============================================================================
// DEPENDENCY INJECTION & APPLICATION SETUP
// ============================================================================

export class AppContainer {
  private userRepository: IUserRepository;
  private createUserUseCase: CreateUserUseCase;
  private getUserUseCase: GetUserUseCase;
  private userController: UserController;
  private userAPI: UserAPI;

  constructor() {
    // Layer 4: Infrastructure
    this.userRepository = new UserRepositoryImpl();

    // Layer 2: Use Cases
    this.createUserUseCase = new CreateUserUseCase(this.userRepository);
    this.getUserUseCase = new GetUserUseCase(this.userRepository);

    // Layer 3: Controllers
    this.userController = new UserController(
      this.createUserUseCase,
      this.getUserUseCase
    );

    // Layer 4: API Gateway
    this.userAPI = new UserAPI(this.userController);
  }

  getUserAPI(): UserAPI {
    return this.userAPI;
  }
}

// Usage
const container = new AppContainer();
const api = container.getUserAPI();

CLEAN_ARCH_EOF

elif [ "$PATTERN" = "mvc" ]; then
  cat > "${OUTPUT_DIR}/${FILENAME}" << 'MVC_ARCH_EOF'
/**
 * MVC Architecture Structure
 * Model-View-Controller pattern
 */

// ============================================================================
// MODEL (Data and Business Logic)
// ============================================================================

export interface User {
  id: string;
  name: string;
  email: string;
  role: 'user' | 'admin';
}

export class UserModel {
  private users: Map<string, User> = new Map();

  create(name: string, email: string): User {
    const user: User = {
      id: Math.random().toString(),
      name,
      email,
      role: 'user',
    };

    this.users.set(user.id, user);
    return user;
  }

  getById(id: string): User | undefined {
    return this.users.get(id);
  }

  update(id: string, updates: Partial<User>): User | null {
    const user = this.users.get(id);
    if (!user) return null;

    const updated = { ...user, ...updates };
    this.users.set(id, updated);
    return updated;
  }

  delete(id: string): boolean {
    return this.users.delete(id);
  }

  getAll(): User[] {
    return Array.from(this.users.values());
  }
}

// ============================================================================
// VIEW (Presentation Logic)
// ============================================================================

export class UserView {
  renderUser(user: User): string {
    return `
      <div class="user">
        <h2>${user.name}</h2>
        <p>Email: ${user.email}</p>
        <p>Role: ${user.role}</p>
      </div>
    `;
  }

  renderUserList(users: User[]): string {
    return `
      <ul>
        ${users.map((user) => `<li>${user.name} (${user.email})</li>`).join('')}
      </ul>
    `;
  }

  renderError(error: string): string {
    return `<div class="error">${error}</div>`;
  }

  renderForm(): string {
    return `
      <form id="user-form">
        <input type="text" id="name" placeholder="Name" required>
        <input type="email" id="email" placeholder="Email" required>
        <button type="submit">Create User</button>
      </form>
    `;
  }
}

// ============================================================================
// CONTROLLER (Business Logic & Coordination)
// ============================================================================

export class UserController {
  constructor(private model: UserModel, private view: UserView) {}

  createUser(name: string, email: string): string {
    try {
      const user = this.model.create(name, email);
      return this.view.renderUser(user);
    } catch (error) {
      return this.view.renderError(
        error instanceof Error ? error.message : 'Error creating user'
      );
    }
  }

  getUser(id: string): string {
    const user = this.model.getById(id);
    if (!user) {
      return this.view.renderError('User not found');
    }
    return this.view.renderUser(user);
  }

  listUsers(): string {
    const users = this.model.getAll();
    return this.view.renderUserList(users);
  }

  updateUser(id: string, updates: Partial<User>): string {
    const user = this.model.update(id, updates);
    if (!user) {
      return this.view.renderError('User not found');
    }
    return this.view.renderUser(user);
  }

  deleteUser(id: string): string {
    const success = this.model.delete(id);
    if (!success) {
      return this.view.renderError('User not found');
    }
    return `<p>User deleted successfully</p>`;
  }
}

// ============================================================================
// APPLICATION SETUP
// ============================================================================

export class MvcApp {
  private model: UserModel;
  private view: UserView;
  private controller: UserController;

  constructor() {
    this.model = new UserModel();
    this.view = new UserView();
    this.controller = new UserController(this.model, this.view);

    this.setupEventListeners();
  }

  private setupEventListeners() {
    // Example: Setup form submission listener
    // document.getElementById('user-form')?.addEventListener('submit', (e) => {
    //   e.preventDefault();
    //   const name = (document.getElementById('name') as HTMLInputElement).value;
    //   const email = (document.getElementById('email') as HTMLInputElement).value;
    //   const html = this.controller.createUser(name, email);
    //   document.getElementById('output')!.innerHTML = html;
    // });
  }

  getController(): UserController {
    return this.controller;
  }
}

// Usage
const app = new MvcApp();
const controller = app.getController();

MVC_ARCH_EOF

fi

echo "✓ Generated: ${OUTPUT_DIR}/${FILENAME}"
echo ""
echo "Pattern: $PATTERN"
echo "Copy to your project and adapt to your needs."
