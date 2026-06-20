/**
 * Global error handler middleware
 */
function errorHandler(err, req, res, next) {
  console.error('Error:', err);

  const statusCode = err.statusCode || 500;
  const message = err.message || 'Server xatosi';

  res.status(statusCode).json({
    success: false,
    message,
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
  });
}

/**
 * 404 handler
 */
function notFoundHandler(req, res) {
  res.status(404).json({
    success: false,
    message: 'API endpoint topilmadi',
  });
}

module.exports = {
  errorHandler,
  notFoundHandler,
};
