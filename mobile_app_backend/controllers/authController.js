import jwt from "jsonwebtoken";

import User from "../models/user.js";
import { sendNotification } from "../utils/notification.js";

const ACCESS_TOKEN_EXPIRY =
  process.env.JWT_EXPIRES_IN || "7d";

const REFRESH_TOKEN_EXPIRY =
  process.env.JWT_REFRESH_EXPIRES_IN || "30d";

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
    const nameParts =
      resolvedFullName
        .split(/\s+/)
        .filter(Boolean);

    if (!resolvedFirstName) {
      resolvedFirstName =
        nameParts[0] || "";
    }

    if (!resolvedLastName) {
      resolvedLastName =
        nameParts
          .slice(1)
          .join(" ");
    }
  }

  if (
    resolvedFirstName &&
    !resolvedLastName
  ) {
    resolvedLastName = "Customer";
  }

  const resolvedName = [
    resolvedFirstName,
    resolvedLastName,
  ]
    .filter(Boolean)
    .join(" ")
    .trim();

  return {
    firstName: resolvedFirstName,
    lastName: resolvedLastName,
    fullName: resolvedName,
  };
};

const getJwtSecret = () => {
  const jwtSecret =
    process.env.JWT_SECRET;

  if (jwtSecret) {
    return jwtSecret;
  }

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

export const generateToken =
  generateAccessToken;

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
    ).map(
      (item) => item.message
    );

    const message =
      errors[0] ||
      "Validation failed";

    return res.status(400).json({
      success: false,
      message,
      msg: message,
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

  const message =
    error?.message ||
    "Internal server error";

  return res.status(500).json({
    success: false,
    message,
    msg: message,
  });
};

const buildSupportedUserData = (
  userData
) => {
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

  return supportedUserData;
};

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

    const normalizedBusinessName =
      normalizeString(
        shopName || businessName
      );

    if (!resolvedName.firstName) {
      return res.status(400).json({
        success: false,
        message:
          "First name is required",
        msg:
          "First name is required",
      });
    }

    if (!resolvedName.lastName) {
      return res.status(400).json({
        success: false,
        message:
          "Last name is required",
        msg:
          "Last name is required",
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

    const duplicateConditions = [
      {
        email:
          normalizedEmail,
      },
    ];

    if (normalizedPhone) {
      duplicateConditions.push({
        phone:
          normalizedPhone,
      });
    }

    const existingUser =
      await User.findOne({
        $or:
          duplicateConditions,
      });

    if (existingUser) {
      const sameEmail =
        normalizeEmail(
          existingUser.email
        ) === normalizedEmail;

      const duplicateField =
        sameEmail
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

      role:
        normalizedRole,

      dob:
        normalizedDob,

      location:
        location || undefined,

      shopName:
        normalizedBusinessName,

      businessName:
        normalizedBusinessName,

      isActive: true,

      isBlocked: false,
    };

    const supportedUserData =
      buildSupportedUserData(
        userData
      );

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

    console.log(
      "CUSTOMER SIGNUP SUCCESS:",
      user.email
    );

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

export const signin = async (
  req,
  res
) => {
  try {
    const email =
      normalizeEmail(
        req.body.email
      );

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

    console.log(
      "SIGNIN ATTEMPT EMAIL:",
      email
    );

    const user =
      await User.findOne({
        email,
      }).select("+password");

    console.log(
      "SIGNIN USER FOUND:",
      Boolean(user)
    );

    if (!user) {
      console.log(
        "SIGNIN FAILED: USER NOT FOUND"
      );

      return res.status(401).json({
        success: false,
        message:
          "Invalid email or password",
        msg:
          "Invalid email or password",
      });
    }

    console.log(
      "SIGNIN USER ID:",
      user._id.toString()
    );

    console.log(
      "SIGNIN USER ROLE:",
      user.role
    );

    console.log(
      "SIGNIN PASSWORD AVAILABLE:",
      Boolean(user.password)
    );

    if (!user.password) {
      console.error(
        "SIGNIN FAILED: PASSWORD FIELD NOT AVAILABLE"
      );

      return res.status(500).json({
        success: false,
        message:
          "Password validation is not configured correctly",
        msg:
          "Password validation is not configured correctly",
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

      console.log(
        "SIGNIN PASSWORD METHOD:",
        "matchPassword"
      );
    } else if (
      typeof user.comparePassword ===
      "function"
    ) {
      passwordMatches =
        await user.comparePassword(
          password
        );

      console.log(
        "SIGNIN PASSWORD METHOD:",
        "comparePassword"
      );
    } else {
      console.error(
        "SIGNIN FAILED: PASSWORD METHOD MISSING"
      );

      return res.status(500).json({
        success: false,
        message:
          "Password validation is not configured correctly",
        msg:
          "Password validation is not configured correctly",
      });
    }

    console.log(
      "SIGNIN PASSWORD MATCHED:",
      passwordMatches
    );

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
      console.log(
        "SIGNIN FAILED: ACCOUNT UNAVAILABLE"
      );

      return res.status(403).json({
        success: false,
        message:
          "This account is unavailable",
        msg:
          "This account is unavailable",
      });
    }

    console.log(
      "SIGNIN SUCCESS:",
      user.email
    );

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

export const googleLogin = async (
  req,
  res
) => {
  try {
    const email =
      normalizeEmail(
        req.body.email
      );

    const name =
      normalizeString(
        req.body.name,
        "Google User"
      );

    const requestedRole =
      normalizeRole(
        req.body.role
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

    let user =
      await User.findOne({
        email,
      });

    if (!user) {
      const resolvedName =
        resolveUserName({
          fullName: name,
        });

      const uniqueSuffix =
        `${Date.now()}_${Math.random()
          .toString(36)
          .slice(2)}`;

      const generatedPassword =
        `Google_${uniqueSuffix}`;

      const generatedPhone =
        `google_${uniqueSuffix}`;

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

        phone:
          generatedPhone,

        mobile:
          generatedPhone,

        password:
          generatedPassword,

        role:
          requestedRole,

        isActive: true,

        isBlocked: false,
      };

      const supportedUserData =
        buildSupportedUserData(
          userData
        );

      user =
        await User.create(
          supportedUserData
        );
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
      } catch (error) {
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

export const logout = async (
  req,
  res
) => {
  return res.status(200).json({
    success: true,
    message:
      "Logout successful",
  });
};

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

      const conditions = [
        {
          phone,
        },
      ];

      if (
        User.schema?.paths?.mobile
      ) {
        conditions.push({
          mobile:
            phone,
        });
      }

      const exists =
        await User.exists({
          $or:
            conditions,
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

      if (
        !User.schema?.paths?.fcmToken
      ) {
        return res.status(500).json({
          success: false,
          message:
            "FCM token field is not configured in the User model",
          msg:
            "FCM token field is not configured in the User model",
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