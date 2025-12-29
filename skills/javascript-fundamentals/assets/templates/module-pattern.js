/**
 * Modern JavaScript Module Pattern Template
 * ES6+ patterns for clean, maintainable code
 */

// ============================================
// 1. Named Exports Pattern
// ============================================

export const API_BASE_URL = 'https://api.example.com';

export function fetchData(endpoint) {
  return fetch(`${API_BASE_URL}${endpoint}`)
    .then(response => {
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      return response.json();
    });
}

export async function fetchDataAsync(endpoint) {
  const response = await fetch(`${API_BASE_URL}${endpoint}`);
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }
  return response.json();
}

// ============================================
// 2. Factory Pattern
// ============================================

export function createUser(name, email) {
  // Private state via closure
  let _password = null;

  return {
    name,
    email,

    setPassword(password) {
      if (password.length < 8) {
        throw new Error('Password must be at least 8 characters');
      }
      _password = password;
    },

    validatePassword(attempt) {
      return _password === attempt;
    },

    toJSON() {
      return { name: this.name, email: this.email };
    }
  };
}

// ============================================
// 3. Class Pattern with Private Fields
// ============================================

export class EventEmitter {
  #listeners = new Map();

  on(event, callback) {
    if (!this.#listeners.has(event)) {
      this.#listeners.set(event, new Set());
    }
    this.#listeners.get(event).add(callback);

    // Return unsubscribe function
    return () => this.off(event, callback);
  }

  off(event, callback) {
    this.#listeners.get(event)?.delete(callback);
  }

  emit(event, ...args) {
    this.#listeners.get(event)?.forEach(callback => {
      try {
        callback(...args);
      } catch (error) {
        console.error(`Error in event listener for ${event}:`, error);
      }
    });
  }

  once(event, callback) {
    const wrapper = (...args) => {
      this.off(event, wrapper);
      callback(...args);
    };
    return this.on(event, wrapper);
  }
}

// ============================================
// 4. Async Utilities
// ============================================

export function debounce(fn, delay = 300) {
  let timeoutId;

  return function debounced(...args) {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => fn.apply(this, args), delay);
  };
}

export function throttle(fn, limit = 300) {
  let inThrottle = false;

  return function throttled(...args) {
    if (!inThrottle) {
      fn.apply(this, args);
      inThrottle = true;
      setTimeout(() => (inThrottle = false), limit);
    }
  };
}

export async function retry(fn, attempts = 3, delay = 1000) {
  for (let i = 0; i < attempts; i++) {
    try {
      return await fn();
    } catch (error) {
      if (i === attempts - 1) throw error;
      await new Promise(resolve => setTimeout(resolve, delay * Math.pow(2, i)));
    }
  }
}

// ============================================
// 5. Array Utilities
// ============================================

export const arrayUtils = {
  chunk(array, size) {
    return Array.from(
      { length: Math.ceil(array.length / size) },
      (_, i) => array.slice(i * size, i * size + size)
    );
  },

  unique(array, key) {
    if (key) {
      const seen = new Set();
      return array.filter(item => {
        const value = item[key];
        if (seen.has(value)) return false;
        seen.add(value);
        return true;
      });
    }
    return [...new Set(array)];
  },

  groupBy(array, key) {
    return array.reduce((groups, item) => {
      const value = typeof key === 'function' ? key(item) : item[key];
      (groups[value] ??= []).push(item);
      return groups;
    }, {});
  },

  sortBy(array, key, order = 'asc') {
    const modifier = order === 'desc' ? -1 : 1;
    return [...array].sort((a, b) => {
      const aVal = typeof key === 'function' ? key(a) : a[key];
      const bVal = typeof key === 'function' ? key(b) : b[key];
      return (aVal < bVal ? -1 : aVal > bVal ? 1 : 0) * modifier;
    });
  }
};

// ============================================
// Default Export
// ============================================

export default {
  API_BASE_URL,
  fetchData,
  fetchDataAsync,
  createUser,
  EventEmitter,
  debounce,
  throttle,
  retry,
  arrayUtils
};
