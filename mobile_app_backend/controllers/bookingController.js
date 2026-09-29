import crypto from "crypto";
import mongoose from "mongoose";

import Booking, {
  BOOKING_STATUSES,
  PAYMENT_METHODS,
  PAYMENT_STATUSES,
} from "../models/Booking.js";

import Service from "../models/service.js";
import Notification from "../models/Notification.js";
import { sendNotification } from "../utils/notification.js";

// =====================================================
// CONFIGURATION
// =====================================================

const MAX_OTP_ATTEMPTS = 5;
const OTP_LOCK_MINUTES = 15;

const PROVIDER_ARRIVAL_RADIUS_METERS = Math.max(
  50,
  Number.parseInt(
    process.env.PROVIDER_ARRIVAL_RADIUS_METERS || "500",
    10
  ) || 500
);

// =====================================================
// BOOKING STATUS TRANSITIONS
// =====================================================

const PROVIDER_STATUS_TRANSITIONS = Object.freeze({
  [BOOKING_STATUSES.PENDING]: [
    BOOKING_STATUSES.ACCEPTED,
    BOOKING_STATUSES.REJECTED,
  ],

  [BOOKING_STATUSES.ACCEPTED]: [
    BOOKING_STATUSES.CANCELLED,
  ],

  [BOOKING_STATUSES.OTP_VERIFIED]: [
    BOOKING_STATUSES.IN_PROGRESS,
    BOOKING_STATUSES.CANCELLED,
  ],

  [BOOKING_STATUSES.IN_PROGRESS]: [
    BOOKING_STATUSES.COMPLETED,
    BOOKING_STATUSES.CANCELLED,
  ],

  [BOOKING_STATUSES.COMPLETED]: [],
  [BOOKING_STATUSES.REJECTED]: [],
  [BOOKING_STATUSES.CANCELLED]: [],
});

const CUSTOMER_CANCELLABLE_STATUSES = [
  BOOKING_STATUSES.PENDING,
  BOOKING_STATUSES.ACCEPTED,
];

// =====================================================
// AUTHENTICATION HELPERS
// =====================================================

const getAuthenticatedUserId = (req) => {
  return (
    req.user?._id?.toString() ||
    req.user?.id?.toString() ||
    ""
  );
};

const getUserRole = (req) => {
  return (
    req.user?.role
      ?.toString()
      .trim()
      .toLowerCase() || ""
  );
};

const isProvider = (req) => {
  return getUserRole(req) === "provider";
};

const isAdmin = (req) => {
  return getUserRole(req) === "admin";
};

// =====================================================
// VALUE HELPERS
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

  const normalized = value
    .toString()
    .trim();

  return normalized || fallback;
};

const normalizeNumber = (
  value,
  fallback = 0
) => {
  if (
    value === null ||
    value === undefined ||
    value === ""
  ) {
    return fallback;
  }

  const parsed = Number(value);

  return Number.isFinite(parsed)
    ? parsed
    : fallback;
};

const normalizePositiveNumber = (
  value,
  fallback = 0
) => {
  return Math.max(
    0,
    normalizeNumber(
      value,
      fallback
    )
  );
};

const normalizeBookingStatus = (
  value
) => {
  const status = normalizeString(value)
    .toLowerCase()
    .replaceAll("-", "_")
    .replaceAll(" ", "_");

  switch (status) {
    case "confirmed":
    case "confirm":
      return BOOKING_STATUSES.ACCEPTED;

    case "inprogress":
    case "processing":
      return BOOKING_STATUSES.IN_PROGRESS;

    case "canceled":
      return BOOKING_STATUSES.CANCELLED;

    default:
      return status;
  }
};

const normalizePaymentMethod = (
  value
) => {
  const method = normalizeString(
    value,
    PAYMENT_METHODS.COD
  ).toUpperCase();

  if (
    Object.values(
      PAYMENT_METHODS
    ).includes(method)
  ) {
    return method;
  }

  return PAYMENT_METHODS.COD;
};

const isValidObjectId = (
  value
) => {
  return mongoose.Types.ObjectId.isValid(
    value
  );
};

const getDocumentId = (
  value
) => {
  if (!value) {
    return "";
  }

  if (value._id) {
    return value._id.toString();
  }

  if (value.id) {
    return value.id.toString();
  }

  return value.toString();
};

const getDisplayName = (
  value
) => {
  if (!value) {
    return "";
  }

  if (typeof value === "string") {
    return value;
  }

  const fullName = [
    value.firstName,
    value.lastName,
  ]
    .filter(Boolean)
    .join(" ")
    .trim();

  return (
    value.businessName ||
    value.shopName ||
    value.name ||
    value.fullName ||
    fullName ||
    ""
  );
};

// =====================================================
// DATE HELPERS
// =====================================================

const getStartOfDay = (
  date = new Date()
) => {
  const result = new Date(date);

  result.setHours(
    0,
    0,
    0,
    0
  );

  return result;
};

const getEndOfDay = (
  date = new Date()
) => {
  const result = new Date(date);

  result.setHours(
    23,
    59,
    59,
    999
  );

  return result;
};

const calculateDurationMinutes = (
  booking
) => {
  if (
    !booking?.startedAt ||
    !booking?.completedAt
  ) {
    return normalizePositiveNumber(
      booking?.durationMinutes,
      0
    );
  }

  const startedAt = new Date(
    booking.startedAt
  ).getTime();

  const completedAt = new Date(
    booking.completedAt
  ).getTime();

  if (
    Number.isNaN(startedAt) ||
    Number.isNaN(completedAt)
  ) {
    return 0;
  }

  return Math.max(
    0,
    Math.round(
      (completedAt - startedAt) /
        60000
    )
  );
};

// =====================================================
// PAGINATION
// =====================================================

const getPagination = (
  req
) => {
  const page = Math.max(
    1,
    Math.floor(
      normalizeNumber(
        req.query.page,
        1
      )
    )
  );

  const requestedLimit = Math.max(
    1,
    Math.floor(
      normalizeNumber(
        req.query.limit,
        20
      )
    )
  );

  const limit = Math.min(
    requestedLimit,
    100
  );

  return {
    page,
    limit,
    skip: (page - 1) * limit,
  };
};

// =====================================================
// LOCATION HELPERS
// =====================================================

const normalizeLocationPoint = (
  body = {}
) => {
  const rawLongitude =
    body.longitude ??
    body.lng ??
    body.locationPoint
      ?.coordinates?.[0];

  const rawLatitude =
    body.latitude ??
    body.lat ??
    body.locationPoint
      ?.coordinates?.[1];

  const hasCoordinates =
    rawLongitude !== undefined &&
    rawLongitude !== null &&
    rawLongitude !== "" &&
    rawLatitude !== undefined &&
    rawLatitude !== null &&
    rawLatitude !== "";

  const longitude = normalizeNumber(
    rawLongitude,
    0
  );

  const latitude = normalizeNumber(
    rawLatitude,
    0
  );

  const validLongitude =
    Number.isFinite(longitude) &&
    longitude >= -180 &&
    longitude <= 180;

  const validLatitude =
    Number.isFinite(latitude) &&
    latitude >= -90 &&
    latitude <= 90;

  return {
    point: {
      type: "Point",

      coordinates:
        validLongitude &&
        validLatitude
          ? [
              longitude,
              latitude,
            ]
          : [0, 0],
    },

    latitude,
    longitude,

    isValid:
      validLongitude &&
      validLatitude,

    hasCoordinates,
  };
};

const calculateDistanceMeters = ({
  fromLatitude,
  fromLongitude,
  toLatitude,
  toLongitude,
}) => {
  const values = [
    fromLatitude,
    fromLongitude,
    toLatitude,
    toLongitude,
  ].map(Number);

  if (
    values.some(
      (value) =>
        !Number.isFinite(value)
    )
  ) {
    return null;
  }

  const [
    latitude1,
    longitude1,
    latitude2,
    longitude2,
  ] = values;

  const earthRadiusMeters =
    6371000;

  const toRadians = (
    degrees
  ) => {
    return (
      degrees *
      Math.PI /
      180
    );
  };

  const latitudeDifference =
    toRadians(
      latitude2 - latitude1
    );

  const longitudeDifference =
    toRadians(
      longitude2 - longitude1
    );

  const firstLatitude =
    toRadians(latitude1);

  const secondLatitude =
    toRadians(latitude2);

  const haversineValue =
    Math.sin(
      latitudeDifference / 2
    ) ** 2 +
    Math.cos(firstLatitude) *
      Math.cos(secondLatitude) *
      Math.sin(
        longitudeDifference / 2
      ) ** 2;

  const boundedValue = Math.min(
    1,
    Math.max(
      0,
      haversineValue
    )
  );

  const angularDistance =
    2 *
    Math.atan2(
      Math.sqrt(
        boundedValue
      ),
      Math.sqrt(
        1 - boundedValue
      )
    );

  return Math.round(
    earthRadiusMeters *
    angularDistance
  );
};

