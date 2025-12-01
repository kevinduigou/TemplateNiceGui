#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${1:-${PROJECT_ROOT}/.env}"  # Pass as argument or fallback

REDIS_URL="${REDIS_URL:-}"
BASE_URL="${BASE_URL:-}"

ENV_VARS_FILE=$(mktemp)
echo "REDIS_URL: \"${REDIS_URL}\"" >> "$ENV_VARS_FILE"

while IFS= read -r line || [ -n "$line" ]; do
  if [[ ! "$line" =~ ^[[:space:]]*# ]] && [[ -n "$line" ]]; then
    line=$(echo "$line" | sed "s/#.*$//")
    line=$(echo "$line" | xargs)
    if [[ -n "$line" ]] && [[ "$line" == *"="* ]]; then
      key="${line%%=*}"
      value="${line#*=}"
      if [[ "$key" != "REDIS_URL" && "$key" != "BASE_URL" ]]; then
        echo "${key}: \"${value}\"" >> "$ENV_VARS_FILE"
      fi
    fi
  fi
done < "${ENV_FILE}"

echo "BASE_URL: \"${BASE_URL}\"" >> "$ENV_VARS_FILE"
echo "$ENV_VARS_FILE"

