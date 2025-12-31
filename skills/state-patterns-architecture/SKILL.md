---
name: state-patterns-architecture
description: Master advanced state patterns including CQRS, Event Sourcing, and State Machines.
sasmp_version: "1.3.0"
version: "2.0.0"
bonded_agent: state-management
bond_type: SECONDARY_BOND
production_config:
  performance_budget:
    command_execution_time: "20ms"
    query_execution_time: "10ms"
    event_processing_time: "15ms"
  scalability:
    event_store_size: "100MB"
    state_machine_transitions: 1000
    concurrent_commands: 50
  monitoring:
    event_tracking: true
    state_transitions: true
    performance_metrics: true
---

# State Patterns & Architecture

Master advanced architectural patterns for state management including CQRS, Event Sourcing, State Machines, and modern architectural approaches for building scalable, maintainable applications.

## Input Schema

```typescript
interface StateArchitectureConfig {
  pattern: 'flux' | 'cqrs' | 'event-sourcing' | 'state-machine';
  dataFlow: {
    direction: 'unidirectional' | 'bidirectional';
    layers: Layer[];
    validation: ValidationStrategy;
  };
  stateDesign: {
    normalization: boolean;
    derivedState: DerivedStateStrategy;
    immutability: ImmutabilityStrategy;
  };
  commands: {
    types: CommandDefinition[];
    validation: ValidationRules;
    middleware: Middleware[];
  };
  queries: {
    types: QueryDefinition[];
    caching: CacheStrategy;
    optimization: OptimizationRules;
  };
}

interface EventSourcingConfig {
  events: EventDefinition[];
  aggregates: AggregateDefinition[];
  projections: ProjectionDefinition[];
  snapshots: SnapshotStrategy;
}

interface StateMachineConfig {
  states: StateDefinition[];
  transitions: TransitionDefinition[];
  guards: GuardFunction[];
  actions: ActionDefinition[];
}
```

## Output Schema

```typescript
interface StateArchitectureImplementation {
  commands: {
    handlers: Record<string, CommandHandler>;
    validators: Record<string, Validator>;
    executors: Record<string, Executor>;
  };
  queries: {
    handlers: Record<string, QueryHandler>;
    selectors: Record<string, Selector>;
    cache: CacheManager;
  };
  events: {
    store: EventStore;
    handlers: Record<string, EventHandler>;
    projections: Record<string, Projection>;
  };
  stateMachine: {
    current: State;
    transition: (event: Event) => State;
    canTransition: (event: Event) => boolean;
  };
  monitoring: {
    commandMetrics: CommandMetrics;
    queryMetrics: QueryMetrics;
    eventMetrics: EventMetrics;
  };
}
```

## Error Handling

| Error Type | Cause | Resolution | Prevention |
|------------|-------|------------|------------|
| `COMMAND_VALIDATION_ERROR` | Invalid command payload | Validate command before execution | Use command validators |
| `AGGREGATE_CONFLICT` | Concurrent modifications | Implement optimistic locking | Use version numbers |
| `EVENT_REPLAY_FAILURE` | Corrupted event store | Restore from snapshot | Regular snapshot creation |
| `PROJECTION_INCONSISTENCY` | Events processed out of order | Rebuild projection | Ensure event ordering |
| `STATE_TRANSITION_ERROR` | Invalid state transition | Check guard conditions | Define valid transitions |
| `CIRCULAR_DEPENDENCY` | Commands reference each other | Refactor command dependencies | Use dependency injection |
| `DENORMALIZATION_ERROR` | Derived state calculation fails | Fix derivation logic | Test derived state thoroughly |
| `SNAPSHOT_LOAD_ERROR` | Snapshot format incompatible | Migration strategy | Version snapshots |

## MANDATORY

