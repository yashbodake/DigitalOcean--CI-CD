# =============================================================================
# FastAPI Backend Application
# =============================================================================
# This is the main entry point for the FastAPI backend API
# It provides RESTful endpoints for the frontend application
# =============================================================================

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import os

# =============================================================================
# Application Initialization
# =============================================================================
# Create FastAPI application instance
# - title: API title shown in documentation
# - description: API description
# - version: API version
# =============================================================================
app = FastAPI(
    title="Demo API",
    description="Backend API for DemoToDigitalOcean application",
    version="1.0.0"
)

# =============================================================================
# CORS Configuration
# =============================================================================
# Configure Cross-Origin Resource Sharing (CORS) middleware
# This allows the frontend (hosted on a different domain) to make API requests
# =============================================================================
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        # Add your frontend URLs here
        os.getenv("FRONTEND_URL", "http://localhost:8080"),
        # Add DigitalOcean Spaces CDN URL if using it
        os.getenv("SPACES_CDN_URL", ""),
        # Production frontend URL
        "https://sethupocjd.tech00000.online",
    ],
    allow_credentials=True,
    allow_methods=["*"],  # Allow all HTTP methods (GET, POST, PUT, DELETE, etc.)
    allow_headers=["*"],  # Allow all headers
)

# =============================================================================
# Health Check Endpoint
# =============================================================================
# This endpoint is used by monitoring systems and load balancers
# to check if the API is running and healthy
# =============================================================================
@app.get("/health")
def health_check():
    """
    Health check endpoint for monitoring and load balancers.
    Returns a simple status to indicate the API is running.
    """
    return {
        "status": "healthy",
        "service": "backend-api",
        "version": "1.0.0"
    }

# =============================================================================
# API Endpoints
# =============================================================================

@app.get("/api/hello")
def hello():
    """
    Simple hello endpoint for testing API connectivity.
    
    Returns:
        dict: A JSON response with a greeting message
    """
    return {
        "message": "Hello from FastAPI",
        "status": "success"
    }

# =============================================================================
# Root Endpoint
# =============================================================================
@app.get("/")
def root():
    """
    Root endpoint that provides API information.
    """
    return {
        "message": "Welcome to Demo API",
        "docs": "/docs",
        "health": "/health"
    }

# =============================================================================
# Application Startup Event
# =============================================================================
# This runs when the application starts up
# Use this for initialization tasks like database connections, etc.
# =============================================================================
@app.on_event("startup")
async def startup_event():
    """
    Startup event handler.
    Perform any initialization tasks here.
    """
    print("🚀 Backend API starting up...")
    print(f"Environment: {os.getenv('ENVIRONMENT', 'development')}")

# =============================================================================
# Application Shutdown Event
# =============================================================================
# This runs when the application shuts down
# Use this for cleanup tasks
# =============================================================================
@app.on_event("shutdown")
async def shutdown_event():
    """
    Shutdown event handler.
    Perform any cleanup tasks here.
    """
    print("👋 Backend API shutting down...")
