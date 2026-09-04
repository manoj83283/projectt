import jwt from "jsonwebtoken";

import User from "../models/user.js";
import { sendNotification } from "../utils/notification.js";

// =====================================================
// CONSTANTS
// =====================================================

const ACCESS_TOKEN_EXPIRY =
  process.env.JWT_EXPIRES_IN || "7d";

const REFRESH_TOKEN_EXPIRY =
  process.env.JWT_REFRESH_EXPIRES_IN ||
  "30d";

// =====================================================
// NORMALIZATION HELPERS
// =====================================================

const normalizeString = (
  value,
  fallback = ""
) => {
  if (
    value === null ||
    value === undefined
  ) {
    return fallback;
  }

  const normalizedValue =
    value.toString().trim();

  return normalizedValue || fallback;
};

const normalizeEmail = (value) => {
  return normalizeString(value)
    .toLowerCase();
};

const normalizeRole = (value) => {
  const role = normalizeString(
    value,
    "user"
  ).toLowerCase();

  return role === "provider"
    ? "provider"
    : "user";
};

// =====================================================
// NAME HELPERS
// =====================================================

const resolveUserName = ({
  firstName,
  lastName,
  fullName,
  name,
}) => {
  let resolvedFirstName =
    normalizeString(firstName);

  let resolvedLastName =
    normalizeString(lastName);

  const resolvedFullName =
    normalizeString(
      fullName || name
    );

  if (
    (!resolvedFirstName ||
      !resolvedLastName) &&
    resolvedFullName
  ) {
    const parts =
      resolvedFullName
        .split(/\s+/)
        .filter(Boolean);

    if (!resolvedFirstName) {
      resolvedFirstName =
        parts[0] || "";
    }

    if (!resolvedLastName) {
      resolvedLastName =
        parts.slice(1).join(" ");
    }
  }

  /*
   * Some Customer registration screens submit only one
   * name. A single-word name should not cause signup to
   * fail.
   */
  if (
    resolvedFirstName &&
    !resolvedLastName
  ) {
    resolvedLastName = "Customer";
  }

  return {
    firstName: resolvedFirstName,
    lastName: resolvedLastName,
    fullName: [
      resolvedFirstName,
      resolvedLastName,
    ]
      .filter(Boolean)
      .join(" ")
      .trim(),
  };
};

// =====================================================
// TOKEN HELPERS
// =====================================================

const getJwtSecret = () => {
  const secret =
    process.env.JWT_SECRET;

  if (!secret) {
    if (
      process.env.NODE_ENV ===
      "production"
    ) {
      throw new Error(
        "JWT_SECRET is not configured"
      );
    }

    console.warn(
      "JWT_SECRET is not configured. " +
        "Using development fallback secret."
    );

    return "eventease-development-secret";
  }

  return secret;
};

const getRefreshTokenSecret = () => {
  return (
    process.env.JWT_REFRESH_SECRET ||
    getJwtSecret()
  );
};

const generateAccessToken = (user) => {
  return jwt.sign(
    {
      id: user._id.toString(),
      role: user.role,
      type: "access",
    },
    getJwtSecret(),
    {
      expiresIn:
        ACCESS_TOKEN_EXPIRY,
    }
  );
};

const generateRefreshToken = (user) => {
  return jwt.sign(
    {
      id: user._id.toString(),
      role: user.role,
      type: "refresh",
    },
    getRefreshTokenSecret(),
    {
      expiresIn:
        REFRESH_TOKEN_EXPIRY,
    }
  );
};

// Existing imports may still use generateToken.
export const generateToken =
  generateAccessToken;

// =====================================================
// RESPONSE HELPERS
// =====================================================

