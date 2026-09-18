import jwt from "jsonwebtoken";

import User from "../models/user.js";

const getJwtSecret = () => {
  const secret = process.env.JWT_SECRET;

  if (secret) {
    return secret;
  }

  if (process.env.NODE_ENV === "production") {
    throw new Error(
      "JWT_SECRET is not configured"
    );
  }

  console.warn(
    "JWT_SECRET is not configured. " +
      "Using development fallback secret."
  );

  return "eventease-development-secret";
};

const extractBearerToken = (
  authorizationHeader
) => {
  if (
    !authorizationHeader ||
    typeof authorizationHeader !== "string"
  ) {
    return null;
  }

  const parts = authorizationHeader
    .trim()
    .split(/\s+/);

  if (
    parts.length !== 2 ||
    parts[0].toLowerCase() !== "bearer"
  ) {
    return null;
  }

  const token = parts[1]?.trim();

  return token || null;
};

const sendAuthError = (
  res,
  statusCode,
  message
) => {
  return res.status(statusCode).json({
    success: false,
    message,
    msg: message,
  });
};

export const protect = async (
  req,
  res,
  next
) => {
  try {
    const token = extractBearerToken(
      req.headers.authorization
    );

    if (!token) {
      return sendAuthError(
        res,
        401,
        "Not authorized, no token"
      );
    }

    let decoded;

    try {
      decoded = jwt.verify(
        token,
        getJwtSecret()
      );
    } catch (error) {
      console.error(
        "JWT verification failed:",
        error.message
      );

      const message =
        error.name === "TokenExpiredError"
          ? "Authentication token has expired"
          : "Not authorized, token failed";

      return sendAuthError(
        res,
        401,
        message
      );
    }

    if (
      decoded.type &&
      decoded.type !== "access"
    ) {
      return sendAuthError(
        res,
        401,
        "Invalid authentication token type"
      );
    }

    const userId =
      decoded.id ||
      decoded._id ||
      decoded.userId;

    if (!userId) {
      return sendAuthError(
        res,
        401,
        "Authentication token does not contain a user ID"
      );
    }

    const user = await User.findById(
      userId
    ).select("-password");

    if (!user) {
      return sendAuthError(
        res,
        401,
        "User associated with this token was not found"
      );
    }

    if (user.isActive === false) {
      return sendAuthError(
        res,
        403,
        "This account is inactive"
      );
    }

    if (user.isBlocked === true) {
      return sendAuthError(
        res,
        403,
        "This account is blocked"
      );
    }

    req.user = user;
    req.userId = user._id.toString();

    req.auth = {
      token,
      userId: user._id.toString(),
      role: user.role,
    };

    console.log(
      "AUTHENTICATED REQUEST:",
      {
        method: req.method,
        path: req.originalUrl,
        userId: user._id.toString(),
        role: user.role,
      }
    );

    return next();
  } catch (error) {
    console.error(
      "Authentication middleware error:",
      error
    );

    return sendAuthError(
      res,
      500,
      "Unable to validate authentication"
    );
  }
};

export const authorizeRoles = (
  ...allowedRoles
) => {
  const normalizedRoles = allowedRoles
    .flat()
    .map((role) =>
      role
        ?.toString()
        .trim()
        .toLowerCase()
    )
    .filter(Boolean);

  return (req, res, next) => {
    if (!req.user) {
      return sendAuthError(
        res,
        401,
        "Authentication required"
      );
    }

    const currentRole = req.user.role
      ?.toString()
      .trim()
      .toLowerCase();

    if (
      !normalizedRoles.includes(
        currentRole
      )
    ) {
      return sendAuthError(
        res,
        403,
        "Access denied: insufficient permissions"
      );
    }

    return next();
  };
};

export const isCustomer = (
  req,
  res,
  next
) => {
  if (!req.user) {
    return sendAuthError(
      res,
      401,
      "Authentication required"
    );
  }

  const currentRole = req.user.role
    ?.toString()
    .trim()
    .toLowerCase();

  if (
    currentRole !== "user" &&
    currentRole !== "customer"
  ) {
    return sendAuthError(
      res,
      403,
      "Access denied: Customer account required"
    );
  }

  return next();
};

export const isProvider = (
  req,
  res,
  next
) => {
  if (!req.user) {
    return sendAuthError(
      res,
      401,
      "Authentication required"
    );
  }

  const currentRole = req.user.role
    ?.toString()
    .trim()
    .toLowerCase();

  if (currentRole !== "provider") {
    return sendAuthError(
      res,
      403,
      "Access denied: Provider account required"
    );
  }

  return next();
};

export const isAdmin = (
  req,
  res,
  next
) => {
  if (!req.user) {
    return sendAuthError(
      res,
      401,
      "Authentication required"
    );
  }

  const currentRole = req.user.role
    ?.toString()
    .trim()
    .toLowerCase();

  if (currentRole !== "admin") {
    return sendAuthError(
      res,
      403,
      "Access denied: Admin account required"
    );
  }

  return next();
};

export const optionalProtect = async (
  req,
  res,
  next
) => {
  try {
    const token = extractBearerToken(
      req.headers.authorization
    );

    if (!token) {
      req.user = null;
      req.userId = null;
      req.auth = null;

      return next();
    }

    let decoded;

    try {
      decoded = jwt.verify(
        token,
        getJwtSecret()
      );
    } catch (error) {
      req.user = null;
      req.userId = null;
      req.auth = null;

      return next();
    }

    if (
      decoded.type &&
      decoded.type !== "access"
    ) {
      req.user = null;
      req.userId = null;
      req.auth = null;

      return next();
    }

    const userId =
      decoded.id ||
      decoded._id ||
      decoded.userId;

    if (!userId) {
      req.user = null;
      req.userId = null;
      req.auth = null;

      return next();
    }

    const user = await User.findById(
      userId
    ).select("-password");

    if (
      !user ||
      user.isActive === false ||
      user.isBlocked === true
    ) {
      req.user = null;
      req.userId = null;
      req.auth = null;

      return next();
    }

    req.user = user;
    req.userId = user._id.toString();

    req.auth = {
      token,
      userId: user._id.toString(),
      role: user.role,
    };

    return next();
  } catch (error) {
    console.error(
      "Optional authentication error:",
      error.message
    );

    req.user = null;
    req.userId = null;
    req.auth = null;

    return next();
  }
};