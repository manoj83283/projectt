import User from "../models/user.js";
import Service from "../models/service.js";
import jwt from "jsonwebtoken";
import { sendNotification } from "../utils/notification.js";

// ================= TOKEN =================

const generateToken = (user) => {
  return jwt.sign(
    {
      id: user._id,
      role: user.role,
    },
    process.env.JWT_SECRET || "secret",
    {
      expiresIn: "7d",
    }
  );
};

// =======================================================
// SIGNUP
// =======================================================

export const signup = async (req, res) => {
  try {
    let {
      firstName,
      lastName,
      fullName,
      name,
      email,
      phone,
      password,
      role,
      userType,
      dob,
      location,
      shopName,
      businessName,
    } = req.body;

    // ===================================================
    // NORMALIZE NAME
    // ===================================================

    if ((!firstName || !lastName) && (fullName || name)) {
      const normalizedName = (fullName || name || "").trim();
      const nameParts = normalizedName.split(/\s+/);

      firstName = firstName || nameParts[0] || "";
      lastName = lastName || nameParts.slice(1).join(" ") || "";
    }

    firstName = firstName?.trim();
    lastName = lastName?.trim();
    email = email?.toLowerCase().trim();
    phone = phone?.trim();

    role = role || userType || "user";

    const finalShopName = shopName || businessName || "";

    // ===================================================
    // REQUIRED FIELD VALIDATION
    // IMPORTANT:
    // dob and location are optional now.
    // ===================================================

    if (
      !firstName ||
      !lastName ||
      !email ||
      !phone ||
      !password ||
      !role
    ) {
      return res.status(400).json({
        success: false,
        msg: "All fields are required",
        message:
          "firstName, lastName, email, phone, password and role are required",
      });
    }

    // ===================================================
    // OPTIONAL DOB / AGE VALIDATION
    // Only validate age if dob is provided.
    // ===================================================

    if (dob) {
      const birthDate = new Date(dob);

      if (Number.isNaN(birthDate.getTime())) {
        return res.status(400).json({
          success: false,
          msg: "Invalid date of birth",
        });
      }

      const today = new Date();

      let age =
        today.getFullYear() -
        birthDate.getFullYear();

      if (
        today.getMonth() < birthDate.getMonth() ||
        (
          today.getMonth() === birthDate.getMonth() &&
          today.getDate() < birthDate.getDate()
        )
      ) {
        age--;
      }

      if (age < 18) {
        return res.status(400).json({
          success: false,
          msg: "You must be at least 18 years old",
        });
      }
    }

    // ===================================================
    // CHECK EXISTING USER
    // ===================================================

    const userExists = await User.findOne({
      email,
    });

    if (userExists) {
      return res.status(400).json({
        success: false,
        msg: "User already exists",
      });
    }

    // ===================================================
    // CREATE USER
    // ===================================================

    const user = await User.create({
      firstName,
      lastName,
      name: `${firstName} ${lastName}`.trim(),
      email,
      phone,
      password,
      dob: dob || null,
      location: location || null,
      role: role === "provider" ? "provider" : "user",
      shopName: finalShopName,
      businessName: finalShopName,
    });

    // ===================================================
    // SEND WELCOME NOTIFICATION
    // ===================================================

    if (user.fcmToken) {
      await sendNotification(
        user.fcmToken,
        "Welcome 🎉",
        "Your account created successfully!"
      );
    }

    // ===================================================
    // TOKEN
    // ===================================================

    const token = generateToken(user);

    return res.status(201).json({
      success: true,
      message: "Signup successful",
      token,
      user,
    });
  } catch (error) {
    console.error("❌ Signup error:", error);

    return res.status(500).json({
      success: false,
      msg: "Server error",
      error: error.message,
    });
  }
};

// =======================================================
// GOOGLE LOGIN
// =======================================================

export const googleLogin = async (
  req,
  res,
  next
) => {
  try {
    const {
      email,
      name,
      role,
    } = req.body;

    if (!email) {
      return res.status(400).json({
        success: false,
        msg: "Email is required",
      });
    }

    const normalizedEmail = email.toLowerCase().trim();

    let user = await User.findOne({
      email: normalizedEmail,
    });

    if (!user) {
      const normalizedName =
        name?.trim() || "Google User";

      const nameParts =
        normalizedName.split(/\s+/);

      user = await User.create({
        firstName: nameParts[0] || "Google",
        lastName:
          nameParts.slice(1).join(" ") ||
          "User",
        name: normalizedName,
        email: normalizedEmail,
        phone: "",
        password: `google_${Date.now()}`,
        role:
          role === "provider"
            ? "provider"
            : "user",
      });
    }

    const token = generateToken(user);

    return res.status(200).json({
      success: true,
      message: "Google login successful",
      token,
      user,
    });
  } catch (error) {
    next(error);
  }
};

// =======================================================
// SIGNIN
// =======================================================

export const signin = async (req, res) => {
  try {
    let {
      email,
      password,
    } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        msg: "Email and password required",
      });
    }

    email = email.toLowerCase().trim();

    const user = await User.findOne({
      email,
    });

    if (
      !user ||
      !(await user.matchPassword(password))
    ) {
      return res.status(400).json({
        success: false,
        msg: "Invalid credentials",
      });
    }

    const token = generateToken(user);

    return res.status(200).json({
      success: true,
      message: "Login successful",
      token,
      user,
    });
  } catch (error) {
    console.error("❌ Login error:", error);

    return res.status(500).json({
      success: false,
      msg: error.message,
    });
  }
};

// =======================================================
// GET SERVICE BY ID
// =======================================================

export const getServiceById = async (
  req,
  res,
  next
) => {
  try {
    const service = await Service.findById(
      req.params.id
    );

    if (!service) {
      res.status(404);
      throw new Error("Service not found");
    }

    return res.json({
      success: true,
      service,
    });
  } catch (error) {
    next(error);
  }
};

// =======================================================
// PROFILE
// =======================================================

export const getProfile = async (req, res) => {
  try {
    return res.json({
      success: true,
      user: req.user,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      msg: error.message,
    });
  }
};