const sanitizeUser = (user) => {
  if (!user) {
    return null;
  }

  const userObject =
    typeof user.toObject === "function"
      ? user.toObject({
          virtuals: true,
        })
      : { ...user };

  delete userObject.password;
  delete userObject.resetPasswordToken;
  delete userObject.resetPasswordExpires;
  delete userObject.__v;

  return {
    ...userObject,
    id:
      userObject._id?.toString() ||
      userObject.id?.toString() ||
      "",
  };
};

const sendAuthResponse = (
  res,
  user,
  {
    statusCode = 200,
    message =
      "Authentication successful",
  } = {}
) => {
  const token =
    generateAccessToken(user);

  const refreshToken =
    generateRefreshToken(user);

  const sanitizedUser =
    sanitizeUser(user);

  return res.status(statusCode).json({
    success: true,
    message,
    token,
    accessToken: token,
    refreshToken,
    user: sanitizedUser,
    data: {
      token,
      accessToken: token,
      refreshToken,
      user: sanitizedUser,
    },
  });
};

const sendControllerError = (
  res,
  label,
  error
) => {
  console.error(
    `${label}:`,
    error
  );

  if (
    error?.name ===
    "ValidationError"
  ) {
    const errors = Object.values(
      error.errors || {}
    ).map((item) => item.message);

    return res.status(400).json({
      success: false,
      message:
        errors[0] ||
        "Validation failed",
      msg:
        errors[0] ||
        "Validation failed",
      errors,
    });
  }

  if (error?.code === 11000) {
    return res.status(409).json({
      success: false,
      message:
        "An account with these details already exists",
      msg:
        "An account with these details already exists",
    });
  }

  return res.status(500).json({
    success: false,
    message:
      error?.message ||
      "Internal server error",
    msg:
      error?.message ||
      "Internal server error",
  });
};

// =====================================================
// SIGNUP
// POST /api/auth/signup
// POST /api/auth/register
// =====================================================

