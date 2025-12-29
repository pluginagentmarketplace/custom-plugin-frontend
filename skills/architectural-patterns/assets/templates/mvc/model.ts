/**
 * MVC: Model Layer
 * Data and business logic encapsulation
 */

// User Model: Contains data and business logic
export class UserModel {
  private id: string;
  private name: string;
  private email: string;
  private createdAt: Date;

  constructor(id: string, name: string, email: string) {
    this.validateEmail(email);
    this.validateName(name);

    this.id = id;
    this.name = name;
    this.email = email;
    this.createdAt = new Date();
  }

  // Getters
  getId(): string {
    return this.id;
  }

  getName(): string {
    return this.name;
  }

  getEmail(): string {
    return this.email;
  }

  getCreatedAt(): Date {
    return this.createdAt;
  }

  // Setters with validation
  setName(name: string): void {
    this.validateName(name);
    this.name = name;
  }

  setEmail(email: string): void {
    this.validateEmail(email);
    this.email = email;
  }

  // Validation logic
  private validateEmail(email: string): void {
    if (!email || !email.includes('@')) {
      throw new Error('Invalid email format');
    }
  }

  private validateName(name: string): void {
    if (!name || name.trim().length === 0) {
      throw new Error('Name cannot be empty');
    }
  }

  // Business logic
  getFullInfo(): string {
    return `${this.name} (${this.email})`;
  }

  isEmailDomain(domain: string): boolean {
    return this.email.endsWith(`@${domain}`);
  }

  // Convert to plain object
  toJSON() {
    return {
      id: this.id,
      name: this.name,
      email: this.email,
      createdAt: this.createdAt.toISOString(),
    };
  }

  // Create from plain object (deserialization)
  static fromJSON(obj: any): UserModel {
    const user = new UserModel(obj.id, obj.name, obj.email);
    return user;
  }
}

// In-Memory Storage (Simple database simulation)
export class UserStore {
  private users: Map<string, UserModel> = new Map();

  add(user: UserModel): void {
    if (this.users.has(user.getId())) {
      throw new Error('User already exists');
    }
    this.users.set(user.getId(), user);
  }

  get(id: string): UserModel | undefined {
    return this.users.get(id);
  }

  getAll(): UserModel[] {
    return Array.from(this.users.values());
  }

  update(user: UserModel): void {
    if (!this.users.has(user.getId())) {
      throw new Error('User not found');
    }
    this.users.set(user.getId(), user);
  }

  delete(id: string): boolean {
    return this.users.delete(id);
  }

  findByEmail(email: string): UserModel | undefined {
    for (const user of this.users.values()) {
      if (user.getEmail() === email) {
        return user;
      }
    }
    return undefined;
  }

  clear(): void {
    this.users.clear();
  }

  size(): number {
    return this.users.size;
  }
}
