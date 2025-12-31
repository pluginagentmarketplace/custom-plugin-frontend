---
name: architectural-patterns
description: Master architectural patterns - MVC, MVVM, Clean Architecture, SOLID principles, domain-driven design.
sasmp_version: "1.3.0"
version: "2.0.0"
bonded_agent: advanced-topics
bond_type: PRIMARY_BOND
production_config:
  performance_budget:
    layer_coupling_index: 0.3
    dependency_depth: 5
    module_cohesion_score: 0.8
  scalability:
    max_layers: 7
    max_dependencies_per_module: 15
    abstraction_level: "high"
  monitoring:
    architecture_violations: true
    dependency_tracking: true
    complexity_metrics: true
---

# Architectural Patterns

Master proven architectural patterns for building scalable, maintainable, and testable applications including MVC, MVVM, Clean Architecture, SOLID principles, and Domain-Driven Design.

## Input Schema

```typescript
interface ArchitecturalDesign {
  pattern: 'mvc' | 'mvvm' | 'clean' | 'hexagonal' | 'layered';
  layers: {
    presentation: PresentationLayer;
    business: BusinessLayer;
    data: DataLayer;
    infrastructure: InfrastructureLayer;
  };
  dependencies: {
    direction: 'inward' | 'outward';
    rules: DependencyRule[];
    injections: DependencyInjection[];
  };
  principles: {
    solid: boolean;
    dryKiss: boolean;
    separation: SeparationStrategy;
  };
}

interface CleanArchitectureConfig {
  entities: EntityDefinition[];
  useCases: UseCaseDefinition[];
  interfaces: InterfaceAdapter[];
  frameworks: FrameworkAdapter[];
  dependencyRule: DependencyRule;
}

interface DomainDrivenDesign {
  boundedContexts: BoundedContext[];
  aggregates: Aggregate[];
  valueObjects: ValueObject[];
  repositories: Repository[];
  services: DomainService[];
}
```

## Output Schema

```typescript
interface ArchitecturalImplementation {
  structure: {
    layers: Layer[];
    modules: Module[];
    boundaries: Boundary[];
  };
  dependencies: {
    graph: DependencyGraph;
    violations: DependencyViolation[];
    circularDeps: CircularDependency[];
  };
  patterns: {
    applied: Pattern[];
    adherence: PatternAdherence;
    violations: PatternViolation[];
  };
  metrics: {
    coupling: CouplingMetrics;
    cohesion: CohesionMetrics;
    complexity: ComplexityMetrics;
  };
}
```

## Error Handling

| Error Type | Cause | Resolution | Prevention |
|------------|-------|------------|------------|
| `DEPENDENCY_INVERSION_VIOLATION` | High-level depends on low-level | Introduce abstraction interface | Follow dependency inversion principle |
| `CIRCULAR_DEPENDENCY` | Modules depend on each other | Refactor to break cycle | Use dependency injection |
| `LAYER_VIOLATION` | Layer bypasses adjacent layer | Enforce layer boundaries | Use architecture testing |
| `TIGHT_COUPLING` | Modules too interdependent | Introduce interfaces/abstractions | Apply SOLID principles |
| `ANEMIC_DOMAIN_MODEL` | Domain objects lack behavior | Move logic to domain objects | Follow DDD principles |
| `GOD_OBJECT` | Single class does too much | Split responsibilities | Apply SRP |
| `ABSTRACTION_LEAK` | Implementation details exposed | Hide behind interface | Apply information hiding |
| `FRAMEWORK_COUPLING` | Business logic coupled to framework | Isolate framework dependencies | Use ports and adapters |

## MANDATORY

