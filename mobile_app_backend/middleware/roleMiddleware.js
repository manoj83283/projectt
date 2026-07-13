// =====================================================
// ROLE AUTHORIZATION MIDDLEWARE
// =====================================================

export const authorizeRoles = (...roles) => {
  return (req, res, next) => {
    try {
      // User must be attached by authMiddleware.js
      if (!req.user) {
        res.status(401);
        throw new Error("Authentication required");
      }

      // Check role access
      if (!roles.includes(req.user.role)) {
        res.status(403);
        throw new Error(
          `Access denied. Allowed roles: ${roles.join(", ")}`
        );
      }

      next();
    } catch (error) {
      next(error);
    }
  };
};

// =====================================================
// ADMIN ONLY
// =====================================================

export const adminOnly = (
  req,
  res,
  next
) => {
  try {
    if (!req.user) {
      res.status(401);
      throw new Error("Authentication required");
    }

    if (req.user.role !== "admin") {
      res.status(403);
      throw new Error(
        "Admin access required"
      );
    }

    next();
  } catch (error) {
    next(error);
  }
};

// =====================================================
// PROVIDER ONLY
// =====================================================

export const providerOnly = (
  req,
  res,
  next
) => {
  try {
    if (!req.user) {
      res.status(401);
      throw new Error("Authentication required");
    }

    if (req.user.role !== "provider") {
      res.status(403);
      throw new Error(
        "Provider access required"
      );
    }

    next();
  } catch (error) {
    next(error);
  }
};

// =====================================================
// CUSTOMER ONLY
// =====================================================

export const customerOnly = (
  req,
  res,
  next
) => {
  try {
    if (!req.user) {
      res.status(401);
      throw new Error("Authentication required");
    }

    if (
      req.user.role !== "user" &&
      req.user.role !== "customer"
    ) {
      res.status(403);
      throw new Error(
        "Customer access required"
      );
    }

    next();
  } catch (error) {
    next(error);
  }
};