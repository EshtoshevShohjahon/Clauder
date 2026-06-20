const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

// POST /api/auth/register - Ro'yxatdan o'tish
router.post('/register', authController.register);

// POST /api/auth/login - Kirish
router.post('/login', authController.login);

// POST /api/auth/verify-phone - Telefon raqamni tasdiqlash
router.post('/verify-phone', authController.verifyPhone);

// POST /api/auth/select-role - Rol tanlash (client/provider)
router.post('/select-role', authController.selectRole);

// POST /api/auth/forgot-password - Parolni tiklash kodini so'rash (SMS)
router.post('/forgot-password', authController.forgotPassword);

// POST /api/auth/reset-password - Kodni tasdiqlab yangi parol o'rnatish
router.post('/reset-password', authController.resetPassword);

module.exports = router;