### MVC (Model-View-Controller) Pattern
```javascript
// Model - Data and business logic
class TodoModel {
  constructor() {
    this.todos = [];
    this.observers = [];
  }

  // Business logic
  addTodo(text) {
    const todo = {
      id: Date.now(),
      text,
      completed: false
    };
    this.todos.push(todo);
    this.notifyObservers();
  }

  getTodos() {
    return this.todos;
  }

  toggleTodo(id) {
    const todo = this.todos.find(t => t.id === id);
    if (todo) {
      todo.completed = !todo.completed;
      this.notifyObservers();
    }
  }

  // Observer pattern for view updates
  subscribe(observer) {
    this.observers.push(observer);
  }

  notifyObservers() {
    this.observers.forEach(observer => observer.update());
  }
}

// View - UI presentation
class TodoView {
  constructor() {
    this.app = document.getElementById('app');
    this.input = document.createElement('input');
    this.button = document.createElement('button');
    this.list = document.createElement('ul');

    this.button.textContent = 'Add';
    this.app.append(this.input, this.button, this.list);
  }

  bindAddTodo(handler) {
    this.button.addEventListener('click', () => {
      if (this.input.value) {
        handler(this.input.value);
        this.input.value = '';
      }
    });
  }

  bindToggleTodo(handler) {
    this.list.addEventListener('click', (e) => {
      if (e.target.tagName === 'LI') {
        handler(e.target.dataset.id);
      }
    });
  }

  displayTodos(todos) {
    this.list.innerHTML = '';
    todos.forEach(todo => {
      const li = document.createElement('li');
      li.textContent = todo.text;
      li.dataset.id = todo.id;
      if (todo.completed) {
        li.style.textDecoration = 'line-through';
      }
      this.list.appendChild(li);
    });
  }
}

// Controller - Mediates between Model and View
class TodoController {
  constructor(model, view) {
    this.model = model;
    this.view = view;

    // Bind view to model updates
    this.model.subscribe(this);

    // Bind view events to controller handlers
    this.view.bindAddTodo(this.handleAddTodo.bind(this));
    this.view.bindToggleTodo(this.handleToggleTodo.bind(this));

    // Initial render
    this.update();
  }

  handleAddTodo(text) {
    this.model.addTodo(text);
  }

  handleToggleTodo(id) {
    this.model.toggleTodo(parseInt(id));
  }

  update() {
    this.view.displayTodos(this.model.getTodos());
  }
}

// Initialize
const app = new TodoController(new TodoModel(), new TodoView());
```

### MVVM (Model-View-ViewModel) Pattern
```javascript
// Model - Data layer
class TodoModel {
  constructor() {
    this.todos = [];
  }

  async fetchTodos() {
    const response = await fetch('/api/todos');
    return response.json();
  }

  async saveTodo(todo) {
    const response = await fetch('/api/todos', {
      method: 'POST',
      body: JSON.stringify(todo)
    });
    return response.json();
  }
}

// ViewModel - Business logic and state
class TodoViewModel {
  constructor(model) {
    this.model = model;
    this.todos = [];
    this.filter = 'all';
    this.loading = false;
    this.listeners = [];
  }

  // Computed properties
  get filteredTodos() {
    switch (this.filter) {
      case 'active':
        return this.todos.filter(t => !t.completed);
      case 'completed':
        return this.todos.filter(t => t.completed);
      default:
        return this.todos;
    }
  }

  get stats() {
    return {
      total: this.todos.length,
      completed: this.todos.filter(t => t.completed).length,
      active: this.todos.filter(t => !t.completed).length
    };
  }

  // Commands
  async loadTodos() {
    this.loading = true;
    this.notify();

    try {
      this.todos = await this.model.fetchTodos();
    } catch (error) {
      console.error('Failed to load todos:', error);
    }

    this.loading = false;
    this.notify();
  }

  async addTodo(text) {
    const todo = { text, completed: false };
    const saved = await this.model.saveTodo(todo);
    this.todos.push(saved);
    this.notify();
  }

  setFilter(filter) {
    this.filter = filter;
    this.notify();
  }

  // Data binding
  subscribe(listener) {
    this.listeners.push(listener);
  }

  notify() {
    this.listeners.forEach(listener => listener());
  }
}

// View - React component with data binding
function TodoView({ viewModel }) {
  const [, forceUpdate] = useReducer(x => x + 1, 0);

  useEffect(() => {
    viewModel.subscribe(forceUpdate);
    viewModel.loadTodos();
  }, [viewModel]);

  return (
    <div>
      {viewModel.loading && <Spinner />}

      <input
        type="text"
        onKeyPress={(e) => {
          if (e.key === 'Enter') {
            viewModel.addTodo(e.target.value);
            e.target.value = '';
          }
        }}
      />

      <div>
        <button onClick={() => viewModel.setFilter('all')}>All</button>
        <button onClick={() => viewModel.setFilter('active')}>Active</button>
        <button onClick={() => viewModel.setFilter('completed')}>Completed</button>
      </div>

      <ul>
        {viewModel.filteredTodos.map(todo => (
          <li key={todo.id}>{todo.text}</li>
        ))}
      </ul>

      <div>
        {viewModel.stats.active} active, {viewModel.stats.completed} completed
      </div>
    </div>
  );
}
```

