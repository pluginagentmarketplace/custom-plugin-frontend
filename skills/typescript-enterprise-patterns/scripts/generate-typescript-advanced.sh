#!/bin/bash
# Advanced TypeScript Generator - Creates enterprise patterns

set -e

PROJECT_PATH="${1:-.}"
mkdir -p "$PROJECT_PATH/src/patterns"

echo "Advanced TypeScript Generator"
echo "============================="
echo ""

# 1. Generic Factory Pattern
echo "📝 Generating generic factory pattern..."
cat > "$PROJECT_PATH/src/patterns/factory.ts" << 'EOF'
/**
 * Generic Factory Pattern
 * Creates instances with type safety
 */

// Base interface for entities with ID
interface Entity {
  id: string;
  createdAt: Date;
}

// Factory interface
interface IFactory<T extends Entity> {
  create(data: Partial<T>): T;
  createBatch(count: number, factory: () => Partial<T>): T[];
}

// Generic factory implementation
class Factory<T extends Entity> implements IFactory<T> {
  constructor(
    private EntityClass: new (data: Partial<T>) => T,
    private defaults: Partial<T> = {}
  ) {}

  create(data: Partial<T>): T {
    return new this.EntityClass({
      ...this.defaults,
      ...data,
      id: data.id || this.generateId(),
      createdAt: new Date()
    });
  }

  createBatch(count: number, factory: () => Partial<T>): T[] {
    return Array.from({ length: count }, () =>
      this.create(factory())
    );
  }

