#!/usr/bin/env bash
# ==============================================================================
# Deploy or start the application stack on the host or in containers.
#
# Usage:
#   bash scripts/deploy.sh [dev|stg|prod]
#   bash scripts/deploy.sh dev
# ==============================================================================
set -euo pipefail

# ANSI color codes
BOLD="\033[1m"
GREEN="\033[0;32m"
RED="\033[0;31m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
NC="\033[0m"

log_info() { echo -e "${BLUE}${BOLD}[DEPLOY]${NC} $*"; }
log_ok() { echo -e "${GREEN}${BOLD}[OK]${NC} $*"; }
log_warn() { echo -e "${YELLOW}${BOLD}[WARN]${NC} $*"; }
log_err() { echo -e "${RED}${BOLD}[ERROR]${NC} $*" >&2; }

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
cd "$ROOT_DIR"

TARGET_ENV="${1:-${ENVIRONMENT:-dev}}"
TARGET_ENV="$(echo "$TARGET_ENV" | tr '[:upper:]' '[:lower:]')"

log_info "Starting deployment for target environment: ${BOLD}${TARGET_ENV}${NC}..."

# 1. Ensure appropriate environment file exists
ENV_FILE=""
if [[ -f ".env.${TARGET_ENV}" ]]; then
  ENV_FILE=".env.${TARGET_ENV}"
elif [[ -f ".env" ]]; then
  ENV_FILE=".env"
elif [[ -f "local.env" ]]; then
  ENV_FILE="local.env"
else
  # Auto-create from .env.example
  if [[ -f ".env.example" ]]; then
    log_warn "No .env file found. Creating .env from .env.example..."
    cp ".env.example" ".env"
    ENV_FILE=".env"
  else
    log_err "Missing .env file and .env.example not found. Aborting."
    exit 1
  fi
fi

log_info "Using environment file: ${ENV_FILE}"

# Load port configuration
APP_PORT="$(grep -E '^FASTAPI_PORT=' "$ENV_FILE" | cut -d '=' -f2 | tr -d ' "\r' || echo "")"
APP_PORT="${APP_PORT:-8000}"

# 2. Deploy via Docker Compose if docker-compose file is present
if [[ -f "docker-compose.yml" ]] && command -v docker >/dev/null 2>&1; then
  log_info "Docker Compose detected. Building and starting services with ${ENV_FILE}..."
  ENV_FILE="$ENV_FILE" docker compose build
  ENV_FILE="$ENV_FILE" docker compose up -d --remove-orphans
  DEPLOY_MODE="compose"
elif command -v uv >/dev/null 2>&1; then
  log_info "Running via local Python environment with uv..."
  uv sync
  DEPLOY_MODE="local"
else
  log_err "Neither Docker nor uv is available to run the application."
  exit 1
fi

# 3. Wait for FastAPI readiness
log_info "Waiting for service readiness at http://127.0.0.1:${APP_PORT}/health..."
TIMEOUT=60
ELAPSED=0

while [ "$ELAPSED" -lt "$TIMEOUT" ]; do
  if curl -sf "http://127.0.0.1:${APP_PORT}/health" >/dev/null 2>&1; then
    log_ok "Application is healthy and ready!"
    break
  fi
  sleep 3
  ELAPSED=$((ELAPSED + 3))
done

if [ "$ELAPSED" -ge "$TIMEOUT" ]; then
  log_warn "Application health check timed out after ${TIMEOUT}s."
  if [[ "$DEPLOY_MODE" == "compose" ]]; then
    docker compose logs --tail 30
  fi
  log_err "Service readiness verification failed."
  exit 1
fi

# 4. Post-deployment smoke test
log_info "Running post-deployment smoke test..."
if ! bash scripts/smoke-test.sh "http://127.0.0.1:${APP_PORT}"; then
  log_err "Post-deployment smoke test failed."
  if [[ "$DEPLOY_MODE" == "compose" ]]; then
    docker compose logs --tail 30
  fi
  exit 1
fi

# 5. Summary
echo ""
if [[ "$DEPLOY_MODE" == "compose" ]]; then
  echo -e "${GREEN}${BOLD}Stack Status:${NC}"
  docker compose ps
  echo ""
fi
echo -e "${GREEN}${BOLD}✅ Deployment of python-project-starter (${TARGET_ENV}) completed successfully!${NC}"
