# python-project-starter

This repository is a define practices for AIT Brainlab to follow.
All `python` project should look like this and follow the standard.

- [python-project-starter](#python-project-starter)
  - [Implemented standard](#implemented-standard)
  - [Branching & Environment Strategy (dev / stg / prod)](#branching--environment-strategy-dev--stg--prod)
    - [Branch Hierarchy](#branch-hierarchy)
    - [Promotion Workflow](#promotion-workflow)
    - [Deployment & Automation Scripts (scripts/)](#deployment--automation-scripts-scripts)
    - [Environment Configurations](#environment-configurations)
  - [TODO](#todo)
  - [Project structure](#project-structure)
  - [How to use this](#how-to-use-this)
    - [Change project name](#change-project-name)
    - [Setup development](#setup-development)
    - [Command Script](#command-script)
    - [Install command script completion](#install-command-script-completion)
  - [Django Setup](#django-setup)
    - [Start a new app module](#start-a-new-app-module)
  - [License](#license)

## Implemented standard

1. Project structure
2. logging system
3. command line (with `Typer`)
4. basic web server and REST API (`with FastAPI and Jinja`)
5. processor module with celery support (options for those who may not need `pub-sub/queue`)
6. Define how Django should be implemented.
7. Branching and environment lifecycle (`dev`, `stg`, `prod` / `main`).

## Branching & Environment Strategy (dev / stg / prod)

This repository follows a 3-tier environment and branching model for all projects at AIT Brainlab. The **`dev`** branch serves as the default main working branch.

### Branch Hierarchy

| Environment | Branch | Role | Default / Working Branch | Debug |
|---|---|---|---|---|
| **Development** | `dev` | Active day-to-day development, feature PR integration | **Yes (Default)** | `True` |
| **Staging** | `stg` | Pre-production QA, integration testing, staging release | No | `False` |
| **Production** | `main` | Production deployment, stable releases, version tags | No | `False` |

- **`dev` (Default)**: All feature branches fork off `dev` and merge back into `dev`.
- **`stg`**: Merged from `dev` when preparing a release candidate for QA/testing.
- **`main` (Production)**: Merged from `stg` after validation. Corresponds to production deployments (`prod`). Release tags (e.g. `v1.0.0`) are created on `main`.

### Promotion Workflow

```
[feature/xxx] ---> [dev] ---> [stg] ---> [main (prod)]
```

1. **Feature development**:
   ```sh
   git checkout dev
   git pull origin dev
   git checkout -b feature/my-feature
   ```
2. **Merge to `dev`**:
   Submit a PR targeting `dev`. CI runs automated tests on `dev`.
3. **Cut a Release from `dev`**:
   ```sh
   bash scripts/release.sh v0.1.0
   ```
4. **Promote `dev` to `stg` (Staging)**:
   ```sh
   bash scripts/release.sh promote stg
   ```
5. **Promote `stg` to `main` (Production)**:
   ```sh
   bash scripts/release.sh promote main
   ```

### Deployment & Automation Scripts (`scripts/`)

- **`scripts/deploy.sh`**:
  Deploys or starts the application stack for the target environment (`dev`, `stg`, or `prod`).
  - Ensures required `.env` file exists (auto-creating from template if missing).
  - Starts services (Docker Compose or local `uv` environment).
  - Polls `/health` until the service is ready.
  - Automatically executes post-deployment smoke tests.
  ```sh
  bash scripts/deploy.sh dev
  bash scripts/deploy.sh stg
  bash scripts/deploy.sh prod
  ```

- **`scripts/smoke-test.sh`**:
  Performs post-deployment validation against the running application:
  - Verifies `/health` responds with `status: ok`.
  - Verifies `/` renders the index page and template context.
  - Verifies `/example/{id}` renders dynamic parameters.
  - Executes Django system integrity checks.
  ```sh
  bash scripts/smoke-test.sh http://127.0.0.1:8000
  ```

- **`scripts/release.sh`**:
  Manages semantic releases and immutable fast-forward promotions:
  - `bash scripts/release.sh vX.Y.Z`: Runs release checks, tags `origin/dev`, pushes tag, and publishes GitHub Release.
  - `bash scripts/release.sh promote stg`: Fast-forwards `stg` branch to the verified release tag.
  - `bash scripts/release.sh promote main`: Fast-forwards `main` branch to the staging-tested release tag.

- **`scripts/release-checks.sh`**:
  Repository-specific pre-release checks sourced by `release.sh` (data guard, unit tests with `uv run pytest`, Django checks).

- **`scripts/check-data-guard.sh`**:
  Validates repository hygiene and prevents sensitive data leaks (spreadsheets, database dumps, personal data in SQL/CSV, CRLF endings, or files > 512 KB).

### GitHub Actions CI/CD Pipeline (`.github/`)

- **Continuous Integration ([`.github/workflows/ci.yml`](.github/workflows/ci.yml))**:
  Runs automated `pytest` and dependency checks across `dev`, `stg`, and `main` upon push and pull requests.
- **Continuous Deployment ([`.github/workflows/cd.yml`](.github/workflows/cd.yml))**:
  Automated multi-environment deployment engine using NetBird mesh and SSH:
  - **Tag `v*` (cut from `dev`)** ➔ deploys to **Development** environment.
  - **Push to `stg`** ➔ deploys to **Staging** environment.
  - **Push to `main`** ➔ deploys to **Production** environment.
  - **Automatic Rollback**: If deployment or smoke tests fail, the server immediately rolls back to the previous verified stable commit (`STABLE_REV`) with zero manual intervention.
- **Composite Actions ([`.github/actions/`](.github/actions/))**:
  - `preflight-check`: Validates deployment credentials and environment configuration.
  - `netbird-connect`: Connects the GitHub runner to the NetBird VPN mesh network.
  - `ssh-setup`: Configures SSH keys and known hosts.
  - `ssh-exec`: Executes atomic deployment and rollback commands over SSH.

### Environment Configurations

Environment files provide configuration templates for each tier:
- `.env.dev.example` (or `local.env.example`): Local development defaults (`ENVIRONMENT=dev`, `DEBUG=True`, `LOG_LEVEL=DEBUG`).
- `.env.stg.example`: Staging environment defaults (`ENVIRONMENT=stg`, `DEBUG=False`, `LOG_LEVEL=INFO`).
- `.env.prod.example`: Production environment defaults (`ENVIRONMENT=prod`, `DEBUG=False`, `LOG_LEVEL=WARNING`).

The application automatically loads environment settings in this order:
1. `ENV_FILE` path if set in `os.environ`
2. `.env.<ENVIRONMENT>` (e.g. `.env.dev`, `.env.stg`, `.env.prod`)
3. `local.env`
4. `.env`

Django settings (`src/django_core/settings.py`) adapt dynamically:
- `DEBUG`: Automatically `True` in `dev`, and `False` in `stg` / `prod`.
- `ALLOWED_HOSTS`: Set via environment variable (defaults to `*` in `dev`).
- `SECRET_KEY`: Set via `DJANGO_SECRET_KEY` in environment.

## TODO

- [ ] Distribution standard (containerize for distribution)
- [ ] Chat/LLM standard (interface, prompt, mcp)
- [ ] tools/framework (some other github repo)

## Project structure

```
.
|-- .devcontainer/               # Where the development containers are defined
|-- .github/                     # GitHub configurations (CI/CD workflows & actions)
|   |-- actions/                 # Reusable composite deployment actions
|   |   |-- netbird-connect/     # Connect runner to NetBird VPN mesh
|   |   |-- preflight-check/     # Validate deployment secrets & variables
|   |   |-- ssh-exec/            # Execute deployment & rollback over SSH
|   |   `-- ssh-setup/           # Setup SSH authentication & known_hosts
|   `-- workflows/
|       |-- cd.yml               # Multi-environment CD deployment pipeline
|       `-- ci.yml               # Continuous integration test runner
|-- .vscode/                     # Where the vscode related configuration are kept
|-- data                         # ! Where data is kept. All the data are ignored by default.
|   `-- example.csv
|-- docs/                        # ! Where document (design, paper, any for reference) is kept. 
|-- logs/                        # Where logs are kept.
|-- models/                      # ! Where models (weight) should be stored.
|-- notebooks/                   # ! Where jupyter notebook should be stored.
|   `-- 0-starter.ipynb
|-- scripts/                     # Deployment, release & verification scripts
|   |-- deploy.sh                # Stack deployment with readiness checks & smoke test
|   |-- release.sh               # Semantic release tagging & multi-env promotion
|   |-- release-checks.sh        # Pre-release checks (pytest, Django check)
|   `-- smoke-test.sh            # Post-deployment health, UI, and route validation
|-- src/                         # ! Where development modules should be.
|   |-- django_core              # |
|   |   |-- __init__.py          # | 
|   |   |-- asgi.py              # | 
|   |   |-- settings.py          # | (environment-aware settings)
|   |   |-- urls.py              # | 
|   |   `-- wsgi.py              # | 
|   |-- django_module            # | 
|   |   |-- __init__.py          # |--- These are `Django` related structure
|   |   |-- admin.py             # | 
|   |   |-- apps.py              # | 
|   |   |-- migrations           # | 
|   |   |   `-- __init__.py      # | 
|   |   |-- models.py            # | 
|   |   |-- tests.py             # | 
|   |   `-- views.py             # | 
|   `-- project                  # Example modules with Brainlab practice.
|       |-- __init__.py          # (dynamic multi-environment config loader)
|       |-- cli.py
|       |-- logger.py            # (environment-aware log level & formatting)
|       |-- processor
|       |   |-- __init__.py
|       |   |-- works.py
|       |   `-- works_test.py
|       |-- processor_celery
|       |   |-- __init__.py
|       |   |-- cli.py
|       |   |-- works.py
|       |   `-- works_test.py
|       `-- web
|           |-- __init__.py
|           |-- py.typed
|           |-- router.py
|           `-- templates
|               |-- base.html
|               |-- example.html
|               `-- index.html   # (environment badge & version indicator)
|-- .env.dev.example             # Development environment template
|-- .env.stg.example             # Staging environment template
|-- .env.prod.example            # Production environment template
|-- .gitignore
|-- .python-version
|-- dev-setup.sh                 # ! run this one when you cloned
|-- django_manage.py
|-- LICENSE
|-- local.env.example            # ! copy and create `local.env`
|-- pyproject.toml               # python configuration. You have to change this.
|-- README.md
|-- supervisord.conf             # ! if you want to run multiple processes at the same time, learn this one
`-- uv.lock
```

## How to use this

There are three main tools we use to manage the project.

1. `uv`: python project manager
2. devcontainer: where we spin development environment
3. `mypy`: a complier-ish that will check if your code meet certain standard

### Change project name

We intend that this repository will be used as a template for `python` development.
There are a lot of places where we have to add a `python-project-start` string to make this run properly.
You should change this name to follow your project/module name.

To change the name, you start from your project/repository name.

```sh
/some/path/to/your/repository/<project_name>
```

Let's say we will create another project based on this template with name `myproject`

```sh
/some/path/path/to/your/repository/myproject
```

The place where you need to change the name are

1. `/.devcontainer/dev/.env`: parameter `PROJECT_NAME`
2. `pyproject.toml`: parameter `project.name`
3. `local.env.example`: parameter `PROJECT_NAME`

This should be enough for you to start developing.

### Setup development

1. (optional) spin up devcontainer in vscode (<kbd>cmd/ctrl</kbd> + <kbd>shift</kbd> + <kbd>P</kbd> and choose `Dev Containers: Rebuild and reopen in Container`)
2. Set up the development environment in one go using `bash dev-setup.sh`

### Command Script

The project has a command script.
By default it uses `python-project-starter`.

```sh
uv run python-project-starter --help
```

If you want to change this command name, you have to configure the following

1. `pyproject.toml`: under section `project.scripts`, change the command name
2. `supervisord.conf`: This use your command name to spawn processes

### Install command script completion

Command line solution uses `Typer` library which has completion capabitily.
After you write the command name, you can use <kbd>tab</kbd> to get suggestion/completion.

This functionality is automatically set for if you use `.devcontainer`.
For local user, you will need to run this manually (because I don't know if you want this install in your computer).

```sh
uv run <command_name> --install-completion
```

To remove this, get the intallation path from the command and delete the file manually.

## Django Setup

Let's agree that we should develop a `Django app module` not an entire Django website.
In this AIT Brainlab best practice, the folders that are related to the Django are

```sh
...
|-- src/                         
|   |-- django_core              # |
|   |   |-- __init__.py          # | 
|   |   |-- asgi.py              # | 
|   |   |-- settings.py          # | 
|   |   |-- urls.py              # | 
|   |   `-- wsgi.py              # | 
|   |-- django_module            # | 
|   |   |-- __init__.py          # |--- These are `Django` related structure
|   |   |-- admin.py             # | 
|   |   |-- apps.py              # | 
|   |   |-- migrations           # | 
|   |   |   `-- __init__.py      # | 
|   |   |-- models.py            # | 
|   |   |-- tests.py             # | 
|   |   `-- views.py             # | 
|-- django_manage.py             # | 
...
```

The provided `django_core` is configuration for the development purposes.
The production may have different configuration.
Thus, your main development should be a modular module that is compatible with any django project.

To access typical django operation, you use

```sh
uv run django_manage.py
```

For example, if you want to start the development server, you use

```sh
uv run django_manage.py runserver 0.0.0.0:8000
```

### Start a new app module

Generate a django app boilerplate

```sh
#                       startapp <app_name> <app_folder>
uv run django_manage.py startapp myapp src/myapp
```

Then, add the module to the development project settings (`/src/django_core/settings.py`)

```py
...
# Application definition

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'myapp'  # <---- Add here
]
...
```

Finally, add the routing in `/src/django_core/urls.py`

```py
...
from django.contrib import admin
from django.urls import include, path

urlpatterns = [
    path('admin/', admin.site.urls),
    path("myapp/", include("myapp.urls")),  #<---- Add here
]
...
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
