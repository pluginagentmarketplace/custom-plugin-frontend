# TypeScript Enterprise Patterns

Production-ready patterns for advanced TypeScript development.

## Generic Factory Pattern

Create instances safely with type preservation:

```typescript
interface Entity {
  id: string;
}

interface IFactory<T extends Entity> {
  create(data: Partial<T>): T;
}

class Factory<T extends Entity> implements IFactory<T> {
  constructor(
    private EntityClass: new (data: Partial<T>) => T,
    private defaults: Partial<T> = {}
  ) {}

  create(data: Partial<T>): T {
    return new this.EntityClass({
      ...this.defaults,
      ...data,
      id: data.id || this.generateId()
    });
  }

  private generateId(): string {
    return Math.random().toString(36).substr(2, 9);
  }
}

// Usage
class User implements Entity {
  id!: string;
  name!: string;
  email!: string;

  constructor(data: Partial<User>) {
    Object.assign(this, data);
  }
}

class UserFactory extends Factory<User> {
  constructor() {
    super(User, { name: 'Unknown' });
  }
}

const userFactory = new UserFactory();
const user = userFactory.create({ email: 'john@example.com' });
```

## Decorator Patterns

### Validation Decorator

```typescript
function ValidateString(minLength: number = 0, maxLength: number = 255) {
  return function (target: any, propertyKey: string, descriptor: PropertyDescriptor) {
    const originalMethod = descriptor.value;

    descriptor.value = function (value: string) {
      if (typeof value !== 'string') {
        throw new TypeError(`${propertyKey} must be a string`);
      }
      if (value.length < minLength) {
        throw new Error(`${propertyKey} must be at least ${minLength} characters`);
      }
      if (value.length > maxLength) {
        throw new Error(`${propertyKey} must not exceed ${maxLength} characters`);
      }
      return originalMethod.call(this, value);
    };

    return descriptor;
  };
}

class User {
  @ValidateString(1, 100)
  setName(name: string): void {
    console.log(`Name set to ${name}`);
  }
}
```

### Memoization Decorator

```typescript
function Memoize<This, Args extends any[], Return>(
  target: (this: This, ...args: Args) => Return,
  context: ClassMethodDecoratorContext<This, (this: This, ...args: Args) => Return>
) {
  const cache = new Map<string, Return>();

  return function (this: This, ...args: Args): Return {
    const key = JSON.stringify(args);

    if (cache.has(key)) {
      console.log(`Cache hit for ${String(context.name)}`);
      return cache.get(key)!;
    }

    const result = target.apply(this, args);
    cache.set(key, result);
    return result;
  };
}

class Calculator {
  @Memoize
  fibonacci(n: number): number {
    if (n <= 1) return n;
    return this.fibonacci(n - 1) + this.fibonacci(n - 2);
  }
}
```

### Logging Decorator

```typescript
function Log() {
  return function (
    target: any,
    propertyKey: string,
    descriptor: PropertyDescriptor
  ) {
    const originalMethod = descriptor.value;

    descriptor.value = async function (...args: any[]) {
      console.log(`[${new Date().toISOString()}] Calling ${propertyKey}`);
      console.log('Arguments:', args);

      try {
        const result = await originalMethod.apply(this, args);
        console.log('Result:', result);
        return result;
      } catch (error) {
        console.error('Error:', error);
        throw error;
      }
    };

    return descriptor;
  };
}

class UserService {
  @Log()
  async getUser(id: string): Promise<any> {
    return fetch(`/api/users/${id}`).then(r => r.json());
  }
}
```

## Type-Safe Discriminated Unions

### State Management Pattern

```typescript
type LoadingState = { status: 'loading' };
type SuccessState<T> = { status: 'success'; data: T };
type ErrorState = { status: 'error'; error: string };

type AsyncState<T> = LoadingState | SuccessState<T> | ErrorState;

function isSuccess<T>(state: AsyncState<T>): state is SuccessState<T> {
  return state.status === 'success';
}

function handleState<T>(state: AsyncState<T>): T | null {
  switch (state.status) {
    case 'loading':
      return null;
    case 'success':
      return state.data;
    case 'error':
      throw new Error(state.error);
  }
}

// React Hook Example
function useAsync<T>(fn: () => Promise<T>) {
  const [state, setState] = useState<AsyncState<T>>({ status: 'loading' });

  useEffect(() => {
    fn()
      .then(data => setState({ status: 'success', data }))
      .catch(error => setState({ status: 'error', error: error.message }));
  }, [fn]);

  return state;
}
```

