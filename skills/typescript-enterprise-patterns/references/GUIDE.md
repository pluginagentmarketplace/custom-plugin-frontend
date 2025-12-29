# TypeScript Enterprise Patterns Technical Guide

## TypeScript Strict Mode

Strict mode enables all strict type checking options. This is essential for enterprise applications.

### Configuration

```json
{
  "compilerOptions": {
    "strict": true, // Enables all strict type checking options below
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
    "noFallthroughCasesInSwitch": true
  }
}
```

### Benefits

- Catches null/undefined errors at compile time
- Prevents implicit `any` types
- Ensures function parameters are typed
- Requires all variables to be initialized
- Prevents accidental global variables

## Advanced Types

### Generics: Type-Safe Reusability

Generics let you write code that works with multiple types while maintaining type safety:

```typescript
// Generic function
function identity<T>(value: T): T {
  return value;
}

const str = identity('hello'); // T = string
const num = identity(42); // T = number

// Generic class
class Container<T> {
  constructor(private value: T) {}

  getValue(): T {
    return this.value;
  }

  setValue(value: T): void {
    this.value = value;
  }
}

const stringContainer = new Container('hello');
const numContainer = new Container(42);

// Generic constraints
function merge<T extends object>(obj1: T, obj2: T): T {
  return { ...obj1, ...obj2 };
}

merge({ a: 1 }, { b: 2 }); // OK
// merge({ a: 1 }, "string"); // Error: string doesn't extend object
```

### Conditional Types: Types That Depend on Other Types

```typescript
// Check if a type is a function
type IsFunction<T> = T extends (...args: any[]) => any ? true : false;

type IsFnStr = IsFunction<(x: number) => string>; // true
type IsFnNum = IsFunction<number>; // false

// Extract return type
type ReturnType<T> = T extends (...args: any[]) => infer R ? R : never;

type RetStr = ReturnType<(x: number) => string>; // string

// Flatten array types
type Flatten<T> = T extends Array<infer U> ? U : T;

type StrFlat = Flatten<string[]>; // string
type NumFlat = Flatten<42>; // 42
```

### Mapped Types: Transform Types Declaratively

```typescript
// Make all properties optional
type Partial<T> = {
  [P in keyof T]?: T[P];
};

// Make all properties readonly
type Readonly<T> = {
  readonly [P in keyof T]: T[P];
};

// Extract only string properties
type StringPropertiesOnly<T> = {
  [P in keyof T]: T[P] extends string ? P : never;
}[keyof T];

interface User {
  id: number;
  name: string;
  email: string;
}

type UserStrings = StringPropertiesOnly<User>; // 'name' | 'email'
```

### Template Literal Types: Compose String Types

```typescript
type Color = 'red' | 'green' | 'blue';
type Size = 'small' | 'medium' | 'large';

// Combine into class names
type ClassName = `btn-${Color}-${Size}`;

const className: ClassName = 'btn-red-large'; // OK
// const bad: ClassName = 'btn-red'; // Error

// HTML tag with attributes
type HTMLElement = 'div' | 'span' | 'p';
type EventName<T extends HTMLElement> = T extends 'button' ? 'click' | 'submit' : 'click';
```

## Decorators for Cross-Cutting Concerns

Decorators enable adding metadata or modifying behavior:

```typescript
// Enable decorators in tsconfig.json
{
  "experimentalDecorators": true,
  "emitDecoratorMetadata": true
}

// Method decorator for logging
function Log(target: any, propertyKey: string, descriptor: PropertyDescriptor) {
  const originalMethod = descriptor.value;

  descriptor.value = function (...args: any[]) {
    console.log(`Calling ${propertyKey}`, { args });
    const result = originalMethod.apply(this, args);
    console.log(`Result:`, { result });
    return result;
  };

  return descriptor;
}

// Usage
class Calculator {
  @Log()
  add(a: number, b: number): number {
    return a + b;
  }
}

// Method decorator for validation
function Validate(predicate: (value: any) => boolean, message: string) {
  return function (target: any, propertyKey: string, descriptor: PropertyDescriptor) {
    const originalMethod = descriptor.value;

    descriptor.value = function (value: any) {
      if (!predicate(value)) {
        throw new Error(`Validation error: ${message}`);
      }
      return originalMethod.call(this, value);
    };

    return descriptor;
  };
}

// Class decorator for injectable
function Injectable() {
  return function (target: Function) {
    // Mark for dependency injection
    Reflect.setMetadata('injectable', true, target);
    return target;
  };
}
```

