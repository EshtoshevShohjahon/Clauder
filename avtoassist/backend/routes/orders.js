const express = require('express');
const router = express.Router();
const orderController = require('../controllers/orderController');
const { authenticate, authorize } = require('../middleware/auth');

// POST /api/orders - Yangi so'rov yaratish (faqat client)
router.post('/', authenticate, authorize('client'), orderController.createOrder);

// GET /api/orders - So'rovlar ro'yxati
router.get('/', authenticate, orderController.getOrders);

// GET /api/orders/:id - Bitta so'rovni ko'rish
router.get('/:id', authenticate, orderController.getOrderById);

// POST /api/orders/:id/accept - So'rovni qabul qilish (faqat provider)
router.post('/:id/accept', authenticate, authorize('provider'), orderController.acceptOrder);

// PUT /api/orders/:id/status - Status o'zgartirish
router.put('/:id/status', authenticate, orderController.updateOrderStatus);

// POST /api/orders/:id/complete - So'rovni yakunlash
router.post('/:id/complete', authenticate, orderController.completeOrder);

// POST /api/orders/:id/cancel - So'rovni bekor qilish
router.post('/:id/cancel', authenticate, orderController.cancelOrder);

// POST /api/orders/:id/rate - Baho berish
router.post('/:id/rate', authenticate, orderController.rateOrder);

module.exports = router;
