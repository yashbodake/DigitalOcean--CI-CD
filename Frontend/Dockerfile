# =============================================================================
# Frontend Dockerfile - Vue.js Application
# =============================================================================
# This Dockerfile uses a multi-stage build:
# Stage 1: Build the Vue.js application
# Stage 2: Serve the built static files with Nginx
# This approach results in a smaller final image
# =============================================================================

# =============================================================================
# Stage 1: Build Stage
# =============================================================================
# Use Node.js 18 Alpine image (lightweight, includes npm)
FROM node:18-alpine AS builder

# Set working directory inside container
WORKDIR /app

# Copy package files first (for better Docker layer caching)
# This allows Docker to cache the npm install step if dependencies don't change
COPY package*.json ./

# Install dependencies
# Using npm ci for faster, reliable, reproducible builds
# This installs exactly what's in package-lock.json
RUN npm ci --only=production=false

# Copy the rest of the application source code
COPY . .

# Build the Vue.js application for production
# This creates optimized, minified static files in the dist/ directory
# Environment variables can be set here for build-time configuration
ARG VUE_APP_API_URL
ENV VUE_APP_API_URL=${VUE_APP_API_URL}
RUN npm run build

# =============================================================================
# Stage 2: Production Stage
# =============================================================================
# Use Nginx Alpine image (lightweight web server)
FROM nginx:alpine

# Copy the built static files from the builder stage
# These files are served by Nginx as static content
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy custom Nginx configuration
# This configures Nginx to properly serve the Vue.js SPA
# and proxy API requests to the backend
COPY nginx.conf /etc/nginx/nginx.conf

# Create a non-root user for security (Nginx already runs as nginx user)
# But we ensure proper permissions
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html

# Expose port 80 (HTTP)
# In production, this would typically be behind a reverse proxy with SSL
EXPOSE 80

# Health check configuration
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

# Start Nginx in foreground mode
# -g "daemon off": Run Nginx in foreground so Docker can track the process
CMD ["nginx", "-g", "daemon off;"]