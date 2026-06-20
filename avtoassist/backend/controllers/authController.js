const bcrypt = require('bcrypt');
const db = require('../config/database');
const { generateToken } = require('../config/jwt');

/**
 * Ro'yxatdan o'tish
 * POST /api/auth/register
 */
async function register(req, res) {
  try {
    const { phone, password, full_name } = req.body;

    if (!phone || !password) {
      return res.status(400).json({ 
        success: false, 
        message: 'Telefon raqam va parol majburiy' 
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

module.exports = {
  register,
  login,
  verifyPhone,
  selectRole,
};
