#!/bin/bash
set -e

PROJECT_NAME="${PROJECT_NAME:-mynicegui}"
GCP_PROJECT_ID="${GCP_PROJECT_ID:-testcopiernicegui}"
GCP_REGION="${GCP_REGION:-europe-west1}"
GAR_REPOSITORY="${GAR_REPOSITORY:-mynicegui}"
IMAGE_VERSION="${IMAGE_VERSION:-latest}"
SERVICE_NAME="${SERVICE_NAME:-mynicegui-app}"
VPC_CONNECTOR_NAME="${SERVICE_NAME}-connector"
MEMORY="${MEMORY:-512Mi}"
CPU="${CPU:-1}"
TIMEOUT="${TIMEOUT:-300}"
CONCURRENCY="${CONCURRENCY:-80}"
MIN_INSTANCES="${MIN_INSTANCES:-1}"
MAX_INSTANCES="${MAX_INSTANCES:-10}"
VOLUME_NAME="${VOLUME_NAME:-mynicegui-data}"
BUCKET_NAME="${GCP_PROJECT_ID}-${VOLUME_NAME}"
MOUNT_PATH="/data"
GAR_URL="${GCP_REGION}-docker.pkg.dev/${GCP_PROJECT_ID}/${GAR_REPOSITORY}"

ENV_VARS_FILE="${1:-env-vars.yaml}"

gcloud run deploy ${SERVICE_NAME} \
  --image=${GAR_URL}/${PROJECT_NAME}-nicegui:${IMAGE_VERSION} \
  --region=${GCP_REGION} \
  --project=${GCP_PROJECT_ID} \
  --platform=managed \
  --allow-unauthenticated \
  --port=8080 \
  --env-vars-file="${ENV_VARS_FILE}" \
  --vpc-connector=${VPC_CONNECTOR_NAME} \
  --memory=${MEMORY} \
  --cpu=${CPU} \
  --timeout=${TIMEOUT} \
  --concurrency=${CONCURRENCY} \
  --min-instances=${MIN_INSTANCES} \
  --max-instances=${MAX_INSTANCES} \
  --execution-environment=gen2 \
  --add-volume=name=${VOLUME_NAME},type=cloud-storage,bucket=${BUCKET_NAME} \
  --add-volume-mount=volume=${VOLUME_NAME},mount-path=${MOUNT_PATH}