### Clean Architecture Layers
```javascript
// Entities (Core Domain)
class Todo {
  constructor(id, text, completed = false) {
    this.id = id;
    this.text = text;
    this.completed = completed;
    this.createdAt = new Date();
  }

  toggle() {
    this.completed = !this.completed;
  }

  isCompleted() {
    return this.completed;
  }
}

// Use Cases (Application Business Rules)
class CreateTodoUseCase {
  constructor(todoRepository) {
    this.todoRepository = todoRepository;
  }

  async execute(text) {
    // Validate
    if (!text || text.trim().length === 0) {
      throw new Error('Todo text cannot be empty');
    }

    // Create entity
    const todo = new Todo(
      this.generateId(),
      text.trim()
    );

    // Save
    await this.todoRepository.save(todo);

    return todo;
  }

  generateId() {
    return `todo-${Date.now()}-${Math.random()}`;
  }
}

class GetTodosUseCase {
  constructor(todoRepository) {
    this.todoRepository = todoRepository;
  }

  async execute(filter = 'all') {
    const todos = await this.todoRepository.findAll();

    switch (filter) {
      case 'active':
        return todos.filter(t => !t.isCompleted());
      case 'completed':
        return todos.filter(t => t.isCompleted());
      default:
        return todos;
    }
  }
}

// Interface Adapters (Repository Interface)
interface TodoRepository {
  save(todo: Todo): Promise<void>;
  findById(id: string): Promise<Todo | null>;
  findAll(): Promise<Todo[]>;
  delete(id: string): Promise<void>;
}

// Infrastructure (Concrete Implementations)
class InMemoryTodoRepository {
  constructor() {
    this.todos = new Map();
  }

  async save(todo) {
    this.todos.set(todo.id, todo);
  }

  async findById(id) {
    return this.todos.get(id) || null;
  }

  async findAll() {
    return Array.from(this.todos.values());
  }

  async delete(id) {
    this.todos.delete(id);
  }
}

class ApiTodoRepository {
  constructor(apiClient) {
    this.apiClient = apiClient;
  }

  async save(todo) {
    await this.apiClient.post('/todos', todo);
  }

  async findAll() {
    const response = await this.apiClient.get('/todos');
    return response.data.map(data =>
      new Todo(data.id, data.text, data.completed)
    );
  }
}

// Dependency Injection (Composition Root)
const todoRepository = new ApiTodoRepository(apiClient);
const createTodoUseCase = new CreateTodoUseCase(todoRepository);
const getTodosUseCase = new GetTodosUseCase(todoRepository);

// UI Layer (Framework)
function TodoApp() {
  const [todos, setTodos] = useState([]);

  const handleAddTodo = async (text) => {
    await createTodoUseCase.execute(text);
    const updated = await getTodosUseCase.execute();
    setTodos(updated);
  };

  return <TodoList todos={todos} onAdd={handleAddTodo} />;
}
```

### Separation of Concerns
```javascript
// Bad: All concerns mixed
class TodoComponent extends React.Component {
  constructor() {
    this.state = { todos: [] };
  }

  componentDidMount() {
    // Data fetching in component
    fetch('/api/todos')
      .then(r => r.json())
      .then(todos => this.setState({ todos }));
  }

  handleAdd = (text) => {
    // Business logic in component
    if (!text || text.length < 3) {
      alert('Too short');
      return;
    }

    // API call in component
    fetch('/api/todos', {
      method: 'POST',
      body: JSON.stringify({ text })
    });
  };

  render() {
    // Presentation logic mixed with everything
    return <div>{/* UI */}</div>;
  }
}

// Good: Separated concerns
// 1. Domain Layer
class Todo {
  constructor(text) {
    this.text = text;
    this.validate();
  }

  validate() {
    if (!this.text || this.text.length < 3) {
      throw new Error('Text must be at least 3 characters');
    }
  }
}

// 2. Service Layer
class TodoService {
  constructor(repository) {
    this.repository = repository;
  }

  async createTodo(text) {
    const todo = new Todo(text);
    return await this.repository.save(todo);
  }

  async getTodos() {
    return await this.repository.findAll();
  }
}

// 3. Repository Layer
class TodoRepository {
  async save(todo) {
    return await api.post('/todos', todo);
  }

  async findAll() {
    const response = await api.get('/todos');
    return response.data;
  }
}

// 4. Custom Hook (State Management)
function useTodos() {
  const [todos, setTodos] = useState([]);
  const [loading, setLoading] = useState(false);

  const service = useMemo(
    () => new TodoService(new TodoRepository()),
    []
  );

  const loadTodos = useCallback(async () => {
    setLoading(true);
    const data = await service.getTodos();
    setTodos(data);
    setLoading(false);
  }, [service]);

  const addTodo = useCallback(async (text) => {
    try {
      await service.createTodo(text);
      await loadTodos();
    } catch (error) {
      // Handle error
    }
  }, [service, loadTodos]);

  return { todos, loading, addTodo, loadTodos };
}

// 5. Presentation Component
function TodoList() {
  const { todos, loading, addTodo } = useTodos();

  if (loading) return <Spinner />;

  return (
    <div>
      <TodoForm onSubmit={addTodo} />
      <ul>
        {todos.map(todo => (
          <TodoItem key={todo.id} todo={todo} />
        ))}
      </ul>
    </div>
  );
}
```

