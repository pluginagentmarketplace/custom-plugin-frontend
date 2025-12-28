#!/bin/bash
# Vue 3 Composable Generator
# Part of vue-composition-api skill - Golden Format E703 Compliant

set -e

COMPOSABLE_NAME="${1:-useExample}"
OUTPUT_DIR="${2:-./src/composables}"
COMPOSABLE_TYPE="${3:-basic}"  # basic, async, store

# Ensure use* prefix
if [[ ! "$COMPOSABLE_NAME" =~ ^use ]]; then
    COMPOSABLE_NAME="use${COMPOSABLE_NAME^}"
fi

# Create directory
mkdir -p "$OUTPUT_DIR"

# Get PascalCase name without 'use' for types
TYPE_NAME="${COMPOSABLE_NAME#use}"

case "$COMPOSABLE_TYPE" in
    async)
        cat > "$OUTPUT_DIR/$COMPOSABLE_NAME.ts" << EOF
import { ref, computed, watch, type Ref } from 'vue';

export interface ${TYPE_NAME}Options {
  /** Initial data */
  initialData?: ${TYPE_NAME}Data | null;
  /** Auto-fetch on mount */
  immediate?: boolean;
  /** Fetch on parameter change */
  watchParams?: boolean;
}

export interface ${TYPE_NAME}Data {
  id: string;
  // Add your data fields here
}

export interface ${TYPE_NAME}Return {
  /** Data state */
  data: Ref<${TYPE_NAME}Data | null>;
  /** Loading state */
  loading: Ref<boolean>;
  /** Error state */
  error: Ref<Error | null>;
  /** Fetch data */
  fetch: (params?: Record<string, unknown>) => Promise<void>;
  /** Refresh data */
  refresh: () => Promise<void>;
  /** Reset state */
  reset: () => void;
}

/**
 * ${COMPOSABLE_NAME}
 *
 * @description Async data fetching composable
 * @example
 * const { data, loading, error, fetch } = ${COMPOSABLE_NAME}({ immediate: true });
 */
export function ${COMPOSABLE_NAME}(
  options: ${TYPE_NAME}Options = {}
): ${TYPE_NAME}Return {
  const { initialData = null, immediate = false, watchParams = false } = options;

  const data = ref<${TYPE_NAME}Data | null>(initialData);
  const loading = ref(false);
  const error = ref<Error | null>(null);
  const lastParams = ref<Record<string, unknown>>({});

  const fetch = async (params: Record<string, unknown> = {}) => {
    loading.value = true;
    error.value = null;
    lastParams.value = params;

    try {
      // Replace with actual API call
      const response = await fetchAPI('/api/endpoint', params);
      data.value = response;
    } catch (e) {
      error.value = e instanceof Error ? e : new Error('Unknown error');
      console.error('${COMPOSABLE_NAME} error:', e);
    } finally {
      loading.value = false;
    }
  };

  const refresh = () => fetch(lastParams.value);

  const reset = () => {
    data.value = initialData;
    loading.value = false;
    error.value = null;
  };

  // Auto-fetch if immediate
  if (immediate) {
    fetch();
  }

  return {
    data,
    loading,
    error,
    fetch,
    refresh,
    reset,
  };
}