  private generateId(): string {
    return `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
  }
}

// Usage example
interface User extends Entity {
  name: string;
  email: string;
}

class UserFactory extends Factory<User> {
  constructor() {
    super(
      class User implements User {
        id!: string;
        createdAt!: Date;
        name!: string;
        email!: string;

        constructor(data: Partial<User>) {
          Object.assign(this, data);
        }
      },
      { name: 'Unknown User' }
    );
  }
}

// Type-safe usage
const userFactory = new UserFactory();
const user = userFactory.create({ name: 'John', email: 'john@example.com' });
const users = userFactory.createBatch(10, () => ({
  name: `User ${Math.random()}`,
  email: `user${Math.random()}@example.com`
}));
EOF
echo "✓ Created: src/patterns/factory.ts"

# 2. Decorators Pattern
echo "📝 Generating decorator patterns..."
cat > "$PROJECT_PATH/src/patterns/decorators.ts" << 'EOF'
/**
 * Decorator Patterns
 * Cross-cutting concerns: validation, caching, logging
 */

// Validation Decorator
function Validate(predicate: (value: any) => boolean, message: string) {
  return function (target: any, propertyKey: string, descriptor: PropertyDescriptor) {
    const originalMethod = descriptor.value;

    descriptor.value = function (...args: any[]) {
      if (!predicate(args[0])) {
        throw new Error(`Validation failed: ${message}`);
      }
      return originalMethod.apply(this, args);
    };

    return descriptor;
  };
}

// Memoization Decorator
function Memoize() {
  const cache = new Map();

  return function (target: any, propertyKey: string, descriptor: PropertyDescriptor) {
    const originalMethod = descriptor.value;

    descriptor.value = function (...args: any[]) {
      const key = JSON.stringify(args);

      if (cache.has(key)) {
        console.log(`Cache hit for ${propertyKey}`);
        return cache.get(key);
      }

      const result = originalMethod.apply(this, args);
      cache.set(key, result);
      return result;
    };

    return descriptor;
  };
}

// Logging Decorator
function Log() {
  return function (target: any, propertyKey: string, descriptor: PropertyDescriptor) {
    const originalMethod = descriptor.value;

    descriptor.value = function (...args: any[]) {
      console.log(`Calling ${propertyKey} with args:`, args);
      const result = originalMethod.apply(this, args);
      console.log(`${propertyKey} returned:`, result);
      return result;
    };

    return descriptor;
  };
}

// Usage
class Calculator {
  @Log()
  @Memoize()
  @Validate(
    (n) => typeof n === 'number',
    'Argument must be a number'
  )
  fibonacci(n: number): number {
    if (n <= 1) return n;
    return this.fibonacci(n - 1) + this.fibonacci(n - 2);
  }
}

const calc = new Calculator();
console.log(calc.fibonacci(5)); // Logs and memoizes
EOF
echo "✓ Created: src/patterns/decorators.ts"

# 3. Discriminated Unions
echo "📝 Generating discriminated union patterns..."
cat > "$PROJECT_PATH/src/patterns/discriminated-unions.ts" << 'EOF'
/**
 * Discriminated Union Types
 * Type-safe polymorphism with perfect exhaustiveness checking
 */

// Define discriminated union for API responses
type ApiResponse<T> =
  | { status: 'success'; data: T }
  | { status: 'error'; error: Error }
  | { status: 'loading' }
  | { status: 'idle' };

// Type guard for discriminated unions
function isSuccess<T>(response: ApiResponse<T>): response is { status: 'success'; data: T } {
  return response.status === 'success';
}

function isError(response: any): response is { status: 'error'; error: Error } {
  return response.status === 'error';
}

// Usage with exhaustiveness checking
function handleResponse<T>(response: ApiResponse<T>): T | null {
  switch (response.status) {
    case 'success':
      return response.data;
    case 'error':
      console.error(response.error);
      return null;
    case 'loading':
      return null;
    case 'idle':
      return null;
    // TypeScript error if you forget a case!
  }
}

// Another example: Event handling
type Event =
  | { type: 'click'; x: number; y: number }
  | { type: 'scroll'; y: number }
  | { type: 'resize'; width: number; height: number }
  | { type: 'keydown'; key: string };

function handleEvent(event: Event): void {
  switch (event.type) {
    case 'click':
      console.log(`Clicked at ${event.x}, ${event.y}`);
      break;
    case 'scroll':
      console.log(`Scrolled to ${event.y}`);
      break;
    case 'resize':
      console.log(`Resized to ${event.width}x${event.height}`);
      break;
    case 'keydown':
      console.log(`Key pressed: ${event.key}`);
      break;
  }
}
EOF
echo "✓ Created: src/patterns/discriminated-unions.ts"

# 4. Advanced Utility Types
echo "📝 Generating advanced utility types..."
cat > "$PROJECT_PATH/src/patterns/utility-types.ts" << 'EOF'
/**
 * Advanced TypeScript Utility Types
 * Powerful type manipulation techniques
 */

// Recursive type for deeply nested structures
type DeepPartial<T> = T extends object
  ? {
      [P in keyof T]?: DeepPartial<T[P]>;
    }
  : T;

// Make all properties readonly recursively
type DeepReadonly<T> = T extends object
  ? {
      readonly [P in keyof T]: DeepReadonly<T[P]>;
    }
  : T;

// Key extraction with specific value type
type KeysOfType<T, V> = {
  [K in keyof T]-?: T[K] extends V ? K : never;
}[keyof T];

// Example usage
interface User {
  id: number;
  name: string;
  email: string;
  role: 'admin' | 'user';
}

// Get only string keys
type StringKeys = KeysOfType<User, string>; // 'name' | 'email'

// Deep partial (nested optional)
const partialUser: DeepPartial<User> = {
  name: 'John'
  // id is optional
};

// Conditional type to check if type is array
type IsArray<T> = T extends Array<infer U> ? U : never;

type NumArray = IsArray<number[]>; // number

// Generic conditional for objects vs primitives
type Flatten<T> = T extends Array<infer U> ? U : T;

type Str = Flatten<string[]>; // string
type Num = Flatten<42>; // 42

// Template literal types
type ApiRoute = `/${string}` & { __brand: 'ApiRoute' };

const route: ApiRoute = '/api/users' as ApiRoute;
EOF
echo "✓ Created: src/patterns/utility-types.ts"

# 5. Type Guards Pattern
echo "📝 Generating type guards..."
cat > "$PROJECT_PATH/src/patterns/type-guards.ts" << 'EOF'
/**
 * Type Guards and Type Predicates
 * Narrow types safely
 */

interface Dog {
  type: 'dog';
  bark(): void;
}

interface Cat {
  type: 'cat';
  meow(): void;
}

type Pet = Dog | Cat;

// Type predicate: narrows the type
function isDog(pet: Pet): pet is Dog {
  return pet.type === 'dog';
}

function isCat(pet: Pet): pet is Cat {
  return pet.type === 'cat';
}

// Usage: TypeScript now knows the specific type
function animalSound(pet: Pet): void {
  if (isDog(pet)) {
    pet.bark(); // TypeScript knows it's a Dog
  } else if (isCat(pet)) {
    pet.meow(); // TypeScript knows it's a Cat
  }
}

// Generic type guard
function isNonNull<T>(value: T | null | undefined): value is T {
  return value !== null && value !== undefined;
}

// Usage
const values: (string | null)[] = ['hello', null, 'world'];
const filtered = values.filter(isNonNull); // Type: string[]

// Constructor type guard
function isDate(value: unknown): value is Date {
  return value instanceof Date;
}

// Record type guard
function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null;
}
EOF
echo "✓ Created: src/patterns/type-guards.ts"

# 6. Inversion of Control Pattern
echo "📝 Generating IoC container..."
cat > "$PROJECT_PATH/src/patterns/ioc-container.ts" << 'EOF'
/**
 * Inversion of Control Container
 * Dependency injection with type safety
 */

type Constructor<T> = new (...args: any[]) => T;
type Factory<T> = () => T;
type Resolver<T> = Constructor<T> | Factory<T>;

class IoCContainer {
  private services = new Map<string, any>();
  private singletons = new Map<string, any>();

  register<T>(key: string, resolver: Resolver<T>, singleton: boolean = false): void {
    this.services.set(key, { resolver, singleton });
  }

  resolve<T>(key: string): T {
    const service = this.services.get(key);

    if (!service) {
      throw new Error(`Service ${key} not found`);
    }

    // Return cached singleton
    if (service.singleton && this.singletons.has(key)) {
      return this.singletons.get(key);
    }

    // Resolve instance
    const instance =
      typeof service.resolver === 'function' && service.resolver.prototype
        ? new (service.resolver as Constructor<T>)()
        : (service.resolver as Factory<T>)();

    // Cache singleton
    if (service.singleton) {
      this.singletons.set(key, instance);
    }

    return instance;
  }
}

// Usage example
interface Logger {
  log(message: string): void;
}

class ConsoleLogger implements Logger {
  log(message: string): void {
    console.log(message);
  }
}

class Database {
  constructor(private logger: Logger) {}

  connect(): void {
    this.logger.log('Connecting to database...');
  }
}

const container = new IoCContainer();
container.register<Logger>('logger', ConsoleLogger, true);
container.register<Database>('database', Database, true);

const logger = container.resolve<Logger>('logger');
logger.log('Hello!');
EOF
echo "✓ Created: src/patterns/ioc-container.ts"

# 7. Generate tsconfig with strict settings
echo "📝 Updating tsconfig.json..."
cat > "$PROJECT_PATH/tsconfig.json" << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "jsx": "react-jsx",

    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "strictBindCallApply": true,
    "strictPropertyInitialization": true,
    "noImplicitThis": true,
    "alwaysStrict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,

    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,

    "experimentalDecorators": true,
    "emitDecoratorMetadata": true,

    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "outDir": "./dist",
    "rootDir": "./src",

    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"],
      "@patterns/*": ["src/patterns/*"],
      "@utils/*": ["src/utils/*"],
      "@types/*": ["src/types/*"]
    }
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "**/*.test.ts"]
}
EOF
echo "✓ Created: tsconfig.json"

echo ""
echo "============================="
echo "✓ Generation Complete!"
echo "============================="
echo ""
echo "Generated patterns:"
echo "  ✓ src/patterns/factory.ts - Generic factory"
echo "  ✓ src/patterns/decorators.ts - Decorators"
echo "  ✓ src/patterns/discriminated-unions.ts - Type-safe unions"
echo "  ✓ src/patterns/utility-types.ts - Advanced types"
echo "  ✓ src/patterns/type-guards.ts - Type guards"
echo "  ✓ src/patterns/ioc-container.ts - IoC container"
echo "  ✓ tsconfig.json - Strict TypeScript config"
echo ""
echo "Next steps:"
echo "1. Review generated patterns"
echo "2. Adapt to your use cases"
echo "3. Run: npm run validate:typescript"
echo ""
