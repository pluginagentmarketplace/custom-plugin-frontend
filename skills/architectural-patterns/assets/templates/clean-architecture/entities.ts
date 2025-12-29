/**
 * Clean Architecture: Entities Layer
 * Core business rules - Independent of frameworks and UI
 */

// Entity: Core domain object with identity
export interface UserId {
  value: string;
}

export interface UserEntity {
  id: UserId;
  name: string;
  email: string;
  createdAt: Date;
  updatedAt: Date;
}

export class User implements UserEntity {
  id: UserId;
  name: string;
  email: string;
  createdAt: Date;
  updatedAt: Date;

  constructor(
    id: UserId,
    name: string,
    email: string,
    createdAt: Date = new Date(),
    updatedAt: Date = new Date()
  ) {
    this.validateEmail(email);
    this.validateName(name);

    this.id = id;
    this.name = name;
    this.email = email;
    this.createdAt = createdAt;
    this.updatedAt = updatedAt;
  }

  // Core business rule: validate email
  private validateEmail(email: string): void {
    if (!email || !email.includes('@')) {
      throw new Error('Invalid email format');
    }
  }

  // Core business rule: validate name
  private validateName(name: string): void {
    if (!name || name.trim().length === 0) {
      throw new Error('Name cannot be empty');
    }
  }

  // Business logic: User can update their profile
  updateProfile(name: string, email: string): void {
    this.validateName(name);
    this.validateEmail(email);

    this.name = name;
    this.email = email;
    this.updatedAt = new Date();
  }

  // Business logic: Check if user account is active
  isAccountActive(): boolean {
    return !!this.id && !!this.name && !!this.email;
  }
}

// Value Object: Immutable, no identity
export class Email {
  readonly value: string;

  constructor(email: string) {
    if (!email.includes('@')) {
      throw new Error('Invalid email');
    }
    this.value = email;
  }

  equals(other: Email): boolean {
    return this.value === other.value;
  }
}

// Business Rule: User creation rule
export class UserCreationRule {
  static canCreateUser(name: string, email: string): boolean {
    return name.trim().length > 0 && email.includes('@');
  }
}