### Flux Architecture Principles
```javascript
// Flux architecture: Action → Dispatcher → Store → View

// Actions (describe what happened)
const Actions = {
  ADD_TODO: 'ADD_TODO',
  REMOVE_TODO: 'REMOVE_TODO',
  TOGGLE_TODO: 'TOGGLE_TODO'
};

// Action Creators
const ActionCreators = {
  addTodo: (text) => ({
    type: Actions.ADD_TODO,
    payload: { text, id: nanoid(), completed: false }
  }),
  removeTodo: (id) => ({
    type: Actions.REMOVE_TODO,
    payload: { id }
  }),
  toggleTodo: (id) => ({
    type: Actions.TOGGLE_TODO,
    payload: { id }
  })
};

// Dispatcher (central hub for all actions)
class Dispatcher {
  constructor() {
    this.callbacks = [];
  }

  register(callback) {
    this.callbacks.push(callback);
    return this.callbacks.length - 1;
  }

  dispatch(action) {
    this.callbacks.forEach(callback => callback(action));
  }
}

// Store (holds application state)
class TodoStore {
  constructor(dispatcher) {
    this.todos = [];
    dispatcher.register(this.handleAction.bind(this));
  }

  handleAction(action) {
    switch (action.type) {
      case Actions.ADD_TODO:
        this.todos = [...this.todos, action.payload];
        this.emitChange();
        break;
      case Actions.REMOVE_TODO:
        this.todos = this.todos.filter(t => t.id !== action.payload.id);
        this.emitChange();
        break;
      case Actions.TOGGLE_TODO:
        this.todos = this.todos.map(t =>
          t.id === action.payload.id
            ? { ...t, completed: !t.completed }
            : t
        );
        this.emitChange();
        break;
    }
  }

  getTodos() {
    return this.todos;
  }

  emitChange() {
    this.listeners.forEach(listener => listener());
  }
}

// View (React component)
function TodoList() {
  const [todos, setTodos] = useState(todoStore.getTodos());

  useEffect(() => {
    const listener = () => setTodos(todoStore.getTodos());
    todoStore.addChangeListener(listener);
    return () => todoStore.removeChangeListener(listener);
  }, []);

  return (
    <ul>
      {todos.map(todo => (
        <li key={todo.id} onClick={() => dispatcher.dispatch(ActionCreators.toggleTodo(todo.id))}>
          {todo.text}
        </li>
      ))}
    </ul>
  );
}
```

### Unidirectional Data Flow
```javascript
// Data flows in one direction: Action → Store → View

// 1. View triggers action
const handleAddTodo = (text) => {
  dispatch(addTodo(text));
};

// 2. Action goes to store
const reducer = (state, action) => {
  switch (action.type) {
    case 'ADD_TODO':
      return {
        ...state,
        todos: [...state.todos, action.payload]
      };
    default:
      return state;
  }
};

// 3. Store updates state
const [state, dispatch] = useReducer(reducer, initialState);

// 4. View reads from store
const todos = state.todos;

// Benefits:
// - Predictable state changes
// - Easier debugging (single source of truth)
// - Better testability
// - Time-travel debugging possible
```

### Normalized State Design
```javascript
// Bad: Nested, denormalized data
const badState = {
  posts: [
    {
      id: 1,
      title: 'Post 1',
      author: { id: 1, name: 'John' },
      comments: [
        { id: 1, text: 'Comment 1', author: { id: 2, name: 'Jane' } },
        { id: 2, text: 'Comment 2', author: { id: 1, name: 'John' } }
      ]
    }
  ]
};

// Good: Normalized state
const normalizedState = {
  entities: {
    users: {
      1: { id: 1, name: 'John' },
      2: { id: 2, name: 'Jane' }
    },
    posts: {
      1: {
        id: 1,
        title: 'Post 1',
        authorId: 1,
        commentIds: [1, 2]
      }
    },
    comments: {
      1: { id: 1, text: 'Comment 1', authorId: 2, postId: 1 },
      2: { id: 2, text: 'Comment 2', authorId: 1, postId: 1 }
    }
  },
  result: [1] // Top-level post IDs
};

// Normalization utilities
import { normalize, schema } from 'normalizr';

const user = new schema.Entity('users');
const comment = new schema.Entity('comments', { author: user });
const post = new schema.Entity('posts', {
  author: user,
  comments: [comment]
});

const normalizedData = normalize(originalData, [post]);

// Denormalization selector
const denormalizePost = (state, postId) => {
  const post = state.entities.posts[postId];
  return {
    ...post,
    author: state.entities.users[post.authorId],
    comments: post.commentIds.map(id => ({
      ...state.entities.comments[id],
      author: state.entities.users[state.entities.comments[id].authorId]
    }))
  };
};
```

