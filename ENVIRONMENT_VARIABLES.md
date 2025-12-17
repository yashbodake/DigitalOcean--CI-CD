# Environment Variables Reference

This document lists all environment variables and secrets required for the CI/CD pipeline and deployment.

## GitHub Secrets (Required)

These must be configured in your GitHub repository under **Settings → Secrets and variables → Actions**.

### DigitalOcean Container Registry
- `DO_REGISTRY_TOKEN` - DigitalOcean API token with registry access
- `DO_REGISTRY_NAME` - Your Container Registry name (e.g., `my-registry`)

### DigitalOcean Spaces
- `DO_SPACES_NAME` - Your Spaces bucket name (e.g., `my-frontend`)
- `DO_SPACES_REGION` - Spaces region (e.g., `nyc3`, `sfo3`, `ams3`)
- `DO_SPACES_ACCESS_KEY` - Spaces access key ID
- `DO_SPACES_SECRET_KEY` - Spaces secret access key
- `DO_SPACES_CDN_ID` - (Optional) CDN endpoint ID if using CDN
- `DO_SPACES_CDN_URL` - (Optional) CDN URL (e.g., `https://cdn.yourdomain.com`)

### DigitalOcean Droplet
- `DROPLET_HOST` - Droplet IP address or domain name
- `DROPLET_USER` - SSH username (usually `root`)
- `DROPLET_SSH_KEY` - SSH private key (entire key including `-----BEGIN` and `-----END`)
- `DROPLET_SSH_PORT` - (Optional) SSH port, defaults to `22` if not set
- `DROPLET_APP_PATH` - (Optional) Application path on droplet, defaults to `/opt/app` if not set

### Application URLs
- `VUE_APP_API_URL` - Backend API URL for frontend build (e.g., `https://api.yourdomain.com`)
- `BACKEND_URL` - Backend URL for health checks (e.g., `https://api.yourdomain.com`)
- `FRONTEND_URL` - Frontend URL for health checks (e.g., `https://yourdomain.com`)

## Droplet Environment Variables

Create a `.env` file on your Droplet at `/opt/app/.env`:

```bash
# Container Registry
DO_REGISTRY=registry.digitalocean.com
DO_REGISTRY_NAME=your-registry-name
DO_REGISTRY_TOKEN=your-registry-token

# Application Environment
ENVIRONMENT=production

# Optional: Application-specific variables
# DATABASE_URL=postgresql://user:password@host:port/database
# SECRET_KEY=your-secret-key-here
# FRONTEND_URL=https://yourdomain.com
# SPACES_CDN_URL=https://cdn.yourdomain.com
```

## Local Development Environment Variables

Create a `.env` file in the project root (not committed to Git):

```bash
# Backend
ENVIRONMENT=development
DATABASE_URL=postgresql://localhost:5432/mydb
SECRET_KEY=dev-secret-key

# Frontend
VUE_APP_API_URL=http://localhost:8000
```

## Environment Variable Usage

### In GitHub Actions Workflow
All secrets are accessed using `${{ secrets.SECRET_NAME }}` syntax.

### In Docker Compose
Environment variables can be:
1. Set directly in `docker-compose.prod.yml`
2. Loaded from `.env` file using `env_file`
3. Passed from host environment

### In Application Code
- **Backend (Python)**: Use `os.getenv('VARIABLE_NAME', 'default_value')`
- **Frontend (Vue.js)**: Use `process.env.VUE_APP_VARIABLE_NAME` (must be prefixed with `VUE_APP_`)

## Security Best Practices

1. **Never commit secrets** to version control
2. **Use GitHub Secrets** for sensitive data in CI/CD
3. **Use .env files** for local development (add to .gitignore)
4. **Rotate secrets regularly** especially if exposed
5. **Use least privilege** - only grant necessary permissions
6. **Monitor secret usage** in GitHub Actions logs

## Verification Checklist

Before deploying, verify all required secrets are set:

- [ ] `DO_REGISTRY_TOKEN` - Container Registry access
- [ ] `DO_REGISTRY_NAME` - Registry name
- [ ] `DO_SPACES_NAME` - Spaces bucket name
- [ ] `DO_SPACES_REGION` - Spaces region
- [ ] `DO_SPACES_ACCESS_KEY` - Spaces access key
- [ ] `DO_SPACES_SECRET_KEY` - Spaces secret key
- [ ] `DROPLET_HOST` - Droplet IP/domain
- [ ] `DROPLET_USER` - SSH user
- [ ] `DROPLET_SSH_KEY` - SSH private key
- [ ] `VUE_APP_API_URL` - Backend API URL
- [ ] `BACKEND_URL` - Backend health check URL
- [ ] `FRONTEND_URL` - Frontend health check URL

## Troubleshooting

### Secret Not Found
- Verify secret name matches exactly (case-sensitive)
- Check if secret is set in correct repository
- Ensure secret is available to the workflow

### Environment Variable Not Working
- Check variable name spelling
- Verify variable is exported/available in context
- Check if variable needs `VUE_APP_` prefix for frontend

### SSH Connection Failed
- Verify `DROPLET_SSH_KEY` includes full key with headers
- Check `DROPLET_HOST` and `DROPLET_USER` are correct
- Ensure SSH port is correct (default: 22)
- Verify firewall allows SSH connections

