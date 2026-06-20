const db = require('../config/database');

/**
 * O'z profilni ko'rish
 * GET /api/users/me
 */
async function getProfile(req, res) {
  try {
    const userId = req.user.user_id;

    const result = await db.query(
      `SELECT u.id, u.phone, u.full_name, u.role, u.phone_verified, u.created_at,
              p.id as provider_id, p.service_type, p.business_name, 
              p.is_available, p.rating, p.total_orders
       FROM users u
       LEFT JOIN providers p ON u.id = p.user_id
       WHERE u.id = $1`,
      [userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ 
        success: false, 
        message: 'Foydalanuvchi topilmadi' 
      });
    }

    const user = result.rows[0];

    res.json({
      success: true,
      data: { user },
    });
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Server xatosi' 
    });
  }
}

/**
 * Profilni yangilash
 * PUT /api/users/me
 */
async function updateProfile(req, res) {
  try {
    const userId = req.user.user_id;
    const { full_name, business_name, service_type } = req.body;

    // Userni yangilash
    if (full_name) {
      await db.query(
        'UPDATE users SET full_name = $1 WHERE id = $2',
        [full_name, userId]
      );
    }

    // Agar provider bo'lsa
    if (req.user.role === 'provider') {
      const updates = [];
      const values = [];
      let paramCount = 1;

      if (business_name) {
        updates.push(`business_name = $${paramCount}`);
        values.push(business_name);
        paramCount++;
      }

      if (service_type) {
        updates.push(`service_type = $${paramCount}`);
        values.push(service_type);
        paramCount++;
      }

      if (updates.length > 0) {
        values.push(userId);
        await db.query(
          `UPDATE providers SET ${updates.join(', ')} WHERE user_id = $${paramCount}`,
          values
        );
      }
    }

    res.json({
      success: true,
      message: 'Profil yangilandi',
    });
  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Server xatosi' 
    });
  }
}

/**
 * Locationni yangilash
 * PUT /api/users/me/location
 */
async function updateLocation(req, res) {
  try {
    const userId = req.user.user_id;
    const { latitude, longitude } = req.body;

    if (!latitude || !longitude) {
      return res.status(400).json({ 
        success: false, 
        message: 'Latitude va longitude majburiy' 
      });
    }

    // Provider bo'lsa locationni yangilash
    if (req.user.role === 'provider') {
      await db.query(
        `UPDATE providers 
         SET current_location = ST_GeomFromText($1, 4326),
             last_location_update = NOW()
         WHERE user_id = $2`,
        [`POINT(${longitude} ${latitude})`, userId]
      );
    }

    res.json({
      success: true,
      message: 'Joylashuv yangilandi',
    });
  } catch (error) {
    console.error('Update location error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Server xatosi' 
    });
  }
}

module.exports = {
  getProfile,
  updateProfile,
  updateLocation,
};
