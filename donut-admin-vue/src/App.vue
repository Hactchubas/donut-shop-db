<template>
  <div id="app">
    <nav class="navbar">
      <div class="nav-brand">
        <h1>🍩 Donut Shop Admin</h1>
      </div>
      <div class="nav-links">
        <RouterLink to="/" class="nav-link">Dashboard</RouterLink>
        <RouterLink to="/customers" class="nav-link">Customers</RouterLink>
        <RouterLink to="/orders" class="nav-link">Orders</RouterLink>
        <RouterLink to="/donuts" class="nav-link">Donuts</RouterLink>
        <RouterLink to="/inventory" class="nav-link">Inventory</RouterLink>
      </div>
    </nav>

    <main class="main-content">
      <RouterView />
    </main>
  </div>
</template>

<script setup lang="ts">
import { RouterLink, RouterView } from 'vue-router'
</script>

<style scoped>
#app {
  width: 100%;
  min-height: 100vh;
  background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
}

.navbar {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-bottom: 1px solid rgba(255, 255, 255, 0.2);
  padding: 1.25rem 2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  position: sticky;
  top: 0;
  z-index: 100;
}

.nav-brand h1 {
  margin: 0;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  font-size: 1.75rem;
  font-weight: 700;
  letter-spacing: -0.02em;
}

.nav-links {
  display: flex;
  gap: 0.5rem;
}

.nav-link {
  text-decoration: none;
  color: #4a5568;
  font-weight: 600;
  padding: 0.75rem 1.25rem;
  border-radius: 12px;
  transition: all 0.3s ease;
  font-size: 0.95rem;
  position: relative;
  overflow: hidden;
}

.nav-link::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  opacity: 0;
  transition: opacity 0.3s ease;
  z-index: -1;
}

.nav-link:hover::before,
.nav-link.router-link-active::before {
  opacity: 1;
}

.nav-link:hover,
.nav-link.router-link-active {
  color: white;
  transform: translateY(-1px);
  box-shadow: 0 4px 20px rgba(102, 126, 234, 0.4);
}

.nav-link:not(.router-link-active):hover {
  background: rgba(102, 126, 234, 0.1);
  color: #667eea;
}

.main-content {
  padding: 2.5rem;
  width: 100%;
  min-height: calc(100vh - 100px);
}

</style>
