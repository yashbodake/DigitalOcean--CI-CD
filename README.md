# DemoToDigitalOcean - CI/CD Deployment Project

A professional full-stack application demonstrating CI/CD pipeline and deployment to DigitalOcean infrastructure.

## 🏗️ Architecture

- **Frontend**: Vue.js 3 application deployed to DigitalOcean Spaces (CDN)
- **Backend**: FastAPI application containerized with Docker and deployed to DigitalOcean Droplet
- **CI/CD**: GitHub Actions for automated testing, building, and deployment
- **Infrastructure**: 
  - DigitalOcean Spaces for static file hosting
  - DigitalOcean Droplet with Docker for backend API
  - Nginx reverse proxy on Droplet
  - DigitalOcean Container Registry for Docker images

## 📁 Project Structure

```
DemoToDigitalOcean/
├── .github/
│   └── workflows/
│       └── deploy.yml              # CI/CD pipeline configuration
├── Backend/
│   ├── main.py                     # FastAPI application
│   ├── requirements.txt            # Python dependencies
│   ├── Dockerfile                  # Backend Docker configuration
│   └── .dockerignore              # Docker ignore patterns
├── Frontend/
│   ├── src/                        # Vue.js source files
│   ├── public/                     # Public assets
│   ├── package.json                # Node.js dependencies
│   ├── vue.config.js               # Vue.js configuration
│   ├── Dockerfile                  # Frontend Docker configuration
│   ├── nginx.conf                  # Nginx config for frontend container
│   └── .dockerignore              # Docker ignore patterns
├── nginx/
│   └── nginx.conf                  # Nginx config for Droplet reverse proxy
├── scripts/
│   ├── deploy-to-droplet.sh        # Manual deployment script for backend
│   └── deploy-to-spaces.sh         # Manual deployment script for frontend
├── docker-compose.yml              # Docker Compose for local development
├── docker-compose.prod.yml         # Docker Compose for production
├── .gitignore                      # Git ignore patterns
├── README.md                       # This file
└── DEPLOYMENT_SETUP.md             # Detailed deployment guide
```

## 🚀 Quick Start

### Prerequisites

- Node.js 18+ and npm
- Python 3.11+
- Docker and Docker Compose
- DigitalOcean account (for deployment)

### Local Development

1. **Clone the repository:**
```bash
git clone https://github.com/yourusername/DemoToDigitalOcean.git
cd DemoToDigitalOcean
```

2. **Backend Setup:**
```bash
cd Backend
pip install -r requirements.txt
uvicorn main:app --reload
```

3. **Frontend Setup:**
```bash
cd Frontend
npm install
npm run serve
```

4. **Using Docker Compose:**
```bash
docker-compose up --build
```

Access:
- Frontend: http://localhost:80
- Backend API: http://localhost:8000
- API Docs: http://localhost:8000/docs

## 🔄 CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/deploy.yml`) automates:

1. **Testing**: Runs tests for both frontend and backend
2. **Building**: Builds Docker images for backend
3. **Pushing**: Pushes images to DigitalOcean Container Registry
4. **Deploying Backend**: Deploys to DigitalOcean Droplet via SSH
5. **Deploying Frontend**: Builds and uploads static files to DigitalOcean Spaces
6. **Health Checks**: Verifies deployment success

### Workflow Triggers

- Push to `main` or `master` branch
- Pull requests (testing only, no deployment)
- Manual trigger via GitHub Actions UI

## 📦 Deployment

### Automated Deployment

1. Configure GitHub Secrets (see [DEPLOYMENT_SETUP.md](./DEPLOYMENT_SETUP.md))
2. Push to `main` branch
3. GitHub Actions handles the rest!

### Manual Deployment

See [DEPLOYMENT_SETUP.md](./DEPLOYMENT_SETUP.md) for detailed instructions.

**Quick manual deployment:**

```bash
# Deploy backend to Droplet
./scripts/deploy-to-droplet.sh

# Deploy frontend to Spaces
./scripts/deploy-to-spaces.sh
```

