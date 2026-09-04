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
// BOOKING STATUS TRANSITIONS
// =====================================================

const PROVIDER_STATUS_TRANSITIONS = Object.freeze({
  [BOOKING_STATUSES.PENDING]: [
    BOOKING_STATUSES.ACCEPTED,
    BOOKING_STATUSES.REJECTED,
  ],

  [BOOKING_STATUSES.ACCEPTED]: [
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
// AUTH HELPERS
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

  const parsedValue = Number(value);

  return Number.isFinite(parsedValue)
    ? parsedValue
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
  return normalizeString(value)
    .toLowerCase()
    .replaceAll("-", "_")
    .replaceAll(" ", "_");
};

const normalizePaymentMethod = (
  value
) => {
  const normalizedValue =
    normalizeString(
      value,
      PAYMENT_METHODS.COD
    ).toUpperCase();

  if (
    Object.values(
      PAYMENT_METHODS
    ).includes(normalizedValue)
  ) {
    return normalizedValue;
  }

  return PAYMENT_METHODS.COD;
};

const isValidObjectId = (value) => {
  return mongoose.Types.ObjectId.isValid(
    value
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

// =====================================================
// PAGINATION
// =====================================================

const getPagination = (req) => {
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
  body
) => {
  const longitude = normalizeNumber(
    body.longitude ??
      body.lng ??
      body.locationPoint
        ?.coordinates?.[0],
    0
  );

  const latitude = normalizeNumber(
    body.latitude ??
      body.lat ??
      body.locationPoint
        ?.coordinates?.[1],
    0
  );

  const validLongitude =
    longitude >= -180 &&
    longitude <= 180;

  const validLatitude =
    latitude >= -90 &&
    latitude <= 90;

  if (
    !validLongitude ||
    !validLatitude
  ) {
    return {
      type: "Point",
      coordinates: [0, 0],
    };
  }

  return {
    type: "Point",
    coordinates: [
      longitude,
      latitude,
    ],
  };
};

// =====================================================
// SERVICE PRICE HELPERS
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
// DOCUMENT HELPERS
// =====================================================

const getDocumentId = (value) => {
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

const getDisplayName = (value) => {
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
// POPULATION HELPERS
// =====================================================

const populateBookingQuery = (query) => {
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
    Booking.findById(bookingId)
  );
};

// =====================================================
// SERIALIZATION
// =====================================================

const serializeBooking = (booking) => {
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

  const customer =
    bookingObject.customer ||
    bookingObject.user;

  const provider =
    bookingObject.provider;

  const service =
    bookingObject.service;

  const totalPrice =
    normalizePositiveNumber(
      bookingObject.totalPrice,
      bookingObject.totalAmount || 0
    );

  const totalAmount =
    normalizePositiveNumber(
      bookingObject.totalAmount,
      totalPrice
    );

  const bookingStatus =
    bookingObject.status ||
    bookingObject.bookingStatus ||
    BOOKING_STATUSES.PENDING;

  return {
    ...bookingObject,

    id: getDocumentId(
      bookingObject
    ),

    customer,

    customerId: getDocumentId(
      customer
    ),

    customerName: getDisplayName(
      customer
    ),

    providerId: getDocumentId(
      provider
    ),

    providerName:
      getDisplayName(provider) ||
      service?.providerName ||
      service?.businessName ||
      "",

    serviceId: getDocumentId(
      service
    ),

    serviceName:
      service?.name ||
      service?.title ||
      bookingObject.serviceName ||
      "",

    bookingNumber:
      bookingObject.bookingNumber ||
      "",

    bookingDate:
      bookingObject.bookingDate ||
      bookingObject.date,

    date:
      bookingObject.date ||
      bookingObject.bookingDate,

    status:
      bookingStatus,

    bookingStatus,

    amount:
      normalizePositiveNumber(
        bookingObject.amount,
        totalAmount
      ),

    gst:
      normalizePositiveNumber(
        bookingObject.gst,
        bookingObject.taxAmount || 0
      ),

    serviceFee:
      normalizePositiveNumber(
        bookingObject.serviceFee,
        bookingObject.platformFee || 0
      ),

    discount:
      normalizePositiveNumber(
        bookingObject.discount,
        bookingObject.discountAmount || 0
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
  } = {}
) => {
  const data =
    serializeBooking(booking);

  return res.status(statusCode).json({
    success: true,
    message,
    booking: data,
    data,
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
  const data = bookings.map(
    serializeBooking
  );

  return res.status(200).json({
    success: true,
    message,
    bookings: data,
    data,
    count: data.length,
    ...extra,
    ...(pagination
      ? { pagination }
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
    ).map((item) => item.message);

    return res.status(400).json({
      success: false,
      message:
        errors[0] ||
        "Booking validation failed",
      errors,
    });
  }

  if (
    error?.name === "CastError"
  ) {
    return res.status(400).json({
      success: false,
      message:
        "Invalid booking identifier",
    });
  }

  if (
    error?.code === 11000
  ) {
    return res.status(409).json({
      success: false,
      message:
        "A duplicate booking record was detected",
    });
  }

  return res.status(500).json({
    success: false,
    message:
      error?.message ||
      "Internal server error",
  });
};

// =====================================================
// SOCKET HELPERS
// =====================================================

const emitBookingEvent = (
  eventName,
  booking
) => {
  const socket = global.io;

  if (!socket || !booking) {
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

  socket.emit(
    eventName,
    data
  );

  socket.emit(
    "bookingUpdate",
    data
  );

  socket.emit(
    "refreshBookings",
    {
      bookingId,
      providerId,
      customerId,
      status: data.status,
    }
  );

  socket.emit(
    "refreshProviderDashboard",
    {
      providerId,
      bookingId,
    }
  );

  socket.emit(
    "refreshCustomerBookings",
    {
      customerId,
      bookingId,
    }
  );

  socket
    .to("admin")
    .emit(
      "refreshAdminBookings",
      {
        bookingId,
        providerId,
        customerId,
      }
    );

  if (providerId) {
    socket
      .to(`provider:${providerId}`)
      .emit(
        eventName,
        data
      );

    socket
      .to(`provider:${providerId}`)
      .emit(
        "bookingNotification",
        {
          title: "New Booking",
          message:
            `Booking ${data.bookingNumber || bookingId}`,
          booking: data,
        }
      );
  }

  if (customerId) {
    socket
      .to(`user:${customerId}`)
      .emit(
        "bookingUpdate",
        data
      );
  }

  if (data.chatRoomId) {
    socket
      .to(data.chatRoomId)
      .emit(
        "bookingUpdate",
        data
      );
  }

  if (bookingId) {
    socket
      .to(bookingId)
      .emit(
        "bookingUpdate",
        data
      );
  }
};

// =====================================================
// DATABASE NOTIFICATION
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
      !isValidObjectId(recipientId)
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
          bookingId || undefined,
        bookingId:
          bookingId || undefined,
        referenceId:
          bookingId || undefined,
        referenceType:
          "booking",
        isRead: false,
        read: false,
      };

      const schemaPaths =
        Notification.schema?.paths || {};

      const supportedData = {};

      for (
        const [key, value] of
        Object.entries(candidateData)
      ) {
        if (
          schemaPaths[key] &&
          value !== undefined &&
          value !== null &&
          value !== ""
        ) {
          supportedData[key] = value;
        }
      }

      if (
        Object.keys(
          supportedData
        ).length === 0
      ) {
        console.warn(
          "Notification model has no compatible fields."
        );

        return null;
      }

      const notification =
        await Notification.create(
          supportedData
        );

      if (global.io) {
        global.io
          .to(`provider:${recipientId}`)
          .emit(
            "newNotification",
            notification
          );

        global.io
          .to(`user:${recipientId}`)
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
// PUSH NOTIFICATION
// =====================================================

const sendPushNotification =
  async ({
    receiver,
    title,
    message,
  }) => {
    try {
      if (receiver?.fcmToken) {
        await sendNotification(
          receiver.fcmToken,
          title,
          message
        );

        return true;
      }

      return false;
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
// POST /api/bookings
// CUSTOMER
// =====================================================

export const createBooking = async (
  req,
  res
) => {
  try {
    const customerId =
      getAuthenticatedUserId(req);

    if (
      !customerId ||
      !isValidObjectId(customerId)
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

    const {
      serviceId,
      service,
      bookingDate,
      date,
      bookingTime,
      time,
      notes,
      specialInstructions,
      address,
      location,
      hoursBooked = 1,
      paymentMethod =
        PAYMENT_METHODS.COD,
      platformFee = 0,
      taxAmount = 0,
      gst = 0,
      serviceFee = 0,
      discountAmount = 0,
      discount = 0,
      couponCode = "",
    } = req.body;

    const resolvedServiceId =
      normalizeString(
        serviceId || service
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
      bookingDate || date;

    if (!rawBookingDate) {
      return sendValidationError(
        res,
        "Booking date is required",
        ["bookingDate"]
      );
    }

    const parsedBookingDate =
      new Date(rawBookingDate);

    if (
      Number.isNaN(
        parsedBookingDate.getTime()
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
        address || location
      );

    if (!resolvedAddress) {
      return sendValidationError(
        res,
        "Service address is required",
        ["address"]
      );
    }

    /*
     * The Provider ID is intentionally obtained from the
     * Service document. The Customer request cannot choose
     * or override the Provider ID.
     */
    const serviceDocument =
      await Service.findOne({
        _id: resolvedServiceId,
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
      !isValidObjectId(providerId)
    ) {
      return res.status(400).json({
        success: false,
        message:
          "This service is not linked to a valid provider",
      });
    }

    if (providerId === customerId) {
      return res.status(400).json({
        success: false,
        message:
          "You cannot book your own service",
      });
    }

    const normalizedHours =
      Math.max(
        1,
        Math.floor(
          normalizeNumber(
            hoursBooked,
            1
          )
        )
      );

    const {
      unitPrice,
      subtotal,
    } = getServicePricing(
      serviceDocument,
      normalizedHours
    );

    if (subtotal <= 0) {
      return res.status(400).json({
        success: false,
        message:
          "The selected service does not have a valid price",
      });
    }

    const normalizedPlatformFee =
      normalizePositiveNumber(
        platformFee ||
          serviceFee,
        0
      );

    const normalizedTax =
      normalizePositiveNumber(
        taxAmount || gst,
        0
      );

    const normalizedDiscount =
      normalizePositiveNumber(
        discountAmount ||
          discount,
        0
      );

    const totalAmount =
      Math.max(
        0,
        subtotal +
          normalizedPlatformFee +
          normalizedTax -
          normalizedDiscount
      );

    const booking =
      new Booking({
        user: customerId,
        customer: customerId,

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
            bookingTime || time
          ),

        duration:
          normalizeString(
            req.body.duration
          ),

        notes:
          normalizeString(notes),

        specialInstructions:
          normalizeString(
            specialInstructions
          ),

        address:
          resolvedAddress,

        location:
          normalizeString(
            location,
            resolvedAddress
          ),

        locationPoint:
          normalizeLocationPoint(
            req.body
          ),

        hoursBooked:
          normalizedHours,

        pricePerHour:
          unitPrice,

        basePrice:
          normalizePositiveNumber(
            serviceDocument.basePrice,
            unitPrice
          ),

        subtotal,

        platformFee:
          normalizedPlatformFee,

        taxAmount:
          normalizedTax,

        discountAmount:
          normalizedDiscount,

        totalPrice:
          totalAmount,

        totalAmount,

        currency:
          normalizeString(
            serviceDocument.currency,
            "INR"
          ).toUpperCase(),

        couponCode:
          normalizeString(
            couponCode
          ).toUpperCase(),

        paymentMethod:
          normalizePaymentMethod(
            paymentMethod
          ),

        paymentStatus:
          PAYMENT_STATUSES.PENDING,

        status:
          BOOKING_STATUSES.PENDING,

        chatEnabled: true,
      });

    /*
     * Mongoose assigns _id when the model instance is created,
     * so the same database booking ID is used for chat.
     */
    booking.chatRoomId =
      booking._id.toString();

    if (!booking.bookingNumber) {
      booking.bookingNumber =
        `EB-${booking._id
          .toString()
          .slice(-8)
          .toUpperCase()}`;
    }

    await booking.save();

    const populatedBooking =
      await getPopulatedBooking(
        booking._id
      );

    const notificationMessage =
      `New booking ${
        booking.bookingNumber
      } for ${serviceDocument.name}.`;

    await createDatabaseNotification({
      recipient: providerId,
      sender: customerId,
      title: "New Booking",
      message:
        notificationMessage,
      booking:
        populatedBooking ||
        booking,
      type: "booking",
    });

    await sendPushNotification({
      receiver:
        serviceDocument.provider,
      title: "New Booking",
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
// GET /api/bookings
// GET /api/bookings/my
// GET /api/bookings/my-bookings
// GET /api/bookings/history
// =====================================================

export const getMyBookings = async (
  req,
  res
) => {
  try {
    const customerId =
      getAuthenticatedUserId(req);

    if (
      !customerId ||
      !isValidObjectId(customerId)
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
          user: customerId,
        },
        {
          customer: customerId,
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

    const total =
      await Booking.countDocuments(
        filter
      );

    const bookings =
      await populateBookingQuery(
        Booking.find(filter)
          .sort({
            createdAt: -1,
          })
          .skip(skip)
          .limit(limit)
      );

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
            page * limit < total,

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

// Existing controller compatibility.
export const getBookings =
  getMyBookings;

// =====================================================
// GET PROVIDER BOOKINGS
// GET /api/bookings/provider
// GET /api/provider/bookings
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
        getAuthenticatedUserId(req);

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
        !isValidObjectId(providerId)
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
        provider: providerId,

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

      const total =
        await Booking.countDocuments(
          filter
        );

      const bookings =
        await populateBookingQuery(
          Booking.find(filter)
            .sort({
              createdAt: -1,
            })
            .skip(skip)
            .limit(limit)
        );

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

      const authenticatedId =
        getAuthenticatedUserId(req);

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

      const bookings =
        await populateBookingQuery(
          Booking.find({
            provider: providerId,

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
            "Today's provider bookings fetched successfully",
        }
      );
    } catch (error) {
      return sendControllerError(
        res,
        "Get Provider Today Bookings Error",
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

      const authenticatedId =
        getAuthenticatedUserId(req);

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

      const bookings =
        await populateBookingQuery(
          Booking.find({
            provider: providerId,

            bookingDate: {
              $gte: new Date(),
            },

            status: {
              $in: [
                BOOKING_STATUSES.PENDING,
                BOOKING_STATUSES.ACCEPTED,
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
            "Upcoming provider bookings fetched successfully",
        }
      );
    } catch (error) {
      return sendControllerError(
        res,
        "Get Provider Upcoming Bookings Error",
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
        getAuthenticatedUserId(req);

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
        !isValidObjectId(providerId)
      ) {
        return res.status(400).json({
          success: false,
          message:
            "Invalid provider identifier",
        });
      }

      const providerObjectId =
        new mongoose.Types.ObjectId(
          providerId
        );

      const statusResults =
        await Booking.aggregate([
          {
            $match: {
              provider:
                providerObjectId,

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
          provider: providerId,

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
        todayBookings,

        pendingBookings:
          counts.pending,

        acceptedBookings:
          counts.accepted,

        rejectedBookings:
          counts.rejected,

        inProgressBookings:
          counts.in_progress,

        completedBookings:
          counts.completed,

        cancelledBookings:
          counts.cancelled,

        totalRevenue,
      };

      return res.status(200).json({
        success: true,
        message:
          "Booking analytics fetched successfully",
        ...analytics,
        analytics,
        data: analytics,
      });
    } catch (error) {
      return sendControllerError(
        res,
        "Get Provider Booking Analytics Error",
        error
      );
    }
  };

// =====================================================
// GET BOOKING BY ID
// =====================================================

export const getBookingById = async (
  req,
  res
) => {
  try {
    const bookingId =
      req.params.id;

    if (
      !isValidObjectId(bookingId)
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
      getAuthenticatedUserId(req);

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
      "Get Booking By ID Error",
      error
    );
  }
};

// =====================================================
// UPDATE BOOKING STATUS
// PROVIDER OR ADMIN
// =====================================================

export const updateBookingStatus =
  async (req, res) => {
    try {
      const bookingId =
        req.params.id;

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
        getAuthenticatedUserId(req);

      if (
        !isAdmin(req) &&
        booking.provider
          ?.toString() !==
          currentUserId
      ) {
        return res.status(403).json({
          success: false,
          message:
            "This booking does not belong to the logged-in provider",
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

      booking.status =
        requestedStatus;

      if (
        requestedStatus ===
        BOOKING_STATUSES.REJECTED
      ) {
        booking.rejectionReason =
          normalizeString(
            req.body.reason ||
              req.body.rejectionReason
          );
      }

      if (
        requestedStatus ===
        BOOKING_STATUSES.CANCELLED
      ) {
        booking.cancellationReason =
          normalizeString(
            req.body.reason ||
              req.body.cancellationReason
          );
      }

      if (
        requestedStatus ===
          BOOKING_STATUSES.COMPLETED &&
        booking.paymentMethod ===
          PAYMENT_METHODS.COD
      ) {
        booking.paymentStatus =
          PAYMENT_STATUSES.PAID;

        booking.paidAt =
          new Date();
      }

      booking.statusHistory.push({
        status:
          requestedStatus,

        changedBy:
          currentUserId,

        note:
          normalizeString(
            req.body.note ||
              req.body.reason
          ),

        changedAt:
          new Date(),
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
          getDocumentId(customer),

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

      emitBookingEvent(
        "bookingUpdated",
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
// CUSTOMER OR ADMIN
// =====================================================

export const cancelBooking = async (
  req,
  res
) => {
  try {
    const bookingId =
      req.params.id;

    if (
      !isValidObjectId(bookingId)
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
      getAuthenticatedUserId(req);

    const bookingCustomerId =
      booking.customer?.toString() ||
      booking.user?.toString();

    if (
      bookingCustomerId !==
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

    booking.status =
      BOOKING_STATUSES.CANCELLED;

    booking.cancelledAt =
      new Date();

    booking.cancellationReason =
      normalizeString(
        req.body.reason ||
          req.body.cancellationReason
      );

    booking.statusHistory.push({
      status:
        BOOKING_STATUSES.CANCELLED,

      changedBy:
        currentUserId,

      note:
        booking.cancellationReason ||
        "Cancelled by customer",

      changedAt:
        new Date(),
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
        getDocumentId(provider),

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
// RATE BOOKING
// CUSTOMER
// =====================================================

export const rateBooking = async (
  req,
  res
) => {
  try {
    const bookingId =
      req.params.id;

    if (
      !isValidObjectId(bookingId)
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
      getAuthenticatedUserId(req);

    const bookingCustomerId =
      booking.customer?.toString() ||
      booking.user?.toString();

    if (
      bookingCustomerId !==
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
      booking.rating !== undefined
    ) {
      return res.status(409).json({
        success: false,
        message:
          "This booking has already been rated",
      });
    }

    booking.rating = rating;
    booking.review = review;
    booking.reviewedAt =
      new Date();

    await booking.save();

    booking =
      await getPopulatedBooking(
        booking._id
      );

    const provider =
      booking.provider;

    await createDatabaseNotification({
      recipient:
        getDocumentId(provider),

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