const bcrypt = require('bcrypt');
const db = require('../config/database');
const { generateToken } = require('../config/jwt');
const { sendSms } = require('../utils/smsService');

/**
 * Ro'yxatdan o'tish
 * POST /api/auth/register
 */
async function register(req, res) {
  try {
    const { phone, password, full_name } = req.body;

    // Validation
    if (!phone || !password) {
      return res.status(400).json({ 
        success: false, 
        message: 'Telefon raqam va parol majburiy' 
      });
    }

    // Phone format validation (O'zbekiston formati: +998XXXXXXXXX)
    const phoneRegex = /^\+998[0-9]{9}$/;
    if (!phoneRegex.test(phone)) {
      return res.status(400).json({ 
        success: false, 
        message: 'Telefon raqam formati noto\'g\'ri. Namuna: +998901234567' 
      });
    }

    // Password validation
    if (password.length < 6) {
      return res.status(400).json({ 
        success: false, 
        message: 'Parol kamida 6 belgidan iborat bo\'lishi kerak' 
      });
    }

    // Full name validation
    if (full_name && (full_name.length < 3 || full_name.length > 100)) {
      return res.status(400).json({ 
        success: false, 
        message: 'Ism 3-100 belgi orasida bo\'lishi kerak' 
      });
    }

    // Telefon mavjudligini tekshirish
    const existingUser = await db.query(
      'SELECT id FROM users WHERE phone = $1',
      [phone]
    );

    if (existingUser.rows.length > 0) {
      return res.status(400).json({ 
        success: false, 
        message: 'Bu telefon raqam allaqachon ro\'yxatdan o\'tgan' 
      });
    }

    // Parolni hash qilish
    const hashedPassword = await bcrypt.hash(password, 10);

    // Yangi foydalanuvchi yaratish
    const result = await db.query(
      `INSERT INTO users (phone, password_hash, full_name, role, phone_verified) 
       VALUES ($1, $2, $3, 'client', false) 
       RETURNING id, phone, full_name, role, phone_verified, created_at`,
      [phone, hashedPassword, full_name || null]
    );

    const user = result.rows[0];

    // JWT token yaratish
    const token = generateToken({ 
      user_id: user.id, 
      role: user.role 
    });

    res.status(201).json({
      success: true,
      message: 'Ro\'yxatdan o\'tish muvaffaqiyatli',
      data: {
        user: {
          id: user.id,
          phone: user.phone,
          full_name: user.full_name,
          role: user.role,
          phone_verified: user.phone_verified,
        },
        token,
      },
    });
  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Server xatosi' 
    });
  }
}

/**
 * Kirish
 * POST /api/auth/login
 */
async function login(req, res) {
  try {
    const { phone, password } = req.body;

    if (!phone || !password) {
      return res.status(400).json({ 
        success: false, 
        message: 'Telefon raqam va parol majburiy' 
      });
    }

    // Foydalanuvchini topish
    const result = await db.query(
      'SELECT * FROM users WHERE phone = $1',
      [phone]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({ 
        success: false, 
        message: 'Telefon yoki parol noto\'g\'ri' 
      });
    }

    const user = result.rows[0];

    // Parolni tekshirish
    const validPassword = await bcrypt.compare(password, user.password_hash);
    if (!validPassword) {
      return res.status(401).json({ 
        success: false, 
        message: 'Telefon yoki parol noto\'g\'ri' 
      });
    }

    // JWT token yaratish
    const token = generateToken({ 
      user_id: user.id, 
      role: user.role 
    });

    res.json({
      success: true,
      message: 'Kirish muvaffaqiyatli',
      data: {
        user: {
          id: user.id,
          phone: user.phone,
          full_name: user.full_name,
          role: user.role,
          phone_verified: user.phone_verified,
        },
        token,
      },
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Server xatosi' 
    });
  }
}

/**
 * Telefon raqamni tasdiqlash
 * POST /api/auth/verify-phone
 */
async function verifyPhone(req, res) {
  try {
    const { phone, code } = req.body;

    // Bu yerda SMS service bilan integratsiya bo'lishi kerak
    // Hozircha oddiy implementatsiya
    
    // Demo: har qanday 4 raqamli kod qabul qilinadi
    if (!code || code.length !== 4) {
      return res.status(400).json({ 
        success: false, 
        message: 'Noto\'g\'ri tasdiqlash kodi' 
      });
    }

    // Telefon raqamni tasdiqlangan deb belgilash
    await db.query(
      'UPDATE users SET phone_verified = true WHERE phone = $1',
      [phone]
    );

    res.json({
      success: true,
      message: 'Telefon raqam tasdiqlandi',
    });
  } catch (error) {
    console.error('Verify phone error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Server xatosi' 
    });
  }
}