// =====================================================
// SERVICE PRICING
// =====================================================

const getServicePricing = (
  service,
  hoursBooked
) => {
  const serviceType =
    normalizeString(
      service.serviceType,
      "fixed"
    ).toLowerCase();

  const fixedPrice =
    normalizePositiveNumber(
      service.price,
      0
    ) ||
    normalizePositiveNumber(
      service.basePrice,
      0
    );

  if (serviceType === "hourly") {
    const hourlyPrice =
      normalizePositiveNumber(
        service.pricePerHour,
        fixedPrice
      );

    return {
      unitPrice: hourlyPrice,
      subtotal:
        hourlyPrice * hoursBooked,
    };
  }

  if (serviceType === "daily") {
    const dailyPrice =
      normalizePositiveNumber(
        service.pricePerDay,
        fixedPrice
      );

    return {
      unitPrice: dailyPrice,
      subtotal: dailyPrice,
    };
  }

  return {
    unitPrice: fixedPrice,
    subtotal: fixedPrice,
  };
};

// =====================================================
// OTP HELPERS
// =====================================================

const getOtpSecret = () => {
  const secret = normalizeString(
    process.env.OTP_SECRET
  );

  if (!secret) {
    const error = new Error(
      "OTP_SECRET is not configured. Add OTP_SECRET to mobile_app_backend/.env and restart the backend."
    );

    error.code =
      "OTP_SECRET_MISSING";

    throw error;
  }

  if (
    process.env.NODE_ENV ===
      "production" &&
    secret.length < 32
  ) {
    const error = new Error(
      "OTP_SECRET must contain at least 32 characters in production."
    );

    error.code =
      "OTP_SECRET_WEAK";

    throw error;
  }

  return secret;
};

const generateServiceOtp = () => {
  return crypto
    .randomInt(
      1000,
      10000
    )
    .toString();
};

const hashServiceOtp = (
  bookingId,
  otp
) => {
  const normalizedBookingId =
    normalizeString(bookingId);

  const normalizedOtp =
    normalizeString(otp);

  if (!normalizedBookingId) {
    throw new Error(
      "Booking ID is required to hash the service OTP"
    );
  }

  if (
    !/^\d{4}$/.test(
      normalizedOtp
    )
  ) {
    throw new Error(
      "A valid 4-digit service OTP is required"
    );
  }

  return crypto
    .createHmac(
      "sha256",
      getOtpSecret()
    )
    .update(
      `${normalizedBookingId}:${normalizedOtp}`,
      "utf8"
    )
    .digest("hex");
};

const otpHashesMatch = (
  storedHash,
  providedHash
) => {
  if (
    !storedHash ||
    !providedHash
  ) {
    return false;
  }

  if (
    !/^[a-f0-9]{64}$/i.test(
      storedHash
    ) ||
    !/^[a-f0-9]{64}$/i.test(
      providedHash
    )
  ) {
    return false;
  }

  const storedBuffer =
    Buffer.from(
      storedHash,
      "hex"
    );

  const providedBuffer =
    Buffer.from(
      providedHash,
      "hex"
    );

  if (
    storedBuffer.length === 0 ||
    storedBuffer.length !==
      providedBuffer.length
  ) {
    return false;
  }

  return crypto.timingSafeEqual(
    storedBuffer,
    providedBuffer
  );
};

// =====================================================
// POPULATION
// =====================================================

const populateBookingQuery = (
  query
) => {
  return query
    .populate(
      "user",
      [
        "firstName",
        "lastName",
        "name",
        "fullName",
        "email",
        "phone",
        "mobile",
        "profileImage",
        "role",
        "fcmToken",
      ].join(" ")
    )
    .populate(
      "customer",
      [
        "firstName",
        "lastName",
        "name",
        "fullName",
        "email",
        "phone",
        "mobile",
        "profileImage",
        "role",
        "fcmToken",
      ].join(" ")
    )
    .populate(
      "provider",
      [
        "firstName",
        "lastName",
        "name",
        "fullName",
        "email",
        "phone",
        "mobile",
        "profileImage",
        "role",
        "businessName",
        "shopName",
        "fcmToken",
      ].join(" ")
    )
    .populate({
      path: "service",

      select: [
        "name",
        "title",
        "description",
        "category",
        "categories",
        "price",
        "basePrice",
        "pricePerHour",
        "pricePerDay",
        "currency",
        "serviceType",
        "location",
        "image",
        "imageUrl",
        "images",
        "provider",
        "providerName",
        "businessName",
        "rating",
        "totalReviews",
        "isActive",
        "isAvailable",
        "approvalStatus",
      ].join(" "),

      populate: {
        path: "provider",

        select: [
          "firstName",
          "lastName",
          "name",
          "fullName",
          "email",
          "phone",
          "mobile",
          "profileImage",
          "businessName",
          "shopName",
          "fcmToken",
        ].join(" "),
      },
    });
};

const getPopulatedBooking = async (
  bookingId
) => {
  return populateBookingQuery(
    Booking.findById(
      bookingId
    )
  );
};

// =====================================================
// SERIALIZATION
// =====================================================

const serializeBooking = (
  booking
) => {
  if (!booking) {
    return null;
  }

  const bookingObject =
    typeof booking.toObject ===
    "function"
      ? booking.toObject({
          virtuals: true,
        })
      : { ...booking };

  delete bookingObject.serviceOtpHash;
  delete bookingObject.serviceOtpDisplay;

  const customer =
    bookingObject.customer ||
    bookingObject.user;

  const provider =
    bookingObject.provider;

  const service =
    bookingObject.service;

  const bookingId =
    getDocumentId(
      bookingObject
    );

  const totalPrice =
    normalizePositiveNumber(
      bookingObject.totalPrice,
      bookingObject.totalAmount ||
        0
    );

  const totalAmount =
    normalizePositiveNumber(
      bookingObject.totalAmount,
      totalPrice
    );

  const status =
    bookingObject.status ||
    bookingObject.bookingStatus ||
    BOOKING_STATUSES.PENDING;

  const chatRoomId =
    normalizeString(
      bookingObject.chatRoomId,
      bookingId
        ? `booking:${bookingId}`
        : ""
    );

  return {
    ...bookingObject,

    id:
      bookingId,

    customer,

    customerId:
      getDocumentId(customer),

    customerName:
      getDisplayName(customer),

    customerPhone:
      customer?.phone ||
      customer?.mobile ||
      bookingObject.contactNumber ||
      "",

    customerEmail:
      customer?.email ||
      "",

    providerId:
      getDocumentId(provider),

    providerName:
      getDisplayName(provider) ||
      service?.providerName ||
      service?.businessName ||
      "",

    providerPhone:
      provider?.phone ||
      provider?.mobile ||
      "",

    providerEmail:
      provider?.email ||
      "",

    serviceId:
      getDocumentId(service),

    serviceName:
      service?.name ||
      service?.title ||
      bookingObject.serviceName ||
      "",

    bookingDate:
      bookingObject.bookingDate ||
      bookingObject.date,

    date:
      bookingObject.date ||
      bookingObject.bookingDate,

    status,

    bookingStatus:
      status,

    providerArrived:
      bookingObject
        .providerArrived === true,

    providerArrivedAt:
      bookingObject
        .providerArrivedAt ||
      null,

    providerArrivalLocation:
      bookingObject
        .providerArrivalLocation ||
      null,

    providerArrivalDistanceMeters:
      bookingObject
        .providerArrivalDistanceMeters ??
      null,

    providerArrivalVerified:
      bookingObject
        .providerArrivalVerified ===
      true,

    otpVerified:
      bookingObject
        .otpVerified === true,

    otpVerifiedAt:
      bookingObject
        .otpVerifiedAt ||
      null,

    chatRoomId,

    amount:
      normalizePositiveNumber(
        bookingObject.amount,
        totalAmount
      ),

    gst:
      normalizePositiveNumber(
        bookingObject.gst,
        bookingObject.taxAmount ||
          0
      ),

    serviceFee:
      normalizePositiveNumber(
        bookingObject.serviceFee,
        bookingObject.platformFee ||
          0
      ),

    discount:
      normalizePositiveNumber(
        bookingObject.discount,
        bookingObject
          .discountAmount ||
          0
      ),

    durationMinutes:
      calculateDurationMinutes(
        bookingObject
      ),

    totalPrice,
    totalAmount,
  };
};

// =====================================================
// RESPONSE HELPERS
// =====================================================

const sendValidationError = (
  res,
  message,
  fields = []
) => {
  return res.status(400).json({
    success: false,
    message,
    fields,
  });
};

const sendBookingResponse = (
  res,
  booking,
  {
    statusCode = 200,
    message =
      "Booking fetched successfully",
    extra = {},
  } = {}
) => {
  const data =
    serializeBooking(booking);

  return res
    .status(statusCode)
    .json({
      success: true,
      message,
      booking: data,
      data,
      ...extra,
    });
};

