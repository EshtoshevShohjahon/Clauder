const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const http = require('http');
const socketIO = require('socket.io');
require('dotenv').config();

const db = require('./config/database');
const { errorHandler, notFoundHandler } = require('./middleware/errorHandler');

// Routes
const authRoutes = require('./routes/auth');
const orderRoutes = require('./routes/orders');
const providerRoutes = require('./routes/providers');
const userRoutes = require('./routes/users');
const vehicleRoutes = require('./routes/vehicles');

const app = express();
const server = http.createServer(app);
const io = socketIO(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST'],
  },
});

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(morgan('dev'));

// Socket.IO ni express'ga ulash
app.set('io', io);

// Health check
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'AvtoAssist API Server',
    version: '1.0.0',
    status: 'running',
  });
});

app.get('/health', async (req, res) => {
  try {
    await db.query('SELECT NOW()');
    res.json({
      success: true,
      message: 'Server va database ishlayapti',
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Database bilan bog\'lanishda xatolik',
    });
  }
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/providers', providerRoutes);
app.use('/api/users', userRoutes);
app.use('/api/vehicles', vehicleRoutes);

// WebSocket connection handler
io.on('connection', (socket) => {
  console.log('✓ Client connected:', socket.id);

  // Provider location update
  socket.on('provider:location', (data) => {
    const { orderId, location } = data;
    // Mijozga location yuborish
    socket.broadcast.to(`order:${orderId}`).emit('provider:location:update', location);
  });

  // Order room'ga qo'shilish
  socket.on('join:order', (orderId) => {
    socket.join(`order:${orderId}`);
    console.log(`Socket ${socket.id} joined order room: ${orderId}`);
  });

  // Order room'dan chiqish
  socket.on('leave:order', (orderId) => {
    socket.leave(`order:${orderId}`);
    console.log(`Socket ${socket.id} left order room: ${orderId}`);
  });

  socket.on('disconnect', () => {
    console.log('✗ Client disconnected:', socket.id);
  });
});

// Error handlers
app.use(notFoundHandler);
app.use(errorHandler);

// Start server
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log('=================================');
  console.log(`🚀 Server ishga tushdi: http://localhost:${PORT}`);
  console.log(`📡 WebSocket: ws://localhost:${PORT}`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log('=================================');
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  server.close(() => {
    console.log('HTTP server closed');
    db.end();
  });
});

module.exports = { app, io };
