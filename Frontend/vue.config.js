// =============================================================================
// Vue.js Configuration File
// =============================================================================
// This file configures the Vue CLI build process and development server
// =============================================================================

module.exports = {
  // Transpile dependencies: Enable Babel transpilation for node_modules
  // Some packages may need to be transpiled for compatibility
  transpileDependencies: true,

  // Production build configuration
  publicPath: process.env.NODE_ENV === 'production'
    ? process.env.VUE_APP_PUBLIC_PATH || '/'  // Use custom public path if set
    : '/',  // Development uses root path

  // Output directory for production builds
  outputDir: 'dist',

  // Assets directory (relative to outputDir)
  assetsDir: 'static',

  // Development server configuration
  devServer: {
    // Port for development server
    port: 8080,

    // Proxy configuration for API requests during development
    // This allows the frontend to make API calls without CORS issues
    proxy: {
      '/api': {
        // Target backend URL
        // For Docker Compose: use service name
        // For local development: use localhost:8000
        target: process.env.VUE_APP_API_URL || 'http://localhost:8000',
        
        // Change the origin of the host header to the target URL
        changeOrigin: true,
        
        // Path rewriting (if needed)
        pathRewrite: {
          '^/api': '/api'  // Keep /api prefix as-is
        },
        
        // WebSocket support (if needed)
        ws: true,
        
        // Log level for proxy
        logLevel: 'debug'
      }
    }
  },

  // Production source maps (set to false for smaller builds)
  productionSourceMap: false,

  // CSS extraction configuration
  css: {
    // Extract CSS into separate files in production
    extract: process.env.NODE_ENV === 'production',
    
    // Enable CSS source maps in development
    sourceMap: process.env.NODE_ENV === 'development'
  },

  // Webpack configuration (advanced)
  configureWebpack: {
    // Optimization settings
    optimization: {
      splitChunks: {
        chunks: 'all',
        cacheGroups: {
          vendor: {
            name: 'chunk-vendors',
            test: /[\\/]node_modules[\\/]/,
            priority: 10,
            chunks: 'initial'
          }
        }
      }
    }
  }
}