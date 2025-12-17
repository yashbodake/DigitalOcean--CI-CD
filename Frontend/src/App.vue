<template>
  <div id="app">
    <header>
      <h1>Vue.js Frontend with FastAPI Backend</h1>
    </header>

    <main>
      <div class="hello-section">
        <h2>Hello World Demo</h2>
        <div class="message-box">
          <p v-if="!message">Loading message from backend...</p>
          <p v-else class="message">{{ message }}</p>
        </div>
        <button @click="getMessage" :disabled="loading" class="btn">
          {{ loading ? 'Loading...' : 'Get Message from Backend' }}
        </button>
      </div>
    </main>
  </div>
</template>

<script>
import axios from 'axios'

export default {
  name: 'App',
  data() {
    return {
      message: null,
      loading: false
    }
  },
  methods: {
    /**
     * Get API base URL based on environment
     * In development: uses proxy (/api)
     * In production: uses environment variable (must be set to backend API URL)
     */
    getApiUrl() {
      // Check if we have a custom API URL from environment
      // This MUST be set in production to point to your backend API server
      if (process.env.VUE_APP_API_URL) {
        const url = process.env.VUE_APP_API_URL.trim();
        // Remove trailing slash if present
        return url.endsWith('/') ? url.slice(0, -1) : url;
      }
      // In development, use proxy (configured in vue.config.js)
      if (process.env.NODE_ENV === 'development') {
        return '/api';
      }
      // In production, if VUE_APP_API_URL is not set, show error
      console.error('VUE_APP_API_URL is not set! Please configure the backend API URL.');
      return null;
    },
    
    /**
     * Fetch message from backend API
     */
    async getMessage() {
      this.loading = true;
      try {
        // Get API base URL
        const apiUrl = this.getApiUrl();
        
        if (!apiUrl) {
          this.message = 'Error: Backend API URL not configured. Please set VUE_APP_API_URL.';
          return;
        }
        
        // Construct endpoint URL
        // Backend endpoint is always /api/hello
        // Remove trailing slash from API URL if present
        const baseUrl = apiUrl.endsWith('/') ? apiUrl.slice(0, -1) : apiUrl;
        
        // If API URL already ends with /api, just append /hello
        // Otherwise, append /api/hello
        let endpoint;
        if (baseUrl.endsWith('/api')) {
          endpoint = `${baseUrl}/hello`;
        } else {
          endpoint = `${baseUrl}/api/hello`;
        }
        
        console.log('Calling API endpoint:', endpoint);
        
        // Make API request
        const response = await axios.get(endpoint);
        this.message = response.data.message;
      } catch (error) {
        // Handle error without console.log (production-friendly)
        // Only log in development mode
        if (process.env.NODE_ENV === 'development') {
          // eslint-disable-next-line no-console
          console.error('Error fetching message:', error);
        }
        this.message = 'Error: Could not get message from backend';
      } finally {
        this.loading = false;
      }
    }
  },
  mounted() {
    // Load message on component mount
    this.getMessage();
  }
}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}

h1 {
  color: #42b983;
}

.hello-section {
  max-width: 600px;
  margin: 0 auto;
  padding: 2rem;
}

.message-box {
  background-color: #f8f9fa;
  border: 1px solid #dee2e6;
  border-radius: 8px;
  padding: 1.5rem;
  margin: 1rem 0;
  min-height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.message {
  font-size: 1.2rem;
  font-weight: bold;
  color: #27ae60;
}

.btn {
  background-color: #42b983;
  color: white;
  border: none;
  padding: 0.75rem 1.5rem;
  border-radius: 4px;
  cursor: pointer;
  font-size: 1rem;
  margin-top: 1rem;
}

.btn:hover:not(:disabled) {
  background-color: #359c6d;
}

.btn:disabled {
  background-color: #bdc3c7;
  cursor: not-allowed;
}
</style>