### Dependency Injection
```javascript
// Manual dependency injection
class UserService {
  constructor(userRepository, emailService) {
    this.userRepository = userRepository;
    this.emailService = emailService;
  }

  async createUser(userData) {
    const user = await this.userRepository.create(userData);
    await this.emailService.sendWelcome(user.email);
    return user;
  }
}

// Composition root
const userRepository = new UserRepository(database);
const emailService = new EmailService(smtpConfig);
const userService = new UserService(userRepository, emailService);

// React context for DI
const ServiceContext = createContext();

function ServiceProvider({ children }) {
  const services = useMemo(() => ({
    userService: new UserService(
      new UserRepository(),
      new EmailService()
    ),
    todoService: new TodoService(
      new TodoRepository()
    )
  }), []);

  return (
    <ServiceContext.Provider value={services}>
      {children}
    </ServiceContext.Provider>
  );
}

function useServices() {
  return useContext(ServiceContext);
}

// Component usage
function UserProfile() {
  const { userService } = useServices();

  const handleUpdate = async (data) => {
    await userService.updateProfile(data);
  };

  return <ProfileForm onSubmit={handleUpdate} />;
}

// TypeScript DI with interfaces
interface IUserRepository {
  create(user: User): Promise<User>;
  findById(id: string): Promise<User | null>;
}

interface IEmailService {
  sendWelcome(email: string): Promise<void>;
}

class UserService {
  constructor(
    private userRepository: IUserRepository,
    private emailService: IEmailService
  ) {}

  async createUser(userData: UserData): Promise<User> {
    const user = await this.userRepository.create(userData);
    await this.emailService.sendWelcome(user.email);
    return user;
  }
}
```

### Service Layer Pattern
```javascript
// Service layer encapsulates business logic

// Domain entities
class Order {
  constructor(id, items, customerId) {
    this.id = id;
    this.items = items;
    this.customerId = customerId;
    this.status = 'pending';
  }

  calculateTotal() {
    return this.items.reduce((sum, item) =>
      sum + (item.price * item.quantity), 0
    );
  }

  canBeCancelled() {
    return ['pending', 'processing'].includes(this.status);
  }
}

// Service layer
class OrderService {
  constructor(orderRepository, paymentService, inventoryService, notificationService) {
    this.orderRepository = orderRepository;
    this.paymentService = paymentService;
    this.inventoryService = inventoryService;
    this.notificationService = notificationService;
  }

  async createOrder(orderData) {
    // Validate inventory
    const available = await this.inventoryService.checkAvailability(
      orderData.items
    );

    if (!available) {
      throw new Error('Some items are out of stock');
    }

    // Create order
    const order = new Order(
      this.generateOrderId(),
      orderData.items,
      orderData.customerId
    );

    // Reserve inventory
    await this.inventoryService.reserve(order.items);

    // Save order
    await this.orderRepository.save(order);

    // Send confirmation
    await this.notificationService.sendOrderConfirmation(order);

    return order;
  }

  async processPayment(orderId, paymentDetails) {
    const order = await this.orderRepository.findById(orderId);

    if (!order) {
      throw new Error('Order not found');
    }

    // Process payment
    const paymentResult = await this.paymentService.charge(
      paymentDetails,
      order.calculateTotal()
    );

    if (paymentResult.success) {
      order.status = 'paid';
      await this.orderRepository.update(order);
      await this.notificationService.sendPaymentConfirmation(order);
    }

    return paymentResult;
  }

  async cancelOrder(orderId) {
    const order = await this.orderRepository.findById(orderId);

    if (!order.canBeCancelled()) {
      throw new Error('Order cannot be cancelled');
    }

    // Release inventory
    await this.inventoryService.release(order.items);

    // Update order
    order.status = 'cancelled';
    await this.orderRepository.update(order);

    // Refund if paid
    if (order.status === 'paid') {
      await this.paymentService.refund(order.id);
    }

    // Notify customer
    await this.notificationService.sendCancellationNotice(order);

    return order;
  }

  generateOrderId() {
    return `ORD-${Date.now()}`;
  }
}
```

## OPTIONAL