### Action/Command Patterns
```javascript
// Command pattern for encapsulating actions

class Command {
  execute() {
    throw new Error('execute() must be implemented');
  }

  undo() {
    throw new Error('undo() must be implemented');
  }
}

// Concrete commands
class AddTodoCommand extends Command {
  constructor(store, todo) {
    super();
    this.store = store;
    this.todo = todo;
  }

  execute() {
    this.store.dispatch({ type: 'ADD_TODO', payload: this.todo });
  }

  undo() {
    this.store.dispatch({ type: 'REMOVE_TODO', payload: { id: this.todo.id } });
  }
}

class UpdateTodoCommand extends Command {
  constructor(store, id, updates) {
    super();
    this.store = store;
    this.id = id;
    this.updates = updates;
    this.previousState = null;
  }

  execute() {
    const todo = this.store.getState().todos.find(t => t.id === this.id);
    this.previousState = { ...todo };
    this.store.dispatch({
      type: 'UPDATE_TODO',
      payload: { id: this.id, updates: this.updates }
    });
  }

  undo() {
    this.store.dispatch({
      type: 'UPDATE_TODO',
      payload: { id: this.id, updates: this.previousState }
    });
  }
}

// Command invoker with undo/redo
class CommandManager {
  constructor() {
    this.history = [];
    this.currentIndex = -1;
  }

  execute(command) {
    command.execute();
    this.history = this.history.slice(0, this.currentIndex + 1);
    this.history.push(command);
    this.currentIndex++;
  }

  undo() {
    if (this.currentIndex >= 0) {
      this.history[this.currentIndex].undo();
      this.currentIndex--;
    }
  }

  redo() {
    if (this.currentIndex < this.history.length - 1) {
      this.currentIndex++;
      this.history[this.currentIndex].execute();
    }
  }

  canUndo() {
    return this.currentIndex >= 0;
  }

  canRedo() {
    return this.currentIndex < this.history.length - 1;
  }
}
```

### State Immutability
```javascript
// Immutability principles and patterns

// Bad: Mutation
const badUpdate = (state) => {
  state.todos.push(newTodo); // Mutates state
  return state;
};

// Good: Immutable update
const goodUpdate = (state) => ({
  ...state,
  todos: [...state.todos, newTodo]
});

// Deep immutable updates
const deepUpdate = (state) => ({
  ...state,
  user: {
    ...state.user,
    profile: {
      ...state.user.profile,
      settings: {
        ...state.user.profile.settings,
        theme: 'dark'
      }
    }
  }
});

// Using Immer for easier immutable updates
import produce from 'immer';

const immerUpdate = produce((draft, action) => {
  switch (action.type) {
    case 'UPDATE_THEME':
      draft.user.profile.settings.theme = action.payload;
      break;
    case 'ADD_TODO':
      draft.todos.push(action.payload);
      break;
  }
});

// Freeze state in development
const createStore = (reducer, initialState) => {
  if (process.env.NODE_ENV !== 'production') {
    return Object.freeze(initialState);
  }
  return initialState;
};
```

### Derived State Strategies
```javascript
// Compute derived state from base state

// Memoized selectors
import { createSelector } from 'reselect';

const getTodos = (state) => state.todos;
const getFilter = (state) => state.filter;

const getVisibleTodos = createSelector(
  [getTodos, getFilter],
  (todos, filter) => {
    switch (filter) {
      case 'COMPLETED':
        return todos.filter(t => t.completed);
      case 'ACTIVE':
        return todos.filter(t => !t.completed);
      default:
        return todos;
    }
  }
);

const getTodoStats = createSelector(
  [getTodos],
  (todos) => ({
    total: todos.length,
    completed: todos.filter(t => t.completed).length,
    active: todos.filter(t => !t.completed).length
  })
);

// Derive at render time
function TodoStats() {
  const todos = useSelector(getTodos);
  const stats = useMemo(() => ({
    total: todos.length,
    completed: todos.filter(t => t.completed).length,
    active: todos.filter(t => !t.completed).length
  }), [todos]);

  return <div>{/* render stats */}</div>;
}

// Store derived state when expensive
const reducer = (state, action) => {
  switch (action.type) {
    case 'ADD_TODO':
      const newTodos = [...state.todos, action.payload];
      return {
        ...state,
        todos: newTodos,
        stats: {
          total: newTodos.length,
          completed: newTodos.filter(t => t.completed).length
        }
      };
    default:
      return state;
  }
};
```

## OPTIONAL

