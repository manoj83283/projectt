import 'package:dio/dio.dart';

import '../core/network/api_service.dart';

class OrderService {
  OrderService._();

  static final OrderService _instance =
      OrderService._();

  factory OrderService() => _instance;

  final ApiService _api = ApiService();

  // =====================================================
  // GET ALL ORDERS
  // =====================================================

  Future<Map<String, dynamic>> getOrders({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? customerId,
    String? providerId,
    String? orderType,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await _api.get(
        '/admin/orders',
        query: {
          'page': page,
          'limit': limit,
          'search': ?search,
          'status': ?status,
          'customerId': ?customerId,
          'providerId': ?providerId,
          'orderType': ?orderType,
          'startDate': ?startDate,
          'endDate': ?endDate,
        },
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // GET ORDER DETAILS
  // =====================================================

  Future<Map<String, dynamic>>
      getOrderDetails(
    String orderId,
  ) async {
    try {
      final response = await _api.get(
        '/admin/orders/$orderId',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // UPDATE ORDER STATUS
  // =====================================================

  Future<bool> updateOrderStatus({
    required String orderId,
    required String status,
    String? notes,
  }) async {
    try {
      await _api.patch(
        '/admin/orders/$orderId/status',
        data: {
          'status': status,
          'notes': notes,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // APPROVE ORDER
  // =====================================================

  Future<bool> approveOrder(
    String orderId,
  ) async {
    try {
      await _api.patch(
        '/admin/orders/$orderId/approve',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // REJECT ORDER
  // =====================================================

  Future<bool> rejectOrder({
    required String orderId,
    required String reason,
  }) async {
    try {
      await _api.patch(
        '/admin/orders/$orderId/reject',
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
  // CANCEL ORDER
  // =====================================================

  Future<bool> cancelOrder({
    required String orderId,
    required String reason,
  }) async {
    try {
      await _api.patch(
        '/admin/orders/$orderId/cancel',
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
  // DELETE ORDER
  // =====================================================

  Future<bool> deleteOrder(
    String orderId,
  ) async {
    try {
      await _api.delete(
        '/admin/orders/$orderId',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // ORDER ITEMS
  // =====================================================

  Future<List<dynamic>>
      getOrderItems(
    String orderId,
  ) async {
    try {
      final response = await _api.get(
        '/admin/orders/$orderId/items',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // ORDER TIMELINE
  // =====================================================

  Future<List<dynamic>>
      getOrderTimeline(
    String orderId,
  ) async {
    try {
      final response = await _api.get(
        '/admin/orders/$orderId/timeline',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // ORDER PAYMENTS
  // =====================================================

  Future<List<dynamic>>
      getOrderPayments(
    String orderId,
  ) async {
    try {
      final response = await _api.get(
        '/admin/orders/$orderId/payments',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // REFUND ORDER
  // =====================================================

  Future<bool> refundOrder({
    required String orderId,
    required double amount,
    String? reason,
  }) async {
    try {
      await _api.post(
        '/admin/orders/$orderId/refund',
        data: {
          'amount': amount,
          'reason': reason,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // ASSIGN DELIVERY PARTNER
  // =====================================================

  Future<bool> assignDeliveryPartner({
    required String orderId,
    required String deliveryPartnerId,
  }) async {
    try {
      await _api.patch(
        '/admin/orders/$orderId/assign-delivery',
        data: {
          'deliveryPartnerId':
              deliveryPartnerId,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // ORDER ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getOrderAnalytics() async {
    try {
      final response = await _api.get(
        '/admin/orders/analytics',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // ORDER STATISTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getOrderStatistics() async {
    try {
      final response = await _api.get(
        '/admin/orders/statistics',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // RECENT ORDERS
  // =====================================================

  Future<List<dynamic>>
      getRecentOrders() async {
    try {
      final response = await _api.get(
        '/admin/orders/recent',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // TOP SELLING PRODUCTS
  // =====================================================

  Future<List<dynamic>>
      getTopSellingProducts() async {
    try {
      final response = await _api.get(
        '/admin/orders/top-products',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // SEARCH ORDERS
  // =====================================================

  Future<List<dynamic>>
      searchOrders(
    String keyword,
  ) async {
    try {
      final response = await _api.get(
        '/admin/orders/search',
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
  // EXPORT ORDERS
  // =====================================================

  Future<Response<dynamic>>
      exportOrders({
    String format = 'excel',
    String? startDate,
    String? endDate,
  }) async {
    try {
      return await _api.get(
        '/admin/orders/export',
        query: {
          'format': format,
          'startDate': startDate,
          'endDate': endDate,
        },
      );
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // SEND NOTIFICATION
  // =====================================================

  Future<bool> sendNotification({
    required String orderId,
    required String title,
    required String message,
  }) async {
    try {
      await _api.post(
        '/admin/orders/$orderId/notify',
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
  // BULK DELETE ORDERS
  // =====================================================

  Future<bool> bulkDeleteOrders(
    List<String> orderIds,
  ) async {
    try {
      await _api.post(
        '/admin/orders/bulk-delete',
        data: {
          'orderIds': orderIds,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // BULK STATUS UPDATE
  // =====================================================

  Future<bool> bulkStatusUpdate({
    required List<String> orderIds,
    required String status,
  }) async {
    try {
      await _api.post(
        '/admin/orders/bulk-status',
        data: {
          'orderIds': orderIds,
          'status': status,
        },
      );

      return true;
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