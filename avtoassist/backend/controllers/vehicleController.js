const db = require('../config/database');

/**
 * Yangi avtomobil qo'shish
 * POST /api/vehicles
 */
async function createVehicle(req, res) {
  try {
    const userId = req.user.user_id;
    const { brand, model, year, plate_number, current_mileage } = req.body;

    if (!brand || !model) {
      return res.status(400).json({
        success: false,
        message: 'Marka va model majburiy',
      });
    }

    const result = await db.query(
      `INSERT INTO vehicles (user_id, brand, model, year, plate_number, current_mileage)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING *`,
      [userId, brand, model, year || null, plate_number || null, current_mileage || 0]
    );

    res.status(201).json({
      success: true,
      message: 'Avtomobil qo\'shildi',
      data: { vehicle: result.rows[0] },
    });
  } catch (error) {
    console.error('Create vehicle error:', error);
    res.status(500).json({ success: false, message: 'Server xatosi' });
  }
}

/**
 * Foydalanuvchining avtomobillari
 * GET /api/vehicles
 */
async function getVehicles(req, res) {
  try {
    const userId = req.user.user_id;

    const result = await db.query(
      `SELECT v.*,
              (SELECT COUNT(*) FROM oil_changes WHERE vehicle_id = v.id) as oil_changes_count,
              (SELECT changed_at FROM oil_changes WHERE vehicle_id = v.id ORDER BY changed_at DESC LIMIT 1) as last_oil_change
       FROM vehicles v
       WHERE v.user_id = $1
       ORDER BY v.created_at DESC`,
      [userId]
    );

    res.json({
      success: true,
      data: { vehicles: result.rows },
    });
  } catch (error) {
    console.error('Get vehicles error:', error);
    res.status(500).json({ success: false, message: 'Server xatosi' });
  }
}

/**
 * Bitta avtomobil ma'lumotlari
 * GET /api/vehicles/:id
 */
async function getVehicleById(req, res) {
  try {
    const userId = req.user.user_id;
    const { id } = req.params;

    const result = await db.query(
      'SELECT * FROM vehicles WHERE id = $1 AND user_id = $2',
      [id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Avtomobil topilmadi',
      });
    }

    res.json({
      success: true,
      data: { vehicle: result.rows[0] },
    });
  } catch (error) {
    console.error('Get vehicle error:', error);
    res.status(500).json({ success: false, message: 'Server xatosi' });
  }
}

/**
 * Avtomobilni yangilash
 * PUT /api/vehicles/:id
 */
async function updateVehicle(req, res) {
  try {
    const userId = req.user.user_id;
    const { id } = req.params;
    const { brand, model, year, plate_number, current_mileage } = req.body;

    const result = await db.query(
      `UPDATE vehicles 
       SET brand = $1, model = $2, year = $3, plate_number = $4, current_mileage = $5
       WHERE id = $6 AND user_id = $7
       RETURNING *`,
      [brand, model, year, plate_number, current_mileage, id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Avtomobil topilmadi',
      });
    }

    res.json({
      success: true,
      message: 'Avtomobil yangilandi',
      data: { vehicle: result.rows[0] },
    });
  } catch (error) {
    console.error('Update vehicle error:', error);
    res.status(500).json({ success: false, message: 'Server xatosi' });
  }
}

/**
 * Avtomobilni o'chirish
 * DELETE /api/vehicles/:id
 */
async function deleteVehicle(req, res) {
  try {
    const userId = req.user.user_id;
    const { id } = req.params;

    const result = await db.query(
      'DELETE FROM vehicles WHERE id = $1 AND user_id = $2 RETURNING id',
      [id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Avtomobil topilmadi',
      });
    }

    res.json({
      success: true,
      message: 'Avtomobil o\'chirildi',
    });
  } catch (error) {
    console.error('Delete vehicle error:', error);
    res.status(500).json({ success: false, message: 'Server xatosi' });
  }
}

/**
 * Moy almashtirish qo'shish
 * POST /api/vehicles/:vehicleId/oil-changes
 */
