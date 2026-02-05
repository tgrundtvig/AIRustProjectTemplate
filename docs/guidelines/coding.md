# Coding Guidelines

## Type System

### Traits
- Use traits for all behavioral abstractions
- Trait gets the clean name: `CharacterAttribute`, `Location`, `Item`
- Implement traits for concrete types

### Structs
- Use for all data types
- Prefer immutable fields (no `mut` unless required)
- Derive common traits: `Debug`, `Clone`, `PartialEq`

### Enums
- Use for fixed value sets and sum types
- Leverage pattern matching exhaustiveness
- Consider `#[non_exhaustive]` for public enums

### Error Handling
- Use `Result<T, E>` for fallible operations
- Define domain-specific error types
- Use `thiserror` for library errors, `anyhow` for applications
- No panics in library code (except `unreachable!`)

### Standard Library Types
- Use `String`, `Vec<T>`, `HashMap<K, V>` appropriately
- Prefer `&str` over `String` in function parameters
- Use `Cow<'_, str>` when ownership is conditional

## Naming

### Types and Implementations
- Trait: clean concept name (`CharacterAttribute`)
- Implementation: descriptive name (`BasicCharacterAttribute`)
- Avoid generic `Impl` suffix

### Constructors
- `new()` for infallible construction
- `try_new()` or `from_*()` for fallible construction
- `with_*()` for builder-style methods

### Methods
- `find_*` returns `Option<T>` (might not exist)
- `get_*` returns `&T` or panics (use sparingly)
- `*_or_default` provides fallback behavior

## Trait Pattern

### Scope
- Traits for behavioral abstractions
- Direct struct construction for data types

### Structure
```rust
pub trait CharacterAttribute {
    fn min_value(&self) -> i32;
    fn max_value(&self) -> i32;
    fn mean_value(&self) -> i32 {
        (self.min_value() + self.max_value()) / 2
    }
}

pub struct BasicCharacterAttribute {
    min: i32,
    max: i32,
}

impl CharacterAttribute for BasicCharacterAttribute {
    fn min_value(&self) -> i32 { self.min }
    fn max_value(&self) -> i32 { self.max }
}
```

### Factory Functions
- Free functions or associated functions
- No factory traits unless truly polymorphic

## Crate Structure

### Workspace Layout (Multi-Crate)
```
project/
├── Cargo.toml           # Workspace root
├── crates/
│   ├── foo-core/        # Core types and traits
│   ├── foo-impl/        # Default implementation
│   └── foo-mock/        # Mock implementation for testing
```

### Single Crate Layout
```
project/
├── Cargo.toml
├── src/
│   ├── lib.rs           # Public API
│   ├── domain/          # Domain types
│   ├── services/        # Business logic
│   └── infrastructure/  # External integrations
```

### Module Visibility
- `pub` for public API
- `pub(crate)` for internal sharing
- Private by default

## Error Handling

### Result Types
```rust
pub type Result<T> = std::result::Result<T, Error>;

#[derive(Debug, thiserror::Error)]
pub enum Error {
    #[error("invalid attribute: min {min} exceeds max {max}")]
    InvalidAttribute { min: i32, max: i32 },

    #[error("character not found: {0}")]
    NotFound(CharacterId),
}
```

### Propagation
- Use `?` operator for propagation
- Add context with `.map_err()` or `anyhow::Context`

### Panics
- Reserve for programming errors only
- Use `debug_assert!` for invariants
- Document panic conditions in doc comments

## Option Handling

### Return Types
- `Option<T>` when absence is valid
- Direct return when value must exist

### Parameters
- Avoid `Option<T>` parameters; use overloading or builders
- Accept `impl Into<Option<T>>` sparingly

### Collections
- Never `Option<Vec<T>>`; use empty Vec

## Code Style

### Immutability
- Prefer immutable bindings (`let` over `let mut`)
- Use `Clone` over interior mutability when reasonable
- `RefCell`/`Mutex` only when truly needed

### Method Length
- No hard limit
- Single responsibility
- Extract when logic becomes nested

### Documentation
- Doc comments (`///`) on all public items
- Include examples in doc comments
- Use `#[doc(hidden)]` for implementation details

### Formatting
- Use `rustfmt` with default settings
- Configure via `rustfmt.toml` if needed

## Dependency Injection

### Constructor Pattern
```rust
pub struct CharacterService {
    repository: Box<dyn CharacterRepository>,
}

impl CharacterService {
    pub fn new(repository: impl CharacterRepository + 'static) -> Self {
        Self {
            repository: Box::new(repository),
        }
    }
}
```

### Generic Alternative
```rust
pub struct CharacterService<R: CharacterRepository> {
    repository: R,
}

impl<R: CharacterRepository> CharacterService<R> {
    pub fn new(repository: R) -> Self {
        Self { repository }
    }
}
```

### No Framework
- Explicit wiring in `main()`
- Compile-time verification
- No runtime reflection

## Logging

### API
- Use `tracing` crate (preferred) or `log`
- `tracing::info!("Player joined: player_id={}", id)`

### Levels
- ERROR: Failed, needs attention
- WARN: Unexpected but handled
- INFO: Significant events
- DEBUG: Troubleshooting detail
- TRACE: Fine-grained tracing

### Content
- Include context: structured fields with `tracing`
- No sensitive data in logs