## Discriminated Unions for Type Narrowing

Discriminated unions provide exhaustiveness checking:

```typescript
type Result<T, E> =
  | { status: 'success'; data: T }
  | { status: 'error'; error: E }
  | { status: 'loading' };

function handleResult<T>(result: Result<T, string>) {
  switch (result.status) {
    case 'success':
      console.log(result.data); // Type is T
      return result.data;

    case 'error':
      console.log(result.error); // Type is string
      throw new Error(result.error);

    case 'loading':
      return null;

    // TypeScript error if you forget a case!
  }
}

// Event handling example
type Event =
  | { type: 'click'; x: number; y: number }
  | { type: 'scroll'; y: number }
  | { type: 'resize'; width: number; height: number };

function handleEvent(event: Event) {
  switch (event.type) {
    case 'click':
      console.log(event.x, event.y);
      break;
    case 'scroll':
      console.log(event.y);
      break;
    case 'resize':
      console.log(event.width, event.height);
      break;
  }
}
```

## Utility Types

Built-in types for common transformations:

```typescript
interface User {
  id: number;
  name: string;
  email: string;
}

// Make all properties optional
type PartialUser = Partial<User>;

// Make all properties required
type RequiredUser = Required<PartialUser>;

// Make all properties readonly
type ReadonlyUser = Readonly<User>;

// Pick specific properties
type UserPreview = Pick<User, 'name' | 'email'>;

// Omit specific properties
type UserWithoutId = Omit<User, 'id'>;

// Create object with specific key/value type
type UserRecord = Record<'admin' | 'user', User>;

// Extract union members matching a type
type StringKeys = Extract<keyof User, string>;

// Exclude union members matching a type
type NonStringKeys = Exclude<keyof User, 'name' | 'email'>;

// Make properties of a specific type optional
type PartialByKey = Partial<Pick<User, 'id'>>;
```

## Type Guards and Type Predicates

Runtime type checking with type narrowing:

```typescript
// Type predicate
function isString(value: unknown): value is string {
  return typeof value === 'string';
}

// Usage narrows type in conditional
const value: unknown = 'hello';

if (isString(value)) {
  value.toUpperCase(); // OK - TypeScript knows it's a string
}

// Class instance check
class User {
  constructor(public name: string) {}
}

function isUser(value: unknown): value is User {
  return value instanceof User;
}

// Non-null assertion
function assertNonNull<T>(value: T | null | undefined): asserts value is T {
  if (value == null) {
    throw new Error('Value is null or undefined');
  }
}

const maybeString: string | null = 'hello';
assertNonNull(maybeString);
maybeString.toUpperCase(); // OK - asserted to be string
```

## Higher-Order Types

Types that operate on other types:

```typescript
// Recursively make all properties partial
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

// Get keys of specific value type
type KeysOfType<T, V> = {
  [K in keyof T]-?: T[K] extends V ? K : never;
}[keyof T];

// Example
interface Config {
  debug: boolean;
  port: number;
  host: string;
}

type StringKeys = KeysOfType<Config, string>; // 'host'
type NumberKeys = KeysOfType<Config, number>; // 'port'
type BooleanKeys = KeysOfType<Config, boolean>; // 'debug'
```

## Type-Safe API Clients

Leveraging TypeScript for API safety:

```typescript
// API response type
interface ApiResponse<T> {
  status: number;
  data: T;
  timestamp: Date;
}

// Generic API client
class ApiClient {
  async get<T>(url: string): Promise<ApiResponse<T>> {
    const response = await fetch(url);
    return response.json();
  }

  async post<T, D>(url: string, data: D): Promise<ApiResponse<T>> {
    const response = await fetch(url, {
      method: 'POST',
      body: JSON.stringify(data)
    });
    return response.json();
  }
}

// Usage with strict typing
const client = new ApiClient();

// TypeScript knows the return type and response structure
const response = await client.get<User>('/api/users/1');
console.log(response.data.name); // OK
// console.log(response.data.unknown); // Error!

const created = await client.post<User, { name: string; email: string }>(
  '/api/users',
  { name: 'John', email: 'john@example.com' }
);
```

This comprehensive approach ensures your TypeScript applications are type-safe, maintainable, and catch errors at compile time rather than runtime.
