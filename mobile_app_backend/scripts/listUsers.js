import mongoose from "mongoose";
import dotenv from "dotenv";

import User from "../models/user.js";

dotenv.config();

async function run() {
  await mongoose.connect(
    process.env.MONGO_URI
  );

  const users = await User.find({})
    .select(
      "email role firstName lastName"
    );

  console.log(users);

  await mongoose.disconnect();
}

run();