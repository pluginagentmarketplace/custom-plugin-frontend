# Architectural Patterns Implementation

Real-world patterns for implementing scalable architectures.

## Repository Pattern

```typescript
/**
 * Data access abstraction layer
 * Decouples business logic from database implementation
 */

interface IRepository<T> {
  getById(id: string): Promise<T | null>;
  getAll(): Promise<T[]>;
  save(item: T): Promise<void>;
  delete(id: string): Promise<void>;
}

class User {
  constructor(
    public id: string,
    public name: string,
    public email: string
  ) {}
}

class UserRepository implements IRepository<User> {
  async getById(id: string): Promise<User | null> {
    const data = await fetch(`/api/users/${id}`);
    return data.json();
  }

  async getAll(): Promise<User[]> {
    const data = await fetch('/api/users');
    return data.json();
  }

  async save(user: User): Promise<void> {
    await fetch('/api/users', {
      method: 'POST',
      body: JSON.stringify(user),
    });
  }

  async delete(id: string): Promise<void> {
    await fetch(`/api/users/${id}`, { method: 'DELETE' });
  }
}

// Usage: Business logic doesn't know about database
class UserService {
  constructor(private userRepository: IRepository<User>) {}

  async promoteUser(userId: string): Promise<void> {
    const user = await this.userRepository.getById(userId);
    if (user) {
      // Business logic
      await this.userRepository.save(user);
    }
  }
}
```

## Service Layer Pattern

```typescript
/**
 * Business logic encapsulation
 * Coordinates repositories, validation, and external services
 */

class CreateOrderService {
  constructor(
    private orderRepository: IRepository<Order>,
    private productRepository: IRepository<Product>,
    private paymentService: PaymentService,
    private notificationService: NotificationService
  ) {}

  async execute(request: CreateOrderRequest): Promise<Order> {
    // Validate
    this.validateRequest(request);

    // Check inventory
    for (const item of request.items) {
      const product = await this.productRepository.getById(item.productId);
      if (!product || product.inventory < item.quantity) {
        throw new Error('Out of stock');
      }
    }

    // Process payment
    await this.paymentService.charge(request.payment);

    // Create order
    const order = new Order(
      Math.random().toString(),
      request.items,
      new Date()
    );

    await this.orderRepository.save(order);

    // Notify customer
    await this.notificationService.sendOrderConfirmation(order);

    return order;
  }

  private validateRequest(request: CreateOrderRequest): void {
    if (!request.items.length) {
      throw new Error('Order must have items');
    }
  }
}
```

## Dependency Injection Pattern

```typescript
/**
 * Constructor injection for loose coupling
 * Dependencies injected at construction time
 */

interface Logger {
  log(message: string): void;
}

class ConsoleLogger implements Logger {
  log(message: string) {
    console.log(message);
  }
}

class SentryLogger implements Logger {
  log(message: string) {
    // Send to Sentry
  }
}

class UserService {
  constructor(
    private userRepository: IRepository<User>,
    private logger: Logger
  ) {}

  async getUser(id: string): Promise<User | null> {
    this.logger.log(`Getting user: ${id}`);
    return this.userRepository.getById(id);
  }
}

// Setup with dependency injection
const logger = process.env.PRODUCTION
  ? new SentryLogger()
  : new ConsoleLogger();

const userRepository = new UserRepository();
const userService = new UserService(userRepository, logger);
```

## Adapter Pattern

```typescript
/**
 * Convert one interface to another
 * Allows working with incompatible interfaces
 */

interface PaymentGateway {
  charge(amount: number, token: string): Promise<void>;
}

class StripePaymentGateway implements PaymentGateway {
  async charge(amount: number, token: string): Promise<void> {
    // Stripe specific logic
  }
}

// Third-party PayPal API with different interface
class PayPalAPI {
  processTransaction(money: { value: number; currency: string }, key: string) {
    // PayPal specific logic
  }
}

// Adapter to make PayPal compatible
class PayPalAdapter implements PaymentGateway {
  async charge(amount: number, token: string): Promise<void> {
    const paypal = new PayPalAPI();
    paypal.processTransaction(
      { value: amount, currency: 'USD' },
      token
    );
  }
}

// Now both can be used interchangeably
const gateway: PaymentGateway = process.env.PAYMENT_PROVIDER === 'paypal'
  ? new PayPalAdapter()
  : new StripePaymentGateway();
```

## Observer Pattern

