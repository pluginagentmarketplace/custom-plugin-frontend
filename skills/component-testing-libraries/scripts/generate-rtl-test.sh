#!/bin/bash

# React Testing Library Test Generator
# Generates RTL test boilerplate for React components
# Usage: ./generate-rtl-test.sh [component-name]

set -e

COMPONENT_NAME="${1:-Button}"
COMPONENT_FILE="${2:-.}"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 React Testing Library Test Generator${NC}"
echo "=========================================="
echo "Component: $COMPONENT_NAME"
echo ""

# Create test directory
TEST_DIR="src/__tests__/components"
mkdir -p "$TEST_DIR"

# Generate test file
TEST_FILE="$TEST_DIR/${COMPONENT_NAME}.test.jsx"

cat > "$TEST_FILE" << EOF
/**
 * RTL Component Test: $COMPONENT_NAME
 * Tests component rendering, user interactions, and accessibility
 */

import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';
import $COMPONENT_NAME from '../../components/${COMPONENT_NAME}';

describe('$COMPONENT_NAME Component', () => {
  describe('Rendering', () => {
    test('should render ${COMPONENT_NAME} component', () => {
      render(<$COMPONENT_NAME />);
      expect(screen.getByRole('button', { name: /$COMPONENT_NAME/i })).toBeInTheDocument();
    });

    test('should render with required props', () => {
      const props = {
        label: 'Click me',
        onClick: jest.fn(),
      };

      render(<$COMPONENT_NAME {...props} />);
      expect(screen.getByRole('button', { name: /click me/i })).toBeInTheDocument();
    });

    test('should apply custom className', () => {
      render(<$COMPONENT_NAME className="custom-class" />);
      const element = screen.getByRole('button');
      expect(element).toHaveClass('custom-class');
    });
  });

  describe('User Interactions', () => {
    test('should call onClick handler when clicked', async () => {
      const handleClick = jest.fn();
      const user = userEvent.setup();

      render(<$COMPONENT_NAME onClick={handleClick} />);

      const button = screen.getByRole('button');
      await user.click(button);

      expect(handleClick).toHaveBeenCalledTimes(1);
    });

    test('should not call onClick when disabled', async () => {
      const handleClick = jest.fn();
      const user = userEvent.setup();

      render(<$COMPONENT_NAME onClick={handleClick} disabled />);

      const button = screen.getByRole('button');
      expect(button).toBeDisabled();

      await user.click(button);
      expect(handleClick).not.toHaveBeenCalled();
    });

    test('should handle multiple clicks', async () => {
      const handleClick = jest.fn();
      const user = userEvent.setup();

      render(<$COMPONENT_NAME onClick={handleClick} />);

      const button = screen.getByRole('button');
      await user.click(button);
      await user.click(button);
      await user.click(button);

      expect(handleClick).toHaveBeenCalledTimes(3);
    });
  });

  describe('Async Operations', () => {
    test('should handle async operations', async () => {
      const handleAsync = jest.fn().mockResolvedValue({ status: 'success' });

      render(<$COMPONENT_NAME onAsync={handleAsync} />);

      const button = screen.getByRole('button');
      fireEvent.click(button);

      await waitFor(() => {
        expect(handleAsync).toHaveBeenCalled();
      });
    });

    test('should display loading state', async () => {
      const { rerender } = render(<$COMPONENT_NAME loading={false} />);

      expect(screen.queryByText(/loading/i)).not.toBeInTheDocument();

      rerender(<$COMPONENT_NAME loading={true} />);
      expect(screen.getByText(/loading/i)).toBeInTheDocument();
    });
  });

  describe('Props Variations', () => {
    test('should render primary variant', () => {
      render(<$COMPONENT_NAME variant="primary" />);
      const button = screen.getByRole('button');
      expect(button).toHaveClass('button--primary');
    });

    test('should render secondary variant', () => {
      render(<$COMPONENT_NAME variant="secondary" />);
      const button = screen.getByRole('button');
      expect(button).toHaveClass('button--secondary');
    });

    test('should render different sizes', () => {
      const { rerender } = render(<$COMPONENT_NAME size="small" />);
      expect(screen.getByRole('button')).toHaveClass('button--small');

      rerender(<$COMPONENT_NAME size="large" />);
      expect(screen.getByRole('button')).toHaveClass('button--large');
    });

    test('should handle icon prop', () => {
      const icon = <span data-testid="icon">🔍</span>;
      render(<$COMPONENT_NAME icon={icon} />);
      expect(screen.getByTestId('icon')).toBeInTheDocument();
    });
  });

  describe('Accessibility', () => {
    test('should have proper ARIA attributes', () => {
      render(<$COMPONENT_NAME aria-label="Custom label" />);
      const button = screen.getByRole('button');
      expect(button).toHaveAttribute('aria-label', 'Custom label');
    });

    test('should support keyboard navigation', async () => {
      const handleClick = jest.fn();
      const user = userEvent.setup();

      render(<$COMPONENT_NAME onClick={handleClick} />);

      const button = screen.getByRole('button');
      button.focus();
      expect(button).toHaveFocus();

      await user.keyboard('{Enter}');
      expect(handleClick).toHaveBeenCalled();
    });

    test('should announce disabled state', () => {
      render(<$COMPONENT_NAME disabled aria-label="Submit button" />);
      const button = screen.getByRole('button', { name: /submit/i });
      expect(button).toBeDisabled();
    });
  });

  describe('Edge Cases', () => {
    test('should handle empty label', () => {
      render(<$COMPONENT_NAME label="" />);
      const button = screen.getByRole('button');
      expect(button).toBeInTheDocument();
    });

    test('should handle very long label', () => {
      const longLabel = 'This is a very long button label that might wrap to multiple lines in some scenarios';
      render(<$COMPONENT_NAME label={longLabel} />);
      expect(screen.getByRole('button', { name: new RegExp(longLabel) })).toBeInTheDocument();
    });

    test('should handle rapid clicks', async () => {
      const handleClick = jest.fn();
      const user = userEvent.setup({ delay: null });

      render(<$COMPONENT_NAME onClick={handleClick} />);

      const button = screen.getByRole('button');
      await user.tripleClick(button);

      expect(handleClick.mock.calls.length).toBeGreaterThanOrEqual(1);
    });
  });

  describe('State Management', () => {
    test('should toggle active state', async () => {
      const { rerender } = render(<$COMPONENT_NAME active={false} />);
      expect(screen.getByRole('button')).not.toHaveClass('button--active');

      rerender(<$COMPONENT_NAME active={true} />);
      expect(screen.getByRole('button')).toHaveClass('button--active');
    });

    test('should reflect prop changes', async () => {
      const { rerender } = render(<$COMPONENT_NAME label="Old Label" />);
      expect(screen.getByRole('button', { name: /old label/i })).toBeInTheDocument();

      rerender(<$COMPONENT_NAME label="New Label" />);
      expect(screen.getByRole('button', { name: /new label/i })).toBeInTheDocument();
    });
  });
});
EOF

