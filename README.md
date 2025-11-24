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
- 🔐 **OAuth Authentication**: Optional Google and/or Twitter OAuth integration

## Quick Start

### Prerequisites

- Python 3.10+
- [Copier](https://copier.readthedocs.io/) (`pipx install copier` or `uv tool install copier`)
- [uv](https://docs.astral.sh/uv/) (recommended for dependency management)

### Create a New Project

```bash
# Using copier from GitHub
copier copy gh:kevinduigou/TemplateNiceGui my-project

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
├── infra/
│   └── terraform/               # Terraform for GKE, Artifact Registry, Redis, CI IAM
├── k8s/                         # Kubernetes manifests for FastAPI, RQ worker, ingress
├── .github/workflows/           # CI/CD pipelines
├── pyproject.toml              # Project configuration
└── README.md
```

## GCP/GKE Deployment Starter Kit

- **Terraform** (`infra/terraform/`): Provisions a regional GKE cluster with an autoscaled node pool, Artifact Registry, a Redis Helm release (Bitnami), and a CI service account with the required roles.
- **Kubernetes manifests** (`k8s/`): Deployments for the FastAPI app and optional RQ worker, HPAs, optional KEDA ScaledObject, ingress, and namespace manifest.
- **GitHub Actions pipeline** (`.github/workflows/deploy-gke.yml`): Builds and pushes the app image to Artifact Registry, fetches GKE credentials, injects the commit SHA as the image tag, and applies the manifests.

### Bootstrap flow

1. Run `terraform init` and `terraform apply` inside `infra/terraform` (set `project_id`, `region`, and other variables).
2. Create GitHub secrets: `GCP_PROJECT_ID`, `GCP_REGION`, `GKE_CLUSTER`, `GCP_SA_KEY` (JSON), and `GCP_ARTIFACT_IMAGE` (e.g., `europe-west1-docker.pkg.dev/PROJECT/REPO/app`).
3. Update `k8s/ingress.yaml` and the image registry path placeholders in the deployment manifests as needed.
4. Push to `main` to trigger the deployment workflow.

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
