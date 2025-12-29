/**
 * Vue 3 Composition API Templates
 * Modern composables for scalable Vue applications
 */

import { ref, reactive, computed, watch, watchEffect, onMounted, onUnmounted, toRefs } from 'vue';
import type { Ref, ComputedRef, UnwrapRef } from 'vue';

// ============================================
// 1. useAsync Composable
// ============================================

interface UseAsyncState<T> {
  data: Ref<T | null>;
  error: Ref<Error | null>;
  isLoading: Ref<boolean>;
  execute: () => Promise<void>;
}

export function useAsync<T>(
  asyncFn: () => Promise<T>,
  immediate = true
): UseAsyncState<T> {
  const data = ref<T | null>(null) as Ref<T | null>;
  const error = ref<Error | null>(null);
  const isLoading = ref(false);

  async function execute(): Promise<void> {
    isLoading.value = true;
    error.value = null;

    try {
      data.value = await asyncFn();
    } catch (e) {
      error.value = e instanceof Error ? e : new Error(String(e));
    } finally {
      isLoading.value = false;
    }
  }

  if (immediate) {
    execute();
  }

  return { data, error, isLoading, execute };
}

// ============================================
// 2. useLocalStorage Composable
// ============================================

export function useLocalStorage<T>(
  key: string,
  defaultValue: T
): Ref<T> {
  const storedValue = localStorage.getItem(key);
  const initial = storedValue ? JSON.parse(storedValue) : defaultValue;

  const state = ref<T>(initial) as Ref<T>;

  watch(
    state,
    (newValue) => {
      localStorage.setItem(key, JSON.stringify(newValue));
    },
    { deep: true }
  );

  return state;
}

// ============================================
// 3. useDebounce Composable
// ============================================

export function useDebounce<T>(value: Ref<T>, delay = 300): Ref<T> {
  const debouncedValue = ref(value.value) as Ref<UnwrapRef<T>>;
  let timeoutId: ReturnType<typeof setTimeout>;

  watch(value, (newValue) => {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => {
      debouncedValue.value = newValue as UnwrapRef<T>;
    }, delay);
  });

  onUnmounted(() => {
    clearTimeout(timeoutId);
  });

  return debouncedValue as Ref<T>;
}

// ============================================
// 4. useFetch Composable
// ============================================

interface UseFetchOptions {
  immediate?: boolean;
  refetch?: boolean;
}

interface UseFetchReturn<T> {
  data: Ref<T | null>;
  error: Ref<Error | null>;
  isLoading: Ref<boolean>;
  execute: () => Promise<void>;
  abort: () => void;
}

export function useFetch<T>(
  url: Ref<string> | string,
  options: UseFetchOptions = {}
): UseFetchReturn<T> {
  const { immediate = true, refetch = false } = options;

  const data = ref<T | null>(null) as Ref<T | null>;
  const error = ref<Error | null>(null);
  const isLoading = ref(false);

  let abortController: AbortController | null = null;

  async function execute(): Promise<void> {
    abortController?.abort();
    abortController = new AbortController();

    isLoading.value = true;
    error.value = null;

    try {
      const urlValue = typeof url === 'string' ? url : url.value;
      const response = await fetch(urlValue, {
        signal: abortController.signal
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      data.value = await response.json();
    } catch (e) {
      if (e instanceof Error && e.name !== 'AbortError') {
        error.value = e;
      }
    } finally {
      isLoading.value = false;
    }
  }

  function abort(): void {
    abortController?.abort();
  }

  if (immediate) {
    execute();
  }

  if (refetch && typeof url !== 'string') {
    watch(url, execute);
  }

  onUnmounted(abort);

  return { data, error, isLoading, execute, abort };
}

// ============================================
// 5. useEventListener Composable
// ============================================

export function useEventListener<K extends keyof WindowEventMap>(
  target: Window | HTMLElement | Ref<HTMLElement | null>,
  event: K,
  handler: (event: WindowEventMap[K]) => void,
  options?: AddEventListenerOptions
): void {
  onMounted(() => {
    const el = 'value' in target ? target.value : target;
    el?.addEventListener(event, handler as EventListener, options);
  });

  onUnmounted(() => {
    const el = 'value' in target ? target.value : target;
    el?.removeEventListener(event, handler as EventListener, options);
  });
}

// ============================================
// 6. useCounter Composable (Simple Example)
// ============================================

interface UseCounterReturn {
  count: Ref<number>;
  increment: () => void;
  decrement: () => void;
  reset: () => void;
  double: ComputedRef<number>;
}

export function useCounter(initialValue = 0): UseCounterReturn {
  const count = ref(initialValue);

  const increment = () => count.value++;
  const decrement = () => count.value--;
  const reset = () => count.value = initialValue;

  const double = computed(() => count.value * 2);

  return { count, increment, decrement, reset, double };
}

// ============================================
// 7. useToggle Composable
// ============================================

export function useToggle(initialValue = false): [Ref<boolean>, () => void] {
  const state = ref(initialValue);
  const toggle = () => state.value = !state.value;

  return [state, toggle];
}

// ============================================
// Export all composables
// ============================================

export default {
  useAsync,
  useLocalStorage,
  useDebounce,
  useFetch,
  useEventListener,
  useCounter,
  useToggle
};
