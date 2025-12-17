# DigitalOcean Deployment Guide

This guide outlines how to deploy your Vue.js + FastAPI application on DigitalOcean.

## Local Development Setup

Before deploying, test your application locally:

### Running with Docker Compose
```bash
# From the project root directory
docker-compose up --build
```

Access the frontend at `http://localhost` and the backend API docs at `http://localhost:8000/docs`

### Running without Docker (Development)
Backend:
```bash
cd Backend
pip install -r requirements.txt
uvicorn main:app --reload
```

Frontend:
```bash
cd Frontend
npm install
npm run serve
```

Access the frontend at `http://localhost:8080` (with automatic proxy to backend)

## Prerequisites for Deployment

1. DigitalOcean account
2. Dockerized application (already done with the provided Dockerfiles)
3. Git repository (to host your code)

## Option 1: Deploy on DigitalOcean App Platform (Recommended)

### Step 1: Prepare Your Repository

1. Initialize a Git repository in your project:
```bash
git init
git add .
git commit -m "Initial commit: Vue.js + FastAPI application"
```

2. Create a GitHub/GitLab/Bitbucket repository and push your code:
```bash
git remote add origin https://github.com/yourusername/your-repo-name.git
git branch -M main
git push -u origin main
```

### Step 2: Deploy on App Platform

1. Log in to your [DigitalOcean Control Panel](https://cloud.digitalocean.com/)
2. Navigate to "Apps" → "Create App"
3. Select your Git provider and authorize access
4. Select the repository you created
5. Choose your branch (typically "main" or "master")
6. Configure the app:
   - Set the app name
   - Select a region closest to your users
   - For Static Site/Client (Frontend):
     - Build Command: `npm install && npm run build`
     - Run Command: `nginx -g "daemon off;"` (This won't work directly for frontend - see below)
   - For Service (Backend):
     - Build Command: `pip install -r requirements.txt`
     - Run Command: `uvicorn main:app --host 0.0.0.0 --port $PORT`

### Step 3: Better Approach for Full-Stack App

Since the App Platform approach might be challenging for a full-stack application, it's better to use a container registry and droplet:

## Option 2: Deploy with Container Registry + Droplets

### Step 1: Create a Docker Image for Your App

1. Build and tag your containers locally:
```bash
# Build the frontend
cd Frontend
docker build -t your-digitalocean-registry/frontend:latest .

# Build the backend  
cd ../Backend
docker build -t your-digitalocean-registry/backend:latest .
```

2. Push to DigitalOcean Container Registry:
```bash
# Login to DigitalOcean Container Registry
doctl registry login

# Tag and push your images
docker tag your-registry-name/frontend:latest registry.digitalocean.com/your-registry-name/frontend:latest
docker tag your-registry-name/backend:latest registry.digitalocean.com/your-registry-name/backend:latest

docker push registry.digitalocean.com/your-registry-name/frontend:latest
docker push registry.digitalocean.com/your-registry-name/backend:latest
```

### Step 2: Create a Droplet

1. Create a new Ubuntu Droplet (2GB RAM minimum recommended)
2. SSH into the droplet
3. Install Docker and Docker Compose:
```bash
# Update packages
sudo apt update

# Install Docker
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add your user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

### Step 3: Deploy Your Application

1. Clone your repository or copy the docker-compose.yml file to your droplet
2. Pull the images from the container registry:
```bash
docker pull registry.digitalocean.com/your-registry-name/frontend:latest
docker pull registry.digitalocean.com/your-registry-name/backend:latest
```

3. Update your docker-compose.yml to use the registry images:
```yaml
version: '3.8'

services:
  backend:
    image: registry.digitalocean.com/your-registry-name/backend:latest
    ports:
      - "8000:8000"
    restart: unless-stopped

  frontend:
    image: registry.digitalocean.com/your-registry-name/frontend:latest
    ports:
      - "80:80"
    depends_on:
      - backend
    restart: unless-stopped
```

4. Run your application:
```bash
docker-compose up -d
```

## Option 3: Using DigitalOcean App Platform with Separate Services

If you want to stick with App Platform, you can deploy the frontend and backend as separate services:

### Backend Component Configuration:
- Type: Service
- GitHub repo: your-repo
- Branch: main
- Run command: `uvicorn main:app --host 0.0.0.0 --port $PORT`
- Environment: Python
- HTTP Port: `$PORT`

### Frontend Component Configuration:
- Type: Static Site (if built separately) or Service
- Build command: `npm install && npm run build`
- Run command: `npx serve -s dist` (for Vue builds)
- Environment: Node.js
- HTTP Port: `$PORT`

### Custom Domains:
- After deployment, configure custom domains in the App Platform dashboard
- Point your domain's DNS records to DigitalOcean's assigned IP address

## Domain Setup and SSL Certificates

DigitalOcean automatically manages SSL certificates for domains connected to your apps.

1. Go to Networking → Domains in your DigitalOcean panel
2. Add your domain
3. Set up DNS records as directed by DigitalOcean
4. Configure your domain in the App Platform settings

## Monitoring and Scaling

1. DigitalOcean Apps Platform provides built-in monitoring
2. Automatically scale based on traffic needs
3. Logs are accessible through the control panel

## Troubleshooting

- Check application logs in the DigitalOcean control panel
- Ensure your backend service is listening on the port specified by the `$PORT` environment variable
- For CORS issues, make sure your frontend allows requests to the backend domain
- Verify that your Docker images build correctly before pushing to the registry

## Cost Estimation

- App Platform: Starts at $5/month for basic apps
- Container Registry: $5/month for up to 500GiB
- Droplets: Start at $4/month for basic plans

Choose the option that best fits your needs in terms of complexity, scalability, and cost.