const db = require('../config/database');

/**
 * Xizmat ko'rsatuvchilar ro'yxati
 * GET /api/providers
 */
async function getProviders(req, res) {
  try {
    const { service_type, limit = 50 } = req.query;

    let query = `
      SELECT p.id, p.service_type, p.business_name, p.rating, 
             p.total_orders, p.is_available,
             u.full_name, u.phone,
             ST_AsText(p.current_location) as current_coords
      FROM providers p
      JOIN users u ON p.user_id = u.id
      WHERE p.is_available = true
    `;

    const params = [];
    if (service_type) {
      params.push(service_type);
      query += ` AND p.service_type = $1`;
    }

    query += ` ORDER BY p.rating DESC, p.total_orders DESC LIMIT $${params.length + 1}`;
    params.push(limit);

    const result = await db.query(query, params);

    res.json({
      success: true,
      data: { providers: result.rows },
    });
  } catch (error) {
    console.error('Get providers error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Server xatosi' 
    });
  }
}

/**
 * Yaqin atrofdagi providerlar
 * GET /api/providers/nearby
 */
async function getNearbyProviders(req, res) {
  try {
    const { latitude, longitude, service_type, radius = 10000 } = req.query;

    if (!latitude || !longitude) {
      return res.status(400).json({ 
        success: false, 
        message: 'Latitude va longitude majburiy' 
      });
    }

    const userLocation = `POINT(${longitude} ${latitude})`;

    let query = `
      SELECT p.id, p.service_type, p.business_name, p.rating, 
             p.total_orders, p.is_available,
             u.full_name, u.phone,
             ST_AsText(p.current_location) as current_coords,
             ST_Distance(
               p.current_location::geography, 
               ST_GeomFromText($1, 4326)::geography
             ) as distance
      FROM providers p
      JOIN users u ON p.user_id = u.id
      WHERE p.is_available = true
        AND p.current_location IS NOT NULL
        AND ST_DWithin(
          p.current_location::geography,
          ST_GeomFromText($1, 4326)::geography,
          $2
        )
    `;

    const params = [userLocation, radius];

    if (service_type) {
      params.push(service_type);
      query += ` AND p.service_type = $3`;
    }

    query += ` ORDER BY distance ASC LIMIT 20`;

    const result = await db.query(query, params);

    res.json({
      success: true,
      data: { 
        providers: result.rows,
        count: result.rows.length,
      },
    });
  } catch (error) {
    console.error('Get nearby providers error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Server xatosi' 
    });
  }
}

/**
 * Provider ma'lumotlari
 * GET /api/providers/:id
 */
async function getProviderById(req, res) {
  try {
    const { id } = req.params;

    const result = await db.query(
      `SELECT p.*, u.full_name, u.phone,
              ST_AsText(p.current_location) as current_coords,
              (SELECT AVG(rating) FROM reviews WHERE provider_id = p.id) as avg_rating,
              (SELECT COUNT(*) FROM reviews WHERE provider_id = p.id) as review_count
       FROM providers p
       JOIN users u ON p.user_id = u.id
       WHERE p.id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ 
        success: false, 
        message: 'Provider topilmadi' 
      });
    }

    const provider = result.rows[0];

    // Reviews olish
    const reviewsResult = await db.query(
      `SELECT r.*, u.full_name as client_name
       FROM reviews r
       JOIN users u ON r.client_id = u.id
       WHERE r.provider_id = $1
       ORDER BY r.created_at DESC
       LIMIT 10`,
      [id]
    );

    res.json({
      success: true,
      data: { 
        provider,
        reviews: reviewsResult.rows,
      },
    });
  } catch (error) {
    console.error('Get provider error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Server xatosi' 
    });
  }
}

/**
 * Ustaxonalar ro'yxati
 * GET /api/providers/workshops
 */
async function getWorkshops(req, res) {
  try {
    const { latitude, longitude, radius = 10000 } = req.query;

    // Bu yerda haqiqiy database dan ustaxonalar ma'lumotlari kelishi kerak
    // Demo uchun static data
    const workshops = [
      {
        id: 1,
        name: 'AvtoRemont №1',
        address: 'Toshkent, Yunusobod tumani',
        rating: 4.5,
        services: ['Dvigatel ta\'miri', 'Diagnostika', 'Elektrika'],
        working_hours: '08:00 - 20:00',
        phone: '+998901234567',
        distance: 2.5,
      },
      {
        id: 2,
        name: 'Car Service Premium',
        address: 'Toshkent, Chilonzor tumani',
        rating: 4.8,
        services: ['Kuzov ta\'miri', 'Bo\'yoq', 'Polirovka'],
        working_hours: '09:00 - 19:00',
        phone: '+998907654321',
        distance: 4.2,
      },
    ];

    res.json({
      success: true,
      data: { workshops },
    });
  } catch (error) {
    console.error('Get workshops error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Server xatosi' 
    });
  }
}

/**
 * Ehtiyot qismlar katalogi
 * GET /api/providers/parts
 */
async function getParts(req, res) {
  try {
    const { search, category } = req.query;

    // Bu yerda haqiqiy database dan ehtiyot qismlar ma'lumotlari kelishi kerak
    // Demo uchun static data
    const parts = [
      {
        id: 1,
        name: 'Moy filtri',
        category: 'Filtrlar',
        price: 45000,
        shop: 'AvtoZapchast №1',
        in_stock: true,
        image: null,
      },
      {
        id: 2,
        name: 'Tormoz kolodkalari (oldingi)',
        category: 'Tormoz tizimi',
        price: 280000,
        shop: 'AutoParts Center',
        in_stock: true,
        image: null,
      },
      {
        id: 3,
        name: 'Akkumulyator 60Ah',
        category: 'Elektrika',
        price: 650000,
        shop: 'Elektro Avto',
        in_stock: false,
        image: null,
      },
    ];

    let filteredParts = parts;

    if (search) {
      filteredParts = filteredParts.filter(p => 
        p.name.toLowerCase().includes(search.toLowerCase())
      );
    }

    if (category) {
      filteredParts = filteredParts.filter(p => p.category === category);
    }

    res.json({
      success: true,
      data: { 
        parts: filteredParts,
        total: filteredParts.length,
      },
    });
  } catch (error) {
    console.error('Get parts error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Server xatosi' 
    });
  }
}

module.exports = {
  getProviders,
  getNearbyProviders,
  getProviderById,
  getWorkshops,
  getParts,
};
