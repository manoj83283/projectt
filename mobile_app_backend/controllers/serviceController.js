import mongoose from "mongoose";

import Service from "../models/service.js";

// ===========================================================
// CONSTANTS
// ===========================================================

const DEFAULT_LIMIT = 20;
const MAX_LIMIT = 100;
const DEFAULT_RADIUS_METERS = 30000;
const MAX_RADIUS_METERS = 100000;

// ===========================================================
// HELPERS
// ===========================================================

const getAuthenticatedUserId = (req) => {
  return req.user?._id?.toString() || req.user?.id?.toString() || "";
};

const isProvider = (req) => {
  return req.user?.role === "provider";
};

const normalizeString = (value, fallback = "") => {
  if (value === null || value === undefined) {
    return fallback;
  }

  return value.toString().trim();
};

const normalizeLowercaseString = (value, fallback = "") => {
  return normalizeString(value, fallback).toLowerCase();
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

const normalizeBoolean = (
  value,
  fallback = false
) => {
  if (
    value === null ||
    value === undefined ||
    value === ""
  ) {
    return fallback;
  }

  if (typeof value === "boolean") {
    return value;
  }

  const normalizedValue = value
    .toString()
    .trim()
    .toLowerCase();

  if (
    normalizedValue === "true" ||
    normalizedValue === "1"
  ) {
    return true;
  }

  if (
    normalizedValue === "false" ||
    normalizedValue === "0"
  ) {
    return false;
  }

  return fallback;
};

const normalizeStringArray = (
  value,
  {
    lowercase = false,
  } = {}
) => {
  let values = [];

  if (Array.isArray(value)) {
    values = value;
  } else if (
    typeof value === "string" &&
    value.trim().isNotEmpty !== true
  ) {
    /*
     * Accept either a comma-separated string or a normal string.
     */
    values = value.includes(",")
      ? value.split(",")
      : [value];
  }

  return Array.from(
    new Set(
      values
        .map((item) => {
          const normalizedValue = normalizeString(item);

          return lowercase
            ? normalizedValue.toLowerCase()
            : normalizedValue;
        })
        .filter(Boolean)
    )
  );
};

const hasValidCoordinates = (
  longitude,
  latitude
) => {
  return (
    Number.isFinite(longitude) &&
    Number.isFinite(latitude) &&
    longitude >= -180 &&
    longitude <= 180 &&
    latitude >= -90 &&
    latitude <= 90
  );
};

const normalizeCoordinates = ({
  longitude,
  latitude,
  locationPoint,
  locationGeo,
  geoLocation,
}) => {
  const directLongitude = Number(longitude);
  const directLatitude = Number(latitude);

  if (
    hasValidCoordinates(
      directLongitude,
      directLatitude
    )
  ) {
    return {
      type: "Point",
      coordinates: [
        directLongitude,
        directLatitude,
      ],
    };
  }

  const possibleLocations = [
    locationPoint,
    locationGeo,
    geoLocation,
  ];

  for (const possibleLocation of possibleLocations) {
    const coordinates =
      possibleLocation?.coordinates;

    if (
      Array.isArray(coordinates) &&
      coordinates.length === 2
    ) {
      const parsedLongitude = Number(
        coordinates[0]
      );

      const parsedLatitude = Number(
        coordinates[1]
      );

      if (
        hasValidCoordinates(
          parsedLongitude,
          parsedLatitude
        )
      ) {
        return {
          type: "Point",
          coordinates: [
            parsedLongitude,
            parsedLatitude,
          ],
        };
      }
    }
  }

  return {
    type: "Point",
    coordinates: [0, 0],
  };
};

const hasRealCoordinates = (locationPoint) => {
  const coordinates =
    locationPoint?.coordinates;

  if (
    !Array.isArray(coordinates) ||
    coordinates.length !== 2
  ) {
    return false;
  }

  const longitude = Number(coordinates[0]);
  const latitude = Number(coordinates[1]);

  return (
    hasValidCoordinates(
      longitude,
      latitude
    ) &&
    !(longitude === 0 && latitude === 0)
  );
};

const getDistance = (
  latitude1,
  longitude1,
  latitude2,
  longitude2
) => {
  const earthRadiusKm = 6371;

  const degreesToRadians = (degrees) => {
    return degrees * (Math.PI / 180);
  };

  const latitudeDifference =
    degreesToRadians(
      latitude2 - latitude1
    );

  const longitudeDifference =
    degreesToRadians(
      longitude2 - longitude1
    );

  const firstLatitudeRadians =
    degreesToRadians(latitude1);

  const secondLatitudeRadians =
    degreesToRadians(latitude2);

  const a =
    Math.sin(latitudeDifference / 2) ** 2 +
    Math.cos(firstLatitudeRadians) *
      Math.cos(secondLatitudeRadians) *
      Math.sin(longitudeDifference / 2) ** 2;

  return (
    earthRadiusKm *
    2 *
    Math.atan2(
      Math.sqrt(a),
      Math.sqrt(1 - a)
    )
  );
};

const buildProviderName = (
  user,
  suppliedProviderName = ""
) => {
  const normalizedSuppliedName =
    normalizeString(suppliedProviderName);

  if (normalizedSuppliedName) {
    return normalizedSuppliedName;
  }

  const businessName = normalizeString(
    user?.businessName ||
      user?.shopName
  );

  if (businessName) {
    return businessName;
  }

  const fullName = [
    normalizeString(user?.firstName),
    normalizeString(user?.lastName),
  ]
    .filter(Boolean)
    .join(" ")
    .trim();

  return fullName || "Provider";
};

const buildPublicServiceFilter = () => {
  return {
    isActive: true,
    isAvailable: true,
    approvalStatus: "approved",
    deletedAt: null,
  };
};

const getPagination = (req) => {
  const page = Math.max(
    1,
    Math.floor(
      normalizeNumber(req.query.page, 1)
    )
  );

  const requestedLimit = Math.max(
    1,
    Math.floor(
      normalizeNumber(
        req.query.limit,
        DEFAULT_LIMIT
      )
    )
  );

  const limit = Math.min(
    requestedLimit,
    MAX_LIMIT
  );

  return {
    page,
    limit,
    skip: (page - 1) * limit,
  };
};

const populateProvider = (query) => {
  return query.populate(
    "provider",
    [
      "firstName",
      "lastName",
      "name",
      "email",
      "phone",
      "profileImage",
      "shopName",
      "businessName",
      "rating",
      "totalReviews",
      "isOnline",
    ].join(" ")
  );
};

const serializeService = (
  service,
  extra = {}
) => {
  const serviceObject =
    typeof service?.toObject === "function"
      ? service.toObject({
          virtuals: true,
        })
      : {
          ...service,
        };

  const provider = serviceObject.provider;

  const providerDisplayName =
    serviceObject.providerName ||
    provider?.businessName ||
    provider?.shopName ||
    [
      provider?.firstName,
      provider?.lastName,
    ]
      .filter(Boolean)
      .join(" ")
      .trim() ||
    provider?.name ||
    "Provider";

  const displayPrice =
    normalizeNumber(
      serviceObject.displayPrice,
      0
    ) ||
    normalizeNumber(
      serviceObject.price,
      0
    ) ||
    normalizeNumber(
      serviceObject.basePrice,
      0
    ) ||
    normalizeNumber(
      serviceObject.pricePerDay,
      0
    ) ||
    normalizeNumber(
      serviceObject.pricePerHour,
      0
    );

  return {
    ...serviceObject,
    id:
      serviceObject._id?.toString() ||
      serviceObject.id,
    providerName: providerDisplayName,
    displayPrice,
    price:
      normalizeNumber(
        serviceObject.price,
        displayPrice
      ) || displayPrice,
    ...extra,
  };
};

const emitServicesRefresh = (
  eventName,
  service = null
) => {
  if (!global.io) {
    return;
  }

  global.io.emit("refreshServices");

  global.io.emit(eventName, {
    serviceId:
      service?._id?.toString() || null,
    service: service
      ? serializeService(service)
      : null,
  });
};

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

const sendServerError = (
  res,
  label,
  error
) => {
  console.error(
    `❌ ${label}:`,
    error
  );

  if (error?.name === "ValidationError") {
    const validationErrors = Object.values(
      error.errors || {}
    ).map((item) => item.message);

    return res.status(400).json({
      success: false,
      message:
        validationErrors[0] ||
        "Service validation failed",
      errors: validationErrors,
    });
  }

  if (error?.name === "CastError") {
    return res.status(400).json({
      success: false,
      message: "Invalid service identifier",
    });
  }

  return res.status(500).json({
    success: false,
    message: "Server error",
    error: error?.message || "Unknown error",
  });
};

// ===========================================================
// CREATE SERVICE
// POST /api/services
// Provider authentication required
// ===========================================================

export const createService = async (
  req,
  res
) => {
  try {
    if (!isProvider(req)) {
      return res.status(403).json({
        success: false,
        message:
          "Only service providers can add services",
      });
    }

    const providerId =
      getAuthenticatedUserId(req);

    if (
      !providerId ||
      !mongoose.Types.ObjectId.isValid(
        providerId
      )
    ) {
      return res.status(401).json({
        success: false,
        message:
          "Authenticated provider could not be identified",
      });
    }

    const {
      name,
      providerName,
      businessName,
      category,
      categories,
      description,
      serviceType,
      price,
      basePrice,
      pricePerDay,
      pricePerHour,
      currency,
      location,
      image,
      imageUrl,
      images,
      tags,
      features,
      latitude,
      longitude,
      locationPoint,
      locationGeo,
      geoLocation,
      isAvailable,
      isActive,
      isPopular,
      isRecommended,
      isFeatured,
    } = req.body;

    const normalizedName =
      normalizeString(name);

    const normalizedLocation =
      normalizeString(location);

    const normalizedCategories =
      normalizeStringArray(
        categories,
        {
          lowercase: true,
        }
      );

    const normalizedCategory =
      normalizeLowercaseString(
        category ||
          normalizedCategories[0]
      );

    if (!normalizedName) {
      return sendValidationError(
        res,
        "Service name is required",
        ["name"]
      );
    }

    if (!normalizedCategory) {
      return sendValidationError(
        res,
        "Service category is required",
        ["category"]
      );
    }

    if (!normalizedLocation) {
      return sendValidationError(
        res,
        "Service location is required",
        ["location"]
      );
    }

    const normalizedPrice =
      normalizeNumber(price, 0);

    const normalizedBasePrice =
      normalizeNumber(
        basePrice,
        normalizedPrice
      );

    const normalizedPricePerDay =
      normalizeNumber(pricePerDay, 0);

    const normalizedPricePerHour =
      normalizeNumber(pricePerHour, 0);

    const primaryPrice =
      normalizedPrice ||
      normalizedBasePrice ||
      normalizedPricePerDay ||
      normalizedPricePerHour;

    if (primaryPrice < 0) {
      return sendValidationError(
        res,
        "Service price cannot be negative",
        [
          "price",
          "basePrice",
          "pricePerDay",
          "pricePerHour",
        ]
      );
    }

    const resolvedImage =
      normalizeString(
        image || imageUrl
      );

    const normalizedImages =
      normalizeStringArray(images);

    if (
      resolvedImage &&
      !normalizedImages.includes(
        resolvedImage
      )
    ) {
      normalizedImages.unshift(
        resolvedImage
      );
    }

    const resolvedLocationPoint =
      normalizeCoordinates({
        longitude,
        latitude,
        locationPoint,
        locationGeo,
        geoLocation,
      });

    const service = await Service.create({
      name: normalizedName,

      provider: providerId,

      providerName: buildProviderName(
        req.user,
        providerName
      ),

      businessName:
        normalizeString(
          businessName ||
            req.user?.businessName ||
            req.user?.shopName
        ),

      category: normalizedCategory,

      categories: Array.from(
        new Set([
          normalizedCategory,
          ...normalizedCategories,
        ])
      ),

      description:
        normalizeString(description),

      serviceType:
        normalizeLowercaseString(
          serviceType,
          "fixed"
        ),

      price: primaryPrice,

      basePrice:
        normalizedBasePrice ||
        primaryPrice,

      pricePerDay:
        normalizedPricePerDay,

      pricePerHour:
        normalizedPricePerHour,

      currency:
        normalizeString(
          currency,
          "INR"
        ).toUpperCase(),

      location: normalizedLocation,

      locationPoint:
        resolvedLocationPoint,

      image: resolvedImage,

      imageUrl: resolvedImage,

      images: normalizedImages,

      tags: normalizeStringArray(
        tags,
        {
          lowercase: true,
        }
      ),

      features:
        normalizeStringArray(features),

      isAvailable:
        normalizeBoolean(
          isAvailable,
          true
        ),

      isActive:
        normalizeBoolean(
          isActive,
          true
        ),

      approvalStatus: "approved",

      approvedAt: new Date(),

      isPopular:
        normalizeBoolean(
          isPopular,
          false
        ),

      isRecommended:
        normalizeBoolean(
          isRecommended,
          false
        ),

      isFeatured:
        normalizeBoolean(
          isFeatured,
          false
        ),
    });

    const populatedService =
      await populateProvider(
        Service.findById(service._id)
      );

    emitServicesRefresh(
      "serviceCreated",
      populatedService
    );

    console.log(
      "✅ Service Created:",
      populatedService.name,
      populatedService._id.toString()
    );

    return res.status(201).json({
      success: true,
      message:
        "Service created successfully",
      service: serializeService(
        populatedService
      ),
      data: serializeService(
        populatedService
      ),
    });
  } catch (error) {
    return sendServerError(
      res,
      "Create Service Error",
      error
    );
  }
};

// ===========================================================
// GET SERVICES
// GET /api/services
// Customer-visible service list
// ===========================================================

export const getServices = async (
  req,
  res
) => {
  try {
    const {
      category,
      search,
      keyword,
      minPrice,
      maxPrice,
      lat,
      lng,
      sort = "newest",
      featured,
      popular,
      recommended,
    } = req.query;

    const {
      page,
      limit,
      skip,
    } = getPagination(req);

    const filter =
      buildPublicServiceFilter();

    const conditions = [];

    const normalizedCategory =
      normalizeLowercaseString(category);

    if (normalizedCategory) {
      conditions.push({
        $or: [
          {
            category:
              normalizedCategory,
          },
          {
            categories: {
              $in: [
                normalizedCategory,
              ],
            },
          },
        ],
      });
    }

    const normalizedSearch =
      normalizeString(
        search || keyword
      );

    if (normalizedSearch) {
      const escapedSearch =
        normalizedSearch.replace(
          /[.*+?^${}()|[\]\\]/g,
          "\\$&"
        );

      const searchExpression =
        new RegExp(
          escapedSearch,
          "i"
        );

      conditions.push({
        $or: [
          {
            name: searchExpression,
          },
          {
            description:
              searchExpression,
          },
          {
            providerName:
              searchExpression,
          },
          {
            businessName:
              searchExpression,
          },
          {
            serviceType:
              searchExpression,
          },
          {
            location:
              searchExpression,
          },
          {
            tags: searchExpression,
          },
        ],
      });
    }

    const normalizedMinPrice =
      minPrice !== undefined
        ? normalizeNumber(
            minPrice,
            null
          )
        : null;

    const normalizedMaxPrice =
      maxPrice !== undefined
        ? normalizeNumber(
            maxPrice,
            null
          )
        : null;

    if (
      normalizedMinPrice !== null ||
      normalizedMaxPrice !== null
    ) {
      const priceCondition = {};

      if (
        normalizedMinPrice !== null
      ) {
        priceCondition.$gte =
          normalizedMinPrice;
      }

      if (
        normalizedMaxPrice !== null
      ) {
        priceCondition.$lte =
          normalizedMaxPrice;
      }

      conditions.push({
        $or: [
          {
            price: priceCondition,
          },
          {
            basePrice:
              priceCondition,
          },
          {
            pricePerDay:
              priceCondition,
          },
          {
            pricePerHour:
              priceCondition,
          },
        ],
      });
    }

    if (
      featured !== undefined
    ) {
      filter.isFeatured =
        normalizeBoolean(
          featured,
          false
        );
    }

    if (
      popular !== undefined
    ) {
      filter.isPopular =
        normalizeBoolean(
          popular,
          false
        );
    }

    if (
      recommended !== undefined
    ) {
      filter.isRecommended =
        normalizeBoolean(
          recommended,
          false
        );
    }

    if (conditions.length > 0) {
      filter.$and = conditions;
    }

    const latitude =
      normalizeNumber(lat, null);

    const longitude =
      normalizeNumber(lng, null);

    const shouldCalculateDistance =
      latitude !== null &&
      longitude !== null &&
      hasValidCoordinates(
        longitude,
        latitude
      );

    let sortQuery = {
      createdAt: -1,
    };

    switch (sort) {
      case "low_price":
        sortQuery = {
          price: 1,
          createdAt: -1,
        };
        break;

      case "high_price":
        sortQuery = {
          price: -1,
          createdAt: -1,
        };
        break;

      case "rating":
      case "top_rated":
        sortQuery = {
          rating: -1,
          totalReviews: -1,
        };
        break;

      case "oldest":
        sortQuery = {
          createdAt: 1,
        };
        break;

      case "newest":
      default:
        sortQuery = {
          createdAt: -1,
        };
        break;
    }

    const total = await Service.countDocuments(
      filter
    );

    const serviceDocuments =
      await populateProvider(
        Service.find(filter)
          .sort(sortQuery)
          .skip(skip)
          .limit(limit)
      );

    let services =
      serviceDocuments.map(
        (service) => {
          let distance = null;

          if (
            shouldCalculateDistance &&
            hasRealCoordinates(
              service.locationPoint
            )
          ) {
            distance = getDistance(
              latitude,
              longitude,
              Number(
                service
                  .locationPoint
                  .coordinates[1]
              ),
              Number(
                service
                  .locationPoint
                  .coordinates[0]
              )
            );
          }

          return serializeService(
            service,
            {
              distance,
            }
          );
        }
      );

    if (
      sort === "nearest" &&
      shouldCalculateDistance
    ) {
      services.sort(
        (first, second) => {
          const firstDistance =
            first.distance ??
            Number.MAX_SAFE_INTEGER;

          const secondDistance =
            second.distance ??
            Number.MAX_SAFE_INTEGER;

          return (
            firstDistance -
            secondDistance
          );
        }
      );
    }

    console.log(
      `✅ Services fetched: ${services.length}`
    );

    return res.status(200).json({
      success: true,
      message:
        "Services fetched successfully",
      services,
      data: services,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(
          total / limit
        ),
        hasNextPage:
          page * limit < total,
        hasPreviousPage:
          page > 1,
      },
    });
  } catch (error) {
    return sendServerError(
      res,
      "Get Services Error",
      error
    );
  }
};