### Domain-Driven Design (DDD)
```javascript
// Value Objects
class Money {
  constructor(amount, currency) {
    this.amount = amount;
    this.currency = currency;
    Object.freeze(this);
  }

  add(other) {
    if (this.currency !== other.currency) {
      throw new Error('Cannot add different currencies');
    }
    return new Money(this.amount + other.amount, this.currency);
  }

  equals(other) {
    return this.amount === other.amount && this.currency === other.currency;
  }
}

class Email {
  constructor(value) {
    if (!this.isValid(value)) {
      throw new Error('Invalid email');
    }
    this.value = value;
    Object.freeze(this);
  }

  isValid(email) {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
  }

  equals(other) {
    return this.value === other.value;
  }
}

// Entities
class Customer {
  constructor(id, email, name) {
    this.id = id;
    this.email = new Email(email);
    this.name = name;
    this.orders = [];
  }

  placeOrder(order) {
    this.orders.push(order);
  }

  getTotalSpent() {
    return this.orders.reduce((total, order) =>
      total.add(order.getTotal()), new Money(0, 'USD')
    );
  }
}

// Aggregates
class Order {
  constructor(id, customerId) {
    this.id = id;
    this.customerId = customerId;
    this.items = [];
    this.status = 'draft';
  }

  // Aggregate root controls all modifications
  addItem(product, quantity) {
    if (this.status !== 'draft') {
      throw new Error('Cannot modify confirmed order');
    }

    const item = new OrderItem(product, quantity);
    this.items.push(item);
  }

  removeItem(productId) {
    if (this.status !== 'draft') {
      throw new Error('Cannot modify confirmed order');
    }

    this.items = this.items.filter(item => item.product.id !== productId);
  }

  confirm() {
    if (this.items.length === 0) {
      throw new Error('Cannot confirm empty order');
    }

    this.status = 'confirmed';
  }

  getTotal() {
    return this.items.reduce((total, item) =>
      total.add(item.getSubtotal()), new Money(0, 'USD')
    );
  }
}

class OrderItem {
  constructor(product, quantity) {
    this.product = product;
    this.quantity = quantity;
  }

  getSubtotal() {
    return new Money(
      this.product.price.amount * this.quantity,
      this.product.price.currency
    );
  }
}

// Domain Services
class PricingService {
  calculateDiscount(customer, order) {
    const totalSpent = customer.getTotalSpent();

    // VIP customers get 10% off
    if (totalSpent.amount > 1000) {
      return order.getTotal().multiply(0.1);
    }

    return new Money(0, 'USD');
  }
}

// Repositories
class OrderRepository {
  async save(order) {
    // Persist aggregate
    await db.orders.save(this.toData(order));

    // Persist items (part of aggregate)
    await Promise.all(
      order.items.map(item =>
        db.orderItems.save(this.itemToData(item, order.id))
      )
    );
  }

  async findById(id) {
    const orderData = await db.orders.findById(id);
    const itemsData = await db.orderItems.findByOrderId(id);

    // Reconstruct aggregate
    const order = new Order(orderData.id, orderData.customerId);
    order.status = orderData.status;

    itemsData.forEach(itemData => {
      const product = this.reconstructProduct(itemData);
      order.items.push(new OrderItem(product, itemData.quantity));
    });

    return order;
  }
}
```

### Repository Pattern
```javascript
// Repository interface
interface Repository<T> {
  findById(id: string): Promise<T | null>;
  findAll(): Promise<T[]>;
  save(entity: T): Promise<T>;
  delete(id: string): Promise<void>;
}

// Generic repository implementation
class BaseRepository<T> implements Repository<T> {
  constructor(private apiClient: ApiClient, private endpoint: string) {}

  async findById(id: string): Promise<T | null> {
    try {
      const response = await this.apiClient.get(`${this.endpoint}/${id}`);
      return this.mapToEntity(response.data);
    } catch (error) {
      if (error.status === 404) {
        return null;
      }
      throw error;
    }
  }

  async findAll(): Promise<T[]> {
    const response = await this.apiClient.get(this.endpoint);
    return response.data.map(item => this.mapToEntity(item));
  }

  async save(entity: T): Promise<T> {
    const data = this.mapToData(entity);

    if (entity.id) {
      const response = await this.apiClient.put(
        `${this.endpoint}/${entity.id}`,
        data
      );
      return this.mapToEntity(response.data);
    } else {
      const response = await this.apiClient.post(this.endpoint, data);
      return this.mapToEntity(response.data);
    }
  }

  async delete(id: string): Promise<void> {
    await this.apiClient.delete(`${this.endpoint}/${id}`);
  }

  protected mapToEntity(data: any): T {
    throw new Error('mapToEntity must be implemented');
  }

  protected mapToData(entity: T): any {
    throw new Error('mapToData must be implemented');
  }
}

// Specific repository
class UserRepository extends BaseRepository<User> {
  constructor(apiClient: ApiClient) {
    super(apiClient, '/users');
  }

  protected mapToEntity(data: any): User {
    return new User(
      data.id,
      data.email,
      data.name,
      new Date(data.createdAt)
    );
  }

  protected mapToData(user: User): any {
    return {
      id: user.id,
      email: user.email,
      name: user.name,
      createdAt: user.createdAt.toISOString()
    };
  }

  // Custom query methods
  async findByEmail(email: string): Promise<User | null> {
    const response = await this.apiClient.get(`${this.endpoint}?email=${email}`);
    const users = response.data.map(item => this.mapToEntity(item));
    return users[0] || null;
  }
}
```

