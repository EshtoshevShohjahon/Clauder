const express = require('express');
const router = express.Router();
const { getVersion } = require('../controllers/versionController');

// GET /api/version - eng yangi versiya ma'lumoti
router.get('/', getVersion);

module.exports = router;