```typescript
/**
 * Reactive event system
 * Components react to events without tight coupling
 */

interface Observer {
  update(event: Event): void;
}

class OrderEventBus {
  private observers: Observer[] = [];

  subscribe(observer: Observer): void {
    this.observers.push(observer);
  }

  unsubscribe(observer: Observer): void {
    this.observers = this.observers.filter(o => o !== observer);
  }

  publish(event: Event): void {
    this.observers.forEach(observer => observer.update(event));
  }
}

class Order {
  private eventBus: OrderEventBus;

  constructor() {
    this.eventBus = new OrderEventBus();
  }

  place(): void {
    // Business logic
    this.eventBus.publish({
      type: 'ORDER_PLACED',
      orderId: this.id,
      timestamp: new Date(),
    });
  }
}

// Observers that react to events
class NotificationService implements Observer {
  update(event: Event): void {
    if (event.type === 'ORDER_PLACED') {
      this.sendNotification(event);
    }
  }

  private sendNotification(event: Event): void {
    console.log('Sending notification for order');
  }
}

class AnalyticsService implements Observer {
  update(event: Event): void {
    if (event.type === 'ORDER_PLACED') {
      this.track(event);
    }
  }

  private track(event: Event): void {
    console.log('Tracking order event');
  }
}

// Setup
const eventBus = new OrderEventBus();
eventBus.subscribe(new NotificationService());
eventBus.subscribe(new AnalyticsService());
```

## Middleware Pattern

```typescript
/**
 * Function composition for processing pipelines
 * Each middleware can inspect, modify, or short-circuit the request
 */

type Middleware<T> = (context: T, next: () => Promise<void>) => Promise<void>;

class RequestProcessor {
  private middlewares: Middleware<RequestContext>[] = [];

  use(middleware: Middleware<RequestContext>) {
    this.middlewares.push(middleware);
  }

  async process(context: RequestContext): Promise<void> {
    let index = -1;

    const dispatch = async (i: number): Promise<void> => {
      if (i <= index) throw new Error('next() called multiple times');
      index = i;

      if (i < this.middlewares.length) {
        await this.middlewares[i](context, () => dispatch(i + 1));
      }
    };

    await dispatch(0);
  }
}

interface RequestContext {
  url: string;
  method: string;
  body: any;
  headers: Record<string, string>;
  startTime: number;
}

// Middleware implementations
const loggingMiddleware: Middleware<RequestContext> = async (ctx, next) => {
  console.log(`→ ${ctx.method} ${ctx.url}`);
  await next();
  const duration = Date.now() - ctx.startTime;
  console.log(`← ${ctx.method} ${ctx.url} (${duration}ms)`);
};

const authMiddleware: Middleware<RequestContext> = async (ctx, next) => {
  const token = ctx.headers['authorization'];
  if (!token) {
    throw new Error('Unauthorized');
  }
  await next();
};

const validationMiddleware: Middleware<RequestContext> = async (ctx, next) => {
  if (!ctx.body || typeof ctx.body !== 'object') {
    throw new Error('Invalid body');
  }
  await next();
};

// Usage
const processor = new RequestProcessor();
processor.use(loggingMiddleware);
processor.use(authMiddleware);
processor.use(validationMiddleware);

// Process request through middleware pipeline
await processor.process({
  url: '/api/users',
  method: 'POST',
  body: { name: 'John' },
  headers: { authorization: 'Bearer token' },
  startTime: Date.now(),
});
```

## Factory Pattern

```typescript
/**
 * Abstract object creation
 * Decouples client from concrete classes
 */

interface DataSourceFactory {
  createDataSource(): DataSource;
}

interface DataSource {
  query(sql: string): Promise<any>;
}

class MySQLDataSource implements DataSource {
  async query(sql: string): Promise<any> {
    // MySQL implementation
  }
}

class PostgresDataSource implements DataSource {
  async query(sql: string): Promise<any> {
    // Postgres implementation
  }
}

class MySQLFactory implements DataSourceFactory {
  createDataSource(): DataSource {
    return new MySQLDataSource();
  }
}

class PostgresFactory implements DataSourceFactory {
  createDataSource(): DataSource {
    return new PostgresDataSource();
  }
}

// Usage
function createDataSourceFactory(type: 'mysql' | 'postgres'): DataSourceFactory {
  switch (type) {
    case 'mysql':
      return new MySQLFactory();
    case 'postgres':
      return new PostgresFactory();
  }
}

const factory = createDataSourceFactory(process.env.DB_TYPE as any);
const dataSource = factory.createDataSource();
```

These patterns provide production-ready implementations for various architectural scenarios.