// ===========================================================
// SEARCH SERVICES
// GET /api/services/search
// ===========================================================

export const searchServices = async (
  req,
  res
) => {
  try {
    const {
      keyword,
      search,
      category,
      lat,
      lng,
      radius =
        DEFAULT_RADIUS_METERS,
    } = req.query;

    const normalizedKeyword =
      normalizeString(
        keyword || search
      );

    const normalizedCategory =
      normalizeLowercaseString(
        category
      );

    const query =
      buildPublicServiceFilter();

    const conditions = [];

    if (normalizedKeyword) {
      const escapedKeyword =
        normalizedKeyword.replace(
          /[.*+?^${}()|[\]\\]/g,
          "\\$&"
        );

      const keywordExpression =
        new RegExp(
          escapedKeyword,
          "i"
        );

      conditions.push({
        $or: [
          {
            name:
              keywordExpression,
          },
          {
            description:
              keywordExpression,
          },
          {
            providerName:
              keywordExpression,
          },
          {
            businessName:
              keywordExpression,
          },
          {
            location:
              keywordExpression,
          },
          {
            tags:
              keywordExpression,
          },
        ],
      });
    }

    if (normalizedCategory) {
      conditions.push({
        $or: [
          {
            category:
              normalizedCategory,
          },
          {
            categories: {
              $in: [
                normalizedCategory,
              ],
            },
          },
        ],
      });
    }

    if (conditions.length > 0) {
      query.$and = conditions;
    }

    const latitude =
      normalizeNumber(lat, null);

    const longitude =
      normalizeNumber(lng, null);

    const radiusMeters =
      Math.min(
        Math.max(
          normalizeNumber(
            radius,
            DEFAULT_RADIUS_METERS
          ),
          1
        ),
        MAX_RADIUS_METERS
      );

    let serviceQuery;

    if (
      latitude !== null &&
      longitude !== null &&
      hasValidCoordinates(
        longitude,
        latitude
      )
    ) {
      serviceQuery = Service.find({
        ...query,
        locationPoint: {
          $near: {
            $geometry: {
              type: "Point",
              coordinates: [
                longitude,
                latitude,
              ],
            },
            $maxDistance:
              radiusMeters,
          },
        },
      }).limit(MAX_LIMIT);
    } else {
      serviceQuery = Service.find(
        query
      )
        .sort({
          createdAt: -1,
        })
        .limit(MAX_LIMIT);
    }

    const serviceDocuments =
      await populateProvider(
        serviceQuery
      );

    const services =
      serviceDocuments.map(
        (service) =>
          serializeService(service)
      );

    console.log(
      `🔍 Search results found: ${services.length}`
    );

    return res.status(200).json({
      success: true,
      message:
        "Service search completed",
      services,
      data: services,
      count: services.length,
    });
  } catch (error) {
    return sendServerError(
      res,
      "Search Services Error",
      error
    );
  }
};

