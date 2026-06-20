const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const { authenticate } = require('../middleware/auth');

// GET /api/users/me - O'z profilni ko'rish
router.get('/me', authenticate, userController.getProfile);

// PUT /api/users/me - Profilni yangilash
router.put('/me', authenticate, userController.updateProfile);

// PUT /api/users/me/location - Locationni yangilash
router.put('/me/location', authenticate, userController.updateLocation);

module.exports = router;
