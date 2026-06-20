const db = require('../config/database');

/**
 * Yaqin atrofdagi xizmat ko'rsatuvchilar
 * GET /api/places/nearby
 * 
 * Offline rejim uchun: Ma'lumotlar mobile da cache qilinadi
 */
async function getNearbyPlaces(req, res) {
  try {
    const { latitude, longitude, type, radius = 10000 } = req.query;

    if (!latitude || !longitude) {
      return res.status(400).json({ 
        success: false, 
        message: 'Latitude va longitude majburiy' 
      });
    }

    const userLocation = `POINT(${longitude} ${latitude})`;

    let query = `
      SELECT 
        id, name, type, address, phone, phone_2,
        working_hours, rating, description,
        ST_X(location::geometry) as longitude,
        ST_Y(location::geometry) as latitude,
        ROUND(
          ST_Distance(
            location::geography, 
            ST_GeogFromText($1)
          )::numeric, 0
        ) as distance
      FROM service_places
      WHERE ST_DWithin(
        location::geography,
        ST_GeogFromText($1),
        $2
      )
    `;

    const params = [userLocation, radius];

    if (type) {
      params.push(type);
      query += ` AND type = $3`;
    }

    query += ` ORDER BY distance ASC LIMIT 50`;

    const result = await db.query(query, params);

    res.json({
      success: true,
      data: {
        places: result.rows,
        count: result.rows.length,
      },
    });
  } catch (error) {
    console.error('Get nearby places error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Server xatosi' 
    });
  }
}

/**
 * Barcha xizmat ko'rsatuvchilar (cache uchun)
 * GET /api/places
 */
async function getAllPlaces(req, res) {
  try {
    const { type, limit = 100 } = req.query;

    let query = `
      SELECT 
        id, name, type, address, phone, phone_2,
        working_hours, rating, description,
        ST_X(location::geometry) as longitude,
        ST_Y(location::geometry) as latitude
      FROM service_places
    `;

    const params = [];

    if (type) {
      params.push(type);
      query += ` WHERE type = $1`;
    }

    query += ` ORDER BY rating DESC, name ASC LIMIT $${params.length + 1}`;
    params.push(limit);

    const result = await db.query(query, params);

    res.json({
      success: true,
      data: {
        places: result.rows,
        count: result.rows.length,
        types: [
          'gas_station',
          'auto_parts', 
          'workshop',
          'evacuator',
          'car_wash',
          'tire_service'
        ],
      },
    });
  } catch (error) {
    console.error('Get all places error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Server xatosi' 
    });
  }
}

/**
 * Bitta xizmat ko'rsatuvchi ma'lumoti
 * GET /api/places/:id
 */
async function getPlaceById(req, res) {
  try {
    const { id } = req.params;

    const result = await db.query(
      `SELECT 
        id, name, type, address, phone, phone_2,
        working_hours, rating, description,
        ST_X(location::geometry) as longitude,
        ST_Y(location::geometry) as latitude,
        created_at
       FROM service_places
       WHERE id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ 
        success: false, 
        message: 'Xizmat ko\'rsatuvchi topilmadi' 
      });
    }

    res.json({
      success: true,
      data: { place: result.rows[0] },
    });
  } catch (error) {
    console.error('Get place error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Server xatosi' 
    });
  }
}

/**
 * Nom bo'yicha qidirish
 * GET /api/places/search
 */
async function searchPlaces(req, res) {
  try {
    const { query, type } = req.query;

    if (!query || query.length < 2) {
      return res.status(400).json({ 
        success: false, 
        message: 'Qidiruv uchun kamida 2 belgi kiriting' 
      });
    }

    let sqlQuery = `
      SELECT 
        id, name, type, address, phone, phone_2,
        working_hours, rating, description,
        ST_X(location::geometry) as longitude,
        ST_Y(location::geometry) as latitude
      FROM service_places
      WHERE (
        name ILIKE $1 
        OR address ILIKE $1 
        OR description ILIKE $1
      )
    `;

    const params = [`%${query}%`];

    if (type) {
      params.push(type);
      sqlQuery += ` AND type = $2`;
    }

    sqlQuery += ` ORDER BY rating DESC LIMIT 20`;

    const result = await db.query(sqlQuery, params);

    res.json({
      success: true,
      data: {
        places: result.rows,
        count: result.rows.length,
      },
    });
  } catch (error) {
    console.error('Search places error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Server xatosi' 
    });
  }
}

/**
 * Yangi xizmat ko'rsatuvchi (do'kon/shoxobcha) qo'shish
 * POST /api/places  (faqat ro'yxatdan o'tgan foydalanuvchilar)
 */
async function createPlace(req, res) {
  try {
    const {
      name, type, address, phone, phone_2,
      latitude, longitude, working_hours, description,
    } = req.body;

    if (!name || !type || !address || !phone ||
        latitude === undefined || longitude === undefined) {
      return res.status(400).json({
        success: false,
        message: 'Majburiy maydonlar to\'ldirilmagan (nom, tur, manzil, telefon, joylashuv)',
      });
    }

    const ownerId = req.user ? (req.user.user_id || req.user.id || null) : null;
    const point = `POINT(${longitude} ${latitude})`;

    const result = await db.query(
      `INSERT INTO service_places
        (name, type, address, phone, phone_2, location, working_hours, rating, description, owner_user_id)
       VALUES ($1, $2, $3, $4, $5, ST_GeogFromText($6), $7, 0, $8, $9)
       RETURNING id, name, type, address, phone, phone_2, working_hours, rating, description,
         ST_X(location::geometry) as longitude,
         ST_Y(location::geometry) as latitude`,
      [name, type, address, phone, phone_2 || null, point, working_hours || null, description || null, ownerId]
    );

    res.status(201).json({
      success: true,
      message: 'Manzil qo\'shildi',
      data: { place: result.rows[0] },
    });
  } catch (error) {
    console.error('Create place error:', error);
    res.status(500).json({ success: false, message: 'Server xatosi' });
  }
}

module.exports = {
  getNearbyPlaces,
  getAllPlaces,
  getPlaceById,
  searchPlaces,
  createPlace,
};
