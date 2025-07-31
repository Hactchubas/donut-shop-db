const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const path = require('path');

const app = express();
const port = 3000;

// Proxy API requests to the dedicated API server
app.use('/api', createProxyMiddleware({
  target: 'http://donut_api:3001',
  changeOrigin: true,
  logLevel: 'info'
}));

// Serve static files from Vue build
app.use(express.static(path.join(__dirname, 'dist')));

// Serve Vue app for all other routes (SPA routing)
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'dist', 'index.html'));
});

app.listen(port, '0.0.0.0', () => {
  console.log(`✅ Donut Shop Admin Frontend running at http://0.0.0.0:${port}`);
  console.log(`📊 Dashboard: http://0.0.0.0:${port}`);
  console.log(`🔧 API requests proxied to: http://donut_api:3001`);
});