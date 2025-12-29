/**
 * MVVM: Model Layer
 * Data and business logic (same as MVC)
 */

export interface IUser {
  id: string;
  name: string;
  email: string;
}

export class UserModel implements IUser {
  id: string;
  name: string;
  email: string;
  createdAt: Date;

  constructor(id: string, name: string, email: string) {
    this.id = id;
    this.name = name;
    this.email = email;
    this.createdAt = new Date();
  }

  isValid(): boolean {
    return this.name.trim().length > 0 && this.email.includes('@');
  }

  clone(): UserModel {
    return new UserModel(this.id, this.name, this.email);
  }

  toJSON() {
    return {
      id: this.id,
      name: this.name,
      email: this.email,
      createdAt: this.createdAt.toISOString(),
    };
  }
}

export class UserService {
  private users: Map<string, UserModel> = new Map();
  private idCounter = 0;

  create(name: string, email: string): UserModel {
    const id = `user_${++this.idCounter}`;
    const user = new UserModel(id, name, email);
    this.users.set(id, user);
    return user;
  }

  getById(id: string): UserModel | undefined {
    return this.users.get(id);
  }

  getAll(): UserModel[] {
    return Array.from(this.users.values());
  }

  update(id: string, name: string, email: string): UserModel | null {
    const user = this.users.get(id);
    if (!user) return null;

    user.name = name;
    user.email = email;
    return user;
  }

  delete(id: string): boolean {
    return this.users.delete(id);
  }

  exists(email: string): boolean {
    return Array.from(this.users.values()).some((u) => u.email === email);
  }
}
