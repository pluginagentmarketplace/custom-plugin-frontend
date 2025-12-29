# Contributing to Frontend Development Assistant

Thank you for your interest in contributing to the Frontend Development Assistant plugin! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How to Contribute](#how-to-contribute)
- [Development Setup](#development-setup)
- [Contribution Guidelines](#contribution-guidelines)
- [Skill Template](#skill-template)
- [Agent Template](#agent-template)
- [Pull Request Process](#pull-request-process)
- [Style Guide](#style-guide)

---

## Code of Conduct

By participating in this project, you agree to:

- Be respectful and inclusive
- Provide constructive feedback
- Focus on educational value and accuracy
- Help maintain a welcoming community

---

## How to Contribute

### Types of Contributions

1. **New Skills** - Add new skill modules to existing agents
2. **Agent Improvements** - Enhance existing agent documentation
3. **Code Examples** - Add production-ready code examples
4. **Bug Fixes** - Fix errors in content or structure
5. **Documentation** - Improve README, guides, or references
6. **Translations** - Help translate content to other languages

### Getting Started

1. Fork the repository
2. Clone your fork locally
3. Create a feature branch
4. Make your changes
5. Test your changes
6. Submit a pull request

---

## Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR-USERNAME/custom-plugin-frontend.git
cd custom-plugin-frontend

# Create a feature branch
git checkout -b feature/your-feature-name

# Validate plugin structure
# (Use Claude Code plugin validation)
/plugin validate ./
```

---

## Contribution Guidelines

### Skill Contributions

When adding or modifying skills:

1. Follow the SASMP v1.3.0 specification
2. Use the Golden Format structure (assets/, scripts/, references/)
3. Include real, working code examples
4. Add comprehensive references
5. Bond skills to appropriate agents

### Code Examples

All code examples must be:

- Production-ready (not toy examples)
- Well-commented
- Following current best practices (2025+ standards)
- Security-conscious
- Performance-optimized

### Content Quality

- Use clear, concise language
- Include practical exercises
- Provide real-world context
- Reference official documentation
- Include security considerations

---

## Skill Template

Use this structure for new skills:

```
skills/skill-name/
├── SKILL.md              # Main skill documentation
├── assets/               # Templates and configurations
│   ├── templates/        # Code templates
│   ├── config/           # Configuration files
│   └── examples/         # Usage examples
├── scripts/              # Utility scripts
│   ├── validate.py       # Validation script
│   └── setup.sh          # Setup script
└── references/           # Documentation
    ├── GUIDE.md          # Usage guide
    └── PATTERNS.md       # Design patterns
```

### SKILL.md Frontmatter

```yaml
---
name: skill-name
description: What this skill teaches
sasmp_version: "1.3.0"
bonded_agent: agent-name
bond_type: PRIMARY_BOND
keywords:
  - keyword1
  - keyword2
---
```

---

## Agent Template

Agents should follow this structure:

```yaml
---
name: agent-name
description: What this agent specializes in
model: sonnet
tools: All tools
sasmp_version: "1.3.0"
eqhm_enabled: true
---
```

---

## Pull Request Process

### Before Submitting

- [ ] Run plugin validation
- [ ] Check all links work
- [ ] Verify code examples compile/run
- [ ] Follow the style guide
- [ ] Update relevant documentation
- [ ] Add yourself to contributors (optional)

### PR Title Format

Use conventional commit style:

- `feat: Add new skill for GraphQL patterns`
- `fix: Correct TypeScript example in React skill`
- `docs: Update installation instructions`
- `refactor: Reorganize state management references`

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] New skill
- [ ] Agent improvement
- [ ] Bug fix
- [ ] Documentation update
- [ ] Code example

## Checklist
- [ ] Plugin validates successfully
- [ ] All examples are tested
- [ ] Documentation is updated
- [ ] Follows SASMP v1.3.0
```

---

## Style Guide

### Markdown

- Use ATX-style headers (`#`, `##`, `###`)
- Include blank lines between sections
- Use fenced code blocks with language identifiers
- Use relative links for internal references

### Code Examples

```typescript
// Good: Well-documented, production-ready
interface UserState {
  user: User | null;
  loading: boolean;
  error: Error | null;
}

// Include type annotations
// Add error handling
// Consider edge cases
```

### Naming Conventions

| Item | Convention | Example |
|------|------------|---------|
| Skills | kebab-case | `react-hooks-patterns` |
| Agents | kebab-case | `state-management` |
| Files | kebab-case | `validation-rules.json` |
| Directories | kebab-case | `assets/templates/` |

---

## Questions?

- Open an issue for discussion
- Tag with `question` label
- Check existing issues first

---

## Recognition

Contributors are recognized in:

- README.md Contributors section
- Individual skill/agent acknowledgments
- Release notes for significant contributions

---

**Thank you for helping improve frontend education!**

---

*Document Version: 1.0.0*
*Last Updated: 2025-12-28*
