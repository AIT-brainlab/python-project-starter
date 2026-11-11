# python-project-starter

Standard Python project template for AIT Brainlab. All Python repositories should adopt this structure and follow the mandated operational standards.

---

## Mandated Standards

1. **Branching Model**:
   - **`dev` (Default)**: Daily development and feature branches fork/merge here. Pushes do not auto-deploy.
   - **`stg`**: Staging environment. Promoted via PR from `dev`. Merging triggers staging deployment.
   - **`main`**: Production environment. Promoted via PR from `stg`. Merging triggers production deployment.
2. **Release & GHCR**: Releases are cut from `dev` using `bash scripts/release.sh vX.Y.Z`. Pushing the tag triggers CI tests and builds/pushes Docker images to GitHub Container Registry (`ghcr.io`).
3. **Environment Configuration**: Strictly one [.env.example](.env.example) template. Local setup is `cp .env.example .env`.
4. **Data Hygiene**: Never commit spreadsheets, database dumps, or raw PII. Enforced locally and in CI via `bash scripts/check-data-guard.sh`.

---

## Quick Start

### 1. Rename Project
When initializing a new repository from this template:
1. Update `project.name` in [`pyproject.toml`](pyproject.toml)
2. Update `PROJECT_NAME` in [`.env.example`](.env.example)

### 2. Setup Environment
```bash
# 1. Create local environment file
cp .env.example .env

# 2. Install dependencies with uv
uv sync
```
*(VS Code Dev Containers are also supported via `.devcontainer/`)*.

### 3. Run Locally
```bash
# Run CLI
uv run python-project-starter --help

# Run Web Server (FastAPI)
uv run python-project-starter web
# Open: http://localhost:8000

# Run Background Worker (Celery + Redis)
docker compose up -d redis
uv run python-project-starter celery worker
```

---

## Operational Scripts (`scripts/`)

| Script | Purpose | Usage |
|---|---|---|
| **[`check.sh`](scripts/check.sh)** | Pre-push verification (data guard, tests, Django check) | `bash scripts/check.sh` |
| **[`release.sh`](scripts/release.sh)** | Cut release tag, push to origin, build GHCR image | `bash scripts/release.sh v0.1.0` |
| **[`release.sh pr`](scripts/release.sh)** | Open promotion PR to `stg` or `main` | `bash scripts/release.sh pr stg` / `pr main` |
| **[`deploy.sh`](scripts/deploy.sh)** | Deploy stack (Docker Compose or local `uv`) with smoke tests | `bash scripts/deploy.sh dev` |
| **[`smoke-test.sh`](scripts/smoke-test.sh)** | End-to-end post-deployment health & route checks | `bash scripts/smoke-test.sh http://localhost:8000` |
| **[`check-data-guard.sh`](scripts/check-data-guard.sh)** | Verify sensitive data guard and file hygiene | `bash scripts/check-data-guard.sh` |

---

## Detailed Documentation (`docs/`)

Technical details and component guides are organized in [`docs/`](docs/):

- **[Django Modular Apps](docs/django.md)**: Reusable app architecture, `django_manage.py`, migrations, and settings.
- **[FastAPI & Web Service](docs/fastapi-web.md)**: REST endpoints, Jinja2 templates, `/health` check, and routing.
- **[Celery & Background Tasks](docs/celery-processor.md)**: Asynchronous task queuing, Redis configuration, and process supervision.
- **[CI/CD & Deployment Guide](docs/deployment.md)**: Multi-environment deployment pipeline (`cd.yml`), NetBird VPN mesh, Traefik reverse proxy overlay, and automated rollbacks.
- **[AI Agent Invariants (`AGENTS.md`)](AGENTS.md)**: Architectural invariants and guidelines for AI coding assistants.

---

## Project Structure

```
.
├── .devcontainer/               # VS Code Dev Container configuration
├── .github/                     # GitHub Actions CI/CD workflows and composite actions
├── data/                        # Local data directory (ignored by git)
├── docs/                        # In-depth module and deployment documentation
├── logs/                        # Application logs (ignored by git)
├── models/                      # Model checkpoints and weights (ignored by git)
├── notebooks/                   # Jupyter notebooks (0-starter.ipynb)
├── scripts/                     # Automation, release, and deployment scripts
├── src/
│   ├── django_core/             # Django dev harness and routing
│   ├── django_module/           # Reusable Django module example
│   └── project/                 # Core FastAPI, CLI, logging, and Celery modules
├── .env.example                 # Single environment configuration template
├── AGENTS.md                    # Operational guidelines for AI agents
├── django_manage.py             # Django entrypoint script
├── docker-compose.yml           # Unified stack compose (App + Redis)
├── docker-compose.traefik.yml   # Traefik overlay for deployed environments
├── Dockerfile                   # Multi-stage production container build
├── pyproject.toml               # Project dependencies and packaging
└── README.md
```

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
