/**
 * React Component Template with TypeScript
 * Modern patterns for React 18+
 */

import React, { useState, useEffect, useCallback, useMemo, memo } from 'react';

// ============================================
// 1. Props Interface
// ============================================

interface ComponentProps {
  /** Primary content to display */
  title: string;
  /** Optional subtitle */
  subtitle?: string;
  /** List of items to render */
  items: Array<{
    id: string;
    name: string;
    value: number;
  }>;
  /** Callback when item is selected */
  onSelect?: (id: string) => void;
  /** Loading state */
  isLoading?: boolean;
  /** Children content */
  children?: React.ReactNode;
}

// ============================================
// 2. Functional Component with Hooks
// ============================================

export const ComponentTemplate: React.FC<ComponentProps> = memo(({
  title,
  subtitle,
  items,
  onSelect,
  isLoading = false,
  children
}) => {
  // State
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [filter, setFilter] = useState('');

  // Computed values with useMemo
  const filteredItems = useMemo(() => {
    if (!filter) return items;
    return items.filter(item =>
      item.name.toLowerCase().includes(filter.toLowerCase())
    );
  }, [items, filter]);

  const totalValue = useMemo(() => {
    return filteredItems.reduce((sum, item) => sum + item.value, 0);
  }, [filteredItems]);

  // Event handlers with useCallback
  const handleSelect = useCallback((id: string) => {
    setSelectedId(id);
    onSelect?.(id);
  }, [onSelect]);

  const handleFilterChange = useCallback((e: React.ChangeEvent<HTMLInputElement>) => {
    setFilter(e.target.value);
  }, []);

  // Side effects
  useEffect(() => {
    console.log('Component mounted');

    return () => {
      console.log('Component unmounted');
    };
  }, []);

  useEffect(() => {
    if (selectedId) {
      console.log(`Selected: ${selectedId}`);
    }
  }, [selectedId]);

  // Early return for loading state
  if (isLoading) {
    return (
      <div className="component-loading" role="status" aria-busy="true">
        <span className="spinner" aria-hidden="true" />
        <span className="sr-only">Loading...</span>
      </div>
    );
  }

  // Render
  return (
    <div className="component-template">
      <header className="component-header">
        <h2>{title}</h2>
        {subtitle && <p className="subtitle">{subtitle}</p>}
      </header>

      <div className="component-controls">
        <input
          type="text"
          placeholder="Filter items..."
          value={filter}
          onChange={handleFilterChange}
          aria-label="Filter items"
        />
        <span className="total">Total: {totalValue}</span>
      </div>

      <ul className="component-list" role="listbox">
        {filteredItems.map(item => (
          <li
            key={item.id}
            role="option"
            aria-selected={selectedId === item.id}
            className={selectedId === item.id ? 'selected' : ''}
            onClick={() => handleSelect(item.id)}
          >
            <span className="item-name">{item.name}</span>
            <span className="item-value">{item.value}</span>
          </li>
        ))}
      </ul>

      {filteredItems.length === 0 && (
        <p className="empty-state">No items found</p>
      )}

      {children && (
        <footer className="component-footer">
          {children}
        </footer>
      )}
    </div>
  );
});

ComponentTemplate.displayName = 'ComponentTemplate';

// ============================================
// 3. Custom Hook Template
// ============================================

interface UseAsyncState<T> {
  data: T | null;
  error: Error | null;
  isLoading: boolean;
}

export function useAsync<T>(
  asyncFn: () => Promise<T>,
  dependencies: React.DependencyList = []
): UseAsyncState<T> {
  const [state, setState] = useState<UseAsyncState<T>>({
    data: null,
    error: null,
    isLoading: true
  });

  useEffect(() => {
    let isMounted = true;

    setState(prev => ({ ...prev, isLoading: true }));

    asyncFn()
      .then(data => {
        if (isMounted) {
          setState({ data, error: null, isLoading: false });
        }
      })
      .catch(error => {
        if (isMounted) {
          setState({ data: null, error, isLoading: false });
        }
      });

    return () => {
      isMounted = false;
    };
  }, dependencies);

  return state;
}

// ============================================
// 4. Export
// ============================================

export default ComponentTemplate;
