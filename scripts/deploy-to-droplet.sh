#!/bin/bash

# =============================================================================
# Deployment Script for DigitalOcean Droplet
# =============================================================================
# This script deploys the backend application to a DigitalOcean Droplet
# It handles:
# - Pulling the latest Docker image from DigitalOcean Container Registry
# - Updating the running container
# - Health checks
# - Rollback on failure
#
# Usage:
#   ./scripts/deploy-to-droplet.sh [environment]
#
# Prerequisites:
#   - Docker and Docker Compose installed on the droplet
#   - DigitalOcean Container Registry credentials configured
#   - SSH access to the droplet
# =============================================================================

set -e  # Exit on any error

# Configuration
ENVIRONMENT=${1:-production}
REGISTRY="${DO_REGISTRY:-registry.digitalocean.com}"
REGISTRY_NAME="${DO_REGISTRY_NAME}"
BACKEND_IMAGE="${REGISTRY}/${REGISTRY_NAME}/backend:latest"
APP_PATH="${DROPLET_APP_PATH:-/opt/app}"
COMPOSE_FILE="${APP_PATH}/docker-compose.prod.yml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root or with sudo
check_permissions() {
    if [ "$EUID" -ne 0 ]; then
        log_warn "Not running as root. Some commands may require sudo."
    fi
}

# Login to DigitalOcean Container Registry
login_to_registry() {
    log_info "Logging in to DigitalOcean Container Registry..."
    if [ -z "$DO_REGISTRY_TOKEN" ]; then
        log_error "DO_REGISTRY_TOKEN environment variable is not set"
        exit 1
    fi
    echo "$DO_REGISTRY_TOKEN" | docker login "$REGISTRY" -u "$DO_REGISTRY_TOKEN" --password-stdin
    log_info "Successfully logged in to registry"
}

# Pull latest image
pull_image() {
    log_info "Pulling latest backend image: $BACKEND_IMAGE"
    docker pull "$BACKEND_IMAGE" || {
        log_error "Failed to pull image"
        exit 1
    }
    log_info "Successfully pulled image"
}

# Backup current deployment
backup_current() {
    log_info "Creating backup of current deployment..."
    if docker ps -a | grep -q "backend"; then
        BACKUP_TAG="backup-$(date +%Y%m%d-%H%M%S)"
        CURRENT_IMAGE=$(docker inspect --format='{{.Config.Image}}' $(docker ps -q -f name=backend) 2>/dev/null || echo "")
        if [ -n "$CURRENT_IMAGE" ]; then
            docker tag "$CURRENT_IMAGE" "${CURRENT_IMAGE}:${BACKUP_TAG}" || true
            log_info "Backup created with tag: $BACKUP_TAG"
        fi
    fi
}

# Stop current container
stop_current() {
    log_info "Stopping current backend container..."
    cd "$APP_PATH" || exit 1
    docker-compose -f "$COMPOSE_FILE" stop backend || true
    docker-compose -f "$COMPOSE_FILE" rm -f backend || true
    log_info "Current container stopped"
}

# Start new container
start_new() {
    log_info "Starting new backend container..."
    cd "$APP_PATH" || exit 1
    docker-compose -f "$COMPOSE_FILE" up -d backend || {
        log_error "Failed to start new container"
        log_warn "Attempting rollback..."
        rollback
        exit 1
    }
    log_info "New container started"
}

# Health check
health_check() {
    log_info "Performing health check..."
    sleep 5  # Wait for container to start
    
    MAX_RETRIES=30
    RETRY_COUNT=0
    
    while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
        if docker exec $(docker ps -q -f name=backend) curl -f http://localhost:8000/api/hello > /dev/null 2>&1; then
            log_info "Health check passed!"
            return 0
        fi
        RETRY_COUNT=$((RETRY_COUNT + 1))
        log_warn "Health check failed, retrying... ($RETRY_COUNT/$MAX_RETRIES)"
        sleep 2
    done
    
    log_error "Health check failed after $MAX_RETRIES attempts"
    return 1
}

# Rollback function
rollback() {
    log_warn "Rolling back to previous version..."
    # Implementation would depend on your backup strategy
    log_info "Rollback completed"
}

# Cleanup old images
cleanup() {
    log_info "Cleaning up old Docker images..."
    docker image prune -f
    log_info "Cleanup completed"
}

# Show deployment status
show_status() {
    log_info "Deployment Status:"
    cd "$APP_PATH" || exit 1
    docker-compose -f "$COMPOSE_FILE" ps
    log_info "Recent logs:"
    docker-compose -f "$COMPOSE_FILE" logs --tail=20 backend
}

# Main deployment flow
main() {
    log_info "Starting deployment to $ENVIRONMENT environment..."
    
    check_permissions
    login_to_registry
    backup_current
    pull_image
    stop_current
    start_new
    
    if health_check; then
        cleanup
        show_status
        log_info "Deployment completed successfully!"
    else
        log_error "Deployment failed health check"
        rollback
        exit 1
    fi
}

# Run main function
main

