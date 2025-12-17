# =============================================================================
# Backend Dockerfile - FastAPI Application
# =============================================================================
# This Dockerfile builds a production-ready container for the FastAPI backend
# It uses a multi-stage build approach for optimization
# =============================================================================

# Base image: Python 3.11 slim (minimal size, includes Python runtime)
FROM python:3.11-slim

# Set working directory inside container
WORKDIR /app

# Install system dependencies required for Python packages
# - gcc: Required for compiling some Python packages
# - curl: Used for health checks
# Clean up apt cache to reduce image size
RUN apt-get update && apt-get install -y \
    gcc \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements file first (for better Docker layer caching)
# This allows Docker to cache the pip install step if requirements don't change
COPY requirements.txt .

# Install Python dependencies
# --no-cache-dir: Don't store pip cache to reduce image size
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy application code
# This is done after installing dependencies to leverage Docker layer caching
COPY . .

# Create a non-root user for security (best practice)
RUN useradd -m -u 1000 appuser && \
    chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose the port the application runs on
# FastAPI/Uvicorn default port is 8000
EXPOSE 8000

# Health check configuration
# This allows Docker to monitor container health
HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=3 \
    CMD curl -f http://localhost:8000/api/hello || exit 1

# Run the application using Uvicorn ASGI server
# --host 0.0.0.0: Listen on all network interfaces
# --port 8000: Use port 8000
# --forwarded-allow-ips *: Allow forwarded headers from proxy (Nginx)
# Note: For production, consider using --workers for multiple processes
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--forwarded-allow-ips", "*"]
