/**
 * Clean Architecture: Use Cases (Application Business Rules)
 * Orchestrates entities and implements application-specific business rules
 */

import { User, UserId, Email } from './entities';

// Repository Interface (abstraction, points inward)
export interface IUserRepository {
  findById(id: UserId): Promise<User | null>;
  findByEmail(email: string): Promise<User | null>;
  save(user: User): Promise<void>;
  delete(id: UserId): Promise<void>;
}

// Use Case Input/Output (Data Transfer Objects)
export interface CreateUserRequest {
  id: string;
  name: string;
  email: string;
}

export interface CreateUserResponse {
  success: boolean;
  userId?: string;
  error?: string;
}

// Use Case: Create User
export class CreateUserUseCase {
  constructor(private userRepository: IUserRepository) {}

  async execute(request: CreateUserRequest): Promise<CreateUserResponse> {
    try {
      // Application rule: Check if user with email already exists
      const existingUser = await this.userRepository.findByEmail(request.email);
      if (existingUser) {
        return {
          success: false,
          error: 'User with this email already exists',
        };
      }

      // Create entity with business logic
      const userId: UserId = { value: request.id };
      const user = new User(userId, request.name, request.email);

      // Persist entity
      await this.userRepository.save(user);

      return {
        success: true,
        userId: user.id.value,
      };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
      };
    }
  }
}

// Use Case: Update User
export interface UpdateUserRequest {
  userId: string;
  name: string;
  email: string;
}

export class UpdateUserUseCase {
  constructor(private userRepository: IUserRepository) {}

  async execute(request: UpdateUserRequest): Promise<CreateUserResponse> {
    try {
      // Fetch entity
      const user = await this.userRepository.findById({
        value: request.userId,
      });

      if (!user) {
        return {
          success: false,
          error: 'User not found',
        };
      }

      // Apply business logic through entity
      user.updateProfile(request.name, request.email);

      // Persist changes
      await this.userRepository.save(user);

      return {
        success: true,
        userId: user.id.value,
      };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
      };
    }
  }
}

// Use Case: Delete User
export class DeleteUserUseCase {
  constructor(private userRepository: IUserRepository) {}

  async execute(userId: string): Promise<CreateUserResponse> {
    try {
      const user = await this.userRepository.findById({ value: userId });

      if (!user) {
        return {
          success: false,
          error: 'User not found',
        };
      }

      await this.userRepository.delete({ value: userId });

      return {
        success: true,
      };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
      };
    }
  }
}

// Use Case: Get User
export class GetUserUseCase {
  constructor(private userRepository: IUserRepository) {}

  async execute(userId: string): Promise<{ success: boolean; user?: User; error?: string }> {
    try {
      const user = await this.userRepository.findById({ value: userId });

      if (!user) {
        return {
          success: false,
          error: 'User not found',
        };
      }

      return {
        success: true,
        user,
      };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
      };
    }
  }
}
