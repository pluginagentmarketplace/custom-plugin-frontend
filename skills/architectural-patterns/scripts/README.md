# Architectural Patterns Scripts

Scripts for validating and scaffolding architectural patterns.

## validate-architecture.sh
Validate architectural pattern compliance in your project.

**Checks:**
- Architecture pattern detection (MVC, MVVM, Clean, DDD)
- Separation of concerns
- Layer independence
- Dependency injection
- SOLID principles compliance
- Design patterns usage

**Output:** `.architecture-validation.json`

## generate-architecture.sh
Generate Clean Architecture or MVC project scaffold.

**Usage:** `./generate-architecture.sh [output-dir] [clean|mvc] [filename]`

**Generates:**
- Clean Architecture: Entities → Use Cases → Controllers → Frameworks
- MVC: Model → View → Controller

**Example:**
```bash
./generate-architecture.sh . clean architecture.ts
./generate-architecture.sh . mvc architecture.ts
```

## Key Concepts

### Clean Architecture Layers
1. **Entities** - Core business logic
2. **Use Cases** - Application business rules
3. **Interface Adapters** - Controllers, presenters
4. **Frameworks & Drivers** - External interfaces, database

### MVC Components
- **Model** - Data and business logic
- **View** - Presentation and rendering
- **Controller** - Coordinates model and view

### Separation Indicators
- Service/Repository layers
- Components/Pages separation
- Data access isolation
- Utility/Helper modules
