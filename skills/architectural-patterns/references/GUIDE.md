# Architectural Patterns Technical Guide

Comprehensive guide to proven architectural patterns for scalable application design.

## Table of Contents
1. [MVC Pattern](#mvc-pattern)
2. [MVVM Pattern](#mvvm-pattern)
3. [Clean Architecture](#clean-architecture)
4. [Domain-Driven Design](#domain-driven-design)
5. [SOLID Principles](#solid-principles)

---

## MVC Pattern

Model-View-Controller separates concerns into three components.

### Components

**Model:** Encapsulates data and business logic
```typescript
class User {
  name: string;
  email: string;

  validate(): boolean {
    return this.email.includes('@');
  }
}
```

**View:** Renders presentation logic
```typescript
class UserView {
  render(user: User): string {
    return `<div>${user.name}</div>`;
  }
}
```

**Controller:** Coordinates Model and View
```typescript
class UserController {
  constructor(private model: User, private view: UserView) {}

  displayUser() {
    const html = this.view.render(this.model);
    document.body.innerHTML = html;
  }
}
```

### Advantages
- Clear separation of concerns
- Easy to test (Mock Model)
- Reusable components
- Multiple views for same model

### Disadvantages
- Tight coupling between Controller and View
- Complex data flows in large apps
- Difficult for two-way binding

### When to Use
- Server-rendered applications
- Small to medium applications
- Traditional web applications

---

## MVVM Pattern

Model-View-ViewModel with automatic data binding.

### Components

**Model:** Business logic and data
```typescript
interface User {
  name: string;
  email: string;
}
```

**View:** UI without logic
```html
<div>
  <input [(ngModel)]="viewModel.name">
  <p>{{viewModel.email}}</p>
</div>
```

**ViewModel:** Bridges Model and View
```typescript
class UserViewModel {
  name: string = '';
  email: string = '';

  loadUser(id: string) {
    // Load from model
  }

  saveUser() {
    // Save to model
  }
}
```

### Advantages
- Automatic two-way data binding
- Reduces boilerplate code
- Easy testing (test ViewModel)
- View-agnostic business logic

### Disadvantages
- Overhead of data binding
- Memory consumption with complex bindings
- Debugging harder

### When to Use
- Rich client applications
- Single Page Applications (SPAs)
- Real-time data synchronization

---

## Clean Architecture

Four-layer architecture with dependency inversion.

### Layers (Inside-Out)

**1. Entities:** Core business rules
```typescript
interface User {
  id: string;
  name: string;
  canDelete(): boolean;
}
```

**2. Use Cases:** Application business rules
```typescript
class CreateUserUseCase {
  execute(name: string): User {
    // Business logic
  }
}
```

**3. Interface Adapters:** Controllers, Gateways, Presenters
```typescript
class UserController {
  constructor(private createUserUseCase: CreateUserUseCase) {}

  createUser(request: CreateUserRequest) {
    return this.createUserUseCase.execute(request.name);
  }
}
```

**4. Frameworks & Drivers:** External interfaces
```typescript
class UserRepository implements IUserRepository {
  save(user: User) {
    return this.db.insert(user);
  }
}
```

### Dependency Rule
- Outer layers depend on inner layers
- Never import outer layer from inner
- All dependencies point inward

### Advantages
- Independent of frameworks
- Testable business logic
- Independent of UI
- Independent of database

### Disadvantages
- Overhead for small projects
- More abstraction layers
- Steeper learning curve

### When to Use
- Large enterprise applications
- Long-term projects
- Complex business logic
- Team of developers

---

## Domain-Driven Design

Organize code around business domains.

### Core Concepts

**Entities:** Objects with identity
```typescript
class Order {
  private id: OrderId;
  private items: OrderItem[];

  canShip(): boolean {
    return this.items.every(item => item.isInStock());
  }
}
```

**Value Objects:** Immutable objects without identity
```typescript
class Money {
  readonly amount: number;
  readonly currency: string;

  add(other: Money): Money {
    return new Money(this.amount + other.amount, this.currency);
  }
}
```

**Aggregates:** Groups of entities with one root
```typescript
class Order {
  private items: OrderItem[];

  addItem(product: Product, quantity: number) {
    // Encapsulates aggregate logic
  }
}
```

**Services:** Stateless operations
```typescript
class PaymentService {
  process(order: Order, payment: Money): Result {
    // Business operation
  }
}
```

### Layered Architecture
- **UI Layer** - User interfaces
- **Application Layer** - Use cases, DTOs
- **Domain Layer** - Entities, value objects, services
- **Infrastructure Layer** - Repositories, external services

### Advantages
- Models real-world domains
- Shared language (Ubiquitous Language)
- Complex logic encapsulated
- Easy to discuss with domain experts

### Disadvantages
- Complex to implement correctly
- Requires domain expertise
- Not suitable for simple CRUD apps
- Significant upfront design effort

### When to Use
- Complex business domains
- Long-lived projects
- Domain expertise available
- Team maturity level high

---

## SOLID Principles

### Single Responsibility Principle
Each class has one reason to change.

```typescript
// WRONG: Multiple responsibilities
class User {
  name: string;

  save() { /* DB logic */ }
  validate() { /* validation */ }
  sendEmail() { /* email logic */ }
}

// RIGHT: Single responsibility
class User {
  name: string;
}

class UserRepository {
  save(user: User) { }
}

class UserValidator {
  validate(user: User): boolean { }
}

class UserEmailService {
  sendEmail(user: User) { }
}
```

### Open/Closed Principle
Open for extension, closed for modification.

```typescript
// WRONG: Modify for each new payment method
class PaymentProcessor {
  process(type: 'credit' | 'paypal' | 'bank') {
    if (type === 'credit') { /* ... */ }
    else if (type === 'paypal') { /* ... */ }
  }
}

// RIGHT: Extend through interface
interface PaymentMethod {
  process(amount: number): Promise<void>;
}

class CreditCardPayment implements PaymentMethod {
  process(amount: number) { }
}

class PayPalPayment implements PaymentMethod {
  process(amount: number) { }
}

class PaymentProcessor {
  process(method: PaymentMethod, amount: number) {
    return method.process(amount);
  }
}
```

### Liskov Substitution Principle
Subtypes must be substitutable for base types.

```typescript
// WRONG: Square breaks Rectangle contract
class Rectangle {
  width: number;
  height: number;
  area() { return this.width * this.height; }
}

class Square extends Rectangle {
  set width(value: number) {
    this.width = value;
    this.height = value; // Breaks contract
  }
}

// RIGHT: Use composition or separate types
interface Shape {
  area(): number;
}

class Rectangle implements Shape {
  area() { return this.width * this.height; }
}

class Square implements Shape {
  area() { return this.side * this.side; }
}
```

### Interface Segregation Principle
Many specific interfaces better than one general.

```typescript
// WRONG: Fat interface
interface Worker {
  work(): void;
  eat(): void;
  sleep(): void;
}

class Robot implements Worker {
  work() { }
  eat() { } // Robot doesn't eat
  sleep() { }
}

// RIGHT: Segregated interfaces
interface Workable {
  work(): void;
}

interface Eatable {
  eat(): void;
}

class Robot implements Workable {
  work() { }
}

class Human implements Workable, Eatable {
  work() { }
  eat() { }
}
```

### Dependency Inversion Principle
Depend on abstractions, not concrete implementations.

```typescript
// WRONG: Depends on concrete class
class UserService {
  private db = new MySQLDatabase();
}

// RIGHT: Depends on abstraction
interface IDatabase {
  query(sql: string): Promise<any>;
}

class UserService {
  constructor(private db: IDatabase) {}
}
```

---

## Best Practices

### Choose Architecture Based On
- Project size and complexity
- Team size and experience
- Long-term maintenance needs
- Business domain complexity
- Time constraints

### Combine Patterns
- Use MVC for simple projects
- Use MVVM for rich UIs
- Use Clean Architecture for complex domains
- Apply DDD to domain-heavy projects
- Follow SOLID in all patterns

### Key Principles
1. **Separation of Concerns** - Different modules for different concerns
2. **Cohesion** - Related code together
3. **Coupling** - Minimize dependencies between modules
4. **Testability** - Easy to unit test components
5. **Maintainability** - Easy to modify and extend

This comprehensive guide covers architectural patterns for different project types and requirements.
