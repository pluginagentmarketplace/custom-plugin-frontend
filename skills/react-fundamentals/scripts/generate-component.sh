#!/bin/bash
# React Component Generator
# Part of react-fundamentals skill - Golden Format E703 Compliant

set -e

COMPONENT_NAME="${1:-MyComponent}"
OUTPUT_DIR="${2:-./src/components}"
COMPONENT_TYPE="${3:-functional}"  # functional, memo, forwardRef

# Create directory
mkdir -p "$OUTPUT_DIR/$COMPONENT_NAME"

# Generate component file
if [ "$COMPONENT_TYPE" = "memo" ]; then
    cat > "$OUTPUT_DIR/$COMPONENT_NAME/$COMPONENT_NAME.tsx" << EOF
import React, { memo } from 'react';
import styles from './$COMPONENT_NAME.module.css';

export interface ${COMPONENT_NAME}Props {
  /** Primary content */
  children?: React.ReactNode;
  /** Additional CSS class */
  className?: string;
  /** Click handler */
  onClick?: () => void;
}

/**
 * $COMPONENT_NAME Component
 *
 * @description Memoized component for performance optimization
 * @example
 * <$COMPONENT_NAME onClick={handleClick}>
 *   Content here
 * </$COMPONENT_NAME>
 */
export const $COMPONENT_NAME = memo<${COMPONENT_NAME}Props>(({
  children,
  className = '',
  onClick,
}) => {
  return (
    <div
      className={\`\${styles.container} \${className}\`}
      onClick={onClick}
      role="button"
      tabIndex={0}
      onKeyDown={(e) => e.key === 'Enter' && onClick?.()}
    >
      {children}
    </div>
  );
});

$COMPONENT_NAME.displayName = '$COMPONENT_NAME';

export default $COMPONENT_NAME;
EOF

elif [ "$COMPONENT_TYPE" = "forwardRef" ]; then
    cat > "$OUTPUT_DIR/$COMPONENT_NAME/$COMPONENT_NAME.tsx" << EOF
import React, { forwardRef } from 'react';
import styles from './$COMPONENT_NAME.module.css';

export interface ${COMPONENT_NAME}Props extends React.HTMLAttributes<HTMLDivElement> {
  /** Primary content */
  children?: React.ReactNode;
  /** Variant style */
  variant?: 'primary' | 'secondary';
}

/**
 * $COMPONENT_NAME Component
 *
 * @description ForwardRef component for DOM access
 * @example
 * const ref = useRef<HTMLDivElement>(null);
 * <$COMPONENT_NAME ref={ref} variant="primary">
 *   Content
 * </$COMPONENT_NAME>
 */
export const $COMPONENT_NAME = forwardRef<HTMLDivElement, ${COMPONENT_NAME}Props>(
  ({ children, className = '', variant = 'primary', ...props }, ref) => {
    return (
      <div
        ref={ref}
        className={\`\${styles.container} \${styles[variant]} \${className}\`}
        {...props}
      >
        {children}
      </div>
    );
  }
);

$COMPONENT_NAME.displayName = '$COMPONENT_NAME';

export default $COMPONENT_NAME;
EOF

else
    # Default functional component
    cat > "$OUTPUT_DIR/$COMPONENT_NAME/$COMPONENT_NAME.tsx" << EOF
import React, { useState, useCallback } from 'react';
import styles from './$COMPONENT_NAME.module.css';

export interface ${COMPONENT_NAME}Props {
  /** Primary content */
  children?: React.ReactNode;
  /** Title text */
  title?: string;
  /** Initial state */
  defaultValue?: string;
  /** Change handler */
  onChange?: (value: string) => void;
}

/**
 * $COMPONENT_NAME Component
 *
 * @description Functional component with hooks
 * @example
 * <$COMPONENT_NAME
 *   title="Example"
 *   onChange={(val) => console.log(val)}
 * >
 *   Child content
 * </$COMPONENT_NAME>
 */
export const $COMPONENT_NAME: React.FC<${COMPONENT_NAME}Props> = ({
  children,
  title = '$COMPONENT_NAME',
  defaultValue = '',
  onChange,
}) => {
  const [value, setValue] = useState(defaultValue);

  const handleChange = useCallback((newValue: string) => {
    setValue(newValue);
    onChange?.(newValue);
  }, [onChange]);

  return (
    <div className={styles.container}>
      {title && <h2 className={styles.title}>{title}</h2>}
      <div className={styles.content}>
        {children}
      </div>
    </div>
  );
};

export default $COMPONENT_NAME;
EOF
fi

# Generate CSS module
cat > "$OUTPUT_DIR/$COMPONENT_NAME/$COMPONENT_NAME.module.css" << EOF
.container {
  padding: 1rem;
  border-radius: 8px;
  background-color: var(--bg-color, #ffffff);
}

.title {
  margin: 0 0 1rem;
  font-size: 1.25rem;
  font-weight: 600;
  color: var(--text-color, #1a1a1a);
}

.content {
  color: var(--text-secondary, #666666);
}

.primary {
  border: 2px solid var(--primary-color, #3b82f6);
}

.secondary {
  border: 2px solid var(--secondary-color, #6b7280);
}
EOF

# Generate test file
cat > "$OUTPUT_DIR/$COMPONENT_NAME/$COMPONENT_NAME.test.tsx" << EOF
import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import { $COMPONENT_NAME } from './$COMPONENT_NAME';

describe('$COMPONENT_NAME', () => {
  it('renders without crashing', () => {
    render(<$COMPONENT_NAME />);
    expect(screen.getByRole('heading', { level: 2 })).toBeInTheDocument();
  });

  it('renders children correctly', () => {
    render(<$COMPONENT_NAME>Test Content</$COMPONENT_NAME>);
    expect(screen.getByText('Test Content')).toBeInTheDocument();
  });

  it('renders custom title', () => {
    render(<$COMPONENT_NAME title="Custom Title" />);
    expect(screen.getByText('Custom Title')).toBeInTheDocument();
  });

  it('calls onChange when value changes', () => {
    const handleChange = jest.fn();
    render(<$COMPONENT_NAME onChange={handleChange} />);
    // Add interaction test based on component type
  });
});
EOF

# Generate index file
cat > "$OUTPUT_DIR/$COMPONENT_NAME/index.ts" << EOF
export { $COMPONENT_NAME, type ${COMPONENT_NAME}Props } from './$COMPONENT_NAME';
export { default } from './$COMPONENT_NAME';
EOF

echo "✓ Generated React component: $OUTPUT_DIR/$COMPONENT_NAME/"
echo ""
echo "Files created:"
echo "  - $COMPONENT_NAME.tsx (${COMPONENT_TYPE} component)"
echo "  - $COMPONENT_NAME.module.css"
echo "  - $COMPONENT_NAME.test.tsx"
echo "  - index.ts"
echo ""
echo "Usage:"
echo "  import { $COMPONENT_NAME } from '@/components/$COMPONENT_NAME';"
