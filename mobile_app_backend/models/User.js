import mongoose from "mongoose";
import bcrypt from "bcryptjs";

const addressSchema = new mongoose.Schema(
  {
    type: {
      type: String,
      enum: [
        "home",
        "work",
        "corporate",
        "other",
      ],
      default: "home",
    },

    addressLine: {
      type: String,
      trim: true,
      default: "",
    },

    landmark: {
      type: String,
      trim: true,
      default: "",
    },

    city: {
      type: String,
      trim: true,
      default: "",
    },

    state: {
      type: String,
      trim: true,
      default: "",
    },

    pincode: {
      type: String,
      trim: true,
      default: "",
    },

    isDefault: {
      type: Boolean,
      default: false,
    },
  },
  {
    _id: true,
  }
);

const userSchema = new mongoose.Schema(
  {
    firstName: {
      type: String,
      required: [
        true,
        "First name is required",
      ],
      trim: true,
    },

    lastName: {
      type: String,
      required: [
        true,
        "Last name is required",
      ],
      trim: true,
    },

    name: {
      type: String,
      trim: true,
      default: "",
    },

    fullName: {
      type: String,
      trim: true,
      default: "",
    },

    email: {
      type: String,
      required: [
        true,
        "Email is required",
      ],
      unique: true,
      lowercase: true,
      trim: true,
      index: true,
    },

    phone: {
      type: String,
      required: [
        true,
        "Phone number is required",
      ],
      trim: true,
    },

    mobile: {
      type: String,
      trim: true,
      default: "",
    },

    password: {
      type: String,
      required: [
        true,
        "Password is required",
      ],
      minlength: [
        6,
        "Password must contain at least 6 characters",
      ],
      select: false,
    },

    role: {
      type: String,
      enum: [
        "user",
        "customer",
        "provider",
        "admin",
      ],
      default: "user",
      index: true,
    },

    isActive: {
      type: Boolean,
      default: true,
    },

    isBlocked: {
      type: Boolean,
      default: false,
    },

    isOnline: {
      type: Boolean,
      default: false,
    },

    locationEnabled: {
      type: Boolean,
      default: true,
    },

    profileImage: {
      type: String,
      trim: true,
      default: "",
    },

    addresses: {
      type: [addressSchema],
      default: [],
    },

    location: {
      type: {
        type: String,
        enum: ["Point"],
        default: "Point",
      },

      coordinates: {
        type: [Number],
        default: [0, 0],
      },
    },

    servicesOffered: [
      {
        type:
          mongoose.Schema.Types.ObjectId,
        ref: "Service",
      },
    ],

    experience: {
      type: Number,
      default: 0,
      min: 0,
    },

    rating: {
      type: Number,
      default: 0,
      min: 0,
      max: 5,
    },

    totalReviews: {
      type: Number,
      default: 0,
      min: 0,
    },

    walletBalance: {
      type: Number,
      default: 0,
    },

    notificationsEnabled: {
      type: Boolean,
      default: true,
    },

    fcmToken: {
      type: String,
      trim: true,
      default: "",
    },

    shopName: {
      type: String,
      trim: true,
      default: "",
    },

    businessName: {
      type: String,
      trim: true,
      default: "",
    },

    dob: {
      type: Date,
      default: null,
    },

    resetPasswordToken: {
      type: String,
      default: null,
      select: false,
    },

    resetPasswordExpires: {
      type: Date,
      default: null,
      select: false,
    },
  },
  {
    timestamps: true,

    toJSON: {
      virtuals: true,
    },

    toObject: {
      virtuals: true,
    },
  }
);

userSchema.index({
  location: "2dsphere",
});

userSchema.pre(
  "validate",
  function (next) {
    if (!this.name) {
      this.name = [
        this.firstName,
        this.lastName,
      ]
        .filter(Boolean)
        .join(" ")
        .trim();
    }

    if (!this.fullName) {
      this.fullName = [
        this.firstName,
        this.lastName,
      ]
        .filter(Boolean)
        .join(" ")
        .trim();
    }

    if (
      !this.mobile &&
      this.phone
    ) {
      this.mobile = this.phone;
    }

    if (
      !this.phone &&
      this.mobile
    ) {
      this.phone = this.mobile;
    }

    if (
      this.role === "customer"
    ) {
      this.role = "user";
    }

    next();
  }
);

userSchema.pre(
  "save",
  async function (next) {
    try {
      if (
        !this.isModified("password")
      ) {
        return next();
      }

      const password =
        this.password
          ?.toString()
          .trim() ?? "";

      if (password.length < 6) {
        return next(
          new Error(
            "Password must contain at least 6 characters"
          )
        );
      }

      const isAlreadyHashed =
        password.startsWith(
          "$2a$"
        ) ||
        password.startsWith(
          "$2b$"
        ) ||
        password.startsWith(
          "$2y$"
        );

      if (isAlreadyHashed) {
        return next();
      }

      const salt =
        await bcrypt.genSalt(10);

      this.password =
        await bcrypt.hash(
          password,
          salt
        );

      return next();
    } catch (error) {
      return next(error);
    }
  }
);

userSchema.methods.matchPassword =
  async function (
    enteredPassword
  ) {
    if (
      !enteredPassword ||
      !this.password
    ) {
      return false;
    }

    const storedPassword =
      this.password
        .toString()
        .trim();

    const suppliedPassword =
      enteredPassword
        .toString();

    const isBcryptHash =
      storedPassword.startsWith(
        "$2a$"
      ) ||
      storedPassword.startsWith(
        "$2b$"
      ) ||
      storedPassword.startsWith(
        "$2y$"
      );

    if (!isBcryptHash) {
      return false;
    }

    return bcrypt.compare(
      suppliedPassword,
      storedPassword
    );
  };

userSchema.methods.comparePassword =
  async function (
    enteredPassword
  ) {
    return this.matchPassword(
      enteredPassword
    );
  };

userSchema.methods.toJSON =
  function () {
    const object =
      this.toObject({
        virtuals: true,
      });

    delete object.password;
    delete object.resetPasswordToken;
    delete object.resetPasswordExpires;
    delete object.__v;

    object.id =
      object._id
        ?.toString() ||
      object.id
        ?.toString() ||
      "";

    return object;
  };

const User =
  mongoose.models.User ||
  mongoose.model(
    "User",
    userSchema
  );

export default User;