### Adapter Pattern
```javascript
// Port (Interface)
interface PaymentGateway {
  charge(amount: number, token: string): Promise<PaymentResult>;
  refund(transactionId: string): Promise<RefundResult>;
}

// Adapters (Implementations)
class StripeAdapter implements PaymentGateway {
  constructor(private stripe: StripeClient) {}

  async charge(amount: number, token: string): Promise<PaymentResult> {
    try {
      const charge = await this.stripe.charges.create({
        amount: amount * 100, // Stripe uses cents
        currency: 'usd',
        source: token
      });

      return {
        success: true,
        transactionId: charge.id,
        amount: charge.amount / 100
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }

  async refund(transactionId: string): Promise<RefundResult> {
    const refund = await this.stripe.refunds.create({
      charge: transactionId
    });

    return {
      success: refund.status === 'succeeded',
      refundId: refund.id
    };
  }
}

class PayPalAdapter implements PaymentGateway {
  constructor(private paypal: PayPalClient) {}

  async charge(amount: number, token: string): Promise<PaymentResult> {
    const payment = await this.paypal.payment.create({
      intent: 'sale',
      payer: { payment_method: 'paypal' },
      transactions: [{
        amount: {
          total: amount.toString(),
          currency: 'USD'
        }
      }],
      redirect_urls: {
        return_url: '/success',
        cancel_url: '/cancel'
      }
    });

    return {
      success: payment.state === 'approved',
      transactionId: payment.id,
      amount: parseFloat(payment.transactions[0].amount.total)
    };
  }

  async refund(transactionId: string): Promise<RefundResult> {
    // PayPal refund implementation
    return { success: true, refundId: 'refund-id' };
  }
}

// Usage with dependency injection
class OrderService {
  constructor(private paymentGateway: PaymentGateway) {}

  async checkout(order: Order, paymentToken: string) {
    const result = await this.paymentGateway.charge(
      order.getTotal(),
      paymentToken
    );

    if (result.success) {
      order.markAsPaid(result.transactionId);
    }

    return result;
  }
}

// Switch implementations easily
const stripeGateway = new StripeAdapter(stripeClient);
const paypalGateway = new PayPalAdapter(paypalClient);

const orderService = new OrderService(stripeGateway);
// or
const orderService = new OrderService(paypalGateway);
```

### Observer Pattern
```javascript
// Subject (Observable)
class Subject {
  constructor() {
    this.observers = [];
  }

  subscribe(observer) {
    this.observers.push(observer);
    return () => {
      this.observers = this.observers.filter(obs => obs !== observer);
    };
  }

  notify(data) {
    this.observers.forEach(observer => observer.update(data));
  }
}

// Observer
class Observer {
  update(data) {
    console.log('Received update:', data);
  }
}

// Event Bus
class EventBus extends Subject {
  constructor() {
    super();
    this.events = new Map();
  }

  on(eventName, handler) {
    if (!this.events.has(eventName)) {
      this.events.set(eventName, []);
    }
    this.events.get(eventName).push(handler);

    return () => {
      const handlers = this.events.get(eventName);
      const index = handlers.indexOf(handler);
      if (index > -1) {
        handlers.splice(index, 1);
      }
    };
  }

  emit(eventName, data) {
    const handlers = this.events.get(eventName) || [];
    handlers.forEach(handler => handler(data));
  }
}

// Usage
const eventBus = new EventBus();

// Subscribe to events
eventBus.on('user.created', (user) => {
  console.log('Send welcome email to:', user.email);
});

eventBus.on('user.created', (user) => {
  console.log('Create user profile for:', user.id);
});

// Emit events
eventBus.emit('user.created', { id: '1', email: 'user@example.com' });
```

### State Management Patterns
```javascript
// Flux pattern
class Store {
  constructor(reducer, initialState) {
    this.reducer = reducer;
    this.state = initialState;
    this.listeners = [];
  }

  getState() {
    return this.state;
  }

  dispatch(action) {
    this.state = this.reducer(this.state, action);
    this.listeners.forEach(listener => listener());
  }

  subscribe(listener) {
    this.listeners.push(listener);
    return () => {
      this.listeners = this.listeners.filter(l => l !== listener);
    };
  }
}

// Middleware pattern
const createStore = (reducer, initialState, middleware = []) => {
  let state = initialState;
  let listeners = [];

  const getState = () => state;

  const dispatch = (action) => {
    const chain = middleware.map(mw => mw({ getState, dispatch }));
    const composedDispatch = chain.reduce(
      (next, mw) => mw(next),
      (action) => {
        state = reducer(state, action);
        listeners.forEach(listener => listener());
      }
    );
    composedDispatch(action);
  };

  const subscribe = (listener) => {
    listeners.push(listener);
    return () => {
      listeners = listeners.filter(l => l !== listener);
    };
  };

  return { getState, dispatch, subscribe };
};

// Logger middleware
const logger = ({ getState }) => next => action => {
  console.log('dispatching', action);
  const result = next(action);
  console.log('next state', getState());
  return result;
};
```

