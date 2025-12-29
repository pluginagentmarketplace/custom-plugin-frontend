#!/bin/bash

# Code Quality Configuration Generator
# Generates ESLint, Prettier, TypeScript, Husky, and lint-staged configs
# Usage: ./generate-quality-config.sh [project-name]

set -e

PROJECT_NAME="${1:-my-project}"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Code Quality Configuration Generator${NC}"
echo "=========================================="
echo "Project: $PROJECT_NAME"
echo ""

# 1. Generate .eslintrc.json
echo -e "${GREEN}Creating .eslintrc.json...${NC}"
cat > ".eslintrc.json" << 'EOF'
{
  "env": {
    "browser": true,
    "es2021": true,
    "node": true,
    "jest": true
  },
  "extends": [
    "eslint:recommended",
    "plugin:react/recommended",
    "plugin:react-hooks/recommended",
    "plugin:@typescript-eslint/recommended",
    "plugin:jsx-a11y/recommended",
    "prettier"
  ],
  "parser": "@typescript-eslint/parser",
  "parserOptions": {
    "ecmaFeatures": {
      "jsx": true
    },
    "ecmaVersion": 12,
    "sourceType": "module"
  },
  "plugins": [
    "react",
    "react-hooks",
    "@typescript-eslint",
    "jsx-a11y",
    "import"
  ],
  "rules": {
    "react/react-in-jsx-scope": "off",
    "react/prop-types": "off",
    "@typescript-eslint/explicit-module-boundary-types": "off",
    "@typescript-eslint/no-explicit-any": "warn",
    "no-console": [
      "warn",
      {
        "allow": [
          "warn",
          "error"
        ]
      }
    ],
    "no-unused-vars": "off",
    "@typescript-eslint/no-unused-vars": [
      "error",
      {
        "argsIgnorePattern": "^_"
      }
    ],
    "prefer-const": "error",
    "no-var": "error",
    "eqeqeq": [
      "error",
      "always"
    ],
    "curly": [
      "error",
      "all"
    ],
    "brace-style": [
      "error",
      "1tbs"
    ],
    "quotes": [
      "error",
      "single",
      {
        "avoidEscape": true
      }
    ],
    "semi": [
      "error",
      "always"
    ]
  },
  "settings": {
    "react": {
      "version": "detect"
    }
  }
}
EOF
echo -e "${GREEN}✓ Created .eslintrc.json${NC}"

# 2. Generate .prettierrc
echo -e "${GREEN}Creating .prettierrc...${NC}"
cat > ".prettierrc" << 'EOF'
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 100,
  "tabWidth": 2,
  "useTabs": false,
  "arrowParens": "always",
  "bracketSpacing": true,
  "endOfLine": "lf"
}
EOF
echo -e "${GREEN}✓ Created .prettierrc${NC}"

# 3. Generate .prettierignore
echo -e "${GREEN}Creating .prettierignore...${NC}"
cat > ".prettierignore" << 'EOF'
node_modules
dist
build
coverage
*.min.js
*.min.css
.next
out
yarn.lock
package-lock.json
EOF
echo -e "${GREEN}✓ Created .prettierignore${NC}"

# 4. Generate .eslintignore
echo -e "${GREEN}Creating .eslintignore...${NC}"
cat > ".eslintignore" << 'EOF'
node_modules
dist
build
coverage
*.min.js
.next
out
EOF
echo -e "${GREEN}✓ Created .eslintignore${NC}"

# 5. Update/Create tsconfig.json
echo -e "${GREEN}Creating tsconfig.json...${NC}"
cat > "tsconfig.json" << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "strictBindCallApply": true,
    "strictPropertyInitialization": true,
    "noImplicitThis": true,
    "alwaysStrict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noEmit": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "jsx": "react-jsx",
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"],
      "@components/*": ["./src/components/*"],
      "@pages/*": ["./src/pages/*"],
      "@utils/*": ["./src/utils/*"],
      "@hooks/*": ["./src/hooks/*"],
      "@types/*": ["./src/types/*"],
      "@styles/*": ["./src/styles/*"]
    }
  },
  "include": ["src"],
  "exclude": ["node_modules", "dist", "build", "coverage"],
  "ts-node": {
    "esm": true
  }
}
EOF
echo -e "${GREEN}✓ Created tsconfig.json${NC}"

# 6. Create .husky/pre-commit
echo -e "${GREEN}Creating Husky pre-commit hook...${NC}"
mkdir -p ".husky"
cat > ".husky/pre-commit" << 'EOF'
#!/bin/sh
. "$(dirname "$0")/_/husky.sh"

npx lint-staged
EOF
chmod +x ".husky/pre-commit"
echo -e "${GREEN}✓ Created .husky/pre-commit${NC}"

