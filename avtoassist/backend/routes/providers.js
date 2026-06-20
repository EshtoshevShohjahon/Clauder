const express = require('express');
const router = express.Router();
const providerController = require('../controllers/providerController');
const { authenticate } = require('../middleware/auth');

// GET /api/providers - Xizmat ko'rsatuvchilar ro'yxati
router.get('/', providerController.getProviders);

// GET /api/providers/nearby - Yaqin atrofdagi providerlar
router.get('/nearby', providerController.getNearbyProviders);

// GET /api/providers/:id - Provider ma'lumotlari
router.get('/:id', providerController.getProviderById);

// GET /api/providers/workshops - Ustaxonalar ro'yxati
router.get('/workshops', providerController.getWorkshops);

// GET /api/providers/parts - Ehtiyot qismlar katalogi
router.get('/parts', providerController.getParts);

module.exports = router;
