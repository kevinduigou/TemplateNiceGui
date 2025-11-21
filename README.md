# Copier NiceGUI Template

A [Copier](https://copier.readthedocs.io/) template for creating NiceGUI applications with clean architecture principles.

## Features

- 🏗️ **Clean Architecture**: Clear separation between Domain, Application, Infrastructure, and Interface layers
- 🐍 **NiceGUI Framework**: Modern Python web framework for building reactive UIs
- 🦀 **Rust-Style Error Handling**: Using the `result` library instead of exceptions
- 🔒 **Immutability First**: Prefer immutable objects and pure functions
- ✅ **Testing**: Pre-configured pytest (unit tests) and behave (BDD integration tests)
- 🔍 **Code Quality**: Ruff for linting/formatting, mypy for type checking
- 🚀 **CI/CD**: GitHub Actions workflow included
- 🐳 **Docker Support**: Optional Docker and Docker Compose configuration
- ⚡ **RQ Worker**: Optional support for long-running async tasks

## Quick Start

### Prerequisites

- Python 3.10+
- [Copier](https://copier.readthedocs.io/) (`pipx install copier` or `uv tool install copier`)
- [uv](https://docs.astral.sh/uv/) (recommended for dependency management)

### Create a New Project

```bash
# Using copier
copier copy gh:yourusername/copier-nicegui-template my-project

# Or from local path
copier copy path/to/this/template my-project
```

Answer the prompts:
- Project name
- Project slug (Python package name)
- Description
- Author information
- Python version
- Optional features (Docker, RQ worker, GitHub Actions)

### Run Your New Project

```bash
cd my-project

# Install dependencies
uv sync --all-extras

# Run the application
uv run python -m your_project_slug
```

Visit http://localhost:8080 to see your application!

## Architecture

The template follows clean architecture principles with four distinct layers:

### 1. Domain Layer (`src/{project}/domain/`)
- **Pure business logic** - no external dependencies
- **Entities**: Mutable domain objects with identity
- **Value Objects**: Immutable objects defined by their values
- **Events**: Immutable domain events

### 2. Application Layer (`src/{project}/application/`)
- **Use cases and orchestration**
- **Commands**: State-changing operations (`commands/`)
- **Queries**: Read-only operations (`queries/`)
- **Async Commands/Queries**: Long-running tasks (`commands_async/`, `queries_async/`)

### 3. Infrastructure Layer (`src/{project}/infrastructure/`)
- **External integrations**: Database, APIs, file I/O
- **Only layer allowed to use try/except** for I/O operations

### 4. Interface Layer (`src/{project}/interface/`)
- **NiceGUI frontend**
- **Pages and components**
- **Event handlers**

## Design Principles

### Immutability First
```python
from dataclasses import dataclass
from typing import final

@final
@dataclass(frozen=True, slots=True)
class Email:
    value: str
```

### Rust-Style Error Handling
```python
from result import Result, Ok, Err

def divide(a: int, b: int) -> Result[int, str]:
    if b == 0:
        return Err("Cannot divide by zero")
    return Ok(a // b)
```

### Explicit Over Implicit
- No magic numbers or dynamic behavior
- Clear, descriptive names
- No single-letter variables

## Development Workflow

### Code Quality Checks

```bash
# Run all checks
uv run pytest          # Unit tests
uv run behave          # Integration tests
uv run ruff check      # Linting
uv run mypy src/       # Type checking
uv run ruff format     # Code formatting
```

### Project Structure

```
my-project/
├── src/
│   └── my_project/
│       ├── domain/              # Pure business logic
│       ├── application/         # Use cases
│       ├── infrastructure/      # External integrations
│       └── interface/           # NiceGUI UI
├── tests/
│   ├── unit/                    # Unit tests
│   └── integration/             # Integration tests
├── features/                    # BDD tests (behave)
├── pyproject.toml              # Project configuration
└── README.md
```

## Customization

The template includes:
- `.clinerules/Agents.md`: Comprehensive guidelines for AI assistants
- Pre-configured `pyproject.toml` with all necessary tools
- Example domain objects, commands, and UI pages
- Complete test suite examples
- GitHub Actions CI/CD pipeline

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This template is released under the MIT License.

## Credits

Built with:
- [Copier](https://copier.readthedocs.io/) - Template engine
- [NiceGUI](https://nicegui.io/) - Python web framework
- [Result](https://github.com/rustedpy/result) - Rust-style error handling
- [Ruff](https://docs.astral.sh/ruff/) - Fast Python linter
- [mypy](https://mypy-lang.org/) - Static type checker
- [pytest](https://pytest.org/) - Testing framework
- [behave](https://behave.readthedocs.io/) - BDD framework
