/**
 * DDD: Domain-Driven Design Example
 * Organizing code around business domains
 */

// === DOMAIN LAYER (Core Business) ===

// Value Objects: Immutable objects without identity
export class OrderId {
  readonly value: string;

  constructor(value: string) {
    if (!value || value.trim().length === 0) {
      throw new Error('OrderId cannot be empty');
    }
    this.value = value;
  }

  equals(other: OrderId): boolean {
    return this.value === other.value;
  }
}

export class Money {
  readonly amount: number;
  readonly currency: string = 'USD';

  constructor(amount: number) {
    if (amount < 0) {
      throw new Error('Amount cannot be negative');
    }
    this.amount = amount;
  }

  add(other: Money): Money {
    if (other.currency !== this.currency) {
      throw new Error('Currency mismatch');
    }
    return new Money(this.amount + other.amount);
  }

  equals(other: Money): boolean {
    return this.amount === other.amount && this.currency === other.currency;
  }
}

// Entities: Objects with identity
export class OrderItem {
  private productId: string;
  private quantity: number;
  private unitPrice: Money;

  constructor(productId: string, quantity: number, unitPrice: Money) {
    if (quantity <= 0) {
      throw new Error('Quantity must be positive');
    }
    this.productId = productId;
    this.quantity = quantity;
    this.unitPrice = unitPrice;
  }

  getTotal(): Money {
    return new Money(this.unitPrice.amount * this.quantity);
  }

  getProductId(): string {
    return this.productId;
  }

  getQuantity(): number {
    return this.quantity;
  }
}

// Aggregate Root: Entity that manages its own consistency
export class Order {
  private id: OrderId;
  private items: OrderItem[] = [];
  private status: 'pending' | 'confirmed' | 'shipped' | 'delivered' = 'pending';
  private createdAt: Date;

  constructor(id: OrderId) {
    this.id = id;
    this.createdAt = new Date();
  }

  // Invariant enforcement: only aggregate root can modify state
  addItem(item: OrderItem): void {
    if (this.status !== 'pending') {
      throw new Error('Cannot add items to non-pending order');
    }
    this.items.push(item);
  }

  removeItem(productId: string): void {
    if (this.status !== 'pending') {
      throw new Error('Cannot remove items from non-pending order');
    }
    this.items = this.items.filter((item) => item.getProductId() !== productId);
  }

  getTotal(): Money {
    if (this.items.length === 0) {
      return new Money(0);
    }
    return this.items.reduce((total, item) => total.add(item.getTotal()), new Money(0));
  }

  confirm(): void {
    if (this.status !== 'pending') {
      throw new Error('Order already confirmed');
    }
    if (this.items.length === 0) {
      throw new Error('Cannot confirm empty order');
    }
    this.status = 'confirmed';
  }

  canShip(): boolean {
    return this.status === 'confirmed';
  }

  ship(): void {
    if (!this.canShip()) {
      throw new Error('Order cannot be shipped');
    }
    this.status = 'shipped';
  }

  getId(): OrderId {
    return this.id;
  }

  getStatus() {
    return this.status;
  }

  getItems(): OrderItem[] {
    return [...this.items];
  }
}

// === REPOSITORY INTERFACE (Application Layer) ===

export interface IOrderRepository {
  save(order: Order): Promise<void>;
  findById(id: OrderId): Promise<Order | null>;
  delete(id: OrderId): Promise<void>;
}

// === SERVICE (Stateless Domain Operations) ===

export class OrderService {
  constructor(private repository: IOrderRepository) {}

  async createOrder(orderId: OrderId): Promise<Order> {
    const order = new Order(orderId);
    await this.repository.save(order);
    return order;
  }

  async getOrder(orderId: OrderId): Promise<Order | null> {
    return await this.repository.findById(orderId);
  }

  async shipOrder(orderId: OrderId): Promise<void> {
    const order = await this.repository.findById(orderId);
    if (!order) {
      throw new Error('Order not found');
    }

    // Business rule: validate before shipping
    if (!order.canShip()) {
      throw new Error('Order cannot be shipped in current state');
    }

    order.ship();
    await this.repository.save(order);
  }
}

// === EXAMPLE USAGE ===

export function runDddExample() {
  console.log('=== Domain-Driven Design Example ===\n');

  try {
    // Create an order
    const orderId = new OrderId('ORDER-001');
    const order = new Order(orderId);

    console.log('Order created:', orderId.value);

    // Add items (maintaining invariants)
    const item1 = new OrderItem('PROD-001', 2, new Money(50));
    const item2 = new OrderItem('PROD-002', 1, new Money(100));

    order.addItem(item1);
    order.addItem(item2);

    console.log('Items added');
    console.log('Total:', order.getTotal().amount, order.getTotal().currency);

    // Confirm order
    order.confirm();
    console.log('Order confirmed');

    // Cannot add items after confirmation
    try {
      const item3 = new OrderItem('PROD-003', 1, new Money(75));
      order.addItem(item3); // This will fail
    } catch (error) {
      console.log('Error (expected):', (error as Error).message);
    }

    // Ship order
    if (order.canShip()) {
      order.ship();
      console.log('Order shipped');
    }
  } catch (error) {
    console.error('Error:', (error as Error).message);
  }
}

/**
 * DDD KEY CONCEPTS:
 *
 * 1. ENTITIES: Objects with identity (Order, User)
 * 2. VALUE OBJECTS: Immutable, no identity (Money, OrderId)
 * 3. AGGREGATES: Group of entities with one root (Order + OrderItems)
 * 4. AGGREGATE ROOT: Entity that controls aggregate (Order)
 * 5. REPOSITORIES: Persist aggregates
 * 6. SERVICES: Stateless operations (OrderService)
 * 7. INVARIANTS: Business rules maintained by aggregate
 * 8. UBIQUITOUS LANGUAGE: Shared terminology
 *
 * BENEFITS:
 * - Models real-world business domains
 * - Complex logic encapsulated in entities
 * - Clear business rules and invariants
 * - Testable business logic
 * - Long-term maintainability
 *
 * COMPLEXITY:
 * - Significant upfront design effort
 * - Requires domain expertise
 * - Not suitable for simple CRUD apps
 * - Steep learning curve
 */