export const signup = async (
  req,
  res
) => {
  try {
    const {
      firstName,
      lastName,
      fullName,
      name,
      email,
      phone,
      mobile,
      password,
      role,
      userType,
      dob,
      location,
      shopName,
      businessName,
    } = req.body;

    const resolvedName =
      resolveUserName({
        firstName,
        lastName,
        fullName,
        name,
      });

    const normalizedEmail =
      normalizeEmail(email);

    const normalizedPhone =
      normalizeString(
        phone || mobile
      );

    const normalizedPassword =
      normalizeString(password);

    const normalizedRole =
      normalizeRole(
        role || userType
      );

    const finalShopName =
      normalizeString(
        shopName || businessName
      );

    if (!resolvedName.firstName) {
      return res.status(400).json({
        success: false,
        message:
          "Customer first name is required",
        msg:
          "Customer first name is required",
      });
    }

    if (!normalizedEmail) {
      return res.status(400).json({
        success: false,
        message:
          "Email is required",
        msg:
          "Email is required",
      });
    }

    if (!normalizedPhone) {
      return res.status(400).json({
        success: false,
        message:
          "Phone number is required",
        msg:
          "Phone number is required",
      });
    }

    if (!normalizedPassword) {
      return res.status(400).json({
        success: false,
        message:
          "Password is required",
        msg:
          "Password is required",
      });
    }

    if (
      normalizedPassword.length < 6
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Password must contain at least 6 characters",
        msg:
          "Password must contain at least 6 characters",
      });
    }

    let normalizedDob = null;

    if (dob) {
      normalizedDob = new Date(dob);

      if (
        Number.isNaN(
          normalizedDob.getTime()
        )
      ) {
        return res.status(400).json({
          success: false,
          message:
            "Invalid date of birth",
          msg:
            "Invalid date of birth",
        });
      }

      const today = new Date();

      let age =
        today.getFullYear() -
        normalizedDob.getFullYear();

      const birthdayOccurred =
        today.getMonth() >
          normalizedDob.getMonth() ||
        (
          today.getMonth() ===
            normalizedDob.getMonth() &&
          today.getDate() >=
            normalizedDob.getDate()
        );

      if (!birthdayOccurred) {
        age -= 1;
      }

      if (age < 18) {
        return res.status(400).json({
          success: false,
          message:
            "You must be at least 18 years old",
          msg:
            "You must be at least 18 years old",
        });
      }
    }

    const existingUser =
      await User.findOne({
        $or: [
          {
            email:
              normalizedEmail,
          },
          {
            phone:
              normalizedPhone,
          },
        ],
      });

    if (existingUser) {
      const duplicateField =
        existingUser.email ===
        normalizedEmail
          ? "email"
          : "phone number";

      return res.status(409).json({
        success: false,
        message:
          `An account with this ${duplicateField} already exists`,
        msg:
          `An account with this ${duplicateField} already exists`,
      });
    }

    const userData = {
      firstName:
        resolvedName.firstName,

      lastName:
        resolvedName.lastName,

      name:
        resolvedName.fullName,

      fullName:
        resolvedName.fullName,

      email:
        normalizedEmail,

      phone:
        normalizedPhone,

      mobile:
        normalizedPhone,

      password:
        normalizedPassword,

      dob:
        normalizedDob,

      location:
        location || null,

      role:
        normalizedRole,

      shopName:
        finalShopName,

      businessName:
        finalShopName,
    };

    /*
     * Only include schema-supported fields.
     * This keeps compatibility with different User model
     * versions while strict mode is enabled.
     */
    const schemaPaths =
      User.schema?.paths || {};

    const supportedUserData = {};

    for (
      const [key, value] of
      Object.entries(userData)
    ) {
      if (
        schemaPaths[key] &&
        value !== undefined
      ) {
        supportedUserData[key] =
          value;
      }
    }

    const user =
      await User.create(
        supportedUserData
      );

    if (user.fcmToken) {
      try {
        await sendNotification(
          user.fcmToken,
          "Welcome to EventEase",
          "Your account was created successfully."
        );
      } catch (notificationError) {
        console.error(
          "Welcome notification error:",
          notificationError.message
        );
      }
    }

    return sendAuthResponse(
      res,
      user,
      {
        statusCode: 201,
        message:
          "Signup successful",
      }
    );
  } catch (error) {
    return sendControllerError(
      res,
      "Signup Error",
      error
    );
  }
};

// =====================================================
// SIGNIN
// POST /api/auth/signin
// POST /api/auth/login
// =====================================================

export const signin = async (
  req,
  res
) => {
  try {
    const email =
      normalizeEmail(req.body.email);

    const password =
      normalizeString(
        req.body.password
      );

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message:
          "Email and password are required",
        msg:
          "Email and password are required",
      });
    }

    /*
     * Password may be excluded by default in the User
     * schema. Explicitly selecting it keeps signin working
     * for models configured with select: false.
     */
    const user =
      await User.findOne({
        email,
      }).select("+password");

    if (!user) {
      return res.status(401).json({
        success: false,
        message:
          "Invalid email or password",
        msg:
          "Invalid email or password",
      });
    }

    let passwordMatches = false;

    if (
      typeof user.matchPassword ===
      "function"
    ) {
      passwordMatches =
        await user.matchPassword(
          password
        );
    } else if (
      typeof user.comparePassword ===
      "function"
    ) {
      passwordMatches =
        await user.comparePassword(
          password
        );
    } else {
      throw new Error(
        "User model does not expose matchPassword or comparePassword"
      );
    }

    if (!passwordMatches) {
      return res.status(401).json({
        success: false,
        message:
          "Invalid email or password",
        msg:
          "Invalid email or password",
      });
    }

    if (
      user.isActive === false ||
      user.isBlocked === true
    ) {
      return res.status(403).json({
        success: false,
        message:
          "This account is unavailable",
        msg:
          "This account is unavailable",
      });
    }

    return sendAuthResponse(
      res,
      user,
      {
        statusCode: 200,
        message:
          "Login successful",
      }
    );
  } catch (error) {
    return sendControllerError(
      res,
      "Signin Error",
      error
    );
  }
};