echo -e "${GREEN}✓ Created test file: $TEST_FILE${NC}"
echo ""

# Generate component stub if it doesn't exist
COMPONENT_PATH="src/components/${COMPONENT_NAME}.jsx"
if [ ! -f "$COMPONENT_PATH" ]; then
    mkdir -p "src/components"

    cat > "$COMPONENT_PATH" << EOF
/**
 * $COMPONENT_NAME Component
 * Description of what this component does
 */

import React from 'react';
import './${COMPONENT_NAME}.css';

const $COMPONENT_NAME = ({
  label = '$COMPONENT_NAME',
  onClick = () => {},
  disabled = false,
  variant = 'primary',
  size = 'medium',
  className = '',
  children,
  ...props
}) => {
  return (
    <button
      className={\`button button--\${variant} button--\${size} \${className}\`}
      onClick={onClick}
      disabled={disabled}
      {...props}
    >
      {children || label}
    </button>
  );
};

export default $COMPONENT_NAME;
EOF

    echo -e "${GREEN}✓ Created component: $COMPONENT_PATH${NC}"

    # Generate component CSS
    cat > "src/components/${COMPONENT_NAME}.css" << EOF
/* $COMPONENT_NAME Styles */

.button {
  padding: 0.5rem 1rem;
  border: 1px solid #ccc;
  border-radius: 4px;
  cursor: pointer;
  font-size: 1rem;
  transition: all 0.2s ease;
}

.button:hover:not(:disabled) {
  background-color: #f0f0f0;
}

.button:focus {
  outline: 2px solid #0066cc;
  outline-offset: 2px;
}

.button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Variants */
.button--primary {
  background-color: #0066cc;
  color: white;
}

.button--primary:hover:not(:disabled) {
  background-color: #0052a3;
}

.button--secondary {
  background-color: #f0f0f0;
  color: #333;
}

.button--secondary:hover:not(:disabled) {
  background-color: #e0e0e0;
}

/* Sizes */
.button--small {
  padding: 0.25rem 0.5rem;
  font-size: 0.875rem;
}

.button--large {
  padding: 0.75rem 1.5rem;
  font-size: 1.125rem;
}
EOF

    echo -e "${GREEN}✓ Created styles: src/components/${COMPONENT_NAME}.css${NC}"
fi

echo ""
echo -e "${BLUE}=========================================="
echo "✅ Test Generation Complete!"
echo "==========================================${NC}"
echo ""
echo "📝 Generated Files:"
echo "  • $TEST_FILE"
if [ ! -f "$COMPONENT_PATH" ]; then
    echo "  • $COMPONENT_PATH"
    echo "  • src/components/${COMPONENT_NAME}.css"
fi
echo ""
echo "📦 Required Dependencies:"
echo "  npm install --save-dev @testing-library/react"
echo "  npm install --save-dev @testing-library/user-event"
echo "  npm install --save-dev @testing-library/jest-dom"
echo ""
echo "🚀 Next Steps:"
echo "  1. Review generated test file: $TEST_FILE"
echo "  2. Customize component in: $COMPONENT_PATH"
echo "  3. Run tests: npm test"
echo "  4. Update assertions based on actual component behavior"
echo ""
echo "📚 Key RTL Concepts:"
echo "  • Use getByRole() for accessibility-first testing"
echo "  • Use userEvent.setup() for realistic user interactions"
echo "  • Use waitFor() for async operations"
echo "  • Avoid testId - use accessible queries instead"
echo ""
