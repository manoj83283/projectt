// =====================================================
// NOT FOUND MIDDLEWARE
// =====================================================

export const notFound = (
  req,
  res,
  next
) => {
  const error = new Error(
    `Route Not Found - ${req.originalUrl}`
  );

  res.status(404);

  next(error);
};

// =====================================================
// GLOBAL ERROR HANDLER
// =====================================================

export const errorHandler = (
  err,
  req,
  res,
  next
) => {
  console.error("❌ Error:", err);

  let statusCode =
    res.statusCode && res.statusCode !== 200
      ? res.statusCode
      : 500;

  let message = err.message;

  // =====================================================
  // INVALID OBJECT ID
  // =====================================================

  if (err.name === "CastError") {
    statusCode = 400;
    message = "Invalid ID format";
  }

  // =====================================================
  // MONGOOSE VALIDATION ERROR
  // =====================================================

  if (err.name === "ValidationError") {
    statusCode = 400;

    message = Object.values(err.errors)
      .map((item) => item.message)
      .join(", ");
  }

  // =====================================================
  // DUPLICATE KEY ERROR
  // =====================================================

  if (err.code === 11000) {
    statusCode = 400;

    const field = Object.keys(
      err.keyValue || {}
    )[0];

    message = `${field} already exists`;
  }

  // =====================================================
  // JWT INVALID
  // =====================================================

  if (err.name === "JsonWebTokenError") {
    statusCode = 401;
    message = "Invalid token";
  }

  // =====================================================
  // JWT EXPIRED
  // =====================================================

  if (err.name === "TokenExpiredError") {
    statusCode = 401;
    message = "Token expired";
  }

  // =====================================================
  // RESPONSE
  // =====================================================

  res.status(statusCode).json({
    success: false,
    statusCode,
    message,

    stack:
      process.env.NODE_ENV ===
      "production"
        ? null
        : err.stack,
  });
};