const sendBookingListResponse = (
  res,
  bookings,
  {
    message =
      "Bookings fetched successfully",
    pagination = null,
    extra = {},
  } = {}
) => {
  const data = bookings
    .map(serializeBooking)
    .filter(Boolean);

  return res.status(200).json({
    success: true,
    message,
    bookings: data,
    data,
    count: data.length,
    ...extra,

    ...(pagination
      ? {
          pagination,
        }
      : {}),
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
      (item) =>
        item.message
    );

    return res.status(400).json({
      success: false,

      message:
        errors[0] ||
        "Booking validation failed",

      errors,
    });
  }

  if (
    error?.name ===
    "CastError"
  ) {
    return res.status(400).json({
      success: false,
      message:
        "Invalid booking identifier",
    });
  }

  if (error?.code === 11000) {
    return res.status(409).json({
      success: false,
      message:
        "A duplicate booking record was detected",
    });
  }

  if (
    error?.code ===
      "OTP_SECRET_MISSING" ||
    error?.code ===
      "OTP_SECRET_WEAK"
  ) {
    return res.status(500).json({
      success: false,

      message:
        process.env.NODE_ENV ===
        "production"
          ? "Booking security configuration is unavailable"
          : error.message,
    });
  }

  return res.status(500).json({
    success: false,

    message:
      process.env.NODE_ENV ===
      "production"
        ? "Internal server error"
        : error?.message ||
          "Internal server error",
  });
};

// =====================================================
// SOCKET.IO
// =====================================================

const emitBookingEvent = (
  eventName,
  booking
) => {
  const io = global.io;

  if (!io || !booking) {
    return;
  }

  const data =
    serializeBooking(booking);

  if (!data) {
    return;
  }

  const bookingId =
    data.id;

  const providerId =
    data.providerId;

  const customerId =
    data.customerId;

  const refreshPayload = {
    bookingId,
    providerId,
    customerId,

    status:
      data.status,

    bookingStatus:
      data.bookingStatus ||
      data.status,

    providerArrived:
      data.providerArrived ===
      true,

    providerArrivedAt:
      data.providerArrivedAt ||
      null,

    providerArrivalVerified:
      data.providerArrivalVerified ===
      true,

    otpVerified:
      data.otpVerified === true,

    otpVerifiedAt:
      data.otpVerifiedAt ||
      null,

    startedAt:
      data.startedAt ||
      null,

    completedAt:
      data.completedAt ||
      null,

    chatRoomId:
      data.chatRoomId ||
      (
        bookingId
          ? `booking:${bookingId}`
          : ""
      ),

    updatedAt:
      data.updatedAt ||
      new Date().toISOString(),
  };

  io.emit(
    eventName,
    data
  );

  io.emit(
    "bookingUpdate",
    data
  );

  io.emit(
    "bookingUpdated",
    data
  );

  io.emit(
    "refreshBookings",
    refreshPayload
  );

  if (providerId) {
    const providerRoom =
      `provider:${providerId}`;

    io.to(providerRoom).emit(
      eventName,
      data
    );

    io.to(providerRoom).emit(
      "bookingUpdated",
      data
    );

    io.to(providerRoom).emit(
      "refreshProviderBookings",
      refreshPayload
    );

    io.to(providerRoom).emit(
      "refreshProviderOrders",
      refreshPayload
    );

    io.to(providerRoom).emit(
      "refreshProviderDashboard",
      refreshPayload
    );

    io.to(providerRoom).emit(
      "refreshProviderEarnings",
      refreshPayload
    );
  }

  if (customerId) {
    const customerRoom =
      `user:${customerId}`;

    io.to(customerRoom).emit(
      eventName,
      data
    );

    io.to(customerRoom).emit(
      "bookingUpdate",
      data
    );

    io.to(customerRoom).emit(
      "bookingUpdated",
      data
    );

    io.to(customerRoom).emit(
      "refreshCustomerBookings",
      refreshPayload
    );
  }

  io.to("admin").emit(
    "refreshAdminBookings",
    refreshPayload
  );

  io.to("admin").emit(
    "refreshAdminDashboard",
    refreshPayload
  );

  if (bookingId) {
    io.to(
      `booking:${bookingId}`
    ).emit(
      eventName,
      data
    );

    io.to(
      `booking:${bookingId}`
    ).emit(
      "bookingUpdated",
      data
    );
  }

  if (data.chatRoomId) {
    io.to(
      data.chatRoomId
    ).emit(
      eventName,
      data
    );
  }
};

// =====================================================
// DATABASE NOTIFICATIONS
// =====================================================

const createDatabaseNotification =
  async ({
    recipient,
    sender = null,
    title,
    message,
    booking,
    type = "booking",
  }) => {
    const recipientId =
      getDocumentId(recipient);

    if (
      !recipientId ||
      !isValidObjectId(
        recipientId
      )
    ) {
      return null;
    }

    try {
      const bookingId =
        getDocumentId(booking);

      const candidateData = {
        user: recipientId,
        recipient: recipientId,
        receiver: recipientId,
        sender,
        title,
        message,
        type,

        booking:
          bookingId ||
          undefined,

        bookingId:
          bookingId ||
          undefined,

        referenceId:
          bookingId ||
          undefined,

        referenceType:
          "booking",

        isRead: false,
        read: false,
      };

      const schemaPaths =
        Notification.schema
          ?.paths || {};

      const supportedData = {};

      for (
        const [
          key,
          value,
        ] of Object.entries(
          candidateData
        )
      ) {
        if (
          schemaPaths[key] &&
          value !== undefined &&
          value !== null &&
          value !== ""
        ) {
          supportedData[key] =
            value;
        }
      }

      if (
        Object.keys(
          supportedData
        ).length === 0
      ) {
        return null;
      }

      const notification =
        await Notification.create(
          supportedData
        );

      if (global.io) {
        global.io
          .to(
            `provider:${recipientId}`
          )
          .emit(
            "newNotification",
            notification
          );

        global.io
          .to(
            `user:${recipientId}`
          )
          .emit(
            "newNotification",
            notification
          );
      }

      return notification;
    } catch (error) {
      console.error(
        "Database Notification Error:",
        error.message
      );

      return null;
    }
  };

// =====================================================
// PUSH NOTIFICATIONS
// =====================================================

const sendPushNotification =
  async ({
    receiver,
    title,
    message,
  }) => {
    try {
      if (!receiver?.fcmToken) {
        return false;
      }

      await sendNotification(
        receiver.fcmToken,
        title,
        message
      );

      return true;
    } catch (error) {
      console.error(
        "Push Notification Error:",
        error.message
      );

      return false;
    }
  };

// =====================================================
// CREATE BOOKING
// =====================================================