### Middleware Patterns
```javascript
// Express-style middleware
const middleware1 = (req, res, next) => {
  console.log('Middleware 1');
  next();
};

const middleware2 = (req, res, next) => {
  console.log('Middleware 2');
  next();
};

// Composing middleware
const compose = (...middlewares) => {
  return (req, res, finalHandler) => {
    let index = 0;

    const next = () => {
      if (index >= middlewares.length) {
        return finalHandler(req, res);
      }

      const middleware = middlewares[index++];
      middleware(req, res, next);
    };

    next();
  };
};

const handler = compose(middleware1, middleware2);

// Redux-style middleware
const thunk = ({ dispatch, getState }) => next => action => {
  if (typeof action === 'function') {
    return action(dispatch, getState);
  }
  return next(action);
};

const promise = ({ dispatch }) => next => action => {
  if (action.payload instanceof Promise) {
    action.payload.then(
      result => dispatch({ ...action, payload: result }),
      error => dispatch({ ...action, payload: error, error: true })
    );
    return;
  }
  return next(action);
};
```

## ADVANCED

### Microservices Architecture
```javascript
// Service boundary
class UserService {
  constructor(eventBus, userRepository) {
    this.eventBus = eventBus;
    this.userRepository = userRepository;
  }

  async createUser(userData) {
    const user = await this.userRepository.create(userData);

    // Publish event
    this.eventBus.publish('user.created', {
      userId: user.id,
      email: user.email,
      timestamp: Date.now()
    });

    return user;
  }
}

class OrderService {
  constructor(eventBus, orderRepository) {
    this.eventBus = eventBus;
    this.orderRepository = orderRepository;

    // Subscribe to events from other services
    this.eventBus.subscribe('user.created', this.handleUserCreated.bind(this));
  }

  async handleUserCreated(event) {
    // Create default cart for new user
    await this.createCart(event.userId);
  }

  async createOrder(orderData) {
    const order = await this.orderRepository.create(orderData);

    this.eventBus.publish('order.created', {
      orderId: order.id,
      userId: order.userId,
      total: order.total
    });

    return order;
  }
}

// API Gateway pattern
class ApiGateway {
  constructor(services) {
    this.services = services;
  }

  async handleRequest(request) {
    const { service, action, data } = request;

    switch (service) {
      case 'users':
        return await this.services.userService[action](data);
      case 'orders':
        return await this.services.orderService[action](data);
      default:
        throw new Error('Unknown service');
    }
  }
}
```

### Event-Driven Architecture
```javascript
// Event store
class EventStore {
  constructor() {
    this.events = [];
    this.handlers = new Map();
  }

  append(event) {
    this.events.push({
      ...event,
      timestamp: Date.now(),
      id: this.generateId()
    });

    this.dispatch(event);
  }

  subscribe(eventType, handler) {
    if (!this.handlers.has(eventType)) {
      this.handlers.set(eventType, []);
    }
    this.handlers.get(eventType).push(handler);
  }

  dispatch(event) {
    const handlers = this.handlers.get(event.type) || [];
    handlers.forEach(handler => handler(event));
  }

  getEvents(aggregateId) {
    return this.events.filter(e => e.aggregateId === aggregateId);
  }

  generateId() {
    return `evt-${Date.now()}-${Math.random()}`;
  }
}

// Saga coordinator
class OrderSaga {
  constructor(eventStore, services) {
    this.eventStore = eventStore;
    this.services = services;

    // Subscribe to events
    this.eventStore.subscribe('order.created', this.handleOrderCreated.bind(this));
    this.eventStore.subscribe('payment.processed', this.handlePaymentProcessed.bind(this));
  }

  async handleOrderCreated(event) {
    try {
      // Reserve inventory
      await this.services.inventory.reserve(event.data.items);

      // Process payment
      const payment = await this.services.payment.process({
        orderId: event.data.orderId,
        amount: event.data.total
      });

      this.eventStore.append({
        type: 'payment.processed',
        aggregateId: event.data.orderId,
        data: payment
      });
    } catch (error) {
      // Compensate on failure
      this.eventStore.append({
        type: 'order.failed',
        aggregateId: event.data.orderId,
        data: { error: error.message }
      });
    }
  }

  async handlePaymentProcessed(event) {
    // Ship order
    await this.services.shipping.ship(event.aggregateId);

    this.eventStore.append({
      type: 'order.shipped',
      aggregateId: event.aggregateId
    });
  }
}
```

