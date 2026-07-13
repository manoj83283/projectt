class ApiConfig {
  ApiConfig._();

  // ==========================================
  // BASE URL
  // ==========================================

  // Android Emulator
  static const String baseUrl =
      'http://10.0.2.2:5000/api';

  // Physical Device Example
  // static const String baseUrl =
  //     'http://192.168.1.10:5000/api';

  // Production Example
  // static const String baseUrl =
  //     'https://api.eventease.com/api';

  // ==========================================
  // AUTH
  // ==========================================

  static const String signup =
      '$baseUrl/auth/signup';

  static const String signin =
      '$baseUrl/auth/signin';

  static const String profile =
      '$baseUrl/auth/profile';

  static const String googleLogin =
      '$baseUrl/auth/google';

  // ==========================================
  // USERS
  // ==========================================

  static const String users =
      '$baseUrl/users';

  // ==========================================
  // CATEGORIES
  // ==========================================

  static const String categories =
      '$baseUrl/categories';

  static String categoryById(
    String id,
  ) =>
      '$baseUrl/categories/$id';

  static String categoryBySlug(
    String slug,
  ) =>
      '$baseUrl/categories/slug/$slug';

  static String categoriesByType(
    String type,
  ) =>
      '$baseUrl/categories/type/$type';

  // ==========================================
  // SERVICES
  // ==========================================

  static const String services =
      '$baseUrl/services';

  static String serviceById(
    String serviceId,
  ) =>
      '$baseUrl/services/$serviceId';

  static String providerServices(
    String providerId,
  ) =>
      '$baseUrl/services/provider/$providerId';

  // ==========================================
  // BOOKINGS
  // ==========================================

  static const String bookings =
      '$baseUrl/bookings';

  static const String myBookings =
      '$baseUrl/bookings/my';

  static String bookingById(
    String bookingId,
  ) =>
      '$baseUrl/bookings/$bookingId';

  // ==========================================
  // ORDERS
  // ==========================================

  static const String orders =
      '$baseUrl/orders';

  static const String myOrders =
      '$baseUrl/orders/my';

  static String orderById(
    String orderId,
  ) =>
      '$baseUrl/orders/$orderId';

  // ==========================================
  // CART
  // ==========================================

  static const String cart =
      '$baseUrl/cart';

  static const String addToCart =
      '$baseUrl/cart/add';

  static const String cartSummary =
      '$baseUrl/cart/summary';

  static String cartItem(
    String itemId,
  ) =>
      '$baseUrl/cart/item/$itemId';

  static const String clearCart =
      '$baseUrl/cart/clear';

  // ==========================================
  // REVIEWS
  // ==========================================

  static const String reviews =
      '$baseUrl/reviews';

  static String reviewById(
    String id,
  ) =>
      '$baseUrl/reviews/$id';

  // ==========================================
  // ADDRESS
  // ==========================================

  static const String address =
      '$baseUrl/address';

  static String addressById(
    String id,
  ) =>
      '$baseUrl/address/$id';

  // ==========================================
  // CHAT
  // ==========================================

  static const String chat =
      '$baseUrl/chat';

  static String roomMessages(
    String roomId,
  ) =>
      '$baseUrl/chat/$roomId';

  // ==========================================
  // NOTIFICATIONS
  // ==========================================

  static const String notifications =
      '$baseUrl/notifications';

  // ==========================================
  // ADMIN
  // ==========================================

  static const String admin =
      '$baseUrl/admin';

  // ==========================================
  // SOCKET URL
  // ==========================================

  static const String socketUrl =
      'http://10.0.2.2:5000';

  // Physical Device Example
  // static const String socketUrl =
  //     'http://192.168.1.10:5000';
}