// =====================================================
// GOOGLE LOGIN
// POST /api/auth/google
// POST /api/auth/google-login
// =====================================================

export const googleLogin = async (
  req,
  res
) => {
  try {
    const email =
      normalizeEmail(req.body.email);

    const name =
      normalizeString(
        req.body.name,
        "Google User"
      );

    const requestedRole =
      normalizeRole(req.body.role);

    if (!email) {
      return res.status(400).json({
        success: false,
        message:
          "Email is required",
        msg:
          "Email is required",
      });
    }

    let user =
      await User.findOne({
        email,
      });

    if (!user) {
      const resolvedName =
        resolveUserName({
          fullName: name,
        });

      const generatedPassword =
        `Google_${Date.now()}_${Math.random()
          .toString(36)
          .slice(2)}`;

      const userData = {
        firstName:
          resolvedName.firstName ||
          "Google",

        lastName:
          resolvedName.lastName ||
          "User",

        name:
          resolvedName.fullName ||
          "Google User",

        fullName:
          resolvedName.fullName ||
          "Google User",

        email,

        /*
         * If phone is required in the User schema, provide
         * a unique placeholder. The user can update it later.
         */
        phone:
          `google_${Date.now()}`,

        mobile:
          `google_${Date.now()}`,

        password:
          generatedPassword,

        role:
          requestedRole,
      };

      const schemaPaths =
        User.schema?.paths || {};

      const supportedUserData = {};

      for (
        const [key, value] of
        Object.entries(userData)
      ) {
        if (
          schemaPaths[key] &&
          value !== undefined
        ) {
          supportedUserData[key] =
            value;
        }
      }

      user =
        await User.create(
          supportedUserData
        );
    }

    return sendAuthResponse(
      res,
      user,
      {
        statusCode: 200,
        message:
          "Google login successful",
      }
    );
  } catch (error) {
    return sendControllerError(
      res,
      "Google Login Error",
      error
    );
  }
};

// =====================================================
// GET PROFILE
// GET /api/auth/profile
// =====================================================

export const getProfile = async (
  req,
  res
) => {
  try {
    const authenticatedUserId =
      req.user?._id ||
      req.user?.id;

    if (!authenticatedUserId) {
      return res.status(401).json({
        success: false,
        message:
          "Authentication required",
        msg:
          "Authentication required",
      });
    }

    const user =
      await User.findById(
        authenticatedUserId
      ).select("-password");

    if (!user) {
      return res.status(404).json({
        success: false,
        message:
          "User not found",
        msg:
          "User not found",
      });
    }

    const sanitizedUser =
      sanitizeUser(user);

    return res.status(200).json({
      success: true,
      message:
        "Profile fetched successfully",
      user:
        sanitizedUser,
      data:
        sanitizedUser,
    });
  } catch (error) {
    return sendControllerError(
      res,
      "Get Profile Error",
      error
    );
  }
};

// =====================================================
// REFRESH ACCESS TOKEN
// POST /api/auth/refresh-token
// =====================================================

export const refreshAccessToken =
  async (req, res) => {
    try {
      const refreshToken =
        normalizeString(
          req.body.refreshToken ||
            req.body.refresh_token
        );

      if (!refreshToken) {
        return res.status(401).json({
          success: false,
          message:
            "Refresh token is required",
          msg:
            "Refresh token is required",
        });
      }

      let decoded;

      try {
        decoded = jwt.verify(
          refreshToken,
          getRefreshTokenSecret()
        );
      } catch (_) {
        return res.status(401).json({
          success: false,
          message:
            "Refresh token is invalid or expired",
          msg:
            "Refresh token is invalid or expired",
        });
      }

      if (
        decoded.type &&
        decoded.type !== "refresh"
      ) {
        return res.status(401).json({
          success: false,
          message:
            "Invalid refresh token type",
          msg:
            "Invalid refresh token type",
        });
      }

      const user =
        await User.findById(
          decoded.id
        );

      if (!user) {
        return res.status(401).json({
          success: false,
          message:
            "User session no longer exists",
          msg:
            "User session no longer exists",
        });
      }

      return sendAuthResponse(
        res,
        user,
        {
          statusCode: 200,
          message:
            "Access token refreshed successfully",
        }
      );
    } catch (error) {
      return sendControllerError(
        res,
        "Refresh Token Error",
        error
      );
    }
  };

