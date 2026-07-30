import 'package:dio/dio.dart';

import '../core/network/api_service.dart';

class CustomerService {
  CustomerService._();

  static final CustomerService _instance =
      CustomerService._();

  factory CustomerService() => _instance;

  final ApiService _api = ApiService();

  // =====================================================
  // GET CUSTOMERS
  // =====================================================

  Future<Map<String, dynamic>> getCustomers({
    int page = 1,
    int limit = 10,
    String? search,
    String? status,
    String? sortBy,
  }) async {
    try {
      final response = await _api.get(
        '/admin/customers',
        query: {
          'page': page,
          'limit': limit,
          if (search != null && search.isNotEmpty)
            'search': search,
          if (status != null) 'status': status,
          if (sortBy != null) 'sortBy': sortBy,
        },
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // GET CUSTOMER DETAILS
  // =====================================================

  Future<Map<String, dynamic>>
      getCustomerDetails(
    String customerId,
  ) async {
    try {
      final response = await _api.get(
        '/admin/customers/$customerId',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // GET CUSTOMER BOOKINGS
  // =====================================================

  Future<List<dynamic>>
      getCustomerBookings(
    String customerId,
  ) async {
    try {
      final response = await _api.get(
        '/admin/customers/$customerId/bookings',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // GET CUSTOMER ORDERS
  // =====================================================

  Future<List<dynamic>>
      getCustomerOrders(
    String customerId,
  ) async {
    try {
      final response = await _api.get(
        '/admin/customers/$customerId/orders',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // GET CUSTOMER REVIEWS
  // =====================================================

  Future<List<dynamic>>
      getCustomerReviews(
    String customerId,
  ) async {
    try {
      final response = await _api.get(
        '/admin/customers/$customerId/reviews',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // VERIFY CUSTOMER
  // =====================================================

  Future<bool> verifyCustomer(
    String customerId,
  ) async {
    try {
      await _api.patch(
        '/admin/customers/$customerId/verify',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // BLOCK CUSTOMER
  // =====================================================

  Future<bool> blockCustomer({
    required String customerId,
    String? reason,
  }) async {
    try {
      await _api.patch(
        '/admin/customers/$customerId/block',
        data: {
          'reason': reason,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // UNBLOCK CUSTOMER
  // =====================================================

  Future<bool> unblockCustomer(
    String customerId,
  ) async {
    try {
      await _api.patch(
        '/admin/customers/$customerId/unblock',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // DELETE CUSTOMER
  // =====================================================

  Future<bool> deleteCustomer(
    String customerId,
  ) async {
    try {
      await _api.delete(
        '/admin/customers/$customerId',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // CUSTOMER ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getCustomerAnalytics() async {
    try {
      final response = await _api.get(
        '/admin/customers/analytics',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // CUSTOMER ACTIVITY LOGS
  // =====================================================

  Future<List<dynamic>>
      getCustomerActivityLogs(
    String customerId,
  ) async {
    try {
      final response = await _api.get(
        '/admin/customers/$customerId/activity-logs',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // SEND NOTIFICATION
  // =====================================================

  Future<bool> sendNotification({
    required String customerId,
    required String title,
    required String message,
  }) async {
    try {
      await _api.post(
        '/admin/customers/$customerId/notify',
        data: {
          'title': title,
          'message': message,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // EXPORT CUSTOMERS
  // =====================================================

  Future<Response<dynamic>>
      exportCustomers({
    String format = 'excel',
  }) async {
    try {
      return await _api.get(
        '/admin/customers/export',
        query: {
          'format': format,
        },
      );
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // SEARCH CUSTOMERS
  // =====================================================

  Future<List<dynamic>>
      searchCustomers(
    String keyword,
  ) async {
    try {
      final response = await _api.get(
        '/admin/customers/search',
        query: {
          'keyword': keyword,
        },
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // CUSTOMER STATS
  // =====================================================

  Future<Map<String, dynamic>>
      getCustomerStats() async {
    try {
      final response = await _api.get(
        '/admin/customers/stats',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // ERROR HANDLER
  // =====================================================

  String _parseError(
    DioException e,
  ) {
    return e.response?.data?['message']
            ?.toString() ??
        e.message ??
        'Something went wrong';
  }
}