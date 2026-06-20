const db = require('../config/database');

/**
 * Yangi so'rov yaratish
 * POST /api/orders
 */
async function createOrder(req, res) {
  try {
    const userId = req.user.user_id;
    const { 
      service_type, 
      description, 
      pickup_location, 
      destination_location 
    } = req.body;

    if (!service_type || !pickup_location) {
      return res.status(400).json({ 
        success: false, 
        message: 'Xizmat turi va joylashuv majburiy' 
      });
    }

    // Yangi order yaratish
    const result = await db.query(
      `INSERT INTO orders 
       (client_id, service_type, description, pickup_location, destination_location, status) 
       VALUES ($1, $2, $3, ST_GeomFromText($4, 4326), ST_GeomFromText($5, 4326), 'pending') 
       RETURNING id, client_id, service_type, description, status, created_at`,
      [
        userId, 
        service_type, 
        description || null,
        pickup_location, // Format: 'POINT(lon lat)'
        destination_location || null,
      ]
    );

    const order = result.rows[0];

    // Socket.io orqali yaqin providerlarni xabardor qilish
    const io = req.app.get('io');
    io.emit('new_order', {
      order_id: order.id,
      service_type: order.service_type,
      message: 'Yangi so\'rov paydo bo\'ldi',
    });

    res.status(201).json({
      success: true,
      message: 'So\'rov yaratildi',
      data: { order },
    });
  } catch (error) {
    console.error('Create order error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Server xatosi' 
    });
  }
}

/**
 * So'rovlar ro'yxati
 * GET /api/orders
 */
async function getOrders(req, res) {
  try {
    const userId = req.user.user_id;
    const role = req.user.role;
    const { status } = req.query;

    let query;
    let params = [userId];

    if (role === 'client') {
      query = `
        SELECT o.*, 
               u.full_name as provider_name, 
               u.phone as provider_phone
        FROM orders o
        LEFT JOIN providers p ON o.provider_id = p.id
        LEFT JOIN users u ON p.user_id = u.id
        WHERE o.client_id = $1
      `;
    } else {
      query = `
        SELECT o.*, 
               u.full_name as client_name, 
               u.phone as client_phone
        FROM orders o
        JOIN users u ON o.client_id = u.id
        LEFT JOIN providers p ON o.provider_id = p.id
        WHERE (p.user_id = $1 OR o.status = 'pending')
      `;
    }

    if (status) {
      query += ` AND o.status = $2`;
      params.push(status);
    }

    query += ` ORDER BY o.created_at DESC LIMIT 50`;

    const result = await db.query(query, params);

    res.json({
      success: true,
      data: { orders: result.rows },
    });
  } catch (error) {
    console.error('Get orders error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Server xatosi' 
    });
  }
}

/**
 * Bitta so'rovni ko'rish
 * GET /api/orders/:id
 */
