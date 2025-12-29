#!/bin/bash
set -e
if grep -r "create.*zustand" src/ 2>/dev/null; then
    echo "✓ Zustand stores found"
fi
if grep -r "useStore" src/ 2>/dev/null; then
    echo "✓ useStore hooks found"
fi
exit 0