// ===========================================================
// GET SERVICE BY ID
// GET /api/services/:id
// ===========================================================

export const getServiceById = async (
  req,
  res
) => {
  try {
    const { id } = req.params;

    if (
      !mongoose.Types.ObjectId.isValid(
        id
      )
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Invalid service identifier",
      });
    }

    const service =
      await populateProvider(
        Service.findOne({
          _id: id,
          ...buildPublicServiceFilter(),
        })
      );

    if (!service) {
      return res.status(404).json({
        success: false,
        message:
          "Service not found",
      });
    }

    const responseData =
      serializeService(service);

    return res.status(200).json({
      success: true,
      message:
        "Service fetched successfully",
      service: responseData,
      data: responseData,
    });
  } catch (error) {
    return sendServerError(
      res,
      "Get Service By ID Error",
      error
    );
  }
};

// ===========================================================
// GET NEARBY SERVICES
// GET /api/services/nearby
// ===========================================================

export const getNearbyServices = async (
  req,
  res
) => {
  try {
    const {
      lat,
      lng,
      radius =
        DEFAULT_RADIUS_METERS,
      category,
    } = req.query;

    const latitude =
      normalizeNumber(lat, null);

    const longitude =
      normalizeNumber(lng, null);

    if (
      latitude === null ||
      longitude === null ||
      !hasValidCoordinates(
        longitude,
        latitude
      )
    ) {
      return sendValidationError(
        res,
        "Valid lat and lng query parameters are required",
        ["lat", "lng"]
      );
    }

    const radiusMeters =
      Math.min(
        Math.max(
          normalizeNumber(
            radius,
            DEFAULT_RADIUS_METERS
          ),
          1
        ),
        MAX_RADIUS_METERS
      );

    const filter =
      buildPublicServiceFilter();

    const normalizedCategory =
      normalizeLowercaseString(
        category
      );

    if (normalizedCategory) {
      filter.$or = [
        {
          category:
            normalizedCategory,
        },
        {
          categories: {
            $in: [
              normalizedCategory,
            ],
          },
        },
      ];
    }

    const serviceDocuments =
      await populateProvider(
        Service.find({
          ...filter,
          locationPoint: {
            $near: {
              $geometry: {
                type: "Point",
                coordinates: [
                  longitude,
                  latitude,
                ],
              },
              $maxDistance:
                radiusMeters,
            },
          },
        }).limit(MAX_LIMIT)
      );

    const services =
      serviceDocuments.map(
        (service) => {
          const serviceLongitude =
            Number(
              service
                .locationPoint
                .coordinates[0]
            );

          const serviceLatitude =
            Number(
              service
                .locationPoint
                .coordinates[1]
            );

          const distance =
            getDistance(
              latitude,
              longitude,
              serviceLatitude,
              serviceLongitude
            );

          return serializeService(
            service,
            {
              distance,
            }
          );
        }
      );

    return res.status(200).json({
      success: true,
      message:
        "Nearby services fetched successfully",
      services,
      data: services,
      count: services.length,
    });
  } catch (error) {
    return sendServerError(
      res,
      "Nearby Services Error",
      error
    );
  }
};