# 7. Create .lintstagedrc
echo -e "${GREEN}Creating .lintstagedrc...${NC}"
cat > ".lintstagedrc" << 'EOF'
{
  "*.{js,jsx,ts,tsx}": [
    "eslint --fix",
    "prettier --write"
  ],
  "*.{json,md,css,scss}": [
    "prettier --write"
  ]
}
EOF
echo -e "${GREEN}✓ Created .lintstagedrc${NC}"

# 8. Create .vscode/settings.json
echo -e "${GREEN}Creating VSCode settings...${NC}"
mkdir -p ".vscode"
cat > ".vscode/settings.json" << 'EOF'
{
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.formatOnSave": true,
  "[typescript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[typescriptreact]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[javascript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[javascriptreact]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[json]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "eslint.enable": true,
  "eslint.format.enable": true,
  "eslint.validate": [
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact"
  ],
  "typescript.tsdk": "node_modules/typescript/lib",
  "typescript.enablePromptUseWorkspaceTsdk": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": "explicit"
  }
}
EOF
echo -e "${GREEN}✓ Created .vscode/settings.json${NC}"

# 9. Create .vscode/extensions.json
cat > ".vscode/extensions.json" << 'EOF'
{
  "recommendations": [
    "esbenp.prettier-vscode",
    "dbaeumer.vscode-eslint",
    "ms-vscode.vscode-typescript-next"
  ]
}
EOF
echo -e "${GREEN}✓ Created .vscode/extensions.json${NC}"

# 10. Create GitHub Actions workflow
echo -e "${GREEN}Creating GitHub Actions workflow...${NC}"
mkdir -p ".github/workflows"
cat > ".github/workflows/quality.yml" << 'EOF'
name: Code Quality

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  quality:
    runs-on: ubuntu-latest

    strategy:
      matrix:
        node-version: [18.x, 20.x]

    steps:
      - uses: actions/checkout@v3

      - name: Use Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v3
        with:
          node-version: ${{ matrix.node-version }}
          cache: "npm"

      - name: Install dependencies
        run: npm ci

      - name: Run ESLint
        run: npm run lint

      - name: Check formatting
        run: npm run format:check

      - name: Run TypeScript check
        run: npm run type-check

      - name: Run tests
        run: npm test -- --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/coverage-final.json
EOF
echo -e "${GREEN}✓ Created GitHub Actions workflow${NC}"

# 11. Update package.json scripts (informational)
echo ""
echo -e "${BLUE}📝 Add these scripts to package.json:${NC}"
cat << 'EOF'
{
  "scripts": {
    "lint": "eslint src --ext .js,.jsx,.ts,.tsx",
    "lint:fix": "eslint src --ext .js,.jsx,.ts,.tsx --fix",
    "format": "prettier --write \"src/**/*.{js,jsx,ts,tsx,json,css,md}\"",
    "format:check": "prettier --check \"src/**/*.{js,jsx,ts,tsx,json,css,md}\"",
    "type-check": "tsc --noEmit",
    "quality": "npm run lint && npm run format:check && npm run type-check"
  }
}
EOF

echo ""
echo -e "${BLUE}=========================================="
echo "✅ Configuration Generation Complete!"
echo "==========================================${NC}"
echo ""
echo "📝 Generated Files:"
echo "  • .eslintrc.json"
echo "  • .prettierrc"
echo "  • .prettierignore"
echo "  • .eslintignore"
echo "  • tsconfig.json"
echo "  • .husky/pre-commit"
echo "  • .lintstagedrc"
echo "  • .vscode/settings.json"
echo "  • .vscode/extensions.json"
echo "  • .github/workflows/quality.yml"
echo ""
echo "📦 Required Dependencies:"
echo "  npm install --save-dev eslint prettier"
echo "  npm install --save-dev @typescript-eslint/eslint-plugin @typescript-eslint/parser"
echo "  npm install --save-dev eslint-plugin-react eslint-plugin-react-hooks"
echo "  npm install --save-dev eslint-plugin-jsx-a11y eslint-plugin-import"
echo "  npm install --save-dev husky lint-staged"
echo "  npm install --save-dev @types/node @types/react typescript"
echo ""
echo "🚀 Next Steps:"
echo "  1. Install dependencies: npm install"
echo "  2. Initialize Husky: npx husky install"
echo "  3. Update package.json with scripts above"
echo "  4. Run: npm run quality"
echo "  5. Commit .husky files to git"
echo ""
echo "💡 Tips:"
echo "  • Use 'npm run lint:fix' to auto-fix code"
echo "  • Use 'npm run format' to format all files"
echo "  • ESLint runs automatically before commits"
echo "  • Install VSCode extensions for real-time feedback"
echo "  • Adjust rules in .eslintrc.json for your needs"
echo ""