// =====================================================
// LOGOUT
// POST /api/auth/logout
// =====================================================

export const logout = async (
  req,
  res
) => {
  /*
   * Authentication currently uses stateless JWTs.
   * Flutter removes the access and refresh tokens locally.
   *
   * If token revocation is added later, store a token ID
   * or token version in MongoDB and invalidate it here.
   */
  return res.status(200).json({
    success: true,
    message:
      "Logout successful",
  });
};

// =====================================================
// CHECK EMAIL
// GET /api/auth/check-email?email=...
// =====================================================

export const checkEmailExists =
  async (req, res) => {
    try {
      const email =
        normalizeEmail(
          req.query.email
        );

      if (!email) {
        return res.status(400).json({
          success: false,
          message:
            "Email is required",
          msg:
            "Email is required",
        });
      }

      const exists =
        await User.exists({
          email,
        });

      return res.status(200).json({
        success: true,
        exists:
          Boolean(exists),
        data: {
          exists:
            Boolean(exists),
        },
      });
    } catch (error) {
      return sendControllerError(
        res,
        "Check Email Error",
        error
      );
    }
  };

// =====================================================
// CHECK PHONE
// GET /api/auth/check-phone?phone=...
// =====================================================

export const checkPhoneExists =
  async (req, res) => {
    try {
      const phone =
        normalizeString(
          req.query.phone ||
            req.query.mobile
        );

      if (!phone) {
        return res.status(400).json({
          success: false,
          message:
            "Phone number is required",
          msg:
            "Phone number is required",
        });
      }

      const exists =
        await User.exists({
          $or: [
            {
              phone,
            },
            {
              mobile: phone,
            },
          ],
        });

      return res.status(200).json({
        success: true,
        exists:
          Boolean(exists),
        data: {
          exists:
            Boolean(exists),
        },
      });
    } catch (error) {
      return sendControllerError(
        res,
        "Check Phone Error",
        error
      );
    }
  };

// =====================================================
// UPDATE FCM TOKEN
// POST /api/auth/fcm-token
// =====================================================

export const updateFcmToken =
  async (req, res) => {
    try {
      const userId =
        req.user?._id ||
        req.user?.id;

      const fcmToken =
        normalizeString(
          req.body.fcmToken
        );

      if (!userId) {
        return res.status(401).json({
          success: false,
          message:
            "Authentication required",
          msg:
            "Authentication required",
        });
      }

      if (!fcmToken) {
        return res.status(400).json({
          success: false,
          message:
            "FCM token is required",
          msg:
            "FCM token is required",
        });
      }

      const user =
        await User.findByIdAndUpdate(
          userId,
          {
            fcmToken,
          },
          {
            new: true,
            runValidators: true,
          }
        ).select("-password");

      if (!user) {
        return res.status(404).json({
          success: false,
          message:
            "User not found",
          msg:
            "User not found",
        });
      }

      const sanitizedUser =
        sanitizeUser(user);

      return res.status(200).json({
        success: true,
        message:
          "FCM token updated successfully",
        user:
          sanitizedUser,
        data:
          sanitizedUser,
      });
    } catch (error) {
      return sendControllerError(
        res,
        "Update FCM Token Error",
        error
      );
    }
  };