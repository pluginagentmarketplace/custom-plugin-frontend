#!/bin/bash
# JavaScript Module Generator
# Part of javascript-fundamentals skill - Golden Format E703 Compliant

set -e

MODULE_NAME="${1:-myModule}"
OUTPUT_DIR="${2:-.}"

OUTPUT_FILE="$OUTPUT_DIR/$MODULE_NAME.js"

cat > "$OUTPUT_FILE" << 'EOF'
/**
 * MODULE_NAME Module
 *
 * @description ES6+ module with modern JavaScript patterns
 * @example
 * import { functionName } from './MODULE_NAME';
 */

// Private state (module scope)
let _privateState = {};

/**
 * Initialize the module
 * @param {Object} config - Configuration options
 */
export const init = (config = {}) => {
  _privateState = { ...config };
  console.log('MODULE_NAME initialized');
};

/**
 * Example async function with error handling
 * @param {string} param - Input parameter
 * @returns {Promise<Object>} Result object
 */
export const fetchData = async (param) => {
  try {
    const response = await fetch(`/api/${param}`);
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    return await response.json();
  } catch (error) {
    console.error('Fetch error:', error);
    throw error;
  }
};

/**
 * Example higher-order function
 * @param {Function} fn - Function to wrap
 * @returns {Function} Wrapped function with logging
 */
export const withLogging = (fn) => {
  return (...args) => {
    console.log(`Calling ${fn.name} with:`, args);
    const result = fn(...args);
    console.log(`Result:`, result);
    return result;
  };
};

/**
 * Example class with modern syntax
 */
export class DataHandler {
  #privateField = [];

  constructor(initialData = []) {
    this.#privateField = initialData;
  }

  get data() {
    return [...this.#privateField];
  }

  add(item) {
    this.#privateField.push(item);
    return this;
  }

  filter(predicate) {
    return this.#privateField.filter(predicate);
  }

  map(transform) {
    return this.#privateField.map(transform);
  }
}

// Default export
export default {
  init,
  fetchData,
  withLogging,
  DataHandler,
};
EOF

# Replace placeholder with actual module name
sed -i '' "s/MODULE_NAME/$MODULE_NAME/g" "$OUTPUT_FILE" 2>/dev/null || \
sed -i "s/MODULE_NAME/$MODULE_NAME/g" "$OUTPUT_FILE"

echo "✓ Generated JavaScript module: $OUTPUT_FILE"
echo ""
echo "Module features:"
echo "  - ES6+ syntax (arrow functions, classes)"
echo "  - Private fields with #"
echo "  - Async/await pattern"
echo "  - Higher-order functions"
echo "  - Named and default exports"
echo ""
echo "Usage:"
echo "  import { init, fetchData, DataHandler } from './$MODULE_NAME';"
echo "  import $MODULE_NAME from './$MODULE_NAME';"
