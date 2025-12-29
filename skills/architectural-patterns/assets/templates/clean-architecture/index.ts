/**
 * Clean Architecture: Complete Example
 * Shows how all layers work together
 */

import { User, UserId } from './entities';
import {
  CreateUserUseCase,
  UpdateUserUseCase,
  DeleteUserUseCase,
  GetUserUseCase,
  IUserRepository,
} from './use-cases';
import { UserController, CreateUserHttpRequest } from './controllers';
import { InMemoryUserRepository } from './repositories';

/**
 * Application Setup (Composition Root)
 * This is where dependencies are wired together
 * This layer depends on all inner layers
 */
export class Application {
  private repository: IUserRepository;
  private userController: UserController;

  constructor() {
    // Create infrastructure layer
    this.repository = new InMemoryUserRepository();

    // Create use cases (application layer)
    const createUserUseCase = new CreateUserUseCase(this.repository);
    const updateUserUseCase = new UpdateUserUseCase(this.repository);
    const deleteUserUseCase = new DeleteUserUseCase(this.repository);
    const getUserUseCase = new GetUserUseCase(this.repository);

    // Create controller (interface adapter layer)
    this.userController = new UserController(
      createUserUseCase,
      updateUserUseCase,
      deleteUserUseCase,
      getUserUseCase
    );
  }

  // Simulate HTTP endpoint
  async createUser(request: CreateUserHttpRequest) {
    return this.userController.handleCreateUser(request);
  }

  async getUser(userId: string) {
    return this.userController.handleGetUser(userId);
  }

  async updateUser(userId: string, request: CreateUserHttpRequest) {
    return this.userController.handleUpdateUser(userId, request);
  }

  async deleteUser(userId: string) {
    return this.userController.handleDeleteUser(userId);
  }
}

// Example usage
export async function runExample() {
  const app = new Application();

  console.log('=== Clean Architecture Example ===\n');

  // Create user
  const createResponse = await app.createUser({
    name: 'John Doe',
    email: 'john@example.com',
  });
  console.log('Create User:', createResponse);

  if (createResponse.data) {
    const userId = createResponse.data.userId;

    // Get user
    const getResponse = await app.getUser(userId);
    console.log('\nGet User:', getResponse);

    // Update user
    const updateResponse = await app.updateUser(userId, {
      name: 'Jane Doe',
      email: 'jane@example.com',
    });
    console.log('\nUpdate User:', updateResponse);

    // Delete user
    const deleteResponse = await app.deleteUser(userId);
    console.log('\nDelete User:', deleteResponse);
  }
}

/**
 * CLEAN ARCHITECTURE PRINCIPLES DEMONSTRATED:
 *
 * 1. LAYERED STRUCTURE:
 *    - Entities (Core business logic)
 *    - Use Cases (Application business rules)
 *    - Interface Adapters (Controllers, Presenters)
 *    - Frameworks & Drivers (Repositories, External services)
 *
 * 2. DEPENDENCY RULE:
 *    - Source code dependencies point inward
 *    - Outer layers depend on inner layers
 *    - Inner layers know nothing about outer layers
 *
 * 3. INDEPENDENCE:
 *    - Independent of frameworks (Express, FastAPI, etc.)
 *    - Independent of databases (PostgreSQL, MongoDB, etc.)
 *    - Independent of UI (Web, Mobile, CLI)
 *    - Testable in isolation
 *
 * 4. BENEFITS:
 *    - Core business logic stays pure and testable
 *    - Easy to swap implementations (DB, HTTP framework)
 *    - Long-term maintainability
 *    - Clear separation of concerns
 *
 * 5. KEY CONCEPTS:
 *    - Entities: No dependencies on anything
 *    - Use Cases: Depend only on entities and repository interface
 *    - Controllers: Depend on use cases
 *    - Repositories: Implement repository interface (depend on entities)
 */