/**
 * Rol tanlash (client/provider)
 * POST /api/auth/select-role
 */
async function selectRole(req, res) {
  try {
    const { phone, role, service_type, business_name } = req.body;

    if (!phone || !role) {
      return res.status(400).json({ 
        success: false, 
        message: 'Telefon va rol majburiy' 
      });
    }

    if (!['client', 'provider'].includes(role)) {
      return res.status(400).json({ 
        success: false, 
        message: 'Noto\'g\'ri rol' 
      });
    }

    // Userni yangilash
    const result = await db.query(
      'UPDATE users SET role = $1 WHERE phone = $2 RETURNING id, phone, full_name, role',
      [role, phone]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ 
        success: false, 
        message: 'Foydalanuvchi topilmadi' 
      });
    }

    const user = result.rows[0];

    // Agar provider bo'lsa, providers jadvaliga qo'shamiz
    if (role === 'provider' && service_type) {
      await db.query(
        `INSERT INTO providers (user_id, service_type, business_name, is_available) 
         VALUES ($1, $2, $3, true)
         ON CONFLICT (user_id) DO UPDATE SET service_type = $2, business_name = $3`,
        [user.id, service_type, business_name || null]
      );
    }

    // Yangi token yaratish
    const token = generateToken({ 
      user_id: user.id, 
      role: user.role 
    });

    res.json({
      success: true,
      message: 'Rol tanlandi',
      data: {
        user,
        token,
      },
    });
  } catch (error) {
    console.error('Select role error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Server xatosi' 
    });
  }
}

/**
 * Parolni tiklash - kod so'rash (SMS)
 * POST /api/auth/forgot-password
 */
async function forgotPassword(req, res) {
  try {
    const { phone } = req.body;
    if (!phone) {
      return res.status(400).json({ success: false, message: 'Telefon raqam majburiy' });
    }

    const userRes = await db.query('SELECT id FROM users WHERE phone = $1', [phone]);
    if (userRes.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Bunday foydalanuvchi topilmadi' });
    }

    const code = Math.floor(100000 + Math.random() * 900000).toString();
    const expires = new Date(Date.now() + 10 * 60 * 1000); // 10 daqiqa

    await db.query(
      'UPDATE users SET reset_code = $1, reset_code_expires = $2 WHERE phone = $3',
      [code, expires, phone]
    );

    const sms = await sendSms(phone, `AvtoHelp: parolni tiklash kodi - ${code}`);

    const resp = { success: true, message: 'Tasdiqlash kodi yuborildi' };
    // SMS provider sozlanmagan bo'lsa - test uchun kodni qaytaramiz
    if (sms.dev) resp.dev_code = code;
    res.json(resp);
  } catch (error) {
    console.error('Forgot password error:', error);
    res.status(500).json({ success: false, message: 'Server xatosi' });
  }
}

/**
 * Parolni tiklash - kodni tasdiqlab yangi parol o'rnatish
 * POST /api/auth/reset-password
 */
async function resetPassword(req, res) {
  try {
    const { phone, code, new_password } = req.body;
    if (!phone || !code || !new_password) {
      return res.status(400).json({ success: false, message: 'Barcha maydonlar majburiy' });
    }
    if (new_password.length < 6) {
      return res.status(400).json({ success: false, message: 'Parol kamida 6 belgidan iborat bo\'lishi kerak' });
    }

    const userRes = await db.query(
      'SELECT reset_code, reset_code_expires FROM users WHERE phone = $1',
      [phone]
    );
    if (userRes.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Foydalanuvchi topilmadi' });
    }

    const u = userRes.rows[0];
    if (!u.reset_code || u.reset_code !== code) {
      return res.status(400).json({ success: false, message: 'Kod noto\'g\'ri' });
    }
    if (new Date(u.reset_code_expires) < new Date()) {
      return res.status(400).json({ success: false, message: 'Kod muddati tugagan' });
    }

    const hashed = await bcrypt.hash(new_password, 10);
    await db.query(
      'UPDATE users SET password_hash = $1, reset_code = NULL, reset_code_expires = NULL WHERE phone = $2',
      [hashed, phone]
    );

    res.json({ success: true, message: 'Parol yangilandi' });
  } catch (error) {
    console.error('Reset password error:', error);
    res.status(500).json({ success: false, message: 'Server xatosi' });
  }
}

module.exports = {
  register,
  login,
  verifyPhone,
  selectRole,
  forgotPassword,
  resetPassword,
};
