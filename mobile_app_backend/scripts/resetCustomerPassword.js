import dotenv from "dotenv";
import mongoose from "mongoose";

import User from "../models/user.js";

dotenv.config();

const email =
  "customer@gmail.com";

const newPassword =
  "123456789";

async function resetCustomerPassword() {
  try {
    if (!process.env.MONGO_URI) {
      throw new Error(
        "MONGO_URI is missing from .env"
      );
    }

    await mongoose.connect(
      process.env.MONGO_URI
    );

    console.log(
      "MongoDB connected"
    );

    const user =
      await User.findOne({
        email: email.toLowerCase().trim(),
      }).select("+password");

    if (!user) {
      throw new Error(
        `Customer not found: ${email}`
      );
    }

    console.log(
      "Customer found:",
      user.email
    );

    console.log(
      "Customer role:",
      user.role
    );

    user.password =
      newPassword;

    user.role = "user";
    user.isActive = true;
    user.isBlocked = false;

    await user.save();

    const updatedUser =
      await User.findOne({
        email: email.toLowerCase().trim(),
      }).select("+password");

    if (!updatedUser) {
      throw new Error(
        "Customer disappeared after password reset"
      );
    }

    const passwordMatches =
      await updatedUser.matchPassword(
        newPassword
      );

    console.log(
      "Password reset completed:",
      passwordMatches
    );

    if (!passwordMatches) {
      throw new Error(
        "Password verification failed after reset"
      );
    }
  } catch (error) {
    console.error(
      "Password reset failed:",
      error.message
    );

    process.exitCode = 1;
  } finally {
    await mongoose.disconnect();

    console.log(
      "MongoDB disconnected"
    );
  }
}

resetCustomerPassword();