const express = require('express');
const os = require('os');
const app = express();
const PORT = 3000;

app.use(express.json());
app.use(express.static('public'));

// ✅ Root route (FIX)
app.get('/', (req, res) => {
  res.send('🚀 Node App is running inside Docker!');
});

// API endpoint for system info
app.get('/api/info', (req, res) => {
  res.json({
    hostname: os.hostname(),
    platform: os.platform(),
    nodeVersion: process.version,
    uptime: Math.floor(process.uptime()),
    memory: {
      total: Math.round(os.totalmem() / 1024 / 1024),
      free: Math.round(os.freemem() / 1024 / 1024),
    },
    environment: process.env.NODE_ENV || 'development',
    containerized: process.env.CONTAINERIZED || 'false',
  });
});

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running on http://0.0.0.0:${PORT}`);
});