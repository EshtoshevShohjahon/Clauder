const express = require('express');
const router = express.Router();
const placesController = require('../controllers/placesController');
const { authenticate } = require('../middleware/auth');

/**
 * Service Places Routes
 * Bu endpoint'lar offline cache uchun ishlatiladi
 */

// Public routes (authentication kerak emas - offline cache uchun)
router.get('/nearby', placesController.getNearbyPlaces);
router.get('/search', placesController.searchPlaces);
router.get('/', placesController.getAllPlaces);
router.get('/:id', placesController.getPlaceById);

module.exports = router;
