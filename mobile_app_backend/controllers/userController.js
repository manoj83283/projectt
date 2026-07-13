import User from '../models/user.js';

// =====================================================
// GET PROFILE
// =====================================================

export const getProfile = async (
  req,
  res,
  next
) => {
  try {
    const user = await User.findById(
      req.user._id
    ).select("-password");

    if (!user) {
      res.status(404);
      throw new Error("User not found");
    }

    res.json({
      success: true,
      user,
    });
  } catch (error) {
    next(error);
  }
};

export const createUser = async (req, res) => {
  try {
    const user = await User.create(req.body);
    res.status(201).json(user);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
export const updateProfile = async (
  req,
  res,
  next
) => {
  try {
    const user = await User.findById(
      req.user._id
    );

    if (!user) {
      res.status(404);
      throw new Error("User not found");
    }

    user.name =
      req.body.name || user.name;

    user.phone =
      req.body.phone || user.phone;

    const updatedUser =
      await user.save();

    res.json({
      success: true,
      user: updatedUser,
    });
  } catch (error) {
    next(error);
  }
};

export const getUsers = async (req, res) => {
  const users = await User.find();
  res.json(users);
};