### CQRS (Command Query Responsibility Segregation)
```javascript
// Separate read and write models

// Write Model (Commands)
class TodoCommandHandler {
  constructor(eventStore) {
    this.eventStore = eventStore;
  }

  async handle(command) {
    switch (command.type) {
      case 'CreateTodo':
        return this.createTodo(command);
      case 'UpdateTodo':
        return this.updateTodo(command);
      case 'DeleteTodo':
        return this.deleteTodo(command);
    }
  }

  async createTodo(command) {
    // Validate command
    if (!command.text) {
      throw new Error('Todo text is required');
    }

    // Create event
    const event = {
      type: 'TodoCreated',
      aggregateId: nanoid(),
      data: {
        text: command.text,
        createdAt: Date.now()
      },
      metadata: {
        userId: command.userId,
        timestamp: Date.now()
      }
    };

    // Persist event
    await this.eventStore.append(event);

    return event.aggregateId;
  }
}

// Read Model (Queries)
class TodoQueryHandler {
  constructor(readModel) {
    this.readModel = readModel;
  }

  async handle(query) {
    switch (query.type) {
      case 'GetTodos':
        return this.getTodos(query);
      case 'GetTodoById':
        return this.getTodoById(query);
      case 'GetTodoStats':
        return this.getTodoStats(query);
    }
  }

  async getTodos(query) {
    const { filter, userId } = query;
    let todos = await this.readModel.findAll({ userId });

    if (filter === 'active') {
      todos = todos.filter(t => !t.completed);
    } else if (filter === 'completed') {
      todos = todos.filter(t => t.completed);
    }

    return todos;
  }

  async getTodoStats(query) {
    const todos = await this.readModel.findAll({ userId: query.userId });
    return {
      total: todos.length,
      completed: todos.filter(t => t.completed).length,
      active: todos.filter(t => !t.completed).length
    };
  }
}

// Usage
const commandBus = new CommandBus(commandHandler);
const queryBus = new QueryBus(queryHandler);

// Write
await commandBus.execute({
  type: 'CreateTodo',
  text: 'Learn CQRS',
  userId: 'user-1'
});

// Read
const todos = await queryBus.execute({
  type: 'GetTodos',
  filter: 'active',
  userId: 'user-1'
});
```

### Event Sourcing Basics
```javascript
// Store state as sequence of events

// Event Store
class EventStore {
  constructor() {
    this.events = [];
  }

  append(event) {
    const eventWithMetadata = {
      ...event,
      sequenceNumber: this.events.length,
      timestamp: Date.now()
    };
    this.events.push(eventWithMetadata);
    return eventWithMetadata;
  }

  getEvents(aggregateId, fromSequence = 0) {
    return this.events.filter(
      e => e.aggregateId === aggregateId && e.sequenceNumber >= fromSequence
    );
  }

  getAllEvents() {
    return this.events;
  }
}

// Aggregate
class TodoAggregate {
  constructor(id) {
    this.id = id;
    this.version = 0;
    this.text = '';
    this.completed = false;
    this.deleted = false;
  }

  // Apply events to rebuild state
  applyEvent(event) {
    switch (event.type) {
      case 'TodoCreated':
        this.text = event.data.text;
        break;
      case 'TodoCompleted':
        this.completed = true;
        break;
      case 'TodoUncompleted':
        this.completed = false;
        break;
      case 'TodoDeleted':
        this.deleted = true;
        break;
    }
    this.version++;
  }

  // Command handlers
  create(text) {
    if (this.version > 0) {
      throw new Error('Todo already exists');
    }
    return {
      type: 'TodoCreated',
      aggregateId: this.id,
      data: { text }
    };
  }

  complete() {
    if (this.completed) {
      throw new Error('Todo already completed');
    }
    return {
      type: 'TodoCompleted',
      aggregateId: this.id
    };
  }
}

// Repository
class TodoRepository {
  constructor(eventStore) {
    this.eventStore = eventStore;
  }

  async load(id) {
    const events = this.eventStore.getEvents(id);
    const aggregate = new TodoAggregate(id);
    events.forEach(event => aggregate.applyEvent(event));
    return aggregate;
  }

  async save(aggregate, events) {
    events.forEach(event => {
      this.eventStore.append(event);
      aggregate.applyEvent(event);
    });
  }
}

// Usage
const repo = new TodoRepository(eventStore);
const todo = new TodoAggregate(nanoid());
const createEvent = todo.create('Learn Event Sourcing');
await repo.save(todo, [createEvent]);

const completeEvent = todo.complete();
await repo.save(todo, [completeEvent]);
```