export const createBooking =
  async (req, res) => {
    try {
      const customerId =
        getAuthenticatedUserId(
          req
        );

      if (
        !customerId ||
        !isValidObjectId(
          customerId
        )
      ) {
        return res.status(401).json({
          success: false,
          message:
            "Authentication required",
        });
      }

      if (isProvider(req)) {
        return res.status(403).json({
          success: false,

          message:
            "Provider accounts cannot create customer bookings",
        });
      }

      const resolvedServiceId =
        normalizeString(
          req.body.serviceId ||
          req.body.service
        );

      if (
        !resolvedServiceId ||
        !isValidObjectId(
          resolvedServiceId
        )
      ) {
        return sendValidationError(
          res,
          "A valid serviceId is required",
          ["serviceId"]
        );
      }

      const rawBookingDate =
        req.body.bookingDate ||
        req.body.date;

      if (!rawBookingDate) {
        return sendValidationError(
          res,
          "Booking date is required",
          ["bookingDate"]
        );
      }

      const parsedBookingDate =
        new Date(
          rawBookingDate
        );

      if (
        Number.isNaN(
          parsedBookingDate
            .getTime()
        )
      ) {
        return sendValidationError(
          res,
          "Booking date is invalid",
          ["bookingDate"]
        );
      }

      const resolvedAddress =
        normalizeString(
          req.body.address ||
          req.body.location
        );

      if (!resolvedAddress) {
        return sendValidationError(
          res,
          "Service address is required",
          ["address"]
        );
      }

      const serviceDocument =
        await Service.findOne({
          _id:
            resolvedServiceId,

          isActive: {
            $ne: false,
          },

          isAvailable: {
            $ne: false,
          },

          approvalStatus: {
            $in: [
              "approved",
              null,
              "",
            ],
          },

          deletedAt: null,
        }).populate(
          "provider",
          [
            "firstName",
            "lastName",
            "name",
            "fullName",
            "email",
            "phone",
            "mobile",
            "fcmToken",
            "businessName",
            "shopName",
          ].join(" ")
        );

      if (!serviceDocument) {
        return res.status(404).json({
          success: false,

          message:
            "Service is unavailable or does not exist",
        });
      }

      const providerId =
        getDocumentId(
          serviceDocument.provider
        );

      if (
        !providerId ||
        !isValidObjectId(
          providerId
        )
      ) {
        return res.status(400).json({
          success: false,

          message:
            "This service is not linked to a valid provider",
        });
      }

      if (
        providerId ===
        customerId
      ) {
        return res.status(400).json({
          success: false,

          message:
            "You cannot book your own service",
        });
      }

      const hoursBooked =
        Math.max(
          1,
          Math.floor(
            normalizeNumber(
              req.body.hoursBooked,
              1
            )
          )
        );

      const pricing =
        getServicePricing(
          serviceDocument,
          hoursBooked
        );

      if (
        pricing.subtotal <= 0
      ) {
        return res.status(400).json({
          success: false,

          message:
            "The selected service does not have a valid price",
        });
      }

      const platformFee =
        normalizePositiveNumber(
          req.body.platformFee ??
          req.body.serviceFee,
          0
        );

      const taxAmount =
        normalizePositiveNumber(
          req.body.taxAmount ??
          req.body.gst,
          0
        );

      const discountAmount =
        normalizePositiveNumber(
          req.body.discountAmount ??
          req.body.discount,
          0
        );

      const totalAmount =
        Math.max(
          0,
          pricing.subtotal +
            platformFee +
            taxAmount -
            discountAmount
        );

      const customerLocation =
        normalizeLocationPoint(
          req.body
        );

      const booking =
        new Booking({
          user:
            customerId,

          customer:
            customerId,

          service:
            serviceDocument._id,

          provider:
            providerId,

          bookingDate:
            parsedBookingDate,

          date:
            parsedBookingDate,

          bookingTime:
            normalizeString(
              req.body.bookingTime ||
              req.body.time
            ),

          duration:
            normalizeString(
              req.body.duration
            ),

          contactNumber:
            normalizeString(
              req.body.contactNumber ||
              req.body.phone ||
              req.body.mobile
            ),

          alternateContactNumber:
            normalizeString(
              req.body
                .alternateContactNumber
            ),

          guestCount:
            normalizePositiveNumber(
              req.body.guestCount,
              0
            ),

          locationType:
            normalizeString(
              req.body.locationType
            ),

          serviceLocationType:
            normalizeString(
              req.body
                .serviceLocationType
            ),

          landmark:
            normalizeString(
              req.body.landmark
            ),

          nearbyLocation:
            normalizeString(
              req.body.nearbyLocation
            ),

          notes:
            normalizeString(
              req.body.notes
            ),

          specialInstructions:
            normalizeString(
              req.body
                .specialInstructions
            ),

          address:
            resolvedAddress,

          location:
            normalizeString(
              req.body.location,
              resolvedAddress
            ),

          locationPoint:
            customerLocation.point,

          hoursBooked,

          pricePerHour:
            pricing.unitPrice,

          basePrice:
            normalizePositiveNumber(
              serviceDocument
                .basePrice,
              pricing.unitPrice
            ),

          subtotal:
            pricing.subtotal,

          platformFee,
          taxAmount,
          discountAmount,

          totalPrice:
            totalAmount,

          totalAmount,

          currency:
            normalizeString(
              serviceDocument
                .currency,
              "INR"
            ).toUpperCase(),

          couponCode:
            normalizeString(
              req.body.couponCode
            ).toUpperCase(),

          paymentMethod:
            normalizePaymentMethod(
              req.body
                .paymentMethod
            ),

          paymentStatus:
            PAYMENT_STATUSES.PENDING,

          status:
            BOOKING_STATUSES.PENDING,

          providerArrived:
            false,

          providerArrivedAt:
            null,

          providerArrivalLocation: {
            type: "Point",
            coordinates: [0, 0],
          },

          providerArrivalDistanceMeters:
            null,

          providerArrivalVerified:
            false,

          otpVerified:
            false,

          otpAttempts:
            0,

          chatEnabled:
            true,
        });

      booking.chatRoomId =
        `booking:${booking._id.toString()}`;

      booking.bookingNumber =
        `EB-${booking._id
          .toString()
          .slice(-8)
          .toUpperCase()}`;

      const serviceOtp =
        generateServiceOtp();

      booking.serviceOtpHash =
        hashServiceOtp(
          booking._id.toString(),
          serviceOtp
        );

      booking.serviceOtpDisplay =
        serviceOtp;

      await booking.save();

      const populatedBooking =
        await getPopulatedBooking(
          booking._id
        );

      const notificationMessage =
        `New booking ${booking.bookingNumber} for ${
          serviceDocument.name ||
          serviceDocument.title ||
          "service"
        }.`;

      await createDatabaseNotification({
        recipient:
          providerId,

        sender:
          customerId,

        title:
          "New Booking",

        message:
          notificationMessage,

        booking,

        type:
          "booking",
      });

      await sendPushNotification({
        receiver:
          serviceDocument.provider,

        title:
          "New Booking",

        message:
          notificationMessage,
      });

      emitBookingEvent(
        "newBooking",
        populatedBooking ||
        booking
      );

      return sendBookingResponse(
        res,
        populatedBooking ||
        booking,
        {
          statusCode: 201,

          message:
            "Booking created successfully",
        }
      );
    } catch (error) {
      return sendControllerError(
        res,
        "Create Booking Error",
        error
      );
    }
  };

// =====================================================
// GET CUSTOMER BOOKINGS
// =====================================================

export const getMyBookings =
  async (req, res) => {
    try {
      const customerId =
        getAuthenticatedUserId(
          req
        );

      if (
        !customerId ||
        !isValidObjectId(
          customerId
        )
      ) {
        return res.status(401).json({
          success: false,
          message:
            "Authentication required",
        });
      }

      const {
        page,
        limit,
        skip,
      } = getPagination(req);

      const filter = {
        $or: [
          {
            user:
              customerId,
          },
          {
            customer:
              customerId,
          },
        ],

        isCustomerDeleted: {
          $ne: true,
        },

        deletedAt: null,
      };

      const requestedStatus =
        normalizeBookingStatus(
          req.query.status
        );

      if (requestedStatus) {
        filter.status =
          requestedStatus;
      }

      const [
        total,
        bookings,
      ] = await Promise.all([
        Booking.countDocuments(
          filter
        ),

        populateBookingQuery(
          Booking.find(filter)
            .sort({
              createdAt: -1,
            })
            .skip(skip)
            .limit(limit)
        ),
      ]);

      return sendBookingListResponse(
        res,
        bookings,
        {
          message:
            "Customer bookings fetched successfully",

          pagination: {
            page,
            limit,
            total,

            totalPages:
              Math.ceil(
                total / limit
              ),

            hasNextPage:
              page * limit <
              total,

            hasPreviousPage:
              page > 1,
          },
        }
      );
    } catch (error) {
      return sendControllerError(
        res,
        "Get My Bookings Error",
        error
      );
    }
  };

export const getBookings =
  getMyBookings;

// =====================================================
// GET PROVIDER BOOKINGS
// =====================================================

export const getProviderBookings =
  async (req, res) => {
    try {
      if (
        !isProvider(req) &&
        !isAdmin(req)
      ) {
        return res.status(403).json({
          success: false,
          message:
            "Provider access required",
        });
      }

      const authenticatedId =
        getAuthenticatedUserId(
          req
        );

      const requestedProviderId =
        normalizeString(
          req.query.providerId
        );

      const providerId =
        isAdmin(req) &&
        requestedProviderId &&
        isValidObjectId(
          requestedProviderId
        )
          ? requestedProviderId
          : authenticatedId;

      if (
        !providerId ||
        !isValidObjectId(
          providerId
        )
      ) {
        return res.status(400).json({
          success: false,
          message:
            "Invalid provider identifier",
        });
      }

      const {
        page,
        limit,
        skip,
      } = getPagination(req);

      const filter = {
        provider:
          providerId,

        isProviderDeleted: {
          $ne: true,
        },

        deletedAt: null,
      };

      const requestedStatus =
        normalizeBookingStatus(
          req.query.status
        );

      if (requestedStatus) {
        filter.status =
          requestedStatus;
      }

      const [
        total,
        bookings,
      ] = await Promise.all([
        Booking.countDocuments(
          filter
        ),

        populateBookingQuery(
          Booking.find(filter)
            .sort({
              createdAt: -1,
            })
            .skip(skip)
            .limit(limit)
        ),
      ]);

      return sendBookingListResponse(
        res,
        bookings,
        {
          message:
            "Provider bookings fetched successfully",

          pagination: {
            page,
            limit,
            total,

            totalPages:
              Math.ceil(
                total / limit
              ),

            hasNextPage:
              page * limit <
              total,

            hasPreviousPage:
              page > 1,
          },
        }
      );
    } catch (error) {
      return sendControllerError(
        res,
        "Get Provider Bookings Error",
        error
      );
    }
  };

// =====================================================
// GET PROVIDER TODAY BOOKINGS
// =====================================================

