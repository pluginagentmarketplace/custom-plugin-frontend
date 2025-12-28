#!/bin/bash
# Custom Hook Generator
# Part of react-hooks-patterns skill - Golden Format E703 Compliant

set -e

HOOK_NAME="${1:-useCustom}"
OUTPUT_DIR="${2:-.}"

# Ensure hook name starts with 'use'
if [[ ! "$HOOK_NAME" =~ ^use ]]; then
    echo "Error: Hook name must start with 'use'"
    exit 1
fi

OUTPUT_FILE="$OUTPUT_DIR/$HOOK_NAME.ts"

cat > "$OUTPUT_FILE" << EOF
import { useState, useEffect, useCallback } from 'react';

/**
 * Custom hook: $HOOK_NAME
 *
 * @description Describe what this hook does
 * @example
 * const { data, loading, error } = $HOOK_NAME(params);
 */
export function $HOOK_NAME<T>(initialValue?: T) {
  const [data, setData] = useState<T | undefined>(initialValue);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  const execute = useCallback(async (params?: unknown) => {
    setLoading(true);
    setError(null);

    try {
      // Implement your logic here
      // const result = await someAsyncOperation(params);
      // setData(result);
    } catch (err) {
      setError(err instanceof Error ? err : new Error('Unknown error'));
    } finally {
      setLoading(false);
    }
  }, []);

  const reset = useCallback(() => {
    setData(initialValue);
    setError(null);
    setLoading(false);
  }, [initialValue]);

  return {
    data,
    loading,
    error,
    execute,
    reset,
  };
}

export default $HOOK_NAME;
EOF

echo "✓ Generated custom hook: $OUTPUT_FILE"
echo ""
echo "Hook features:"
echo "  - TypeScript generic support"
echo "  - Loading and error state management"
echo "  - Execute and reset functions"
echo "  - useCallback for stable references"
echo ""
echo "Usage:"
echo "  import { $HOOK_NAME } from './$HOOK_NAME';"
echo "  const { data, loading, error, execute } = $HOOK_NAME<YourType>(initialValue);"
