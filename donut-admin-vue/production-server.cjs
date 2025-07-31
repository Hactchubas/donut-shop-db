const express = require('express');
const path = require('path');

const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());

// Simple manual proxy for API requests
app.use('/api/*', async (req, res) => {
  try {
    const apiUrl = process.env.API_URL || 'http://donut_api:3001';
    const targetUrl = `${apiUrl}${req.originalUrl}`;
    
    const response = await fetch(targetUrl, {
      method: req.method,
      headers: {
        'Content-Type': 'application/json',
        ...req.headers
      },
      body: req.method !== 'GET' && req.method !== 'HEAD' ? JSON.stringify(req.body) : null
    });
    
    const data = await response.text();
    res.status(response.status);
    res.set(response.headers);
    res.send(data);
  } catch (error) {
    console.error('Proxy error:', error);
    res.status(500).json({ error: 'Proxy error' });
  }
});

// Serve static files from Vue build
app.use(express.static(path.join(__dirname, 'dist')));

// Serve Vue app for all other routes (SPA routing)
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'dist', 'index.html'));
});

app.listen(port, '0.0.0.0', () => {
  console.log(`✅ Donut Shop Admin Frontend running at http://0.0.0.0:${port}`);
  console.log(`📊 Dashboard: http://0.0.0.0:${port}`);
  console.log(`🔧 API requests proxied to: ${process.env.API_URL || 'http://donut_api:3001'}`);
});