export const getProviderTodayBookings =
  async (req, res) => {
    try {
      if (
        !isProvider(req) &&
        !isAdmin(req)
      ) {
        return res.status(403).json({
          success: false,
          message:
            "Provider access required",
        });
      }

      const providerId =
        getAuthenticatedUserId(
          req
        );

      const bookings =
        await populateBookingQuery(
          Booking.find({
            provider:
              providerId,

            bookingDate: {
              $gte:
                getStartOfDay(),

              $lte:
                getEndOfDay(),
            },

            isProviderDeleted: {
              $ne: true,
            },

            deletedAt: null,
          }).sort({
            bookingDate: 1,
            bookingTime: 1,
          })
        );

      return sendBookingListResponse(
        res,
        bookings,
        {
          message:
            "Today's Provider bookings fetched successfully",
        }
      );
    } catch (error) {
      return sendControllerError(
        res,
        "Get Today Bookings Error",
        error
      );
    }
  };

// =====================================================
// GET PROVIDER UPCOMING BOOKINGS
// =====================================================

export const getProviderUpcomingBookings =
  async (req, res) => {
    try {
      if (
        !isProvider(req) &&
        !isAdmin(req)
      ) {
        return res.status(403).json({
          success: false,
          message:
            "Provider access required",
        });
      }

      const providerId =
        getAuthenticatedUserId(
          req
        );

      const bookings =
        await populateBookingQuery(
          Booking.find({
            provider:
              providerId,

            bookingDate: {
              $gte:
                new Date(),
            },

            status: {
              $in: [
                BOOKING_STATUSES.PENDING,
                BOOKING_STATUSES.ACCEPTED,
                BOOKING_STATUSES.OTP_VERIFIED,
                BOOKING_STATUSES.IN_PROGRESS,
              ],
            },

            isProviderDeleted: {
              $ne: true,
            },

            deletedAt: null,
          })
            .sort({
              bookingDate: 1,
              bookingTime: 1,
            })
            .limit(100)
        );

      return sendBookingListResponse(
        res,
        bookings,
        {
          message:
            "Upcoming Provider bookings fetched successfully",
        }
      );
    } catch (error) {
      return sendControllerError(
        res,
        "Get Upcoming Bookings Error",
        error
      );
    }
  };

// =====================================================
// PROVIDER BOOKING ANALYTICS
// =====================================================

export const getProviderBookingAnalytics =
  async (req, res) => {
    try {
      if (
        !isProvider(req) &&
        !isAdmin(req)
      ) {
        return res.status(403).json({
          success: false,
          message:
            "Provider access required",
        });
      }

      const authenticatedId =
        getAuthenticatedUserId(
          req
        );

      const requestedProviderId =
        normalizeString(
          req.query.providerId
        );

      const providerId =
        isAdmin(req) &&
        requestedProviderId &&
        isValidObjectId(
          requestedProviderId
        )
          ? requestedProviderId
          : authenticatedId;

      if (
        !providerId ||
        !isValidObjectId(
          providerId
        )
      ) {
        return res.status(400).json({
          success: false,
          message:
            "Invalid provider identifier",
        });
      }

      const statusResults =
        await Booking.aggregate([
          {
            $match: {
              provider:
                new mongoose.Types.ObjectId(
                  providerId
                ),

              deletedAt: null,
            },
          },
          {
            $group: {
              _id: "$status",

              count: {
                $sum: 1,
              },

              amount: {
                $sum: {
                  $ifNull: [
                    "$totalAmount",
                    "$totalPrice",
                  ],
                },
              },
            },
          },
        ]);

      const counts = {
        pending: 0,
        accepted: 0,
        otp_verified: 0,
        rejected: 0,
        in_progress: 0,
        completed: 0,
        cancelled: 0,
      };

      let totalBookings = 0;
      let totalRevenue = 0;

      for (
        const result of
        statusResults
      ) {
        if (
          Object.hasOwn(
            counts,
            result._id
          )
        ) {
          counts[result._id] =
            result.count;
        }

        totalBookings +=
          result.count;

        if (
          result._id ===
          BOOKING_STATUSES.COMPLETED
        ) {
          totalRevenue +=
            normalizeNumber(
              result.amount,
              0
            );
        }
      }

      const todayBookings =
        await Booking.countDocuments({
          provider:
            providerId,

          bookingDate: {
            $gte:
              getStartOfDay(),

            $lte:
              getEndOfDay(),
          },

          deletedAt: null,
        });

      const analytics = {
        totalBookings,

        totalOrders:
          totalBookings,

        todayBookings,

        pendingBookings:
          counts.pending,

        pendingOrders:
          counts.pending,

        acceptedBookings:
          counts.accepted,

        acceptedOrders:
          counts.accepted,

        otpVerifiedBookings:
          counts.otp_verified,

        otpVerifiedOrders:
          counts.otp_verified,

        inProgressBookings:
          counts.in_progress,

        inProgressOrders:
          counts.in_progress,

        completedBookings:
          counts.completed,

        completedOrders:
          counts.completed,

        cancelledBookings:
          counts.cancelled,

        cancelledOrders:
          counts.cancelled,

        rejectedBookings:
          counts.rejected,

        rejectedOrders:
          counts.rejected,

        totalRevenue,

        totalEarnings:
          totalRevenue,
      };

      return res.status(200).json({
        success: true,

        message:
          "Booking analytics fetched successfully",

        analytics,
        data: analytics,
        ...analytics,
      });
    } catch (error) {
      return sendControllerError(
        res,
        "Booking Analytics Error",
        error
      );
    }
  };

// =====================================================
// GET BOOKING BY ID
// =====================================================

export const getBookingById =
  async (req, res) => {
    try {
      const bookingId =
        normalizeString(
          req.params.id
        );

      if (
        !isValidObjectId(
          bookingId
        )
      ) {
        return res.status(400).json({
          success: false,
          message:
            "Invalid booking identifier",
        });
      }

      const booking =
        await getPopulatedBooking(
          bookingId
        );

      if (!booking) {
        return res.status(404).json({
          success: false,
          message:
            "Booking not found",
        });
      }

      const currentUserId =
        getAuthenticatedUserId(
          req
        );

      const customerId =
        getDocumentId(
          booking.customer ||
          booking.user
        );

      const providerId =
        getDocumentId(
          booking.provider
        );

      const hasAccess =
        currentUserId ===
          customerId ||
        currentUserId ===
          providerId ||
        isAdmin(req);

      if (!hasAccess) {
        return res.status(403).json({
          success: false,
          message:
            "Access denied",
        });
      }

      return sendBookingResponse(
        res,
        booking
      );
    } catch (error) {
      return sendControllerError(
        res,
        "Get Booking Error",
        error
      );
    }
  };

// =====================================================
// MARK PROVIDER ARRIVED
// =====================================================

