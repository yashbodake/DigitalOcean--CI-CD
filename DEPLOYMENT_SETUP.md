# Deployment Setup Guide - DigitalOcean CI/CD

This guide provides step-by-step instructions for setting up CI/CD and deploying your application to DigitalOcean.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [DigitalOcean Setup](#digitalocean-setup)
3. [GitHub Secrets Configuration](#github-secrets-configuration)
4. [Droplet Setup](#droplet-setup)
5. [Initial Deployment](#initial-deployment)
6. [Verification](#verification)
7. [Troubleshooting](#troubleshooting)

## Prerequisites

- GitHub account with repository access
- DigitalOcean account
- Domain name (optional but recommended)
- Basic knowledge of Docker, Nginx, and Linux

## DigitalOcean Setup

### 1. Create DigitalOcean Container Registry

1. Log in to [DigitalOcean Control Panel](https://cloud.digitalocean.com/)
2. Navigate to **Container Registry** → **Create Registry**
3. Choose a registry name (e.g., `my-app-registry`)
4. Select a region closest to your users
5. Note down your registry name for later use

### 2. Create DigitalOcean Spaces

1. Navigate to **Spaces** → **Create a Space**
2. Choose a unique name (e.g., `my-app-frontend`)
3. Select the same region as your registry
4. Choose **File Listing: Restricted** (for security)
5. Click **Create a Space**

### 3. Generate Spaces Access Keys

1. Navigate to **API** → **Spaces Keys**
2. Click **Generate New Key**
3. Give it a name (e.g., `spaces-deployment-key`)
4. **Save both Access Key and Secret Key** - you won't see the secret again!

### 4. Create DigitalOcean Droplet

1. Navigate to **Droplets** → **Create Droplet**
2. Choose:
   - **Image**: Ubuntu 22.04 LTS
   - **Plan**: Basic (2GB RAM minimum recommended)
   - **Region**: Same as registry and spaces
   - **Authentication**: SSH keys (recommended) or root password
3. Click **Create Droplet**
4. Note the IP address

## GitHub Secrets Configuration

Add the following secrets to your GitHub repository:

1. Go to your repository → **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret** for each:

### Container Registry Secrets
- `DO_REGISTRY_TOKEN`: Your DigitalOcean API token (Settings → API → Generate New Token)
- `DO_REGISTRY_NAME`: Your registry name (e.g., `my-app-registry`)

### Spaces Secrets
- `DO_SPACES_NAME`: Your Spaces name (e.g., `my-app-frontend`)
- `DO_SPACES_REGION`: Your Spaces region (e.g., `nyc3`)
- `DO_SPACES_ACCESS_KEY`: Spaces access key
- `DO_SPACES_SECRET_KEY`: Spaces secret key
- `DO_SPACES_CDN_ID`: (Optional) CDN endpoint ID if using CDN
- `DO_SPACES_CDN_URL`: (Optional) CDN URL (e.g., `https://cdn.yourdomain.com`)

### Droplet Secrets
- `DROPLET_HOST`: Your droplet IP address or domain
- `DROPLET_USER`: SSH user (usually `root`)
- `DROPLET_SSH_KEY`: Your private SSH key (the entire key, including `-----BEGIN` and `-----END` lines)
- `DROPLET_SSH_PORT`: SSH port (usually `22`)
- `DROPLET_APP_PATH`: Path on droplet (e.g., `/opt/app`)

### Application URLs
- `VUE_APP_API_URL`: Backend API URL (e.g., `https://api.yourdomain.com`)
- `BACKEND_URL`: Backend URL for health checks (e.g., `https://api.yourdomain.com`)
- `FRONTEND_URL`: Frontend URL (e.g., `https://yourdomain.com`)

## Droplet Setup

### 1. Initial Server Setup

SSH into your droplet:
```bash
ssh root@your-droplet-ip
```

### 2. Update System

```bash
apt update && apt upgrade -y
```

### 3. Install Docker

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Start and enable Docker
systemctl start docker
systemctl enable docker

# Add current user to docker group (if not root)
usermod -aG docker $USER
```

### 4. Install Docker Compose

```bash
# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Verify installation
docker-compose --version
```

### 5. Install Nginx

```bash
apt install nginx -y
systemctl start nginx
systemctl enable nginx
```

### 6. Configure Nginx

1. Copy the Nginx configuration:
```bash
mkdir -p /etc/nginx/sites-available
nano /etc/nginx/sites-available/your-app
```

2. Copy contents from `nginx/nginx.conf` and update:
   - Replace `api.yourdomain.com` with your domain
   - Update any other domain references

3. Enable the site:
```bash
ln -s /etc/nginx/sites-available/your-app /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default  # Remove default site
nginx -t  # Test configuration
systemctl reload nginx
```

### 7. Set Up SSL with Let's Encrypt

```bash
# Install Certbot
apt install certbot python3-certbot-nginx -y

# Obtain SSL certificate
certbot --nginx -d api.yourdomain.com

# Auto-renewal is set up automatically
```

### 8. Create Application Directory

```bash
mkdir -p /opt/app
cd /opt/app
```

### 9. Set Up Docker Compose for Production

```bash
# Copy docker-compose.prod.yml to droplet
# You can do this via SCP or by cloning your repo
nano docker-compose.prod.yml
```

Paste the contents of `docker-compose.prod.yml` and update environment variables.

### 10. Configure Environment Variables

Create a `.env` file on the droplet:
```bash
nano /opt/app/.env
```

Add:
```bash
DO_REGISTRY=registry.digitalocean.com
DO_REGISTRY_NAME=your-registry-name
DO_REGISTRY_TOKEN=your-registry-token
ENVIRONMENT=production
```

### 11. Log in to Container Registry

```bash
echo "your-registry-token" | docker login registry.digitalocean.com -u "your-registry-token" --password-stdin
```

### 12. Set Up Deployment Script (Optional)

```bash
# Copy deployment script to droplet
mkdir -p /opt/app/scripts
# Copy deploy-to-droplet.sh to /opt/app/scripts/
chmod +x /opt/app/scripts/deploy-to-droplet.sh
```

## Initial Deployment

### Option 1: Manual Deployment

1. **Build and push backend image:**
```bash
# On your local machine or CI/CD
cd Backend
docker build -t registry.digitalocean.com/your-registry/backend:latest .
docker push registry.digitalocean.com/your-registry/backend:latest
```

2. **Deploy on droplet:**
```bash
# SSH into droplet
ssh root@your-droplet-ip
cd /opt/app

# Pull and start container
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d
```

3. **Deploy frontend to Spaces:**
```bash
# On your local machine
./scripts/deploy-to-spaces.sh
```

### Option 2: Automated Deployment via GitHub Actions

1. Push your code to the `main` branch
2. GitHub Actions will automatically:
   - Test the code
   - Build Docker images
   - Push to Container Registry
   - Deploy backend to Droplet
   - Deploy frontend to Spaces

## Verification

### Check Backend

```bash
# On droplet
docker-compose -f docker-compose.prod.yml ps
docker-compose -f docker-compose.prod.yml logs backend

# Test API
curl http://localhost:8000/api/hello
curl https://api.yourdomain.com/api/hello
```

### Check Frontend

1. Visit your Spaces URL: `https://your-spaces-name.region.digitaloceanspaces.com`
2. Or visit your custom domain if configured
3. Check browser console for errors

### Check Nginx

```bash
# Check Nginx status
systemctl status nginx

# Check Nginx logs
tail -f /var/log/nginx/api-access.log
tail -f /var/log/nginx/api-error.log

# Test Nginx configuration
nginx -t
```

## Troubleshooting

### Backend Issues

**Container won't start:**
```bash
# Check logs
docker-compose -f docker-compose.prod.yml logs backend

# Check container status
docker ps -a

# Restart container
docker-compose -f docker-compose.prod.yml restart backend
```

**Can't connect to registry:**
```bash
# Re-login to registry
echo "your-token" | docker login registry.digitalocean.com -u "your-token" --password-stdin
```

### Frontend Issues

**Files not uploading to Spaces:**
- Verify Spaces credentials in GitHub Secrets
- Check AWS CLI configuration
- Verify Spaces name and region

**CORS errors:**
- Update CORS settings in `Backend/main.py`
- Check Nginx CORS headers

### Nginx Issues

**502 Bad Gateway:**
- Check if backend container is running: `docker ps`
- Verify backend is listening on port 8000
- Check Nginx upstream configuration

**SSL certificate issues:**
```bash
# Renew certificate
certbot renew

# Check certificate status
certbot certificates
```

### General Issues

**Check system resources:**
```bash
# Disk space
df -h

# Memory
free -h

# Docker resources
docker system df
```

**View all logs:**
```bash
# Docker logs
docker-compose -f docker-compose.prod.yml logs

# Nginx logs
tail -f /var/log/nginx/*.log

# System logs
journalctl -u docker
journalctl -u nginx
```

## Maintenance

### Update Application

Simply push to the `main` branch - CI/CD will handle the rest!

### Manual Update

```bash
# On droplet
cd /opt/app
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d
docker image prune -f  # Clean up old images
```

### Backup

```bash
# Backup docker-compose and .env files
tar -czf backup-$(date +%Y%m%d).tar.gz docker-compose.prod.yml .env
```

## Security Best Practices

1. **Use SSH keys** instead of passwords
2. **Keep system updated**: `apt update && apt upgrade`
3. **Use firewall**: Configure UFW or similar
4. **Regular backups**: Set up automated backups
5. **Monitor logs**: Set up log monitoring
6. **Use secrets**: Never commit secrets to Git
7. **SSL/TLS**: Always use HTTPS in production
8. **Non-root user**: Run containers as non-root when possible

## Next Steps

- Set up monitoring (e.g., DigitalOcean Monitoring)
- Configure automated backups
- Set up log aggregation
- Implement database backups (if using database)
- Set up staging environment
- Configure custom domain for Spaces CDN