## 🔧 Configuration

### Environment Variables

Create a `.env` file based on `.env.example`:

```bash
# DigitalOcean Container Registry
DO_REGISTRY=registry.digitalocean.com
DO_REGISTRY_NAME=your-registry-name
DO_REGISTRY_TOKEN=your-token

# DigitalOcean Spaces
DO_SPACES_NAME=your-spaces-name
DO_SPACES_REGION=nyc3
DO_SPACES_ACCESS_KEY=your-access-key
DO_SPACES_SECRET_KEY=your-secret-key

# Application URLs
VUE_APP_API_URL=https://api.yourdomain.com
BACKEND_URL=https://api.yourdomain.com
FRONTEND_URL=https://yourdomain.com
```

### GitHub Secrets

Required secrets for CI/CD:

- `DO_REGISTRY_TOKEN` - DigitalOcean API token
- `DO_REGISTRY_NAME` - Container registry name
- `DO_SPACES_NAME` - Spaces name
- `DO_SPACES_REGION` - Spaces region
- `DO_SPACES_ACCESS_KEY` - Spaces access key
- `DO_SPACES_SECRET_KEY` - Spaces secret key
- `DROPLET_HOST` - Droplet IP or domain
- `DROPLET_USER` - SSH user
- `DROPLET_SSH_KEY` - SSH private key
- `VUE_APP_API_URL` - Backend API URL
- `BACKEND_URL` - Backend URL for health checks
- `FRONTEND_URL` - Frontend URL

## 📚 API Documentation

Once deployed, access API documentation at:
- Swagger UI: `https://api.yourdomain.com/docs`
- ReDoc: `https://api.yourdomain.com/redoc`

### Available Endpoints

- `GET /api/hello` - Hello world endpoint
- `GET /health` - Health check endpoint
- `GET /` - API information

## 🛠️ Development

### Adding New Features

1. Create a feature branch
2. Make your changes
3. Test locally
4. Push and create a pull request
5. After merge, CI/CD will deploy automatically

### Project Standards

- **Backend**: Follow PEP 8 Python style guide
- **Frontend**: Follow Vue.js style guide
- **Commits**: Use conventional commit messages
- **Documentation**: Update README and code comments

## 🔒 Security

- Never commit secrets or `.env` files
- Use environment variables for sensitive data
- Keep dependencies updated
- Use HTTPS in production
- Implement proper authentication/authorization
- Regular security audits

## 📊 Monitoring

### Health Checks

- Backend: `https://api.yourdomain.com/health`
- Frontend: Check Spaces/CDN availability

### Logs

**Backend logs:**
```bash
# On Droplet
docker-compose -f docker-compose.prod.yml logs -f backend
```

**Nginx logs:**
```bash
# On Droplet
tail -f /var/log/nginx/api-access.log
tail -f /var/log/nginx/api-error.log
```

## 🐛 Troubleshooting

See [DEPLOYMENT_SETUP.md](./DEPLOYMENT_SETUP.md) for detailed troubleshooting guide.

Common issues:
- **502 Bad Gateway**: Check if backend container is running
- **CORS errors**: Verify CORS configuration in backend
- **Deployment fails**: Check GitHub Actions logs and secrets

## 📝 License

This project is a proof of concept demonstration.

## 🤝 Contributing

This is a POC project, but contributions are welcome!

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📞 Support

For issues and questions:
- Check [DEPLOYMENT_SETUP.md](./DEPLOYMENT_SETUP.md)
- Review GitHub Actions logs
- Check DigitalOcean documentation

## 🎯 Future Enhancements

- [ ] Database integration
- [ ] Authentication/Authorization
- [ ] Automated testing
- [ ] Monitoring and alerting
- [ ] Staging environment
- [ ] Blue-green deployments
- [ ] Database migrations
- [ ] API rate limiting
- [ ] Caching layer

---

**Built with ❤️ for DigitalOcean deployment demonstration**
