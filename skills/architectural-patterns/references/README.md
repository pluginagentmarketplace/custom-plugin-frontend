# Architectural Patterns References

Complete documentation for architectural patterns and SOLID principles.

## GUIDE.md
**600+ word technical guide** covering:
- MVC (Model-View-Controller) pattern
- MVVM (Model-View-ViewModel) pattern
- Clean Architecture (4-layer structure)
- Domain-Driven Design (DDD)
- SOLID Principles (all 5)

## PATTERNS.md
**600+ word real-world patterns** including:
- Repository pattern for data access
- Service layer pattern
- Dependency injection pattern
- Adapter pattern for interfaces
- Observer pattern for events
- Middleware pattern for pipelines
- Factory pattern for object creation

## Architecture Selection Guide

| Architecture | Best For | Complexity | Team Size |
|-------------|----------|-----------|-----------|
| MVC | Simple apps | Low | 1-3 |
| MVVM | Rich UIs | Medium | 2-5 |
| Clean | Complex logic | High | 5+ |
| DDD | Domains | Very High | 10+ |

## SOLID Principles Checklist

- [ ] **S** - Single Responsibility: One reason to change
- [ ] **O** - Open/Closed: Open for extension, closed for modification
- [ ] **L** - Liskov Substitution: Subtypes substitutable
- [ ] **I** - Interface Segregation: Many specific interfaces
- [ ] **D** - Dependency Inversion: Depend on abstractions

## Design Patterns Quick Reference

| Pattern | Purpose | When to Use |
|---------|---------|------------|
| Repository | Data access abstraction | Always, for persistence |
| Service | Business logic | Complex operations |
| Factory | Object creation | Many object types |
| Adapter | Interface conversion | Third-party integration |
| Observer | Event notification | Decoupled systems |
| Middleware | Processing pipeline | Request handling |

## Implementation Layers

### Clean Architecture
1. Entities (Business rules)
2. Use Cases (Application logic)
3. Adapters (Controllers, presenters)
4. Frameworks (DB, web, UI)

### DDD
1. Domain (Entities, value objects)
2. Application (Use cases, DTOs)
3. Infrastructure (Repositories, services)
4. UI (Presentation)

## Best Practices

1. **Start Simple** - Don't over-engineer early
2. **Separate Concerns** - Different modules for different concerns
3. **Inject Dependencies** - Loose coupling through DI
4. **Interface-Based** - Depend on abstractions
5. **Test-Friendly** - Design for testability
