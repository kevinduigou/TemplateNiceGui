# Software Design Assistant Guidelines

You are a software design assistant specialized in building applications with the NiceGUI framework and clean architecture principles.

You should create the perfect Copir Template

## Core Framework

- **Use the Python framework NiceGUI** to design frontend and backend
- NiceGUI provides a Pythonic way to build web interfaces with reactive components

## Architecture Principles

### Separation of Concerns

When doing structural modifications to the application, use clear separation between layers:

1. **Domain Layer**: Core business logic
   - Immutable, pure functions
   - No DB, I/O, or HTTP code
   - Contains Entities (mutable), Value Objects (immutable), and Events (immutable)
   - Located in: `src/{PROJECT_NAME}/domain/`

2. **Application Layer**: Use cases and orchestration
   - Coordinates domain objects and infrastructure
   - Contains Commands (mutate state) and Queries (read-only)
   - Located in: `src/{PROJECT_NAME}/application/`
   - Subdivided into:
     - `commands/` - Synchronous state-changing operations
     - `commands_async/` - Long-running tasks executed by RQ worker
     - `queries/` - Synchronous read operations
     - `queries_async/` - Long-running read operations

3. **Infrastructure Layer**: External integrations
   - Database access, APIs, file I/O
   - May contain mutable functions
   - Only layer allowed to use `try/except` around I/O operations
   - Located in: `src/{PROJECT_NAME}/infrastructure/`

4. **Interface Layer**: NiceGUI frontend
   - User interface components
   - Event handlers
   - Located in: `src/{PROJECT_NAME}/interface/`

### Immutability First

- **Treat all function parameters as immutable by default**
- Never modify inputs directly
- Prefer pure functions and immutable objects with `@final` and `__slots__`
- Infrastructure may contain mutable functions
- Entity objects must be mutable
- Prefer using `tuple` (immutable) over `list` (mutable)

Example:
```python
from dataclasses import dataclass
from typing import final

@final
@dataclass(frozen=True, slots=True)
class ValueObject:
    name: str
    value: int
```

### Make Illegal States Unrepresentable

- Domain objects must not allow invalid construction
- Use factory methods like `try_create()` or validation before instantiation
- Never expose public constructors for domain objects with constraints

Example:
```python
from result import Result, Ok, Err

@dataclass
class Email:
    value: str
    
    @staticmethod
    def try_create(email_str: str) -> Result['Email', str]:
        if '@' not in email_str:
            return Err("Invalid email format")
        return Ok(Email(value=email_str))
```

### Be Explicit

- **No dynamic behavior or magic numbers**
- No metaclasses, monkey patching, or decorators that inject logic
- Function and variable names shall be as explicit as possible
- **Do not use single-letter variable names**

Bad:
```python
def f(x, y):
    return x + y
```

Good:
```python
def calculate_total_price(base_price: int, tax_amount: int) -> int:
    return base_price + tax_amount
```

### Keep Domain Objects Simple

- Use simple dataclasses for domain objects
- Entities: mutable
- Value Objects: immutable
- Events: immutable
- Don't use `try_create` if there's no explicit way to reject creation

Example:
```python
from dataclasses import dataclass

# Simple entity (mutable)
@dataclass
class User:
    user_id: str
    name: str
    email: str

# Simple value object (immutable)
@dataclass(frozen=True)
class Money:
    amount: int
    currency: str
```

## Error Handling: Rust-Style Control Flow

### No Exceptions in Domain/Application Layers

- **Do not use `try`, `except`, or `raise`** in domain or application layers
- Only infrastructure layer may contain `try/except` around I/O operations
- Use the `result` library for error handling

Install in `pyproject.toml`:
```toml
dependencies = [
    "result>=0.16.0",
]
```

### Using Result Type

```python
from result import Result, Ok, Err

def divide(dividend: int, divisor: int) -> Result[int, str]:
    if divisor == 0:
        return Err("Cannot divide by zero")
    return Ok(dividend // divisor)

# Usage with pattern matching
values = [(10, 0), (10, 5)]
for dividend, divisor in values:
    match divide(dividend, divisor):
        case Ok(value):
            print(f"{dividend} // {divisor} == {value}")
        case Err(error_message):
            print(error_message)
```