export const markProviderArrived =
  async (req, res) => {
    try {
      const bookingId =
        normalizeString(
          req.params.id
        );

      if (
        !isValidObjectId(
          bookingId
        )
      ) {
        return res.status(400).json({
          success: false,

          message:
            "Invalid booking identifier",
        });
      }

      if (
        !isProvider(req) &&
        !isAdmin(req)
      ) {
        return res.status(403).json({
          success: false,

          message:
            "Provider access required",
        });
      }

      let booking =
        await Booking.findById(
          bookingId
        );

      if (!booking) {
        return res.status(404).json({
          success: false,
          message:
            "Booking not found",
        });
      }

      const currentUserId =
        getAuthenticatedUserId(
          req
        );

      if (
        !isAdmin(req) &&
        booking.provider
          ?.toString() !==
          currentUserId
      ) {
        return res.status(403).json({
          success: false,

          message:
            "This booking is not assigned to the logged-in Provider",
        });
      }

      if (
        booking.status !==
        BOOKING_STATUSES.ACCEPTED
      ) {
        return res.status(400).json({
          success: false,

          message:
            "Provider arrival can only be recorded for an accepted booking",

          currentStatus:
            booking.status,
        });
      }

      if (
        booking.providerArrived ===
        true
      ) {
        booking =
          await getPopulatedBooking(
            booking._id
          );

        return sendBookingResponse(
          res,
          booking,
          {
            message:
              "Provider arrival is already recorded",
          }
        );
      }

      const arrivalLocation =
        normalizeLocationPoint(
          req.body
        );

      if (
        !arrivalLocation
          .hasCoordinates ||
        !arrivalLocation.isValid
      ) {
        return sendValidationError(
          res,

          "Valid Provider latitude and longitude are required",

          [
            "latitude",
            "longitude",
          ]
        );
      }

      let distanceMeters =
        null;

      let locationVerified =
        false;

      const destinationCoordinates =
        booking.locationPoint
          ?.coordinates;

      if (
        Array.isArray(
          destinationCoordinates
        ) &&
        destinationCoordinates
          .length === 2
      ) {
        const destinationLongitude =
          Number(
            destinationCoordinates[0]
          );

        const destinationLatitude =
          Number(
            destinationCoordinates[1]
          );

        const hasDestination =
          Number.isFinite(
            destinationLongitude
          ) &&
          Number.isFinite(
            destinationLatitude
          ) &&
          !(
            destinationLongitude ===
              0 &&
            destinationLatitude ===
              0
          );

        if (hasDestination) {
          distanceMeters =
            calculateDistanceMeters({
              fromLatitude:
                arrivalLocation
                  .latitude,

              fromLongitude:
                arrivalLocation
                  .longitude,

              toLatitude:
                destinationLatitude,

              toLongitude:
                destinationLongitude,
            });

          locationVerified =
            distanceMeters !== null &&
            distanceMeters <=
              PROVIDER_ARRIVAL_RADIUS_METERS;
        }
      }

      const now = new Date();

      booking.providerArrived =
        true;

      booking.providerArrivedAt =
        now;

      booking.providerArrivalLocation =
        arrivalLocation.point;

      booking.providerArrivalDistanceMeters =
        distanceMeters;

      booking.providerArrivalVerified =
        locationVerified;

      if (
        !Array.isArray(
          booking.statusHistory
        )
      ) {
        booking.statusHistory =
          [];
      }

      booking.statusHistory.push({
        status:
          booking.status,

        changedBy:
          currentUserId,

        note:
          locationVerified
            ? "Provider arrived at the verified service location"
            : "Provider reported arrival at the service location",

        changedAt:
          now,
      });

      await booking.save();

      booking =
        await getPopulatedBooking(
          booking._id
        );

      const customer =
        booking.customer ||
        booking.user;

      const notificationMessage =
        `The Provider has arrived for booking ${
          booking.bookingNumber ||
          booking._id
        }. Confirm the Provider before sharing the service OTP.`;

      await createDatabaseNotification({
        recipient:
          getDocumentId(
            customer
          ),

        sender:
          currentUserId,

        title:
          "Provider Arrived",

        message:
          notificationMessage,

        booking,

        type:
          "booking",
      });

      await sendPushNotification({
        receiver:
          customer,

        title:
          "Provider Arrived",

        message:
          notificationMessage,
      });

      emitBookingEvent(
        "providerArrived",
        booking
      );

      return sendBookingResponse(
        res,
        booking,
        {
          message:
            "Provider arrival updated successfully",

          extra: {
            providerArrived:
              true,

            providerArrivedAt:
              now,

            providerArrivalDistanceMeters:
              distanceMeters,

            providerArrivalVerified:
              locationVerified,
          },
        }
      );
    } catch (error) {
      return sendControllerError(
        res,
        "Provider Arrival Error",
        error
      );
    }
  };

// =====================================================
// GET CUSTOMER SERVICE OTP
// =====================================================

export const getServiceOtp =
  async (req, res) => {
    try {
      const bookingId =
        normalizeString(
          req.params.id
        );

      if (
        !isValidObjectId(
          bookingId
        )
      ) {
        return res.status(400).json({
          success: false,
          message:
            "Invalid booking identifier",
        });
      }

      const booking =
        await Booking.findById(
          bookingId
        ).select(
          [
            "+serviceOtpDisplay",
            "user",
            "customer",
            "status",
            "otpVerified",
            "otpVerifiedAt",
            "providerArrived",
            "providerArrivedAt",
            "providerArrivalVerified",
            "bookingNumber",
          ].join(" ")
        );

      if (!booking) {
        return res.status(404).json({
          success: false,
          message:
            "Booking not found",
        });
      }

      const currentUserId =
        getAuthenticatedUserId(
          req
        );

      const customerId =
        booking.customer
          ?.toString() ||
        booking.user
          ?.toString();

      if (
        currentUserId !==
        customerId
      ) {
        return res.status(403).json({
          success: false,

          message:
            "Only the customer can view the service OTP",
        });
      }

      if (
        booking.status ===
        BOOKING_STATUSES.PENDING
      ) {
        return res.status(409).json({
          success: false,

          message:
            "Service OTP will be available after the Provider accepts the booking",

          otpAvailable:
            false,
        });
      }

      if (
        [
          BOOKING_STATUSES.CANCELLED,
          BOOKING_STATUSES.REJECTED,
          BOOKING_STATUSES.COMPLETED,
        ].includes(
          booking.status
        )
      ) {
        return res.status(409).json({
          success: false,

          message:
            "Service OTP is unavailable for this booking",

          otpAvailable:
            false,
        });
      }

      if (
        booking.otpVerified ===
        true
      ) {
        const data = {
          bookingId:
            booking._id.toString(),

          bookingNumber:
            booking.bookingNumber,

          otp: null,
          serviceOtp: null,

          otpAvailable:
            false,

          otpVerified:
            true,

          otpVerifiedAt:
            booking.otpVerifiedAt,

          providerArrived:
            booking.providerArrived ===
            true,

          providerArrivedAt:
            booking
              .providerArrivedAt,

          providerArrivalVerified:
            booking
              .providerArrivalVerified ===
            true,
        };

        return res.status(200).json({
          success: true,

          message:
            "Service OTP has already been verified",

          ...data,
          data,
        });
      }

      if (
        !booking.serviceOtpDisplay
      ) {
        return res.status(409).json({
          success: false,

          message:
            "Service OTP is unavailable. Please contact support.",

          otpAvailable:
            false,
        });
      }

      const data = {
        bookingId:
          booking._id.toString(),

        bookingNumber:
          booking.bookingNumber,

        otp:
          booking.serviceOtpDisplay,

        serviceOtp:
          booking.serviceOtpDisplay,

        otpAvailable:
          true,

        otpVerified:
          false,

        providerArrived:
          booking.providerArrived ===
          true,

        providerArrivedAt:
          booking.providerArrivedAt,

        providerArrivalVerified:
          booking
            .providerArrivalVerified ===
          true,

        warning:
          "Share this OTP only after the Provider arrives and you confirm the Provider.",
      };

      return res.status(200).json({
        success: true,

        message:
          "Service OTP fetched successfully",

        ...data,
        data,
      });
    } catch (error) {
      return sendControllerError(
        res,
        "Get Service OTP Error",
        error
      );
    }
  };

// =====================================================
// VERIFY SERVICE OTP
// =====================================================

export const verifyServiceOtp =
  async (req, res) => {
    try {
      const bookingId =
        normalizeString(
          req.params.id
        );

      if (
        !isValidObjectId(
          bookingId
        )
      ) {
        return res.status(400).json({
          success: false,
          message:
            "Invalid booking identifier",
        });
      }

      if (
        !isProvider(req) &&
        !isAdmin(req)
      ) {
        return res.status(403).json({
          success: false,
          message:
            "Provider access required",
        });
      }

      const providedOtp =
        normalizeString(
          req.body.otp ||
          req.body.serviceOtp
        );

      if (
        !/^\d{4}$/.test(
          providedOtp
        )
      ) {
        return sendValidationError(
          res,

          "A valid 4-digit service OTP is required",

          ["otp"]
        );
      }

      let booking =
        await Booking.findById(
          bookingId
        ).select(
          [
            "+serviceOtpHash",
            "+serviceOtpDisplay",
            "user",
            "customer",
            "provider",
            "status",
            "statusHistory",
            "otpVerified",
            "otpVerifiedAt",
            "otpVerifiedBy",
            "otpAttempts",
            "otpLockedUntil",
            "providerArrived",
            "providerArrivedAt",
            "providerArrivalLocation",
            "providerArrivalDistanceMeters",
            "providerArrivalVerified",
            "bookingNumber",
          ].join(" ")
        );

      if (!booking) {
        return res.status(404).json({
          success: false,
          message:
            "Booking not found",
        });
      }

      const currentUserId =
        getAuthenticatedUserId(
          req
        );

      if (
        !isAdmin(req) &&
        booking.provider
          ?.toString() !==
          currentUserId
      ) {
        return res.status(403).json({
          success: false,

          message:
            "This booking is not assigned to the logged-in Provider",
        });
      }

      if (
        booking.otpVerified ===
        true
      ) {
        booking =
          await getPopulatedBooking(
            booking._id
          );

        return sendBookingResponse(
          res,
          booking,
          {
            message:
              "Service OTP is already verified",

            extra: {
              otpVerified:
                true,
            },
          }
        );
      }

      if (
        booking.status !==
        BOOKING_STATUSES.ACCEPTED
      ) {
        return res.status(400).json({
          success: false,

          message:
            "Service OTP can only be verified after the booking is accepted",

          currentStatus:
            booking.status,
        });
      }

      if (
        booking.providerArrived !==
        true
      ) {
        return res.status(400).json({
          success: false,

          message:
            "Mark arrival at the customer location before verifying the service OTP",

          providerArrived:
            false,

          currentStatus:
            booking.status,
        });
      }

      if (
        booking.otpLockedUntil &&
        new Date(
          booking.otpLockedUntil
        ).getTime() >
          Date.now()
      ) {
        return res.status(429).json({
          success: false,

          message:
            "OTP verification is temporarily locked",

          lockedUntil:
            booking.otpLockedUntil,
        });
      }

      const providedHash =
        hashServiceOtp(
          booking._id.toString(),
          providedOtp
        );

      const isCorrectOtp =
        otpHashesMatch(
          booking.serviceOtpHash,
          providedHash
        );

      if (!isCorrectOtp) {
        booking.otpAttempts =
          normalizePositiveNumber(
            booking.otpAttempts,
            0
          ) + 1;

        const attemptsRemaining =
          Math.max(
            0,
            MAX_OTP_ATTEMPTS -
              booking.otpAttempts
          );

        if (
          booking.otpAttempts >=
          MAX_OTP_ATTEMPTS
        ) {
          booking.otpLockedUntil =
            new Date(
              Date.now() +
                OTP_LOCK_MINUTES *
                  60 *
                  1000
            );

          booking.otpAttempts =
            0;
        }

        await booking.save();

        return res.status(400).json({
          success: false,

          message:
            attemptsRemaining === 0
              ? `Too many incorrect attempts. Try again after ${OTP_LOCK_MINUTES} minutes.`
              : "Invalid service OTP",

          attemptsRemaining,

          lockedUntil:
            booking.otpLockedUntil,
        });
      }

      const now = new Date();

      booking.otpVerified =
        true;

      booking.otpVerifiedAt =
        now;

      booking.otpVerifiedBy =
        currentUserId;

      booking.otpAttempts =
        0;

      booking.otpLockedUntil =
        null;

      booking.status =
        BOOKING_STATUSES.OTP_VERIFIED;

      if (
        !Array.isArray(
          booking.statusHistory
        )
      ) {
        booking.statusHistory =
          [];
      }

      booking.statusHistory.push({
        status:
          BOOKING_STATUSES.OTP_VERIFIED,

        changedBy:
          currentUserId,

        note:
          "Customer service OTP verified",

        changedAt:
          now,
      });

      await booking.save();

      booking =
        await getPopulatedBooking(
          booking._id
        );

      const customer =
        booking.customer ||
        booking.user;

      const message =
        `Service OTP for booking ${
          booking.bookingNumber ||
          booking._id
        } was verified successfully.`;

      await createDatabaseNotification({
        recipient:
          getDocumentId(
            customer
          ),

        sender:
          currentUserId,

        title:
          "Service OTP Verified",

        message,

        booking,

        type:
          "booking",
      });

      await sendPushNotification({
        receiver:
          customer,

        title:
          "Service OTP Verified",

        message,
      });

      emitBookingEvent(
        "bookingOtpVerified",
        booking
      );

      return sendBookingResponse(
        res,
        booking,
        {
          message:
            "Service OTP verified successfully",

          extra: {
            otpVerified:
              true,

            status:
              BOOKING_STATUSES.OTP_VERIFIED,
          },
        }
      );
    } catch (error) {
      return sendControllerError(
        res,
        "Verify Service OTP Error",
        error
      );
    }
  };

