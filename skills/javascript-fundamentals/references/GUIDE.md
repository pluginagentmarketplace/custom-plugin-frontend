# JavaScript Fundamentals Guide

## ES6+ Features Quick Reference

### Variable Declarations

```javascript
// const - for values that won't be reassigned
const PI = 3.14159;
const user = { name: 'John' }; // Object reference is constant
user.name = 'Jane'; // ✓ Properties can change

// let - for values that will be reassigned
let count = 0;
count++; // ✓ Allowed

// Avoid var - function scoped, hoisted
// var old = 'legacy'; // ❌ Don't use
```

### Arrow Functions

```javascript
// Traditional
function add(a, b) {
  return a + b;
}

// Arrow function
const add = (a, b) => a + b;

// With body
const process = (data) => {
  const result = data.map(x => x * 2);
  return result;
};

// Important: Arrow functions don't have their own 'this'
const obj = {
  name: 'Example',
  // ❌ Arrow function loses 'this'
  badMethod: () => console.log(this.name),
  // ✓ Regular function preserves 'this'
  goodMethod() { console.log(this.name); }
};
```

### Destructuring

```javascript
// Object destructuring
const { name, age, city = 'Unknown' } = person;

// Nested destructuring
const { address: { street } } = person;

// Renaming
const { name: userName } = person;

// Array destructuring
const [first, second, ...rest] = array;

// Swap values
[a, b] = [b, a];

// Function parameters
const greet = ({ name, age }) => `Hello ${name}, age ${age}`;
```

### Spread & Rest Operators

```javascript
// Spread - expand
const newArray = [...oldArray, newItem];
const newObj = { ...oldObj, newProp: value };

// Rest - collect
const [first, ...others] = array;
const { id, ...restProps } = object;

// Function rest parameters
const sum = (...numbers) => numbers.reduce((a, b) => a + b, 0);
```

### Template Literals

```javascript
// Multi-line strings
const html = `
  <div class="card">
    <h2>${title}</h2>
    <p>${description}</p>
  </div>
`;

// Tagged templates
const highlight = (strings, ...values) => {
  return strings.reduce((acc, str, i) =>
    `${acc}${str}<mark>${values[i] || ''}</mark>`, '');
};

const result = highlight`Name: ${name}, Age: ${age}`;
```

## Async/Await Patterns

### Basic Usage

```javascript
// Async function
const fetchUser = async (id) => {
  const response = await fetch(`/api/users/${id}`);
  return response.json();
};

// Error handling
const fetchWithError = async (url) => {
  try {
    const response = await fetch(url);
    if (!response.ok) throw new Error(response.statusText);
    return await response.json();
  } catch (error) {
    console.error('Fetch failed:', error);
    throw error;
  }
};
```

### Parallel Execution

```javascript
// Sequential (slow)
const user = await fetchUser(1);
const posts = await fetchPosts(1);

// Parallel (fast)
const [user, posts] = await Promise.all([
  fetchUser(1),
  fetchPosts(1)
]);

// With error handling
const results = await Promise.allSettled([
  fetchUser(1),
  fetchPosts(1)
]);
// results: [{ status: 'fulfilled', value }, { status: 'rejected', reason }]
```

## Array Methods

### Essential Methods

```javascript
// map - transform each element
const doubled = numbers.map(n => n * 2);

// filter - keep matching elements
const adults = users.filter(u => u.age >= 18);

// reduce - accumulate to single value
const sum = numbers.reduce((acc, n) => acc + n, 0);

// find - first matching element
const admin = users.find(u => u.role === 'admin');

// findIndex - index of first match
const index = users.findIndex(u => u.id === targetId);

// some - any element matches?
const hasAdmin = users.some(u => u.role === 'admin');

// every - all elements match?
const allAdults = users.every(u => u.age >= 18);
```

### Chaining

```javascript
const result = users
  .filter(u => u.active)
  .map(u => ({ name: u.name, age: u.age }))
  .sort((a, b) => a.age - b.age)
  .slice(0, 10);
```

## Classes & OOP

### Modern Class Syntax

```javascript
class User {
  // Private field
  #password;

  // Static property
  static count = 0;

  constructor(name, email) {
    this.name = name;
    this.email = email;
    this.#password = '';
    User.count++;
  }

  // Getter
  get displayName() {
    return `${this.name} <${this.email}>`;
  }

  // Setter
  set password(value) {
    if (value.length < 8) throw new Error('Password too short');
    this.#password = value;
  }

  // Method
  greet() {
    return `Hello, I'm ${this.name}`;
  }

  // Static method
  static create(data) {
    return new User(data.name, data.email);
  }
}

// Inheritance
class Admin extends User {
  constructor(name, email, role) {
    super(name, email);
    this.role = role;
  }

  greet() {
    return `${super.greet()} (${this.role})`;
  }
}
```

## Modules

### Named Exports

```javascript
// math.js
export const add = (a, b) => a + b;
export const subtract = (a, b) => a - b;
export const PI = 3.14159;

// Import
import { add, subtract, PI } from './math.js';
import { add as sum } from './math.js'; // Rename
import * as math from './math.js'; // Namespace
```

### Default Export

```javascript
// user.js
export default class User { }

// Import
import User from './user.js';
import MyUser from './user.js'; // Can rename freely
```

## Best Practices

1. **Use const by default**, let when reassignment needed
2. **Prefer arrow functions** for callbacks and short functions
3. **Use destructuring** for cleaner code
4. **Handle errors** with try/catch in async code
5. **Use optional chaining** `?.` and nullish coalescing `??`
6. **Prefer map/filter/reduce** over for loops
7. **Use modules** to organize code
