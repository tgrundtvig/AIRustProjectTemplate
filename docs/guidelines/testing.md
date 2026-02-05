# Testing Guidelines

## Philosophy

### Test Behavior, Not Implementation
- Test observable behavior through public APIs
- Internal structure is implementation detail
- Refactoring internals should not break tests

### Test at Module Boundaries
- Each crate/module has a public API — test that
- Higher confidence than isolated unit tests
- Catches integration issues

## Test Organization

### Location
```
project/
├── src/
│   ├── lib.rs
│   └── domain/
│       ├── mod.rs
│       └── character.rs    # Contains #[cfg(test)] mod tests
├── tests/                  # Integration tests
│   ├── character_tests.rs
│   └── common/
│       └── mod.rs          # Shared test utilities
└── benches/                # Benchmarks (optional)
    └── performance.rs
```

### Unit Tests (Inline)
```rust
// In src/domain/character.rs
pub struct Character {
    name: String,
    health: u32,
}

impl Character {
    pub fn new(name: impl Into<String>, health: u32) -> Self {
        Self { name: name.into(), health }
    }

    pub fn is_alive(&self) -> bool {
        self.health > 0
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn character_with_health_is_alive() {
        let character = Character::new("Hero", 100);
        assert!(character.is_alive());
    }

    #[test]
    fn character_with_zero_health_is_dead() {
        let character = Character::new("Hero", 0);
        assert!(!character.is_alive());
    }
}
```

### Integration Tests
```rust
// In tests/character_tests.rs
use my_crate::Character;

#[test]
fn character_can_take_damage() {
    let mut character = Character::new("Hero", 100);
    character.take_damage(30);
    assert_eq!(character.health(), 70);
}
```

## Contract Testing with Traits

### Define Contract
```rust
// In crate API
pub trait CharacterRepository {
    fn find(&self, id: CharacterId) -> Option<Character>;
    fn save(&mut self, character: &Character) -> Result<(), Error>;
}
```

### Contract Test Macro
```rust
// Test utilities module
#[macro_export]
macro_rules! test_character_repository_contract {
    ($create_repo:expr) => {
        #[test]
        fn saved_character_can_be_found() {
            let mut repo = $create_repo;
            let character = Character::new("Hero", 100);
            repo.save(&character).unwrap();

            let found = repo.find(character.id());
            assert!(found.is_some());
            assert_eq!(found.unwrap().name(), "Hero");
        }

        #[test]
        fn missing_character_returns_none() {
            let repo = $create_repo;
            let found = repo.find(CharacterId::new());
            assert!(found.is_none());
        }
    };
}

// In implementation tests
mod tests {
    use super::*;

    test_character_repository_contract!(InMemoryCharacterRepository::new());
}
```

## Mock Implementations

### Purpose
- Alternative implementations for testing
- Reusable across crates
- Verified by contract tests

### Design
```rust
pub struct MockEmailService {
    sent_emails: RefCell<Vec<Email>>,
    should_fail: Cell<bool>,
}

impl MockEmailService {
    pub fn new() -> Self {
        Self {
            sent_emails: RefCell::new(Vec::new()),
            should_fail: Cell::new(false),
        }
    }

    // Test helpers
    pub fn sent_count(&self) -> usize {
        self.sent_emails.borrow().len()
    }

    pub fn last_sent(&self) -> Option<Email> {
        self.sent_emails.borrow().last().cloned()
    }

    pub fn set_should_fail(&self, fail: bool) {
        self.should_fail.set(fail);
    }
}

impl EmailService for MockEmailService {
    fn send(&self, email: Email) -> Result<(), Error> {
        if self.should_fail.get() {
            return Err(Error::SimulatedFailure);
        }
        self.sent_emails.borrow_mut().push(email);
        Ok(())
    }
}
```

### No External Mock Frameworks
- Hand-written mocks are explicit and debuggable
- AI generates them easily
- Mocks verified by contract tests
- Fewer dependencies

## Test Naming

### Pattern
```rust
#[test]
fn should_return_none_when_character_not_found() { }

#[test]
fn should_panic_when_min_exceeds_max() { }

// Or descriptive snake_case
#[test]
fn empty_inventory_has_zero_items() { }
```

### Principles
- Name describes behavior, not function being tested
- Failure message is informative
- Use `#[test]` attribute (no `test_` prefix needed)

## Test Structure

### Arrange-Act-Assert
```rust
#[test]
fn should_calculate_mean() {
    // Arrange
    let attribute = BasicCharacterAttribute::new(2, 10);

    // Act
    let mean = attribute.mean_value();

    // Assert
    assert_eq!(mean, 6);
}
```

### Keep Tests Short
- One behavior per test
- Comments optional if structure is clear

## Assertions

### Standard Library
```rust
assert!(condition);
assert_eq!(left, right);
assert_ne!(left, right);
assert!(result.is_ok());
assert!(result.is_err());
```

### Pattern Matching
```rust
assert!(matches!(result, Ok(Character { health: 100, .. })));
assert!(matches!(error, Error::NotFound(_)));
```

### Custom Messages
```rust
assert!(character.is_alive(), "Character should be alive with {} health", health);
```

## When to Test

### Always Test
- Public API behavior
- Edge cases and error paths
- Business logic

### Do Not Test
- Private implementation details
- Simple getters/setters
- Compiler-verified behavior (type system)

### Avoid
- 100% coverage as a goal
- Tests coupled to implementation
- Flaky tests (fix or remove)