async function getOrderById(req, res) {
  try {
    const { id } = req.params;
    const userId = req.user.user_id;

    const result = await db.query(
      `SELECT o.*, 
              ST_AsText(o.pickup_location) as pickup_coords,
              ST_AsText(o.destination_location) as destination_coords,
              u1.full_name as client_name, 
              u1.phone as client_phone,
              u2.full_name as provider_name, 
              u2.phone as provider_phone,
              p.service_type as provider_service_type,
              p.rating as provider_rating
       FROM orders o
       JOIN users u1 ON o.client_id = u1.id
       LEFT JOIN providers p ON o.provider_id = p.id
       LEFT JOIN users u2 ON p.user_id = u2.id
       WHERE o.id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ 
        success: false, 
        message: 'So\'rov topilmadi' 
      });
    }

    const order = result.rows[0];

    // Faqat tegishli foydalanuvchilar ko'rishi mumkin
    if (order.client_id !== userId && order.provider_id !== userId) {
      return res.status(403).json({ 
        success: false, 
        message: 'Sizda bu so\'rovni ko\'rish huquqi yo\'q' 
      });
    }

    res.json({
      success: true,
      data: { order },
    });
  } catch (error) {
    console.error('Get order error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Server xatosi' 
    });
  }
}

/**
 * So'rovni qabul qilish (provider)
 * POST /api/orders/:id/accept
 */
async function acceptOrder(req, res) {
  try {
    const { id } = req.params;
    const userId = req.user.user_id;

    // Providerni topish
    const providerResult = await db.query(
      'SELECT id FROM providers WHERE user_id = $1',
      [userId]
    );

    if (providerResult.rows.length === 0) {
      return res.status(400).json({ 
        success: false, 
        message: 'Siz provider sifatida ro\'yxatdan o\'tmagansiz' 
      });
    }

    const providerId = providerResult.rows[0].id;

    // Orderni yangilash
    const result = await db.query(
      `UPDATE orders 
       SET provider_id = $1, status = 'accepted', accepted_at = NOW()
       WHERE id = $2 AND status = 'pending'
       RETURNING *`,
      [providerId, id]
    );

    if (result.rows.length === 0) {
      return res.status(400).json({ 
        success: false, 
        message: 'So\'rov topilmadi yoki allaqachon qabul qilingan' 
      });
    }

    const order = result.rows[0];

    // Mijozga xabar yuborish
    const io = req.app.get('io');
    io.to(`order:${id}`).emit('order:accepted', {
      order_id: order.id,
      provider_id: providerId,
      message: 'Sizning so\'rovingiz qabul qilindi',
    });

    res.json({
      success: true,
      message: 'So\'rov qabul qilindi',
      data: { order },
    });
  } catch (error) {
    console.error('Accept order error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Server xatosi' 
    });
  }
}

/**
 * Status o'zgartirish
 * PUT /api/orders/:id/status
 */
async function updateOrderStatus(req, res) {
  try {
    const { id } = req.params;
    const { status } = req.body;
    const userId = req.user.user_id;

    const validStatuses = ['pending', 'accepted', 'in_progress', 'completed', 'cancelled'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ 
        success: false, 
        message: 'Noto\'g\'ri status' 
      });
    }

    const result = await db.query(
      `UPDATE orders 
       SET status = $1, updated_at = NOW()
       WHERE id = $2
       RETURNING *`,
      [status, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ 
        success: false, 
        message: 'So\'rov topilmadi' 
      });
    }

    const order = result.rows[0];

    // Real-time update
    const io = req.app.get('io');
    io.to(`order:${id}`).emit('order:status_changed', {
      order_id: order.id,
      status: order.status,
    });

    res.json({
      success: true,
      message: 'Status yangilandi',
      data: { order },
    });
  } catch (error) {
    console.error('Update status error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Server xatosi' 
    });
  }
}

/**
 * So'rovni yakunlash
 * POST /api/orders/:id/complete
 */
async function completeOrder(req, res) {
  try {
    const { id } = req.params;

    const result = await db.query(
      `UPDATE orders 
       SET status = 'completed', completed_at = NOW()
       WHERE id = $1 AND status = 'in_progress'
       RETURNING *`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(400).json({ 
        success: false, 
        message: 'So\'rov topilmadi yoki yakunlanishi mumkin emas' 
      });
    }

    const order = result.rows[0];

    // Real-time notification
    const io = req.app.get('io');
    io.to(`order:${id}`).emit('order:completed', {
      order_id: order.id,
      message: 'Xizmat yakunlandi',
    });

    res.json({
      success: true,
      message: 'Xizmat yakunlandi',
      data: { order },
    });
  } catch (error) {
    console.error('Complete order error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Server xatosi' 
    });
  }
}

/**
 * So'rovni bekor qilish
 * POST /api/orders/:id/cancel
 */
async function cancelOrder(req, res) {
  try {
    const { id } = req.params;
    const { reason } = req.body;

    const result = await db.query(
      `UPDATE orders 
       SET status = 'cancelled', updated_at = NOW()
       WHERE id = $1 AND status IN ('pending', 'accepted')
       RETURNING *`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(400).json({ 
        success: false, 
        message: 'So\'rov topilmadi yoki bekor qilinishi mumkin emas' 
      });
    }

    res.json({
      success: true,
      message: 'So\'rov bekor qilindi',
    });
  } catch (error) {
    console.error('Cancel order error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Server xatosi' 
    });
  }
}

/**
 * Baho berish
 * POST /api/orders/:id/rate
 */
async function rateOrder(req, res) {
  try {
    const { id } = req.params;
    const userId = req.user.user_id;
    const { rating, comment } = req.body;

    if (!rating || rating < 1 || rating > 5) {
      return res.status(400).json({ 
        success: false, 
        message: 'Baho 1 dan 5 gacha bo\'lishi kerak' 
      });
    }

    // Orderni tekshirish
    const orderResult = await db.query(
      'SELECT * FROM orders WHERE id = $1 AND client_id = $2 AND status = $3',
      [id, userId, 'completed']
    );

    if (orderResult.rows.length === 0) {
      return res.status(400).json({ 
        success: false, 
        message: 'So\'rov topilmadi yoki yakunlanmagan' 
      });
    }

    const order = orderResult.rows[0];

    // Review qo'shish
    await db.query(
      `INSERT INTO reviews (order_id, provider_id, client_id, rating, comment)
       VALUES ($1, $2, $3, $4, $5)`,
      [id, order.provider_id, userId, rating, comment || null]
    );

    // Provider reytingini yangilash
    await db.query(
      `UPDATE providers 
       SET rating = (
         SELECT AVG(rating)::DECIMAL(3,2) 
         FROM reviews 
         WHERE provider_id = $1
       ),
       total_orders = total_orders + 1
       WHERE id = $1`,
      [order.provider_id]
    );

    res.json({
      success: true,
      message: 'Baho qo\'shildi',
    });
  } catch (error) {
    console.error('Rate order error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Server xatosi' 
    });
  }
}

module.exports = {
  createOrder,
  getOrders,
  getOrderById,
  acceptOrder,
  updateOrderStatus,
  completeOrder,
  cancelOrder,
  rateOrder,
};
