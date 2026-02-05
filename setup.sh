#!/bin/bash

# Project Setup Script
# Customizes the template for a new project

set -e

echo "=== Project Setup ==="
echo

# Prompt for project details
read -p "Project name (e.g., my-project): " PROJECT_NAME
read -p "Author name: " AUTHOR_NAME
read -p "Author email: " AUTHOR_EMAIL
read -p "Project description: " DESCRIPTION

# Validate inputs
if [ -z "$PROJECT_NAME" ] || [ -z "$AUTHOR_NAME" ]; then
    echo "Error: Project name and author are required"
    exit 1
fi

echo
echo "Configuring project..."

# Update Cargo.toml
sed -i "s/^name = .*/name = \"${PROJECT_NAME}\"/" Cargo.toml
sed -i "s/^authors = .*/authors = [\"${AUTHOR_NAME} <${AUTHOR_EMAIL}>\"]/" Cargo.toml
sed -i "s/^description = .*/description = \"${DESCRIPTION}\"/" Cargo.toml

# Update binary name
sed -i "s/name = \"project-template\"/name = \"${PROJECT_NAME}\"/" Cargo.toml

# Update project overview
cat > docs/project/overview.md << EOF
# Project Overview

## Name

${PROJECT_NAME}

## Description

${DESCRIPTION}

## Status

Development

## Key Technologies

- Rust (2024 edition)
- Cargo
EOF

echo
echo "=== Setup Complete ==="
echo
echo "Next steps:"
echo "  1. Review Cargo.toml"
echo "  2. Update docs/project/overview.md with more details"
echo "  3. Update docs/project/architecture.md"
echo "  4. Start coding!"
echo