## Long-Running Tasks

### RQ Worker for Async Operations

Long-running use cases/tasks are:

1. **Executed by an RQ worker** (configured in `docker/Dockerfile.worker`)
2. **Located under**:
   - `src/{PROJECT_NAME}/application/commands_async/`
   - `src/{PROJECT_NAME}/application/queries_async/`

### Enqueueing Jobs

In the interface layer, enqueue long-running jobs:

```python
result = self._rq_client.enqueue_job(
    "{PROJECT_NAME}.application.commands_async.load_kb_campaigns.execute_load_kb_campaigns_job",
    irma_base_url,
    self._db_url,
    job_timeout=7200,  # 2 hours timeout
)
```

### Monitoring Job Status

Use a timer to check job status and metadata:

```python
status_result = self._rq_client.get_job_status(self._job_id)
meta_result = self._rq_client.get_job_meta(self._job_id)
```

### Moderately Long Tasks

For moderately long tasks, use NiceGUI's async utilities:

```python
from nicegui import run, ui

# For I/O-bound tasks
await run.io_bound(some_io_function, arg1, arg2)

# For CPU-bound tasks
await run.cpu_bound(some_cpu_function, arg1, arg2)
```

## Dependency Rules

- **Domain objects must not depend on external libraries, ORMs, or I/O**
- Domain layer should only use Python standard library and pure logic
- Use infrastructure objects in the application layer
- Don't use Port/Adapter pattern unless complexity demands it (keep it simple)

## Application Layer Organization

The application layer is the home of use cases, distinguished between:

1. **Commands**: Mutate state
   - Located in `application/commands/`
   - Return `Result[SuccessType, ErrorType]`

2. **Queries**: Don't mutate state
   - Located in `application/queries/`
   - Return `Result[DataType, ErrorType]`

## Testing Strategy

### Unit Tests with pytest

- Focus on domain-specific functions
- Test pure logic without I/O
- Located in `tests/unit/`

Example:
```python
import pytest
from result import Ok, Err

def test_divide_success():
    result = divide(10, 2)
    assert result == Ok(5)

def test_divide_by_zero():
    result = divide(10, 0)
    assert result == Err("Cannot divide by zero")
```

### Integration Tests with behave

- Use behave library for BDD-style integration tests
- Located in `features/`

Example structure:
```
features/
├── steps/
│   └── user_steps.py
└── user_management.feature
```

## Code Quality Workflow

When a modification is done on Python files, **always perform**:

```bash
# Run tests
uv run pytest

# Check code quality
uv run ruff check

# Type checking
uv run mypy

# Format code (do this last)
uv run ruff format
```

Ensure there are no errors remaining before completing the task.

## Project Configuration

### pyproject.toml Requirements

Automatically create `pyproject.toml` with:

- **ruff**: Linting and formatting
- **result**: Rust-style error handling
- **mypy**: Static type checking
- **pytest**: Unit testing
- **behave**: Integration testing
- **nicegui**: Web framework
- **rq**: Task queue (if using async workers)

### GitHub Actions Pipeline

Create a pipeline automatically under `.github/workflows/` with:

- Python version matrix testing
- Dependency installation with `uv`
- Linting with `ruff check`
- Type checking with `mypy`
- Unit tests with `pytest`
- Integration tests with `behave`
- Code formatting check with `ruff format --check`

## Summary Checklist

When creating or modifying code:

- [ ] Separate concerns into appropriate layers (Domain/Application/Infrastructure/Interface)
- [ ] Use immutable objects by default (except Entities)
- [ ] Use `Result` type instead of exceptions
- [ ] Make variable and function names explicit
- [ ] Validate domain objects properly
- [ ] Keep domain layer pure (no external dependencies)
- [ ] Use RQ workers for long-running tasks
- [ ] Write unit tests for domain logic
- [ ] Write integration tests with behave
- [ ] Run quality checks: pytest, ruff, mypy, format
- [ ] Document complex business logic
