# Project Structure

This document provides a detailed overview of the project structure and the purpose of each file and directory.

## 📁 Directory Tree

```
DemoToDigitalOcean/
│
├── .github/
│   └── workflows/
│       ├── deploy.yml              # GitHub Actions CI/CD pipeline
│       └── README.md               # Workflow documentation
│
├── Backend/
│   ├── main.py                     # FastAPI application entry point
│   ├── requirements.txt            # Python dependencies
│   ├── Dockerfile                  # Backend Docker image configuration
│   └── .dockerignore              # Files to exclude from Docker build
│
├── Frontend/
│   ├── src/
│   │   ├── App.vue                 # Main Vue.js component
│   │   └── main.js                 # Vue.js application entry point
│   ├── public/                     # Static public assets
│   ├── package.json                # Node.js dependencies and scripts
│   ├── vue.config.js               # Vue CLI configuration
│   ├── babel.config.js             # Babel transpilation configuration
│   ├── Dockerfile                  # Frontend Docker image configuration
│   ├── nginx.conf                  # Nginx config for frontend container
│   └── .dockerignore              # Files to exclude from Docker build
│
├── nginx/
│   └── nginx.conf                  # Nginx config for Droplet reverse proxy
│
├── scripts/
│   ├── deploy-to-droplet.sh        # Manual backend deployment script
│   ├── deploy-to-spaces.sh         # Manual frontend deployment script
│   └── README.md                   # Scripts documentation
│
├── .gitignore                      # Git ignore patterns
├── docker-compose.yml              # Docker Compose for local development
├── docker-compose.prod.yml         # Docker Compose for production
├── README.md                       # Main project documentation
├── QUICK_START.md                  # Quick start guide
├── DEPLOYMENT_SETUP.md             # Detailed deployment instructions
├── DEPLOYMENT.md                   # Original deployment guide (legacy)
└── PROJECT_STRUCTURE.md            # This file
```

## 📄 File Descriptions

### Root Level Files

#### `.gitignore`
- Excludes sensitive files, dependencies, and build artifacts from version control
- Includes patterns for Python, Node.js, IDEs, and environment files

#### `docker-compose.yml`
- Docker Compose configuration for local development
- Defines both frontend and backend services
- Includes health checks and service dependencies

#### `docker-compose.prod.yml`
- Production Docker Compose configuration
- Only includes backend service (frontend served from Spaces)
- Configured for DigitalOcean Droplet deployment

### Backend Directory (`Backend/`)

#### `main.py`
- FastAPI application entry point
- Defines API routes and endpoints
- Includes CORS configuration and health checks
- Well-documented with comments

#### `requirements.txt`
- Python package dependencies
- Includes FastAPI, Uvicorn, and other required packages
- Version-pinned for reproducibility

#### `Dockerfile`
- Multi-stage Docker build configuration
- Creates optimized production image
- Includes security best practices (non-root user)
- Health check configuration

#### `.dockerignore`
- Excludes unnecessary files from Docker build context
- Reduces build time and image size

### Frontend Directory (`Frontend/`)

#### `src/App.vue`
- Main Vue.js component
- Handles API communication
- Includes error handling and loading states

#### `src/main.js`
- Vue.js application entry point
- Initializes and mounts the Vue app

#### `package.json`
- Node.js dependencies and scripts
- Defines build, serve, and lint commands
- Includes Vue.js and development tools

#### `vue.config.js`
- Vue CLI configuration
- Proxy settings for development
- Build optimization settings
- Environment variable configuration

#### `Dockerfile`
- Multi-stage build (Node.js builder + Nginx server)
- Builds Vue.js app and serves with Nginx
- Optimized for production

#### `nginx.conf`
- Nginx configuration for frontend container
- Serves static files and proxies API requests
- Includes compression and caching headers

#### `.dockerignore`
- Excludes node_modules and build artifacts from Docker build

### Nginx Directory (`nginx/`)

#### `nginx.conf`
- Production Nginx configuration for Droplet
- Reverse proxy for backend API
- SSL/TLS configuration
- Security headers and rate limiting
- CORS configuration

