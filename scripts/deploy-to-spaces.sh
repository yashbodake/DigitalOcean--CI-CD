#!/bin/bash

# =============================================================================
# Deployment Script for DigitalOcean Spaces
# =============================================================================
# This script builds the frontend and deploys static files to DigitalOcean Spaces
# It handles:
# - Building the Vue.js application for production
# - Uploading files to Spaces with proper cache headers
# - CDN cache invalidation (if configured)
#
# Usage:
#   ./scripts/deploy-to-spaces.sh [environment]
#
# Prerequisites:
#   - AWS CLI installed and configured for DigitalOcean Spaces
#   - DO_SPACES_ACCESS_KEY and DO_SPACES_SECRET_KEY environment variables set
#   - Node.js and npm installed
# =============================================================================

set -e  # Exit on any error

# Configuration
ENVIRONMENT=${1:-production}
SPACES_NAME="${DO_SPACES_NAME}"
SPACES_REGION="${DO_SPACES_REGION}"
SPACES_ENDPOINT="${SPACES_REGION}.digitaloceanspaces.com"
FRONTEND_DIR="./Frontend"
BUILD_DIR="${FRONTEND_DIR}/dist"

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

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if Node.js is installed
    if ! command -v node &> /dev/null; then
        log_error "Node.js is not installed"
        exit 1
    fi
    
    # Check if npm is installed
    if ! command -v npm &> /dev/null; then
        log_error "npm is not installed"
        exit 1
    fi
    
    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        log_warn "AWS CLI not found. Installing..."
        pip install awscli || {
            log_error "Failed to install AWS CLI"
            exit 1
        }
    fi
    
    # Check environment variables
    if [ -z "$DO_SPACES_ACCESS_KEY" ] || [ -z "$DO_SPACES_SECRET_KEY" ]; then
        log_error "DO_SPACES_ACCESS_KEY and DO_SPACES_SECRET_KEY must be set"
        exit 1
    fi
    
    if [ -z "$SPACES_NAME" ] || [ -z "$SPACES_REGION" ]; then
        log_error "DO_SPACES_NAME and DO_SPACES_REGION must be set"
        exit 1
    fi
    
    log_info "All prerequisites met"
}

# Configure AWS CLI for DigitalOcean Spaces
configure_aws_cli() {
    log_info "Configuring AWS CLI for DigitalOcean Spaces..."
    
    mkdir -p ~/.aws
    cat > ~/.aws/credentials << EOF
[default]
aws_access_key_id = ${DO_SPACES_ACCESS_KEY}
aws_secret_access_key = ${DO_SPACES_SECRET_KEY}
EOF
    
    cat > ~/.aws/config << EOF
[default]
region = ${SPACES_REGION}
s3 =
    endpoint_url = https://${SPACES_ENDPOINT}
    signature_version = s3v4
EOF
    
    log_info "AWS CLI configured"
}

# Install dependencies
install_dependencies() {
    log_info "Installing frontend dependencies..."
    cd "$FRONTEND_DIR" || exit 1
    npm ci
    cd - || exit 1
    log_info "Dependencies installed"
}

# Build frontend
build_frontend() {
    log_info "Building frontend for production..."
    cd "$FRONTEND_DIR" || exit 1
    
    # Set production environment variables
    export NODE_ENV=production
    export VUE_APP_API_URL="${VUE_APP_API_URL:-}"
    
    npm run build
    
    if [ ! -d "$BUILD_DIR" ]; then
        log_error "Build failed: dist directory not found"
        exit 1
    fi
    
    cd - || exit 1
    log_info "Frontend built successfully"
}

# Upload to Spaces
upload_to_spaces() {
    log_info "Uploading files to DigitalOcean Spaces..."
    
    # Upload static assets with long cache headers
    log_info "Uploading static assets (JS, CSS, images, fonts)..."
    aws s3 sync "$BUILD_DIR/" "s3://${SPACES_NAME}/" \
        --endpoint-url "https://${SPACES_ENDPOINT}" \
        --delete \
        --acl public-read \
        --cache-control "public, max-age=31536000, immutable" \
        --exclude "*.html" \
        --exclude "*.map" || {
        log_error "Failed to upload static assets"
        exit 1
    }
    
    # Upload HTML files with no-cache headers
    log_info "Uploading HTML files..."
    aws s3 sync "$BUILD_DIR/" "s3://${SPACES_NAME}/" \
        --endpoint-url "https://${SPACES_ENDPOINT}" \
        --delete \
        --acl public-read \
        --cache-control "public, max-age=0, must-revalidate" \
        --content-type "text/html" \
        --include "*.html" || {
        log_error "Failed to upload HTML files"
        exit 1
    }
    
    # Upload source maps with no-cache (optional, for debugging)
    if find "$BUILD_DIR" -name "*.map" | grep -q .; then
        log_info "Uploading source maps..."
        aws s3 sync "$BUILD_DIR/" "s3://${SPACES_NAME}/" \
            --endpoint-url "https://${SPACES_ENDPOINT}" \
            --delete \
            --acl public-read \
            --cache-control "public, max-age=0, must-revalidate" \
            --include "*.map" || {
            log_warn "Failed to upload source maps (non-critical)"
        }
    fi
    
    log_info "Files uploaded successfully"
}

# Set index.html as default
set_index_file() {
    log_info "Setting index.html as default index file..."
    aws s3 cp "$BUILD_DIR/index.html" "s3://${SPACES_NAME}/index.html" \
        --endpoint-url "https://${SPACES_ENDPOINT}" \
        --acl public-read \
        --cache-control "public, max-age=0, must-revalidate" \
        --content-type "text/html" || {
        log_warn "Failed to set index.html (may already be set)"
    }
}

# Invalidate CDN cache (if using CDN)
invalidate_cdn() {
    if [ -n "$DO_SPACES_CDN_ID" ]; then
        log_info "Invalidating CDN cache..."
        # DigitalOcean CDN invalidation would go here
        # This requires doctl CLI or API calls
        log_warn "CDN invalidation not implemented. Please invalidate manually if needed."
    else
        log_info "CDN not configured, skipping cache invalidation"
    fi
}

# Verify deployment
verify_deployment() {
    log_info "Verifying deployment..."
    
    FRONTEND_URL="${DO_SPACES_CDN_URL:-https://${SPACES_NAME}.${SPACES_ENDPOINT}}"
    
    if curl -f -s "$FRONTEND_URL" > /dev/null; then
        log_info "Frontend is accessible at: $FRONTEND_URL"
    else
        log_warn "Could not verify frontend accessibility (may take a few minutes to propagate)"
    fi
}

# Main deployment flow
main() {
    log_info "Starting frontend deployment to DigitalOcean Spaces..."
    log_info "Environment: $ENVIRONMENT"
    log_info "Spaces: $SPACES_NAME ($SPACES_REGION)"
    
    check_prerequisites
    configure_aws_cli
    install_dependencies
    build_frontend
    upload_to_spaces
    set_index_file
    invalidate_cdn
    verify_deployment
    
    log_info "Frontend deployment completed successfully!"
    log_info "Frontend URL: https://${SPACES_NAME}.${SPACES_ENDPOINT}"
}

# Run main function
main