// =====================================================
// UPDATE BOOKING STATUS
// =====================================================

export const updateBookingStatus =
  async (req, res) => {
    try {
      const bookingId =
        normalizeString(
          req.params.id
        );

      if (
        !isValidObjectId(
          bookingId
        )
      ) {
        return res.status(400).json({
          success: false,
          message:
            "Invalid booking identifier",
        });
      }

      if (
        !isProvider(req) &&
        !isAdmin(req)
      ) {
        return res.status(403).json({
          success: false,
          message:
            "Provider access required",
        });
      }

      const requestedStatus =
        normalizeBookingStatus(
          req.body.status
        );

      if (
        !Object.values(
          BOOKING_STATUSES
        ).includes(
          requestedStatus
        )
      ) {
        return sendValidationError(
          res,
          "Invalid booking status",
          ["status"]
        );
      }

      if (
        requestedStatus ===
        BOOKING_STATUSES.OTP_VERIFIED
      ) {
        return res.status(400).json({
          success: false,

          message:
            "Use the service OTP verification endpoint to verify the booking",
        });
      }

      let booking =
        await Booking.findById(
          bookingId
        );

      if (!booking) {
        return res.status(404).json({
          success: false,
          message:
            "Booking not found",
        });
      }

      const currentUserId =
        getAuthenticatedUserId(
          req
        );

      if (
        !isAdmin(req) &&
        booking.provider
          ?.toString() !==
          currentUserId
      ) {
        return res.status(403).json({
          success: false,

          message:
            "This booking does not belong to the logged-in Provider",
        });
      }

      if (
        booking.status ===
        requestedStatus
      ) {
        booking =
          await getPopulatedBooking(
            booking._id
          );

        return sendBookingResponse(
          res,
          booking,
          {
            message:
              "Booking already has the requested status",
          }
        );
      }

      const allowedStatuses =
        PROVIDER_STATUS_TRANSITIONS[
          booking.status
        ] || [];

      if (
        !isAdmin(req) &&
        !allowedStatuses.includes(
          requestedStatus
        )
      ) {
        return res.status(400).json({
          success: false,

          message:
            `Cannot change booking status from ${booking.status} to ${requestedStatus}`,

          currentStatus:
            booking.status,

          allowedStatuses,
        });
      }

      if (
        requestedStatus ===
        BOOKING_STATUSES.IN_PROGRESS
      ) {
        if (
          booking.providerArrived !==
          true
        ) {
          return res.status(400).json({
            success: false,

            message:
              "Mark arrival at the customer location before starting the service",

            providerArrived:
              false,

            currentStatus:
              booking.status,
          });
        }

        if (
          booking.otpVerified !==
            true ||
          booking.status !==
            BOOKING_STATUSES.OTP_VERIFIED
        ) {
          return res.status(400).json({
            success: false,

            message:
              "Verify the customer service OTP before starting the service",

            otpVerified:
              booking.otpVerified ===
              true,

            currentStatus:
              booking.status,
          });
        }
      }

      if (
        requestedStatus ===
          BOOKING_STATUSES.COMPLETED &&
        !booking.startedAt
      ) {
        return res.status(400).json({
          success: false,

          message:
            "The service must be started before it can be completed",

          currentStatus:
            booking.status,
        });
      }

      const now = new Date();

      booking.status =
        requestedStatus;

      if (
        requestedStatus ===
        BOOKING_STATUSES.REJECTED
      ) {
        booking.rejectionReason =
          normalizeString(
            req.body.reason ||
            req.body.rejectionReason,
            "Rejected by Provider"
          );
      }

      if (
        requestedStatus ===
        BOOKING_STATUSES.CANCELLED
      ) {
        booking.cancellationReason =
          normalizeString(
            req.body.reason ||
            req.body
              .cancellationReason,
            "Cancelled by Provider"
          );
      }

      if (
        requestedStatus ===
        BOOKING_STATUSES.COMPLETED
      ) {
        booking.completedAt =
          now;

        booking.durationMinutes =
          calculateDurationMinutes({
            startedAt:
              booking.startedAt,

            completedAt:
              now,
          });

        if (
          booking.paymentMethod ===
          PAYMENT_METHODS.COD
        ) {
          booking.paymentStatus =
            PAYMENT_STATUSES.PAID;

          booking.paidAt =
            booking.paidAt ||
            now;
        }

        if (
          !booking.invoiceNumber
        ) {
          booking.invoiceNumber =
            `INV-${booking.bookingNumber}`;
        }

        booking.invoiceGeneratedAt =
          booking
            .invoiceGeneratedAt ||
          now;
      }

      if (
        !Array.isArray(
          booking.statusHistory
        )
      ) {
        booking.statusHistory =
          [];
      }

      booking.statusHistory.push({
        status:
          requestedStatus,

        changedBy:
          currentUserId,

        note:
          normalizeString(
            req.body.note ||
            req.body.reason,
            `Booking changed to ${requestedStatus}`
          ),

        changedAt:
          now,
      });

      await booking.save();

      booking =
        await getPopulatedBooking(
          booking._id
        );

      const customer =
        booking.customer ||
        booking.user;

      const readableStatus =
        requestedStatus.replaceAll(
          "_",
          " "
        );

      const notificationMessage =
        `Booking ${
          booking.bookingNumber ||
          booking._id
        } is now ${readableStatus}.`;

      await createDatabaseNotification({
        recipient:
          getDocumentId(
            customer
          ),

        sender:
          currentUserId,

        title:
          "Booking Updated",

        message:
          notificationMessage,

        booking,

        type:
          "booking",
      });

      await sendPushNotification({
        receiver:
          customer,

        title:
          "Booking Update",

        message:
          notificationMessage,
      });

      let socketEvent =
        "bookingUpdated";

      switch (requestedStatus) {
        case BOOKING_STATUSES.ACCEPTED:
          socketEvent =
            "bookingAccepted";
          break;

        case BOOKING_STATUSES.REJECTED:
          socketEvent =
            "bookingRejected";
          break;

        case BOOKING_STATUSES.IN_PROGRESS:
          socketEvent =
            "bookingStarted";
          break;

        case BOOKING_STATUSES.COMPLETED:
          socketEvent =
            "bookingCompleted";
          break;

        case BOOKING_STATUSES.CANCELLED:
          socketEvent =
            "bookingCancelled";
          break;

        default:
          socketEvent =
            "bookingUpdated";
      }

      emitBookingEvent(
        socketEvent,
        booking
      );

      return sendBookingResponse(
        res,
        booking,
        {
          message:
            "Booking status updated successfully",
        }
      );
    } catch (error) {
      return sendControllerError(
        res,
        "Update Booking Status Error",
        error
      );
    }
  };

