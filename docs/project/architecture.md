# Project Architecture

<!-- TODO: Fill in project-specific architecture -->

## Crate Overview

```
project/
├── src/
│   ├── lib.rs           # Public API
│   ├── domain/          # Domain types and logic
│   ├── services/        # Application services
│   └── infrastructure/  # External integrations
└── tests/               # Integration tests
```

## Module Diagram

```
[Binary/Entry Point]
        ↓
[Application Layer]
        ↓
[Domain Layer]
        ↓
[Infrastructure Layer]
```

## Key Architectural Decisions

### [Decision 1]

**Context:** [Why was this decision needed?]

**Decision:** [What was decided?]

**Consequences:** [What are the implications?]

## Crate Dependencies

```
[Dependency diagram or description]
```

## External Dependencies

| Crate | Purpose |
|-------|---------|
| [crate] | [Why] |
