const cors = require('cors');
const { createProxyMiddleware } = require('http-proxy-middleware');
const express = require('express');

const app = express();

// Configuration CORS permissive pour le développement
app.use(cors({
  origin: '*',
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept']
}));

// Proxy vers l'API backend
app.use('/api', createProxyMiddleware({
  target: 'http://localhost:3000',
  changeOrigin: true,
  logLevel: 'debug',
  onProxyReq: (proxyReq, req, res) => {
    console.log(`[PROXY] ${req.method} ${req.originalUrl} -> http://localhost:3000${req.originalUrl}`);
  },
  onError: (err, req, res) => {
    console.error('[PROXY ERROR]', err);
    res.status(500).send('Proxy Error');
  }
}));

const PORT = 8080;
app.listen(PORT, () => {
  console.log(`🔧 Proxy CORS démarré sur http://localhost:${PORT}`);
  console.log(`📡 Proxifie vers http://localhost:3000`);
  console.log(`\n💡 Dans votre app Flutter, utilisez: http://localhost:${PORT}/api`);
});

module.exports = app;