## Inversion of Control Container

```typescript
type ServiceProvider<T> = () => T;

class Container {
  private services = new Map<string | Symbol, any>();
  private singletons = new Map<string | Symbol, any>();

  register<T>(token: string | Symbol, provider: ServiceProvider<T>, singleton = false) {
    this.services.set(token, { provider, singleton });
  }

  resolve<T>(token: string | Symbol): T {
    const registration = this.services.get(token);

    if (!registration) {
      throw new Error(`No service registered for ${String(token)}`);
    }

    // Return cached singleton
    if (registration.singleton && this.singletons.has(token)) {
      return this.singletons.get(token);
    }

    // Create new instance
    const instance = registration.provider();

    // Cache singleton
    if (registration.singleton) {
      this.singletons.set(token, instance);
    }

    return instance;
  }
}

// Usage with type safety
interface Logger {
  log(message: string): void;
}

class ConsoleLogger implements Logger {
  log(message: string): void {
    console.log(`[LOG] ${message}`);
  }
}

const container = new Container();
container.register<Logger>('logger', () => new ConsoleLogger(), true);

const logger = container.resolve<Logger>('logger');
logger.log('Hello'); // [LOG] Hello
```

## Type-Safe Event Emitter

```typescript
type EventMap = Record<string, any>;

abstract class TypedEventEmitter<Events extends EventMap> {
  private listeners = new Map<keyof Events, Function[]>();

  on<K extends keyof Events>(
    event: K,
    listener: (data: Events[K]) => void
  ): this {
    if (!this.listeners.has(event)) {
      this.listeners.set(event, []);
    }
    this.listeners.get(event)!.push(listener);
    return this;
  }

  emit<K extends keyof Events>(event: K, data: Events[K]): boolean {
    const callbacks = this.listeners.get(event);
    if (!callbacks) return false;

    callbacks.forEach(callback => callback(data));
    return true;
  }

  off<K extends keyof Events>(event: K, listener: Function): this {
    const callbacks = this.listeners.get(event);
    if (!callbacks) return this;

    const index = callbacks.indexOf(listener);
    if (index !== -1) callbacks.splice(index, 1);

    return this;
  }
}

// Usage
interface UserEvents {
  'user:created': { id: string; name: string };
  'user:deleted': { id: string };
  'user:updated': { id: string; changes: Record<string, any> };
}

class UserEventEmitter extends TypedEventEmitter<UserEvents> {}

const emitter = new UserEventEmitter();

// Type-safe listeners
emitter.on('user:created', (data) => {
  console.log(`User created: ${data.name}`); // data is typed!
  // console.log(data.invalid); // Error!
});

emitter.emit('user:created', { id: '1', name: 'John' });
```

## Chaining Builder Pattern

```typescript
class QueryBuilder<T> {
  private filters: ((item: T) => boolean)[] = [];
  private mappers: ((item: T) => any)[] = [];
  private limit?: number;

  where(predicate: (item: T) => boolean): this {
    this.filters.push(predicate);
    return this;
  }

  select<K extends keyof T>(...keys: K[]): QueryBuilder<Pick<T, K>> {
    return this as any;
  }

  limit(count: number): this {
    this.limit = count;
    return this;
  }

  map<U>(mapper: (item: T) => U): QueryBuilder<U> {
    this.mappers.push(mapper as any);
    return this as any;
  }

  execute(items: T[]): any[] {
    let results = items;

    // Apply filters
    for (const filter of this.filters) {
      results = results.filter(filter);
    }

    // Apply limit
    if (this.limit) {
      results = results.slice(0, this.limit);
    }

    // Apply mappers
    for (const mapper of this.mappers) {
      results = results.map(mapper);
    }

    return results;
  }
}

// Type-safe chaining
interface User {
  id: number;
  name: string;
  email: string;
  age: number;
}

const users: User[] = [
  { id: 1, name: 'John', email: 'john@example.com', age: 30 },
  { id: 2, name: 'Jane', email: 'jane@example.com', age: 25 }
];

const results = new QueryBuilder<User>()
  .where(u => u.age > 20)
  .limit(10)
  .execute(users);
```

These patterns provide enterprise-grade approaches for building scalable, maintainable TypeScript applications with maximum type safety and minimal runtime errors.
