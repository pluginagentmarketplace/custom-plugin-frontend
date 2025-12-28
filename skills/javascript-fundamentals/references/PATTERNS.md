# JavaScript Design Patterns

## Module Pattern

Encapsulate private state with public API:

```javascript
const Counter = (() => {
  // Private
  let count = 0;

  // Public API
  return {
    increment: () => ++count,
    decrement: () => --count,
    getCount: () => count,
    reset: () => { count = 0; }
  };
})();

Counter.increment(); // 1
Counter.getCount();  // 1
```

## Singleton Pattern

Ensure single instance:

```javascript
class Database {
  static #instance = null;

  constructor() {
    if (Database.#instance) {
      return Database.#instance;
    }
    Database.#instance = this;
    this.connection = null;
  }

  connect(url) {
    this.connection = url;
    return this;
  }

  static getInstance() {
    if (!Database.#instance) {
      Database.#instance = new Database();
    }
    return Database.#instance;
  }
}

const db1 = Database.getInstance();
const db2 = Database.getInstance();
console.log(db1 === db2); // true
```

## Factory Pattern

Create objects without specifying exact class:

```javascript
class UserFactory {
  static create(type, data) {
    switch (type) {
      case 'admin':
        return new Admin(data);
      case 'editor':
        return new Editor(data);
      case 'viewer':
        return new Viewer(data);
      default:
        throw new Error(`Unknown user type: ${type}`);
    }
  }
}

const admin = UserFactory.create('admin', { name: 'John' });
```

## Observer Pattern

Publish/Subscribe for event handling:

```javascript
class EventEmitter {
  #events = {};

  on(event, callback) {
    if (!this.#events[event]) {
      this.#events[event] = [];
    }
    this.#events[event].push(callback);
    return () => this.off(event, callback); // Return unsubscribe
  }

  off(event, callback) {
    if (!this.#events[event]) return;
    this.#events[event] = this.#events[event]
      .filter(cb => cb !== callback);
  }

  emit(event, data) {
    if (!this.#events[event]) return;
    this.#events[event].forEach(cb => cb(data));
  }

  once(event, callback) {
    const wrapper = (data) => {
      callback(data);
      this.off(event, wrapper);
    };
    this.on(event, wrapper);
  }
}

// Usage
const emitter = new EventEmitter();
const unsubscribe = emitter.on('userLogin', (user) => {
  console.log(`${user.name} logged in`);
});

emitter.emit('userLogin', { name: 'John' });
unsubscribe(); // Remove listener
```

## Decorator Pattern

Add behavior dynamically:

```javascript
// Function decorator
const withLogging = (fn) => {
  return function(...args) {
    console.log(`Calling ${fn.name} with:`, args);
    const result = fn.apply(this, args);
    console.log(`Result:`, result);
    return result;
  };
};

const add = (a, b) => a + b;
const loggedAdd = withLogging(add);
loggedAdd(2, 3); // Logs: Calling add with: [2, 3], Result: 5

// Class method decorator (Stage 3 proposal)
function log(target, key, descriptor) {
  const original = descriptor.value;
  descriptor.value = function(...args) {
    console.log(`${key} called with:`, args);
    return original.apply(this, args);
  };
  return descriptor;
}
```

## Strategy Pattern

Interchangeable algorithms:

```javascript
// Strategies
const strategies = {
  add: (a, b) => a + b,
  subtract: (a, b) => a - b,
  multiply: (a, b) => a * b,
  divide: (a, b) => a / b,
};

// Context
class Calculator {
  constructor(strategy = 'add') {
    this.strategy = strategy;
  }

  setStrategy(strategy) {
    this.strategy = strategy;
  }

  calculate(a, b) {
    return strategies[this.strategy](a, b);
  }
}

const calc = new Calculator('multiply');
calc.calculate(4, 5); // 20
calc.setStrategy('add');
calc.calculate(4, 5); // 9
```

## Proxy Pattern

Control access to objects:

```javascript
const createReactiveObject = (target, onChange) => {
  return new Proxy(target, {
    get(obj, prop) {
      console.log(`Getting ${prop}`);
      return obj[prop];
    },
    set(obj, prop, value) {
      console.log(`Setting ${prop} to ${value}`);
      obj[prop] = value;
      onChange(prop, value);
      return true;
    }
  });
};

const state = createReactiveObject(
  { count: 0 },
  (prop, value) => console.log(`State changed: ${prop} = ${value}`)
);

state.count = 5; // Logs: Setting count to 5, State changed: count = 5
```

## Async Patterns

### Retry Pattern

```javascript
const retry = async (fn, maxAttempts = 3, delay = 1000) => {
  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await fn();
    } catch (error) {
      if (attempt === maxAttempts) throw error;
      console.log(`Attempt ${attempt} failed, retrying...`);
      await new Promise(r => setTimeout(r, delay * attempt));
    }
  }
};

// Usage
const data = await retry(() => fetch('/api/data').then(r => r.json()));
```

### Debounce Pattern

```javascript
const debounce = (fn, delay) => {
  let timeoutId;
  return (...args) => {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => fn(...args), delay);
  };
};

// Usage
const handleSearch = debounce((query) => {
  console.log('Searching:', query);
}, 300);
```

### Throttle Pattern

```javascript
const throttle = (fn, limit) => {
  let inThrottle;
  return (...args) => {
    if (!inThrottle) {
      fn(...args);
      inThrottle = true;
      setTimeout(() => inThrottle = false, limit);
    }
  };
};

// Usage
const handleScroll = throttle(() => {
  console.log('Scroll event');
}, 100);
```

## Composition Over Inheritance

```javascript
// Composable behaviors
const canFly = (state) => ({
  fly: () => console.log(`${state.name} is flying`)
});

const canSwim = (state) => ({
  swim: () => console.log(`${state.name} is swimming`)
});

const canWalk = (state) => ({
  walk: () => console.log(`${state.name} is walking`)
});

// Factory with composition
const createDuck = (name) => {
  const state = { name };
  return {
    ...state,
    ...canFly(state),
    ...canSwim(state),
    ...canWalk(state)
  };
};

const duck = createDuck('Donald');
duck.fly();  // Donald is flying
duck.swim(); // Donald is swimming
```