### State Machines with XState
```javascript
import { createMachine, interpret } from 'xstate';

// Define state machine
const todoMachine = createMachine({
  id: 'todo',
  initial: 'idle',
  context: {
    todos: [],
    error: null
  },
  states: {
    idle: {
      on: {
        FETCH: 'loading',
        ADD: {
          actions: 'addTodo'
        }
      }
    },
    loading: {
      invoke: {
        src: 'fetchTodos',
        onDone: {
          target: 'success',
          actions: 'setTodos'
        },
        onError: {
          target: 'failure',
          actions: 'setError'
        }
      }
    },
    success: {
      on: {
        FETCH: 'loading',
        ADD: {
          actions: 'addTodo'
        },
        TOGGLE: {
          actions: 'toggleTodo'
        }
      }
    },
    failure: {
      on: {
        RETRY: 'loading'
      }
    }
  }
}, {
  actions: {
    addTodo: (context, event) => ({
      todos: [...context.todos, event.todo]
    }),
    toggleTodo: (context, event) => ({
      todos: context.todos.map(t =>
        t.id === event.id ? { ...t, completed: !t.completed } : t
      )
    }),
    setTodos: (context, event) => ({
      todos: event.data
    }),
    setError: (context, event) => ({
      error: event.data
    })
  },
  services: {
    fetchTodos: async () => {
      const response = await fetch('/api/todos');
      return response.json();
    }
  }
});

// Use in React
import { useMachine } from '@xstate/react';

function TodoApp() {
  const [state, send] = useMachine(todoMachine);

  return (
    <div>
      {state.matches('loading') && <Spinner />}
      {state.matches('success') && (
        <TodoList
          todos={state.context.todos}
          onToggle={(id) => send({ type: 'TOGGLE', id })}
        />
      )}
      {state.matches('failure') && (
        <Error error={state.context.error} onRetry={() => send('RETRY')} />
      )}
    </div>
  );
}
```

### Optimistic Updates
```javascript
// Update UI immediately, rollback on error

const optimisticUpdate = async (dispatch, getState) => {
  const tempId = `temp-${Date.now()}`;
  const todo = { id: tempId, text: 'New todo', completed: false };

  // Optimistic update
  dispatch({
    type: 'ADD_TODO_OPTIMISTIC',
    payload: todo
  });

  try {
    // Server request
    const response = await api.createTodo(todo);

    // Replace temporary todo with server response
    dispatch({
      type: 'ADD_TODO_SUCCESS',
      payload: response.data,
      meta: { tempId }
    });
  } catch (error) {
    // Rollback optimistic update
    dispatch({
      type: 'ADD_TODO_FAILURE',
      payload: { tempId },
      error: true
    });
  }
};

// Reducer
const reducer = (state, action) => {
  switch (action.type) {
    case 'ADD_TODO_OPTIMISTIC':
      return {
        ...state,
        todos: [...state.todos, { ...action.payload, pending: true }]
      };
    case 'ADD_TODO_SUCCESS':
      return {
        ...state,
        todos: state.todos.map(t =>
          t.id === action.meta.tempId
            ? { ...action.payload, pending: false }
            : t
        )
      };
    case 'ADD_TODO_FAILURE':
      return {
        ...state,
        todos: state.todos.filter(t => t.id !== action.payload.tempId)
      };
    default:
      return state;
  }
};
```

### State Hydration
```javascript
// Rehydrate state from persistent storage

// Save state
const saveState = (state) => {
  try {
    const serialized = JSON.stringify(state);
    localStorage.setItem('appState', serialized);
  } catch (error) {
    console.error('Failed to save state:', error);
  }
};

// Load state
const loadState = () => {
  try {
    const serialized = localStorage.getItem('appState');
    if (serialized === null) {
      return undefined;
    }
    return JSON.parse(serialized);
  } catch (error) {
    console.error('Failed to load state:', error);
    return undefined;
  }
};

// Redux persistence
import { createStore } from 'redux';
import throttle from 'lodash/throttle';

const persistedState = loadState();
const store = createStore(reducer, persistedState);

// Save on every state change (throttled)
store.subscribe(throttle(() => {
  saveState(store.getState());
}, 1000));

// Migration strategy
const migrateState = (persistedState, version) => {
  if (!persistedState) return undefined;

  let migrated = persistedState;

  if (migrated.version < 2) {
    migrated = {
      ...migrated,
      newField: 'default',
      version: 2
    };
  }

  if (migrated.version < 3) {
    migrated = {
      ...migrated,
      renamedField: migrated.oldField,
      version: 3
    };
    delete migrated.oldField;
  }

  return migrated;
};
```