### Hexagonal Architecture
```javascript
// Core domain (Hexagon)
class OrderService {
  constructor(orderRepository, paymentPort, notificationPort) {
    // Depend on ports (interfaces), not implementations
    this.orderRepository = orderRepository;
    this.paymentPort = paymentPort;
    this.notificationPort = notificationPort;
  }

  async placeOrder(orderData) {
    // Domain logic
    const order = this.validateAndCreateOrder(orderData);

    // Use ports
    const payment = await this.paymentPort.charge(order.total);

    if (payment.success) {
      await this.orderRepository.save(order);
      await this.notificationPort.sendConfirmation(order);
      return order;
    }

    throw new Error('Payment failed');
  }
}

// Ports (Interfaces)
interface PaymentPort {
  charge(amount: number): Promise<PaymentResult>;
}

interface NotificationPort {
  sendConfirmation(order: Order): Promise<void>;
}

// Adapters (Implementations)
class StripePaymentAdapter implements PaymentPort {
  async charge(amount: number): Promise<PaymentResult> {
    // Stripe-specific implementation
    return await stripe.charges.create({ amount });
  }
}

class EmailNotificationAdapter implements NotificationPort {
  async sendConfirmation(order: Order): Promise<void> {
    // Email-specific implementation
    await emailService.send({
      to: order.customerEmail,
      subject: 'Order Confirmation',
      body: `Your order ${order.id} is confirmed`
    });
  }
}

// Dependency injection (outside hexagon)
const orderService = new OrderService(
  new OrderRepository(),
  new StripePaymentAdapter(),
  new EmailNotificationAdapter()
);
```

## Test Templates

### Architecture Tests
```javascript
describe('Architecture Rules', () => {
  test('domain layer should not depend on infrastructure', () => {
    const domainFiles = glob.sync('src/domain/**/*.js');
    const infraImports = /from ['"].*infrastructure/;

    domainFiles.forEach(file => {
      const content = fs.readFileSync(file, 'utf-8');
      expect(content).not.toMatch(infraImports);
    });
  });

  test('use cases should only depend on domain and ports', () => {
    const useCaseFiles = glob.sync('src/usecases/**/*.js');

    useCaseFiles.forEach(file => {
      const content = fs.readFileSync(file, 'utf-8');
      expect(content).not.toMatch(/from ['"].*adapters/);
      expect(content).not.toMatch(/from ['"].*infrastructure/);
    });
  });
});
```

### Layer Tests
```javascript
describe('Clean Architecture Layers', () => {
  test('entities should be framework independent', () => {
    const User = require('./domain/User');
    expect(User).toBeDefined();
    expect(typeof User).toBe('function');
    // Should not import React, Express, etc.
  });

  test('use case executes business logic', async () => {
    const createUser = new CreateUserUseCase(mockRepository);
    const user = await createUser.execute({ email: 'test@example.com' });
    expect(user).toBeDefined();
    expect(mockRepository.save).toHaveBeenCalled();
  });
});
```

## Best Practices

### Architecture Design
- Start with simple patterns
- Add complexity only when needed
- Keep business logic independent of frameworks
- Use dependency inversion
- Design for testability

### Layer Boundaries
- Define clear responsibilities
- Enforce dependency rules
- Use interfaces for abstractions
- Avoid leaky abstractions
- Test architectural constraints

### SOLID Principles
- **S**ingle Responsibility: One reason to change
- **O**pen/Closed: Open for extension, closed for modification
- **L**iskov Substitution: Subtypes must be substitutable
- **I**nterface Segregation: Small, focused interfaces
- **D**ependency Inversion: Depend on abstractions

### Domain-Driven Design
- Model the domain accurately
- Use ubiquitous language
- Define bounded contexts
- Protect aggregate boundaries
- Use value objects for concepts

### Testing
- Test business logic in isolation
- Mock dependencies
- Test architectural rules
- Use integration tests for adapters
- Test use cases independently

## Production Configuration

```javascript
// Dependency injection container
class Container {
  constructor() {
    this.services = new Map();
  }

  register(name, factory) {
    this.services.set(name, factory);
  }

  resolve(name) {
    const factory = this.services.get(name);
    if (!factory) {
      throw new Error(`Service ${name} not found`);
    }
    return factory(this);
  }
}

// Configuration
const container = new Container();

// Infrastructure
container.register('database', () => new Database(config.db));
container.register('apiClient', () => new ApiClient(config.api));

// Repositories
container.register('userRepository', (c) =>
  new UserRepository(c.resolve('database'))
);

// Services
container.register('userService', (c) =>
  new UserService(
    c.resolve('userRepository'),
    c.resolve('emailService')
  )
);

// Use cases
container.register('createUser', (c) =>
  new CreateUserUseCase(c.resolve('userRepository'))
);

// Resolve
const createUser = container.resolve('createUser');
```

## Scripts

See `scripts/README.md` for available tools

## References

- See `references/GUIDE.md` for architectural principles
- See `references/PATTERNS.md` for implementation patterns

## Resources

- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Domain-Driven Design](https://martinfowler.com/bliki/DomainDrivenDesign.html)
- [Hexagonal Architecture](https://alistair.cockburn.us/hexagonal-architecture/)
- [SOLID Principles](https://en.wikipedia.org/wiki/SOLID)

---
**Status:** Production Ready | **Version:** 2.0.0 | **Last Updated:** 2025-12-30
