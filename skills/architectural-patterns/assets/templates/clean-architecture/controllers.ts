/**
 * Clean Architecture: Interface Adapters (Controllers Layer)
 * Converts external input to internal format and vice versa
 */

import {
  CreateUserUseCase,
  CreateUserRequest,
  CreateUserResponse,
  UpdateUserUseCase,
  UpdateUserRequest,
  DeleteUserUseCase,
  GetUserUseCase,
} from './use-cases';
import { User } from './entities';

// HTTP Request/Response DTOs
export interface CreateUserHttpRequest {
  name: string;
  email: string;
}

export interface UserHttpResponse {
  id: string;
  name: string;
  email: string;
  createdAt: string;
  updatedAt: string;
}

export interface HttpResponse<T> {
  status: number;
  data?: T;
  error?: string;
}

// User Controller: Handles HTTP requests
export class UserController {
  constructor(
    private createUserUseCase: CreateUserUseCase,
    private updateUserUseCase: UpdateUserUseCase,
    private deleteUserUseCase: DeleteUserUseCase,
    private getUserUseCase: GetUserUseCase
  ) {}

  // Convert HTTP request to use case request
  async handleCreateUser(
    httpRequest: CreateUserHttpRequest
  ): Promise<HttpResponse<{ userId: string }>> {
    try {
      const useCaseRequest: CreateUserRequest = {
        id: this.generateId(),
        name: httpRequest.name,
        email: httpRequest.email,
      };

      const response = await this.createUserUseCase.execute(useCaseRequest);

      if (!response.success) {
        return {
          status: 400,
          error: response.error,
        };
      }

      return {
        status: 201,
        data: { userId: response.userId! },
      };
    } catch (error) {
      return {
        status: 500,
        error: 'Internal server error',
      };
    }
  }

  async handleUpdateUser(
    userId: string,
    httpRequest: CreateUserHttpRequest
  ): Promise<HttpResponse<{ userId: string }>> {
    try {
      const useCaseRequest: UpdateUserRequest = {
        userId,
        name: httpRequest.name,
        email: httpRequest.email,
      };

      const response = await this.updateUserUseCase.execute(useCaseRequest);

      if (!response.success) {
        return {
          status: 400,
          error: response.error,
        };
      }

      return {
        status: 200,
        data: { userId: response.userId! },
      };
    } catch (error) {
      return {
        status: 500,
        error: 'Internal server error',
      };
    }
  }

  async handleDeleteUser(userId: string): Promise<HttpResponse<null>> {
    try {
      const response = await this.deleteUserUseCase.execute(userId);

      if (!response.success) {
        return {
          status: 400,
          error: response.error,
        };
      }

      return {
        status: 200,
        data: null,
      };
    } catch (error) {
      return {
        status: 500,
        error: 'Internal server error',
      };
    }
  }

  async handleGetUser(userId: string): Promise<HttpResponse<UserHttpResponse>> {
    try {
      const response = await this.getUserUseCase.execute(userId);

      if (!response.success) {
        return {
          status: 404,
          error: response.error,
        };
      }

      const user = response.user!;
      return {
        status: 200,
        data: {
          id: user.id.value,
          name: user.name,
          email: user.email,
          createdAt: user.createdAt.toISOString(),
          updatedAt: user.updatedAt.toISOString(),
        },
      };
    } catch (error) {
      return {
        status: 500,
        error: 'Internal server error',
      };
    }
  }

  // Presenter: Format response
  presentUser(user: User): UserHttpResponse {
    return {
      id: user.id.value,
      name: user.name,
      email: user.email,
      createdAt: user.createdAt.toISOString(),
      updatedAt: user.updatedAt.toISOString(),
    };
  }

  private generateId(): string {
    return `user_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }
}

// Presenter: Separate presentation logic
export class UserPresenter {
  static toHttpResponse(user: User): UserHttpResponse {
    return {
      id: user.id.value,
      name: user.name,
      email: user.email,
      createdAt: user.createdAt.toISOString(),
      updatedAt: user.updatedAt.toISOString(),
    };
  }

  static formatError(error: Error): { message: string; code: string } {
    if (error.message.includes('email')) {
      return {
        message: 'Invalid email format',
        code: 'INVALID_EMAIL',
      };
    }

    return {
      message: error.message,
      code: 'UNKNOWN_ERROR',
    };
  }
}
