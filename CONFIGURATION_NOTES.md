# Configuration Notes

This document contains specific configuration details for your deployment.

## Frontend URL

Your frontend is deployed at:
- **Full URL**: https://sethupocjd.tech00000.online/index.html
- **Base URL**: https://sethupocjd.tech00000.online

## GitHub Secrets Configuration

Make sure to set the following secrets in your GitHub repository:

### Required Secrets

1. **FRONTEND_URL**: `https://sethupocjd.tech00000.online`
   - Used for health checks and CORS configuration
   - Use base URL (without /index.html)

2. **BACKEND_URL**: Your backend API URL
   - Example: `https://api.sethupocjd.tech00000.online` or your backend domain
   - Used for health checks
   - **IMPORTANT**: This should be the full URL to your backend API server (Droplet)

3. **VUE_APP_API_URL**: Your backend API URL (REQUIRED)
   - **MUST be set** to your backend API server URL
   - Example: `https://api.sethupocjd.tech00000.online` or `http://YOUR_DROPLET_IP:8000`
   - Should match BACKEND_URL
   - Used during frontend build to configure API endpoints
   - **If not set, frontend will try to call `/api/hello` on Spaces domain, which will fail with 403**

## CORS Configuration

The backend CORS configuration has been updated to allow requests from:
- `https://sethupocjd.tech00000.online`
- Any URL set in `FRONTEND_URL` environment variable
- Any URL set in `SPACES_CDN_URL` environment variable

## Health Check URLs

- **Frontend Health Check**: https://sethupocjd.tech00000.online
- **Backend Health Check**: Your BACKEND_URL + `/api/hello` or `/health`

## Notes

- The frontend URL includes `/index.html` in the full path, but health checks use the base URL
- CORS is configured to accept requests from your frontend domain
- Make sure your backend API URL is correctly configured in GitHub Secrets