// Helper function (replace with your API client)
async function fetchAPI(url: string, params: Record<string, unknown>) {
  const queryString = new URLSearchParams(
    params as Record<string, string>
  ).toString();
  const response = await fetch(\`\${url}?\${queryString}\`);
  if (!response.ok) throw new Error(response.statusText);
  return response.json();
}

export default ${COMPOSABLE_NAME};
EOF
        ;;

    store)
        cat > "$OUTPUT_DIR/$COMPOSABLE_NAME.ts" << EOF
import { ref, computed, readonly, type DeepReadonly, type Ref } from 'vue';

export interface ${TYPE_NAME}State {
  items: ${TYPE_NAME}Item[];
  selectedId: string | null;
  filter: string;
}

export interface ${TYPE_NAME}Item {
  id: string;
  name: string;
  // Add your item fields here
}

export interface ${TYPE_NAME}Return {
  /** Readonly state */
  state: DeepReadonly<Ref<${TYPE_NAME}State>>;
  /** Computed: filtered items */
  filteredItems: Ref<${TYPE_NAME}Item[]>;
  /** Computed: selected item */
  selectedItem: Ref<${TYPE_NAME}Item | undefined>;
  /** Actions */
  addItem: (item: Omit<${TYPE_NAME}Item, 'id'>) => void;
  removeItem: (id: string) => void;
  updateItem: (id: string, updates: Partial<${TYPE_NAME}Item>) => void;
  selectItem: (id: string | null) => void;
  setFilter: (filter: string) => void;
  reset: () => void;
}

// Singleton state (shared across components)
const state = ref<${TYPE_NAME}State>({
  items: [],
  selectedId: null,
  filter: '',
});

/**
 * ${COMPOSABLE_NAME}
 *
 * @description Store-like composable with shared state
 * @example
 * const { state, filteredItems, addItem, selectItem } = ${COMPOSABLE_NAME}();
 */
export function ${COMPOSABLE_NAME}(): ${TYPE_NAME}Return {
  // Computed
  const filteredItems = computed(() => {
    const filter = state.value.filter.toLowerCase();
    if (!filter) return state.value.items;
    return state.value.items.filter(item =>
      item.name.toLowerCase().includes(filter)
    );
  });

  const selectedItem = computed(() =>
    state.value.items.find(item => item.id === state.value.selectedId)
  );

  // Actions
  const addItem = (item: Omit<${TYPE_NAME}Item, 'id'>) => {
    const newItem: ${TYPE_NAME}Item = {
      ...item,
      id: crypto.randomUUID(),
    };
    state.value.items.push(newItem);
  };

  const removeItem = (id: string) => {
    const index = state.value.items.findIndex(item => item.id === id);
    if (index > -1) {
      state.value.items.splice(index, 1);
      if (state.value.selectedId === id) {
        state.value.selectedId = null;
      }
    }
  };

  const updateItem = (id: string, updates: Partial<${TYPE_NAME}Item>) => {
    const item = state.value.items.find(item => item.id === id);
    if (item) {
      Object.assign(item, updates);
    }
  };

  const selectItem = (id: string | null) => {
    state.value.selectedId = id;
  };

  const setFilter = (filter: string) => {
    state.value.filter = filter;
  };

  const reset = () => {
    state.value = {
      items: [],
      selectedId: null,
      filter: '',
    };
  };

  return {
    state: readonly(state),
    filteredItems,
    selectedItem,
    addItem,
    removeItem,
    updateItem,
    selectItem,
    setFilter,
    reset,
  };
}

export default ${COMPOSABLE_NAME};
EOF
        ;;

    *)
        # Basic composable
        cat > "$OUTPUT_DIR/$COMPOSABLE_NAME.ts" << EOF
import { ref, computed, watch, onMounted, onUnmounted, type Ref } from 'vue';

export interface ${TYPE_NAME}Options {
  /** Initial value */
  initialValue?: string;
  /** Enable feature */
  enabled?: boolean;
}

export interface ${TYPE_NAME}Return {
  /** Current value */
  value: Ref<string>;
  /** Computed: value is empty */
  isEmpty: Ref<boolean>;
  /** Update value */
  setValue: (newValue: string) => void;
  /** Reset to initial */
  reset: () => void;
}

/**
 * ${COMPOSABLE_NAME}
 *
 * @description Basic composable with reactive state
 * @example
 * const { value, isEmpty, setValue, reset } = ${COMPOSABLE_NAME}({
 *   initialValue: 'Hello',
 *   enabled: true,
 * });
 */
export function ${COMPOSABLE_NAME}(
  options: ${TYPE_NAME}Options = {}
): ${TYPE_NAME}Return {
  const { initialValue = '', enabled = true } = options;

  // State
  const value = ref(initialValue);

  // Computed
  const isEmpty = computed(() => value.value.length === 0);

  // Methods
  const setValue = (newValue: string) => {
    if (enabled) {
      value.value = newValue;
    }
  };

  const reset = () => {
    value.value = initialValue;
  };

  // Watchers
  watch(value, (newVal, oldVal) => {
    console.log(\`${COMPOSABLE_NAME}: value changed from \${oldVal} to \${newVal}\`);
  });

  // Lifecycle
  onMounted(() => {
    console.log('${COMPOSABLE_NAME}: mounted');
  });

  onUnmounted(() => {
    console.log('${COMPOSABLE_NAME}: unmounted');
  });

  return {
    value,
    isEmpty,
    setValue,
    reset,
  };
}

export default ${COMPOSABLE_NAME};
EOF
        ;;
esac

# Generate test file
cat > "$OUTPUT_DIR/$COMPOSABLE_NAME.test.ts" << EOF
import { describe, it, expect, vi } from 'vitest';
import { ${COMPOSABLE_NAME} } from './${COMPOSABLE_NAME}';

describe('${COMPOSABLE_NAME}', () => {
  it('should initialize with default values', () => {
    const result = ${COMPOSABLE_NAME}();
    expect(result).toBeDefined();
  });

  it('should accept options', () => {
    const result = ${COMPOSABLE_NAME}({ enabled: true });
    expect(result).toBeDefined();
  });

  // Add more tests based on composable type
});
EOF

echo "✓ Generated Vue 3 composable: $OUTPUT_DIR/$COMPOSABLE_NAME.ts"
echo ""
echo "Files created:"
echo "  - $COMPOSABLE_NAME.ts ($COMPOSABLE_TYPE type)"
echo "  - $COMPOSABLE_NAME.test.ts"
echo ""
echo "Usage:"
echo "  import { $COMPOSABLE_NAME } from '@/composables/$COMPOSABLE_NAME';"
echo "  const { ... } = $COMPOSABLE_NAME();"