### Server State vs Client State
```javascript
// Separate server and client concerns

// Server state (from API)
const useServerState = () => {
  const { data, isLoading, error } = useQuery('todos', fetchTodos);
  return { todos: data, loading: isLoading, error };
};

// Client state (UI only)
const useClientState = () => {
  const [filter, setFilter] = useState('all');
  const [searchTerm, setSearchTerm] = useState('');
  return { filter, setFilter, searchTerm, setSearchTerm };
};

// Combined in component
function TodoApp() {
  // Server state
  const { todos, loading } = useServerState();

  // Client state
  const { filter, setFilter, searchTerm, setSearchTerm } = useClientState();

  // Derived state
  const filteredTodos = useMemo(() => {
    let result = todos || [];

    if (filter === 'active') {
      result = result.filter(t => !t.completed);
    } else if (filter === 'completed') {
      result = result.filter(t => t.completed);
    }

    if (searchTerm) {
      result = result.filter(t =>
        t.text.toLowerCase().includes(searchTerm.toLowerCase())
      );
    }

    return result;
  }, [todos, filter, searchTerm]);

  return <TodoList todos={filteredTodos} />;
}
```

## ADVANCED

### Event-Driven Architecture
```javascript
// Event bus for decoupled communication

class EventBus {
  constructor() {
    this.subscribers = new Map();
  }

  subscribe(eventType, handler) {
    if (!this.subscribers.has(eventType)) {
      this.subscribers.set(eventType, []);
    }
    this.subscribers.get(eventType).push(handler);

    // Return unsubscribe function
    return () => {
      const handlers = this.subscribers.get(eventType);
      const index = handlers.indexOf(handler);
      if (index > -1) {
        handlers.splice(index, 1);
      }
    };
  }

  publish(event) {
    const handlers = this.subscribers.get(event.type) || [];
    handlers.forEach(handler => handler(event));
  }
}

// Event handlers
const eventBus = new EventBus();

eventBus.subscribe('TodoCreated', (event) => {
  analytics.track('todo_created', event.data);
});

eventBus.subscribe('TodoCreated', (event) => {
  notifications.show(`Todo "${event.data.text}" created`);
});

eventBus.subscribe('TodoCompleted', (event) => {
  analytics.track('todo_completed', event.data);
});

// Publish events
eventBus.publish({
  type: 'TodoCreated',
  data: { text: 'Learn Event-Driven Architecture', id: '1' }
});
```

### Saga Patterns
```javascript
import { takeEvery, call, put, select } from 'redux-saga/effects';

// Saga for complex async flows
function* createTodoSaga(action) {
  try {
    // Start loading
    yield put({ type: 'CREATE_TODO_START' });

    // Call API
    const todo = yield call(api.createTodo, action.payload);

    // Success
    yield put({ type: 'CREATE_TODO_SUCCESS', payload: todo });

    // Side effects
    yield call(analytics.track, 'todo_created', { id: todo.id });

    // Navigate
    yield call(navigate, `/todos/${todo.id}`);

  } catch (error) {
    yield put({ type: 'CREATE_TODO_FAILURE', error: error.message });
    yield call(showNotification, 'Failed to create todo');
  }
}

function* watchCreateTodo() {
  yield takeEvery('CREATE_TODO_REQUEST', createTodoSaga);
}

// Complex coordination
function* fetchTodoWithRelatedData(action) {
  const { todoId } = action.payload;

  // Fetch in parallel
  const [todo, comments, author] = yield all([
    call(api.getTodo, todoId),
    call(api.getComments, todoId),
    call(api.getUser, todoId)
  ]);

  yield put({
    type: 'FETCH_TODO_SUCCESS',
    payload: { todo, comments, author }
  });
}
```

