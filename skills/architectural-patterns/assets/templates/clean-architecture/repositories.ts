/**
 * Clean Architecture: Frameworks & Drivers (Infrastructure Layer)
 * Concrete implementations of interfaces - Depends on inner layers
 */

import { User, UserId } from './entities';
import { IUserRepository } from './use-cases';

// In-Memory Database (Example implementation)
interface UserRecord {
  id: string;
  name: string;
  email: string;
  createdAt: string;
  updatedAt: string;
}

export class InMemoryUserRepository implements IUserRepository {
  private users: Map<string, UserRecord> = new Map();

  async findById(id: UserId): Promise<User | null> {
    const record = this.users.get(id.value);
    if (!record) return null;

    return new User(
      { value: record.id },
      record.name,
      record.email,
      new Date(record.createdAt),
      new Date(record.updatedAt)
    );
  }

  async findByEmail(email: string): Promise<User | null> {
    for (const record of this.users.values()) {
      if (record.email === email) {
        return new User(
          { value: record.id },
          record.name,
          record.email,
          new Date(record.createdAt),
          new Date(record.updatedAt)
        );
      }
    }
    return null;
  }

  async save(user: User): Promise<void> {
    const record: UserRecord = {
      id: user.id.value,
      name: user.name,
      email: user.email,
      createdAt: user.createdAt.toISOString(),
      updatedAt: user.updatedAt.toISOString(),
    };

    this.users.set(user.id.value, record);
  }

  async delete(id: UserId): Promise<void> {
    this.users.delete(id.value);
  }
}

// Database Interface (for real database)
export interface IDatabaseConnection {
  query(sql: string, params: any[]): Promise<any[]>;
  execute(sql: string, params: any[]): Promise<void>;
  close(): Promise<void>;
}

// PostgreSQL Repository (Example - not implemented)
export class PostgresUserRepository implements IUserRepository {
  constructor(private db: IDatabaseConnection) {}

  async findById(id: UserId): Promise<User | null> {
    const results = await this.db.query(
      'SELECT * FROM users WHERE id = $1',
      [id.value]
    );

    if (results.length === 0) return null;

    const row = results[0];
    return new User(
      { value: row.id },
      row.name,
      row.email,
      new Date(row.created_at),
      new Date(row.updated_at)
    );
  }

  async findByEmail(email: string): Promise<User | null> {
    const results = await this.db.query(
      'SELECT * FROM users WHERE email = $1',
      [email]
    );

    if (results.length === 0) return null;

    const row = results[0];
    return new User(
      { value: row.id },
      row.name,
      row.email,
      new Date(row.created_at),
      new Date(row.updated_at)
    );
  }

  async save(user: User): Promise<void> {
    const now = new Date();

    await this.db.execute(
      `INSERT INTO users (id, name, email, created_at, updated_at)
       VALUES ($1, $2, $3, $4, $5)
       ON CONFLICT (id) DO UPDATE SET
       name = $2, email = $3, updated_at = $5`,
      [
        user.id.value,
        user.name,
        user.email,
        user.createdAt.toISOString(),
        user.updatedAt.toISOString(),
      ]
    );
  }

  async delete(id: UserId): Promise<void> {
    await this.db.execute('DELETE FROM users WHERE id = $1', [id.value]);
  }
}

// Factory: Creates appropriate repository based on environment
export class RepositoryFactory {
  static createUserRepository(type: 'memory' | 'postgres', db?: IDatabaseConnection): IUserRepository {
    if (type === 'memory') {
      return new InMemoryUserRepository();
    }

    if (type === 'postgres' && db) {
      return new PostgresUserRepository(db);
    }

    throw new Error(`Unknown repository type: ${type}`);
  }
}
