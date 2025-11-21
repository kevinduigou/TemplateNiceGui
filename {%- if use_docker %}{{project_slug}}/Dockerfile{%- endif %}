# Multi-stage Dockerfile for {{ project_name }}
# This base stage can be used for both production and development (devcontainer)

# Base stage - shared between all targets
FROM python:{{ python_version }}-slim as base

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.cargo/bin:$PATH"

WORKDIR /app

# Development base stage - for devcontainer
FROM base as dev-base

# Install additional development tools
RUN apt-get update && apt-get install -y \
    build-essential \
    vim \
    nano \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user for development
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

USER $USERNAME
WORKDIR /workspace

# Production dependencies stage
FROM base as dependencies

# Copy dependency files
COPY pyproject.toml ./
{%- if use_oauth %}
COPY .env.example .env
{%- endif %}

# Install dependencies
RUN uv pip install --system -e ".[dev]"

# Production stage
FROM base as production

# Copy installed dependencies from dependencies stage
COPY --from=dependencies /usr/local/lib/python{{ python_version }}/site-packages /usr/local/lib/python{{ python_version }}/site-packages
COPY --from=dependencies /usr/local/bin /usr/local/bin

# Copy application code
COPY src/ /app/src/
COPY pyproject.toml /app/

# Create non-root user for production
RUN useradd -m -u 1000 appuser && \
    chown -R appuser:appuser /app

USER appuser

# Expose port
EXPOSE 8080

# Run the application
CMD ["python", "-m", "{{ project_slug }}"]

{%- if use_rq_worker %}

# Worker stage for RQ workers
FROM production as worker

# Override CMD to run worker instead
CMD ["rq", "worker", "--url", "redis://redis:6379"]
{%- endif %}
