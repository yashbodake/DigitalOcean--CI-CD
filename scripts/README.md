# Deployment Scripts

This directory contains deployment scripts for manual deployment to DigitalOcean infrastructure.

## Scripts

### `deploy-to-droplet.sh`

Deploys the backend application to a DigitalOcean Droplet.

**Usage:**
```bash
./scripts/deploy-to-droplet.sh [environment]
```

**Prerequisites:**
- Docker and Docker Compose installed on the droplet
- DigitalOcean Container Registry credentials configured
- SSH access to the droplet
- Environment variables set (see script for details)

**What it does:**
1. Logs in to DigitalOcean Container Registry
2. Pulls the latest backend Docker image
3. Creates a backup of the current deployment
4. Stops the current container
5. Starts the new container
6. Performs health checks
7. Cleans up old images

### `deploy-to-spaces.sh`

Builds the frontend and deploys static files to DigitalOcean Spaces.

**Usage:**
```bash
./scripts/deploy-to-spaces.sh [environment]
```

**Prerequisites:**
- Node.js and npm installed
- AWS CLI installed (for Spaces API)
- DigitalOcean Spaces credentials configured
- Environment variables set (see script for details)

**What it does:**
1. Checks prerequisites
2. Configures AWS CLI for DigitalOcean Spaces
3. Installs frontend dependencies
4. Builds the Vue.js application
5. Uploads files to Spaces with proper cache headers
6. Verifies deployment

## Environment Variables

Both scripts require environment variables to be set. See `.env.example` for reference.

### For Droplet Deployment

```bash
export DO_REGISTRY=registry.digitalocean.com
export DO_REGISTRY_NAME=your-registry-name
export DO_REGISTRY_TOKEN=your-token
export DROPLET_APP_PATH=/opt/app
```

### For Spaces Deployment

```bash
export DO_SPACES_NAME=your-spaces-name
export DO_SPACES_REGION=nyc3
export DO_SPACES_ACCESS_KEY=your-access-key
export DO_SPACES_SECRET_KEY=your-secret-key
export VUE_APP_API_URL=https://api.yourdomain.com
```

## Making Scripts Executable

If scripts are not executable, run:

```bash
chmod +x scripts/*.sh
```

## Troubleshooting

### Permission Denied

```bash
chmod +x scripts/deploy-to-droplet.sh
chmod +x scripts/deploy-to-spaces.sh
```

### Script Not Found

Make sure you're running from the project root:
```bash
./scripts/deploy-to-droplet.sh
```

Not:
```bash
cd scripts
./deploy-to-droplet.sh
```

### Environment Variables Not Set

Check that all required environment variables are set:
```bash
echo $DO_REGISTRY_TOKEN
echo $DO_SPACES_ACCESS_KEY
```

## Notes

- Scripts use `set -e` to exit on any error
- Scripts include colored output for better readability
- Scripts include health checks and rollback capabilities
- All scripts are idempotent (safe to run multiple times)