async function addOilChange(req, res) {
  try {
    const userId = req.user.user_id;
    const { vehicleId } = req.params;
    const {
      oil_type,
      oil_brand,
      mileage,
      next_change_mileage,
      location,
      workshop_name,
      price,
      notes,
      changed_at,
    } = req.body;

    if (!oil_type || !mileage || !changed_at) {
      return res.status(400).json({
        success: false,
        message: 'Moy turi, kilometraj va sana majburiy',
      });
    }

    // Vehicle ownership check
    const vehicleCheck = await db.query(
      'SELECT id FROM vehicles WHERE id = $1 AND user_id = $2',
      [vehicleId, userId]
    );

    if (vehicleCheck.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Avtomobil topilmadi',
      });
    }

    const result = await db.query(
      `INSERT INTO oil_changes 
       (user_id, vehicle_id, oil_type, oil_brand, mileage, next_change_mileage, 
        location, workshop_name, price, notes, changed_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
       RETURNING *`,
      [
        userId,
        vehicleId,
        oil_type,
        oil_brand || null,
        mileage,
        next_change_mileage || null,
        location || null,
        workshop_name || null,
        price || null,
        notes || null,
        changed_at,
      ]
    );

    // Update vehicle mileage
    await db.query(
      'UPDATE vehicles SET current_mileage = $1 WHERE id = $2',
      [mileage, vehicleId]
    );

    // Create reminder if next_change_mileage provided
    if (next_change_mileage) {
      await db.query(
        `INSERT INTO maintenance_reminders 
         (user_id, vehicle_id, reminder_type, title, due_mileage)
         VALUES ($1, $2, 'oil_change', 'Moy almashtirish vaqti', $3)`,
        [userId, vehicleId, next_change_mileage]
      );
    }

    res.status(201).json({
      success: true,
      message: 'Moy almashtirish qo\'shildi',
      data: { oil_change: result.rows[0] },
    });
  } catch (error) {
    console.error('Add oil change error:', error);
    res.status(500).json({ success: false, message: 'Server xatosi' });
  }
}

/**
 * Moy almashtirish tarixi
 * GET /api/vehicles/:vehicleId/oil-changes
 */
async function getOilChanges(req, res) {
  try {
    const userId = req.user.user_id;
    const { vehicleId } = req.params;

    const result = await db.query(
      `SELECT oc.*, v.brand, v.model
       FROM oil_changes oc
       JOIN vehicles v ON oc.vehicle_id = v.id
       WHERE oc.vehicle_id = $1 AND oc.user_id = $2
       ORDER BY oc.changed_at DESC`,
      [vehicleId, userId]
    );

    res.json({
      success: true,
      data: { oil_changes: result.rows },
    });
  } catch (error) {
    console.error('Get oil changes error:', error);
    res.status(500).json({ success: false, message: 'Server xatosi' });
  }
}

/**
 * Bitta moy almashtirish ma'lumoti
 * GET /api/vehicles/oil-changes/:id
 */
async function getOilChangeById(req, res) {
  try {
    const userId = req.user.user_id;
    const { id } = req.params;

    const result = await db.query(
      'SELECT * FROM oil_changes WHERE id = $1 AND user_id = $2',
      [id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Ma\'lumot topilmadi',
      });
    }

    res.json({
      success: true,
      data: { oil_change: result.rows[0] },
    });
  } catch (error) {
    console.error('Get oil change error:', error);
    res.status(500).json({ success: false, message: 'Server xatosi' });
  }
}

/**
 * Moy almashtirish ma'lumotini yangilash
 * PUT /api/vehicles/oil-changes/:id
 */
async function updateOilChange(req, res) {
  try {
    const userId = req.user.user_id;
    const { id } = req.params;
    const {
      oil_type,
      oil_brand,
      mileage,
      next_change_mileage,
      location,
      workshop_name,
      price,
      notes,
      changed_at,
    } = req.body;

    const result = await db.query(
      `UPDATE oil_changes
       SET oil_type = $1, oil_brand = $2, mileage = $3, 
           next_change_mileage = $4, location = $5, workshop_name = $6,
           price = $7, notes = $8, changed_at = $9
       WHERE id = $10 AND user_id = $11
       RETURNING *`,
      [
        oil_type,
        oil_brand,
        mileage,
        next_change_mileage,
        location,
        workshop_name,
        price,
        notes,
        changed_at,
        id,
        userId,
      ]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Ma\'lumot topilmadi',
      });
    }

    res.json({
      success: true,
      message: 'Ma\'lumot yangilandi',
      data: { oil_change: result.rows[0] },
    });
  } catch (error) {
    console.error('Update oil change error:', error);
    res.status(500).json({ success: false, message: 'Server xatosi' });
  }
}

/**
 * Moy almashtirish ma'lumotini o'chirish
 * DELETE /api/vehicles/oil-changes/:id
 */
async function deleteOilChange(req, res) {
  try {
    const userId = req.user.user_id;
    const { id } = req.params;

    const result = await db.query(
      'DELETE FROM oil_changes WHERE id = $1 AND user_id = $2 RETURNING id',
      [id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Ma\'lumot topilmadi',
      });
    }

    res.json({
      success: true,
      message: 'Ma\'lumot o\'chirildi',
    });
  } catch (error) {
    console.error('Delete oil change error:', error);
    res.status(500).json({ success: false, message: 'Server xatosi' });
  }
}