### CQRS Implementation
```typescript
// Full CQRS implementation with Event Sourcing

interface Command {
  type: string;
  aggregateId: string;
  data: any;
}

interface Event {
  type: string;
  aggregateId: string;
  data: any;
  sequenceNumber: number;
  timestamp: number;
}

class CommandBus {
  private handlers = new Map<string, CommandHandler>();

  register(commandType: string, handler: CommandHandler) {
    this.handlers.set(commandType, handler);
  }

  async execute(command: Command): Promise<any> {
    const handler = this.handlers.get(command.type);
    if (!handler) {
      throw new Error(`No handler for command: ${command.type}`);
    }
    return handler.handle(command);
  }
}

class QueryBus {
  private handlers = new Map<string, QueryHandler>();

  register(queryType: string, handler: QueryHandler) {
    this.handlers.set(queryType, handler);
  }

  async execute(query: Query): Promise<any> {
    const handler = this.handlers.get(query.type);
    if (!handler) {
      throw new Error(`No handler for query: ${query.type}`);
    }
    return handler.handle(query);
  }
}

// Projection builder
class ProjectionBuilder {
  private projections = new Map();

  async project(event: Event) {
    const projection = this.projections.get(event.aggregateId) || {};

    switch (event.type) {
      case 'TodoCreated':
        projection.id = event.aggregateId;
        projection.text = event.data.text;
        projection.completed = false;
        break;
      case 'TodoCompleted':
        projection.completed = true;
        break;
    }

    this.projections.set(event.aggregateId, projection);
  }

  getProjection(id: string) {
    return this.projections.get(id);
  }

  getAllProjections() {
    return Array.from(this.projections.values());
  }
}
```

## Test Templates

### Command Tests
```javascript
describe('TodoCommandHandler', () => {
  test('creates todo', async () => {
    const handler = new TodoCommandHandler(eventStore);
    const command = {
      type: 'CreateTodo',
      text: 'Test todo',
      userId: 'user-1'
    };

    const id = await handler.handle(command);

    const events = eventStore.getEvents(id);
    expect(events).toHaveLength(1);
    expect(events[0].type).toBe('TodoCreated');
  });
});
```

### Event Sourcing Tests
```javascript
describe('TodoAggregate', () => {
  test('applies events correctly', () => {
    const aggregate = new TodoAggregate('1');
    aggregate.applyEvent({ type: 'TodoCreated', data: { text: 'Test' } });
    aggregate.applyEvent({ type: 'TodoCompleted' });

    expect(aggregate.text).toBe('Test');
    expect(aggregate.completed).toBe(true);
  });
});
```

## Best Practices

### Architecture Design
- Choose patterns based on complexity
- Start simple, evolve as needed
- Separate concerns clearly
- Document architectural decisions
- Use ADRs (Architecture Decision Records)

### State Design
- Normalize complex data structures
- Minimize state, derive when possible
- Keep state serializable
- Version your state shape
- Implement migration strategies

### Command/Query Separation
- Clear separation of read/write
- Commands modify state, queries don't
- Validate commands before execution
- Cache query results appropriately
- Monitor command/query performance

### Event Sourcing
- Events are immutable facts
- Use past tense for event names
- Include metadata (user, timestamp)
- Implement snapshots for performance
- Version your events

### Performance
- Optimize projections for queries
- Use snapshots to reduce replays
- Cache derived state
- Monitor state size
- Implement pagination

## Production Configuration

```javascript
// Production-ready CQRS setup
const commandBus = new CommandBus({
  middleware: [
    validationMiddleware,
    authorizationMiddleware,
    loggingMiddleware
  ],
  errorHandler: (error) => {
    logger.error('Command failed:', error);
    metrics.increment('command.error');
  }
});

const queryBus = new QueryBus({
  cache: new QueryCache({
    ttl: 300000, // 5 minutes
    maxSize: 1000
  }),
  middleware: [
    cachingMiddleware,
    performanceMiddleware
  ]
});

const eventStore = new EventStore({
  storage: productionStorage,
  snapshotInterval: 100,
  encryption: true
});
```

## Assets

- See `assets/state-architecture-config.yaml` for patterns

## Resources

- [CQRS Pattern](https://martinfowler.com/bliki/CQRS.html)
- [Event Sourcing](https://martinfowler.com/eaaDev/EventSourcing.html)
- [XState Documentation](https://xstate.js.org/)
- [Flux Architecture](https://facebook.github.io/flux/)
- [Redux Architecture](https://redux.js.org/understanding/thinking-in-redux/three-principles)

---
**Status:** Production Ready | **Version:** 2.0.0 | **Last Updated:** 2025-12-30