// ===========================================================
// GET MY SERVICES
// GET /api/services/my-services
// ===========================================================

export const getMyServices = async (
  req,
  res
) => {
  try {
    if (!isProvider(req)) {
      return res.status(403).json({
        success: false,
        message:
          "Only providers can access their services",
      });
    }

    const providerId =
      getAuthenticatedUserId(req);

    const services =
      await Service.find({
        provider: providerId,
        deletedAt: null,
      })
        .sort({
          createdAt: -1,
        })
        .setOptions({
          includeDeleted: false,
        });

    const serializedServices =
      services.map(
        (service) =>
          serializeService(service)
      );

    return res.status(200).json({
      success: true,
      message:
        "Provider services fetched successfully",
      services:
        serializedServices,
      data:
        serializedServices,
      count:
        serializedServices.length,
    });
  } catch (error) {
    return sendServerError(
      res,
      "Get My Services Error",
      error
    );
  }
};

// ===========================================================
// UPDATE SERVICE
// PUT/PATCH /api/services/:id
// ===========================================================

export const updateService = async (
  req,
  res
) => {
  try {
    if (!isProvider(req)) {
      return res.status(403).json({
        success: false,
        message:
          "Only providers can update services",
      });
    }

    const {
      id,
    } = req.params;

    if (
      !mongoose.Types.ObjectId.isValid(
        id
      )
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Invalid service identifier",
      });
    }

    const providerId =
      getAuthenticatedUserId(req);

    const service =
      await Service.findOne({
        _id: id,
        provider:
          providerId,
        deletedAt: null,
      });

    if (!service) {
      return res.status(404).json({
        success: false,
        message:
          "Service not found or access denied",
      });
    }

    const allowedFields = [
      "name",
      "description",
      "serviceType",
      "currency",
      "location",
      "isAvailable",
      "isActive",
    ];

    for (const field of allowedFields) {
      if (
        Object.prototype.hasOwnProperty.call(
          req.body,
          field
        )
      ) {
        service[field] =
          req.body[field];
      }
    }

    if (
      Object.prototype.hasOwnProperty.call(
        req.body,
        "providerName"
      )
    ) {
      service.providerName =
        normalizeString(
          req.body.providerName
        );
    }

    if (
      Object.prototype.hasOwnProperty.call(
        req.body,
        "businessName"
      )
    ) {
      service.businessName =
        normalizeString(
          req.body.businessName
        );
    }

    if (
      req.body.categories !==
      undefined ||
      req.body.category !==
      undefined
    ) {
      const normalizedCategories =
        normalizeStringArray(
          req.body.categories,
          {
            lowercase: true,
          }
        );

      const normalizedCategory =
        normalizeLowercaseString(
          req.body.category ||
            normalizedCategories[0]
        );

      if (!normalizedCategory) {
        return sendValidationError(
          res,
          "Service category cannot be empty",
          ["category"]
        );
      }

      service.category =
        normalizedCategory;

      service.categories =
        Array.from(
          new Set([
            normalizedCategory,
            ...normalizedCategories,
          ])
        );
    }

    const pricingFields = [
      "price",
      "basePrice",
      "pricePerDay",
      "pricePerHour",
    ];

    for (
      const pricingField of
      pricingFields
    ) {
      if (
        Object.prototype.hasOwnProperty.call(
          req.body,
          pricingField
        )
      ) {
        const normalizedValue =
          normalizeNumber(
            req.body[pricingField],
            0
          );

        if (normalizedValue < 0) {
          return sendValidationError(
            res,
            `${pricingField} cannot be negative`,
            [pricingField]
          );
        }

        service[pricingField] =
          normalizedValue;
      }
    }

    if (
      req.body.image !==
        undefined ||
      req.body.imageUrl !==
        undefined
    ) {
      const resolvedImage =
        normalizeString(
          req.body.image ||
            req.body.imageUrl
        );

      service.image =
        resolvedImage;

      service.imageUrl =
        resolvedImage;
    }

    if (
      req.body.images !==
      undefined
    ) {
      service.images =
        normalizeStringArray(
          req.body.images
        );
    }

    if (
      req.body.tags !==
      undefined
    ) {
      service.tags =
        normalizeStringArray(
          req.body.tags,
          {
            lowercase: true,
          }
        );
    }

    if (
      req.body.features !==
      undefined
    ) {
      service.features =
        normalizeStringArray(
          req.body.features
        );
    }

    const hasLocationUpdate =
      req.body.latitude !==
        undefined ||
      req.body.longitude !==
        undefined ||
      req.body.locationPoint !==
        undefined ||
      req.body.locationGeo !==
        undefined ||
      req.body.geoLocation !==
        undefined;

    if (hasLocationUpdate) {
      service.locationPoint =
        normalizeCoordinates({
          longitude:
            req.body.longitude,
          latitude:
            req.body.latitude,
          locationPoint:
            req.body.locationPoint,
          locationGeo:
            req.body.locationGeo,
          geoLocation:
            req.body.geoLocation,
        });
    }

    await service.save();

    const populatedService =
      await populateProvider(
        Service.findById(
          service._id
        )
      );

    emitServicesRefresh(
      "serviceUpdated",
      populatedService
    );

    return res.status(200).json({
      success: true,
      message:
        "Service updated successfully",
      service: serializeService(
        populatedService
      ),
      data: serializeService(
        populatedService
      ),
    });
  } catch (error) {
    return sendServerError(
      res,
      "Update Service Error",
      error
    );
  }
};

