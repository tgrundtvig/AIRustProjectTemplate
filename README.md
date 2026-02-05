# Project Template

Rust project template with AI-assisted development guidelines.

## Project Structure

```
project/
├── crates/                 # Rust crates (workspace members)
│   └── app/                # Main application
├── docs/
│   ├── guidelines/         # Reusable development guidelines
│   └── project/            # Project-specific documentation
├── .claude/                # AI collaboration tooling
├── .github/                # CI/CD workflows
├── discussions/            # Brainstorm session logs
└── Cargo.toml              # Workspace manifest
```

## Getting Started

### Using as Template

1. Click "Use this template" on GitHub
2. Clone your new repository
3. Run setup script: `./setup.sh`
4. Fill in `docs/project/overview.md`
5. Start coding in `crates/<project-name>/src/`

### Manual Setup

1. Update `Cargo.toml`:
   - `authors`: your information

2. Update `crates/app/Cargo.toml`:
   - `name`: project name
   - `description`: project description

3. Rename `crates/app/` to match your project name

4. Update `docs/project/overview.md` with project description

## Documentation

- [Project Overview](docs/project/overview.md)
- [Architecture](docs/project/architecture.md)
- [Domain Model](docs/project/domain.md)

### Guidelines

- [Collaboration](docs/guidelines/collaboration-guidelines.md)
- [Coding](docs/guidelines/coding.md)
- [Testing](docs/guidelines/testing.md)
- [DevOps](docs/guidelines/devops.md)

## Building

```bash
cargo build --release
```

## Testing

```bash
cargo test
```

## Linting

```bash
cargo clippy
cargo fmt -- --check
```

## Adding Crates

To add a new crate to the workspace:

```bash
mkdir -p crates/my-crate/src
# Create crates/my-crate/Cargo.toml with workspace inheritance
```

The workspace uses `members = ["crates/*"]`, so new crates are auto-discovered.

## License

[Choose a license]
