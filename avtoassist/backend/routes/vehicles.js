const express = require('express');
const router = express.Router();
const vehicleController = require('../controllers/vehicleController');
const { authenticate } = require('../middleware/auth');

// Vehicle CRUD
router.post('/', authenticate, vehicleController.createVehicle);
router.get('/', authenticate, vehicleController.getVehicles);
router.get('/:id', authenticate, vehicleController.getVehicleById);
router.put('/:id', authenticate, vehicleController.updateVehicle);
router.delete('/:id', authenticate, vehicleController.deleteVehicle);

// Oil changes
router.post('/:vehicleId/oil-changes', authenticate, vehicleController.addOilChange);
router.get('/:vehicleId/oil-changes', authenticate, vehicleController.getOilChanges);
router.get('/oil-changes/:id', authenticate, vehicleController.getOilChangeById);
router.put('/oil-changes/:id', authenticate, vehicleController.updateOilChange);
router.delete('/oil-changes/:id', authenticate, vehicleController.deleteOilChange);

// Maintenance reminders
router.post('/:vehicleId/reminders', authenticate, vehicleController.createReminder);
router.get('/:vehicleId/reminders', authenticate, vehicleController.getReminders);
router.put('/reminders/:id/complete', authenticate, vehicleController.completeReminder);
router.delete('/reminders/:id', authenticate, vehicleController.deleteReminder);

// Statistics
router.get('/:vehicleId/stats', authenticate, vehicleController.getVehicleStats);

module.exports = router;
