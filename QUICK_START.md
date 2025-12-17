# Quick Start Guide

This guide provides a quick overview of the project and how to get started.

## 🎯 What This Project Does

This project demonstrates a complete CI/CD pipeline that:
- **Tests** your code automatically
- **Builds** Docker images
- **Deploys** backend to DigitalOcean Droplet
- **Deploys** frontend to DigitalOcean Spaces (CDN)

## ⚡ Quick Setup (5 minutes)

### 1. Clone and Install

```bash
git clone <your-repo-url>
cd DemoToDigitalOcean

# Backend
cd Backend && pip install -r requirements.txt && cd ..

# Frontend
cd Frontend && npm install && cd ..
```

### 2. Run Locally

```bash
# Option 1: Using Docker Compose (Recommended)
docker-compose up --build

# Option 2: Run separately
# Terminal 1 - Backend
cd Backend && uvicorn main:app --reload

# Terminal 2 - Frontend
cd Frontend && npm run serve
```

### 3. Access Application

- Frontend: http://localhost:80 (Docker) or http://localhost:8080 (npm)
- Backend API: http://localhost:8000
- API Docs: http://localhost:8000/docs

## 🚀 Deploy to DigitalOcean (15 minutes)

### Step 1: Set Up DigitalOcean Resources

1. **Create Container Registry**
   - Go to Container Registry → Create
   - Note the registry name

2. **Create Spaces**
   - Go to Spaces → Create
   - Note the name and region

3. **Create Droplet**
   - Ubuntu 22.04, 2GB RAM minimum
   - Note the IP address

### Step 2: Configure GitHub Secrets

Go to your GitHub repo → Settings → Secrets → Actions → New secret

Add these secrets:
```
DO_REGISTRY_TOKEN=your-do-api-token
DO_REGISTRY_NAME=your-registry-name
DO_SPACES_NAME=your-spaces-name
DO_SPACES_REGION=nyc3
DO_SPACES_ACCESS_KEY=your-access-key
DO_SPACES_SECRET_KEY=your-secret-key
DROPLET_HOST=your-droplet-ip
DROPLET_USER=root
DROPLET_SSH_KEY=your-ssh-private-key
VUE_APP_API_URL=https://api.yourdomain.com
BACKEND_URL=https://api.yourdomain.com
FRONTEND_URL=https://yourdomain.com
```

### Step 3: Set Up Droplet

SSH into your droplet and run:

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install Nginx
apt update && apt install nginx -y

# Create app directory
mkdir -p /opt/app
cd /opt/app
```

### Step 4: Configure Nginx

1. Copy `nginx/nginx.conf` to `/etc/nginx/sites-available/your-app`
2. Update domain names in the config
3. Enable site: `ln -s /etc/nginx/sites-available/your-app /etc/nginx/sites-enabled/`
4. Test: `nginx -t`
5. Reload: `systemctl reload nginx`

### Step 5: Set Up SSL (Optional but Recommended)

```bash
apt install certbot python3-certbot-nginx -y
certbot --nginx -d api.yourdomain.com
```

### Step 6: Deploy!

Just push to `main` branch - GitHub Actions will handle everything!

```bash
git add .
git commit -m "Initial deployment setup"
git push origin main
```

## 📋 Checklist

Before deploying, make sure you have:

- [ ] DigitalOcean account
- [ ] Container Registry created
- [ ] Spaces created
- [ ] Droplet created
- [ ] GitHub Secrets configured
- [ ] Droplet set up (Docker, Nginx)
- [ ] Domain configured (optional)
- [ ] SSL certificate (optional)

## 🔍 Verify Deployment

### Check Backend

```bash
# On droplet
docker ps
curl http://localhost:8000/api/hello

# From anywhere
curl https://api.yourdomain.com/api/hello
```

### Check Frontend

Visit your Spaces URL or custom domain in a browser.

### Check GitHub Actions

Go to your GitHub repo → Actions tab to see deployment status.

## 🆘 Common Issues

**502 Bad Gateway**
- Check if backend container is running: `docker ps`
- Check Nginx logs: `tail -f /var/log/nginx/error.log`

**Deployment fails**
- Check GitHub Actions logs
- Verify all secrets are set correctly
- Check droplet SSH access

**Frontend not loading**
- Verify Spaces files uploaded
- Check CDN configuration
- Verify CORS settings

## 📚 More Information

- **Detailed Setup**: See [DEPLOYMENT_SETUP.md](./DEPLOYMENT_SETUP.md)
- **Project Structure**: See [README.md](./README.md)
- **Scripts**: See [scripts/README.md](./scripts/README.md)

## 🎓 Learning Resources

- [DigitalOcean Documentation](https://docs.digitalocean.com/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Documentation](https://docs.docker.com/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Vue.js Documentation](https://vuejs.org/)

---

**Need help?** Check the detailed guides or open an issue!

