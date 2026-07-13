import User from "../models/user.js";
import jwt from "jsonwebtoken";
import { sendNotification } from "../utils/notification.js";
//import sendNotification from "../utils/notification.js"; //  ADD THIS

// ================= TOKEN =================
const generateToken = (user) => {
  return jwt.sign(
    {
      id: user._id,
      role: user.role,
    },
    process.env.JWT_SECRET || "secret",
    { expiresIn: "7d" }
  );
};

// =======================================================
// ✅ ✅ ✅ SIGNUP (FINAL CLEAN VERSION)
// =======================================================
export const signup = async (req, res) => {
  try {

    let {
      firstName,
      lastName,
      email,
      phone,
      password,
      role,
      dob,
      location,
      shopName,
    } = req.body;

    /// ✅ VALIDATION
    if (
      !firstName ||
      !lastName ||
      !email ||
      !phone ||
      !password ||
      !dob ||
      !location ||
      !role
    ) {
      return res.status(400).json({
        msg: "All fields are required",
      });
    }

    /// ✅ CLEAN DATA
    firstName = firstName.trim();
    lastName = lastName.trim();
    email = email.toLowerCase().trim();
    phone = phone.trim();

    /// ✅ AGE VALIDATION
    const birthDate = new Date(dob);
    const today = new Date();

    let age = today.getFullYear() - birthDate.getFullYear();

    if (
      today.getMonth() < birthDate.getMonth() ||
      (today.getMonth() === birthDate.getMonth() &&
        today.getDate() < birthDate.getDate())
    ) {
      age--;
    }

    if (age < 18) {
      return res.status(400).json({
        msg: "You must be at least 18 years old",
      });
    }

    /// ✅ CHECK EXISTING USER
    const userExists = await User.findOne({ email });

    if (userExists) {
      return res.status(400).json({
        msg: "User already exists",
      });
    }

    /// ✅ CREATE USER
    const user = await User.create({
      firstName,
      lastName,
      email,
      phone,
      password,
      dob,
      location,
      role: role === "provider" ? "provider" : "user",
      shopName: shopName || "",
    });

    /// ✅ ✅ ✅ NEW: SEND WELCOME NOTIFICATION
    if (user.fcmToken) {
      await sendNotification(
        user.fcmToken,
        "Welcome 🎉",
        "Your account created successfully!"
      );
    }

    /// ✅ TOKEN
    const token = generateToken(user);

    return res.status(201).json({
      message: "Signup successful",
      token,
      user,
    });

  } catch (error) {
    console.error("❌ Signup error:", error);

    res.status(500).json({
      msg: "Server error",
      error: error.message,
    });
  }
};
export const googleLogin = async (
  req,
  res,
  next
) => {
  try {
    const { email, name } = req.body;

    let user = await User.findOne({ email });

    if (!user) {
      user = await User.create({
        name,
        email,
        role: "user",
      });
    }

    const token = generateToken(user._id);

    res.json({
      success: true,
      token,
      user,
    });
  } catch (error) {
    next(error);
  }
};


// =======================================================
// ✅ SIGNIN
// =======================================================
export const signin = async (req, res) => {
  try {

    let { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        msg: "Email and password required",
      });
    }

    email = email.toLowerCase().trim();

    const user = await User.findOne({ email });

    if (!user || !(await user.matchPassword(password))) {
      return res.status(400).json({
        msg: "Invalid credentials",
      });
    }

    const token = generateToken(user);

    res.status(200).json({
      message: "Login successful",
      token,
      user,
    });

  } catch (error) {
    console.error("❌ Login error:", error);

    res.status(500).json({
      msg: error.message,
    });
  }
};
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

    res.json({
      success: true,
      service,
    });
  } catch (error) {
    next(error); // ✅ Send to errorMiddleware.js
  }
};


// =======================================================
// ✅ PROFILE
// =======================================================
export const getProfile = async (req, res) => {
  try {
    res.json({
      user: req.user,
    });
  } catch (error) {
    res.status(500).json({
      msg: error.message,
    });
  }
};