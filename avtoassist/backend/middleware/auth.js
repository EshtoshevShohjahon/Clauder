const { verifyToken } = require('../config/jwt');

/**
 * Authentication middleware - JWT tokenni tekshiradi
 */
function authenticate(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ 
      success: false, 
      message: 'Token topilmadi' 
    });
  }

  const token = authHeader.substring(7); // "Bearer " ni olib tashlash
  const decoded = verifyToken(token);

  if (!decoded) {
    return res.status(401).json({ 
      success: false, 
      message: 'Noto\'g\'ri yoki muddati o\'tgan token' 
    });
  }

  req.user = decoded; // user_id va role
  next();
}

/**
 * Role-based authorization middleware
 */
function authorize(...allowedRoles) {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ 
        success: false, 
        message: 'Autentifikatsiya talab qilinadi' 
      });
    }

    if (!allowedRoles.includes(req.user.role)) {
      return res.status(403).json({ 
        success: false, 
        message: 'Sizda bu resursga kirish huquqi yo\'q' 
      });
    }

    next();
  };
}

module.exports = {
  authenticate,
  authorize,
};