// ===========================================================
// UPDATE SERVICE STATUS
// PATCH /api/services/:id/status
// ===========================================================

export const updateServiceStatus = async (
  req,
  res
) => {
  try {
    if (!isProvider(req)) {
      return res.status(403).json({
        success: false,
        message:
          "Only providers can update service status",
      });
    }

    const {
      id,
    } = req.params;

    if (
      !mongoose.Types.ObjectId.isValid(
        id
      )
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Invalid service identifier",
      });
    }

    const hasIsActive =
      Object.prototype.hasOwnProperty.call(
        req.body,
        "isActive"
      );

    const hasIsAvailable =
      Object.prototype.hasOwnProperty.call(
        req.body,
        "isAvailable"
      );

    if (
      !hasIsActive &&
      !hasIsAvailable
    ) {
      return sendValidationError(
        res,
        "isActive or isAvailable is required",
        [
          "isActive",
          "isAvailable",
        ]
      );
    }

    const updates = {};

    if (hasIsActive) {
      updates.isActive =
        normalizeBoolean(
          req.body.isActive,
          true
        );
    }

    if (hasIsAvailable) {
      updates.isAvailable =
        normalizeBoolean(
          req.body.isAvailable,
          true
        );
    }

    const service =
      await Service.findOneAndUpdate(
        {
          _id: id,
          provider:
            getAuthenticatedUserId(
              req
            ),
          deletedAt: null,
        },
        {
          $set: updates,
        },
        {
          new: true,
          runValidators: true,
        }
      );

    if (!service) {
      return res.status(404).json({
        success: false,
        message:
          "Service not found or access denied",
      });
    }

    emitServicesRefresh(
      "serviceStatusUpdated",
      service
    );

    return res.status(200).json({
      success: true,
      message:
        "Service status updated successfully",
      service:
        serializeService(
          service
        ),
      data:
        serializeService(
          service
        ),
    });
  } catch (error) {
    return sendServerError(
      res,
      "Update Service Status Error",
      error
    );
  }
};

// ===========================================================
// DELETE SERVICE
// DELETE /api/services/:id
// Soft delete
// ===========================================================

export const deleteService = async (
  req,
  res
) => {
  try {
    if (!isProvider(req)) {
      return res.status(403).json({
        success: false,
        message:
          "Only providers can delete services",
      });
    }

    const {
      id,
    } = req.params;

    if (
      !mongoose.Types.ObjectId.isValid(
        id
      )
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Invalid service identifier",
      });
    }

    const service =
      await Service.findOneAndUpdate(
        {
          _id: id,
          provider:
            getAuthenticatedUserId(req),
          deletedAt: null,
        },
        {
          $set: {
            deletedAt: new Date(),
            isActive: false,
            isAvailable: false,
          },
        },
        {
          new: true,
        }
      );

    if (!service) {
      return res.status(404).json({
        success: false,
        message:
          "Service not found or access denied",
      });
    }

    emitServicesRefresh(
      "serviceDeleted",
      service
    );

    return res.status(200).json({
      success: true,
      message:
        "Service deleted successfully",
      deletedId:
        service._id.toString(),
    });
  } catch (error) {
    return sendServerError(
      res,
      "Delete Service Error",
      error
    );
  }
};