// =====================================================
// CANCEL BOOKING
// =====================================================

export const cancelBooking =
  async (req, res) => {
    try {
      const bookingId =
        normalizeString(
          req.params.id
        );

      if (
        !isValidObjectId(
          bookingId
        )
      ) {
        return res.status(400).json({
          success: false,
          message:
            "Invalid booking identifier",
        });
      }

      let booking =
        await Booking.findById(
          bookingId
        );

      if (!booking) {
        return res.status(404).json({
          success: false,
          message:
            "Booking not found",
        });
      }

      const currentUserId =
        getAuthenticatedUserId(
          req
        );

      const customerId =
        booking.customer
          ?.toString() ||
        booking.user
          ?.toString();

      if (
        customerId !==
          currentUserId &&
        !isAdmin(req)
      ) {
        return res.status(403).json({
          success: false,

          message:
            "You cannot cancel this booking",
        });
      }

      if (
        !CUSTOMER_CANCELLABLE_STATUSES.includes(
          booking.status
        )
      ) {
        return res.status(400).json({
          success: false,

          message:
            `A ${booking.status} booking cannot be cancelled`,
        });
      }

      const now = new Date();

      booking.status =
        BOOKING_STATUSES.CANCELLED;

      booking.cancelledAt =
        now;

      booking.cancellationReason =
        normalizeString(
          req.body.reason ||
          req.body
            .cancellationReason,
          "Cancelled by customer"
        );

      if (
        !Array.isArray(
          booking.statusHistory
        )
      ) {
        booking.statusHistory =
          [];
      }

      booking.statusHistory.push({
        status:
          BOOKING_STATUSES.CANCELLED,

        changedBy:
          currentUserId,

        note:
          booking.cancellationReason,

        changedAt:
          now,
      });

      await booking.save();

      booking =
        await getPopulatedBooking(
          booking._id
        );

      const provider =
        booking.provider;

      const notificationMessage =
        `Booking ${
          booking.bookingNumber ||
          booking._id
        } was cancelled by the customer.`;

      await createDatabaseNotification({
        recipient:
          getDocumentId(
            provider
          ),

        sender:
          currentUserId,

        title:
          "Booking Cancelled",

        message:
          notificationMessage,

        booking,

        type:
          "booking",
      });

      await sendPushNotification({
        receiver:
          provider,

        title:
          "Booking Cancelled",

        message:
          notificationMessage,
      });

      emitBookingEvent(
        "bookingCancelled",
        booking
      );

      return sendBookingResponse(
        res,
        booking,
        {
          message:
            "Booking cancelled successfully",
        }
      );
    } catch (error) {
      return sendControllerError(
        res,
        "Cancel Booking Error",
        error
      );
    }
  };

// =====================================================
// GET BOOKING INVOICE
// =====================================================

export const getBookingInvoice =
  async (req, res) => {
    try {
      const bookingId =
        normalizeString(
          req.params.id
        );

      if (
        !isValidObjectId(
          bookingId
        )
      ) {
        return res.status(400).json({
          success: false,
          message:
            "Invalid booking identifier",
        });
      }

      const booking =
        await getPopulatedBooking(
          bookingId
        );

      if (!booking) {
        return res.status(404).json({
          success: false,
          message:
            "Booking not found",
        });
      }

      const currentUserId =
        getAuthenticatedUserId(
          req
        );

      const customerId =
        getDocumentId(
          booking.customer ||
          booking.user
        );

      const providerId =
        getDocumentId(
          booking.provider
        );

      const hasAccess =
        currentUserId ===
          customerId ||
        currentUserId ===
          providerId ||
        isAdmin(req);

      if (!hasAccess) {
        return res.status(403).json({
          success: false,
          message:
            "Access denied",
        });
      }

      if (
        booking.status !==
        BOOKING_STATUSES.COMPLETED
      ) {
        return res.status(400).json({
          success: false,

          message:
            "Invoice is available only for completed bookings",
        });
      }

      const invoice = {
        invoiceNumber:
          booking.invoiceNumber ||
          `INV-${booking.bookingNumber}`,

        bookingId:
          booking._id.toString(),

        bookingNumber:
          booking.bookingNumber,

        customer:
          booking.customer ||
          booking.user,

        provider:
          booking.provider,

        service:
          booking.service,

        bookingDate:
          booking.bookingDate,

        bookingTime:
          booking.bookingTime,

        startedAt:
          booking.startedAt,

        completedAt:
          booking.completedAt,

        durationMinutes:
          calculateDurationMinutes(
            booking
          ),

        address:
          booking.address,

        currency:
          booking.currency,

        basePrice:
          normalizePositiveNumber(
            booking.basePrice,
            0
          ),

        subtotal:
          normalizePositiveNumber(
            booking.subtotal,
            0
          ),

        platformFee:
          normalizePositiveNumber(
            booking.platformFee,
            0
          ),

        taxAmount:
          normalizePositiveNumber(
            booking.taxAmount,
            0
          ),

        discountAmount:
          normalizePositiveNumber(
            booking.discountAmount,
            0
          ),

        totalAmount:
          normalizePositiveNumber(
            booking.totalAmount,
            booking.totalPrice
          ),

        paymentMethod:
          booking.paymentMethod,

        paymentStatus:
          booking.paymentStatus,

        transactionId:
          booking.transactionId,

        paidAt:
          booking.paidAt,

        generatedAt:
          booking
            .invoiceGeneratedAt ||
          booking.completedAt ||
          new Date(),
      };

      return res.status(200).json({
        success: true,

        message:
          "Booking invoice fetched successfully",

        invoice,
        data: invoice,
      });
    } catch (error) {
      return sendControllerError(
        res,
        "Get Invoice Error",
        error
      );
    }
  };

// =====================================================
// RATE BOOKING
// =====================================================

export const rateBooking =
  async (req, res) => {
    try {
      const bookingId =
        normalizeString(
          req.params.id
        );

      if (
        !isValidObjectId(
          bookingId
        )
      ) {
        return res.status(400).json({
          success: false,
          message:
            "Invalid booking identifier",
        });
      }

      const rating =
        normalizeNumber(
          req.body.rating,
          0
        );

      const review =
        normalizeString(
          req.body.review
        );

      if (
        rating < 1 ||
        rating > 5
      ) {
        return sendValidationError(
          res,

          "Rating must be between 1 and 5",

          ["rating"]
        );
      }

      let booking =
        await Booking.findById(
          bookingId
        );

      if (!booking) {
        return res.status(404).json({
          success: false,
          message:
            "Booking not found",
        });
      }

      const currentUserId =
        getAuthenticatedUserId(
          req
        );

      const customerId =
        booking.customer
          ?.toString() ||
        booking.user
          ?.toString();

      if (
        customerId !==
        currentUserId
      ) {
        return res.status(403).json({
          success: false,

          message:
            "You cannot rate this booking",
        });
      }

      if (
        booking.status !==
        BOOKING_STATUSES.COMPLETED
      ) {
        return res.status(400).json({
          success: false,

          message:
            "Only completed bookings can be rated",
        });
      }

      if (
        booking.rating !== null &&
        booking.rating !==
          undefined
      ) {
        return res.status(409).json({
          success: false,

          message:
            "This booking has already been rated",
        });
      }

      booking.rating =
        rating;

      booking.review =
        review;

      booking.reviewedAt =
        new Date();

      await booking.save();

      booking =
        await getPopulatedBooking(
          booking._id
        );

      await createDatabaseNotification({
        recipient:
          getDocumentId(
            booking.provider
          ),

        sender:
          currentUserId,

        title:
          "New Booking Review",

        message:
          `Booking ${
            booking.bookingNumber ||
            booking._id
          } received a ${rating}-star rating.`,

        booking,

        type:
          "review",
      });

      emitBookingEvent(
        "bookingRated",
        booking
      );

      return sendBookingResponse(
        res,
        booking,
        {
          message:
            "Rating submitted successfully",
        }
      );
    } catch (error) {
      return sendControllerError(
        res,
        "Rate Booking Error",
        error
      );
    }
  };

// =====================================================
// CHAT MESSAGE PUSH NOTIFICATION
// =====================================================

export const sendMessageNotification =
  async (
    receiver,
    message
  ) => {
    return sendPushNotification({
      receiver,

      title:
        "New Message",

      message:
        normalizeString(
          message,
          "You received a new message."
        ),
    });
  };