### Scripts Directory (`scripts/`)

#### `deploy-to-droplet.sh`
- Bash script for manual backend deployment
- Handles Docker image pulling and container updates
- Includes health checks and rollback capabilities
- Colored output for better readability

#### `deploy-to-spaces.sh`
- Bash script for manual frontend deployment
- Builds Vue.js application
- Uploads to DigitalOcean Spaces with proper cache headers
- Includes CDN invalidation support

### GitHub Actions (`.github/workflows/`)

#### `deploy.yml`
- Complete CI/CD pipeline configuration
- Automated testing, building, and deployment
- Integrates with DigitalOcean services
- Includes health checks and verification

## 🔄 Data Flow

### Development Flow
```
Developer → Git Push → GitHub → GitHub Actions → 
  ├─ Test Backend
  ├─ Test Frontend
  ├─ Build Backend Docker Image
  ├─ Build Frontend
  ├─ Push to Container Registry
  ├─ Deploy Backend to Droplet
  ├─ Deploy Frontend to Spaces
  └─ Health Check
```

### Request Flow (Production)
```
User → Domain/CDN → DigitalOcean Spaces (Frontend)
                ↓
User → Domain → Nginx (Droplet) → Backend Container (Droplet)
```

## 🗂️ Configuration Files

### Environment Variables
- `.env.example` - Template for environment variables (not committed)
- `.env` - Actual environment variables (not committed, created locally)

### Docker Configuration
- `Dockerfile` (Backend) - Backend container image
- `Dockerfile` (Frontend) - Frontend container image
- `docker-compose.yml` - Local development orchestration
- `docker-compose.prod.yml` - Production orchestration

### Web Server Configuration
- `nginx/nginx.conf` - Production Nginx config
- `Frontend/nginx.conf` - Frontend container Nginx config

## 📦 Build Artifacts

### Generated Files (Not in Repository)
- `Frontend/dist/` - Built frontend static files
- `Backend/__pycache__/` - Python bytecode cache
- `node_modules/` - Node.js dependencies
- Docker images (built locally or in CI/CD)

## 🔐 Security Considerations

### Files Never Committed
- `.env` files with secrets
- SSH private keys
- API tokens and credentials
- Database connection strings

### Files with Sensitive Data
- GitHub Secrets (configured in repository settings)
- Droplet `.env` file (created on server)
- Nginx SSL certificates (on server)

## 📝 Documentation Files

- `README.md` - Main project overview
- `QUICK_START.md` - Quick setup guide
- `DEPLOYMENT_SETUP.md` - Detailed deployment instructions
- `PROJECT_STRUCTURE.md` - This file
- `DEPLOYMENT.md` - Legacy deployment guide

## 🎯 Key Directories

### `.github/workflows/`
Contains CI/CD pipeline definitions. Add new workflows here for additional automation.

### `Backend/`
Python FastAPI application. Add new API routes and business logic here.

### `Frontend/`
Vue.js application. Add new components and pages here.

### `scripts/`
Deployment and utility scripts. Add custom scripts here.

### `nginx/`
Nginx configuration files for production server.

## 🔧 Customization Points

### Adding New Features
1. **Backend API**: Add routes in `Backend/main.py`
2. **Frontend Pages**: Add components in `Frontend/src/`
3. **Dependencies**: Update `requirements.txt` or `package.json`
4. **Deployment**: Modify GitHub Actions workflow or scripts

### Environment-Specific Config
- Development: `docker-compose.yml`, `vue.config.js`
- Production: `docker-compose.prod.yml`, `nginx/nginx.conf`

## 📊 File Sizes and Dependencies

### Backend
- Small footprint (~100MB Docker image)
- Minimal dependencies (FastAPI, Uvicorn)

### Frontend
- Build output: ~1-5MB (compressed)
- Dependencies: Vue.js ecosystem

### Infrastructure
- Droplet: 2GB RAM minimum
- Spaces: Pay per storage/bandwidth
- Container Registry: Pay per storage

---

**Last Updated**: See git history for latest changes