/**
 * Eslatma yaratish
 * POST /api/vehicles/:vehicleId/reminders
 */
async function createReminder(req, res) {
  try {
    const userId = req.user.user_id;
    const { vehicleId } = req.params;
    const { reminder_type, title, description, due_mileage, due_date } = req.body;

    const result = await db.query(
      `INSERT INTO maintenance_reminders
       (user_id, vehicle_id, reminder_type, title, description, due_mileage, due_date)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING *`,
      [userId, vehicleId, reminder_type, title, description, due_mileage, due_date]
    );

    res.status(201).json({
      success: true,
      message: 'Eslatma yaratildi',
      data: { reminder: result.rows[0] },
    });
  } catch (error) {
    console.error('Create reminder error:', error);
    res.status(500).json({ success: false, message: 'Server xatosi' });
  }
}

/**
 * Eslatmalar ro'yxati
 * GET /api/vehicles/:vehicleId/reminders
 */
async function getReminders(req, res) {
  try {
    const userId = req.user.user_id;
    const { vehicleId } = req.params;

    const result = await db.query(
      `SELECT mr.*, v.brand, v.model, v.current_mileage
       FROM maintenance_reminders mr
       JOIN vehicles v ON mr.vehicle_id = v.id
       WHERE mr.vehicle_id = $1 AND mr.user_id = $2
       ORDER BY mr.is_completed ASC, mr.due_date ASC`,
      [vehicleId, userId]
    );

    res.json({
      success: true,
      data: { reminders: result.rows },
    });
  } catch (error) {
    console.error('Get reminders error:', error);
    res.status(500).json({ success: false, message: 'Server xatosi' });
  }
}

/**
 * Eslatmani bajarilgan deb belgilash
 * PUT /api/vehicles/reminders/:id/complete
 */
async function completeReminder(req, res) {
  try {
    const userId = req.user.user_id;
    const { id } = req.params;

    const result = await db.query(
      `UPDATE maintenance_reminders
       SET is_completed = true, completed_at = NOW()
       WHERE id = $1 AND user_id = $2
       RETURNING *`,
      [id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Eslatma topilmadi',
      });
    }

    res.json({
      success: true,
      message: 'Eslatma bajarilgan deb belgilandi',
      data: { reminder: result.rows[0] },
    });
  } catch (error) {
    console.error('Complete reminder error:', error);
    res.status(500).json({ success: false, message: 'Server xatosi' });
  }
}

/**
 * Eslatmani o'chirish
 * DELETE /api/vehicles/reminders/:id
 */
async function deleteReminder(req, res) {
  try {
    const userId = req.user.user_id;
    const { id } = req.params;

    const result = await db.query(
      'DELETE FROM maintenance_reminders WHERE id = $1 AND user_id = $2 RETURNING id',
      [id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Eslatma topilmadi',
      });
    }

    res.json({
      success: true,
      message: 'Eslatma o\'chirildi',
    });
  } catch (error) {
    console.error('Delete reminder error:', error);
    res.status(500).json({ success: false, message: 'Server xatosi' });
  }
}

/**
 * Avtomobil statistikasi
 * GET /api/vehicles/:vehicleId/stats
 */
async function getVehicleStats(req, res) {
  try {
    const userId = req.user.user_id;
    const { vehicleId } = req.params;

    // Oil change stats
    const oilStats = await db.query(
      `SELECT 
         COUNT(*) as total_oil_changes,
         AVG(price) as avg_price,
         SUM(price) as total_spent,
         MAX(changed_at) as last_change_date,
         MAX(mileage) as last_change_mileage
       FROM oil_changes
       WHERE vehicle_id = $1 AND user_id = $2`,
      [vehicleId, userId]
    );

    // Upcoming reminders
    const reminders = await db.query(
      `SELECT COUNT(*) as pending_reminders
       FROM maintenance_reminders
       WHERE vehicle_id = $1 AND user_id = $2 AND is_completed = false`,
      [vehicleId, userId]
    );

    res.json({
      success: true,
      data: {
        oil_changes: oilStats.rows[0],
        reminders: reminders.rows[0],
      },
    });
  } catch (error) {
    console.error('Get vehicle stats error:', error);
    res.status(500).json({ success: false, message: 'Server xatosi' });
  }
}

module.exports = {
  createVehicle,
  getVehicles,
  getVehicleById,
  updateVehicle,
  deleteVehicle,
  addOilChange,
  getOilChanges,
  getOilChangeById,
  updateOilChange,
  deleteOilChange,
  createReminder,
  getReminders,
  completeReminder,
  deleteReminder,
  getVehicleStats,
};
