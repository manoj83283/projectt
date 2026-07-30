import '../services/customer_service.dart';

class CustomerRepository {
  final CustomerService _customerService;

  CustomerRepository({
    CustomerService? customerService,
  }) : _customerService =
            customerService ??
                CustomerService();

  // =====================================================
  // GET CUSTOMERS
  // =====================================================

  Future<Map<String, dynamic>> getCustomers({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    bool? isBlocked,
  }) async {
    try {
      return await _customerService
          .getCustomers(
        page: page,
        limit: limit,
        search: search,
        status: status,
        isBlocked: isBlocked,
      );
    } catch (e) {
      rethrow;
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
      return await _customerService
          .getCustomerDetails(
        customerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // SEARCH CUSTOMERS
  // =====================================================

  Future<List<dynamic>> searchCustomers(
    String keyword,
  ) async {
    try {
      return await _customerService
          .searchCustomers(
        keyword,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // CUSTOMER BOOKINGS
  // =====================================================

  Future<List<dynamic>>
      getCustomerBookings(
    String customerId,
  ) async {
    try {
      return await _customerService
          .getCustomerBookings(
        customerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // CUSTOMER ORDERS
  // =====================================================

  Future<List<dynamic>>
      getCustomerOrders(
    String customerId,
  ) async {
    try {
      return await _customerService
          .getCustomerOrders(
        customerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // CUSTOMER PAYMENTS
  // =====================================================

  Future<List<dynamic>>
      getCustomerPayments(
    String customerId,
  ) async {
    try {
      return await _customerService
          .getCustomerPayments(
        customerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // CUSTOMER REVIEWS
  // =====================================================

  Future<List<dynamic>>
      getCustomerReviews(
    String customerId,
  ) async {
    try {
      return await _customerService
          .getCustomerReviews(
        customerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // ACTIVATE CUSTOMER
  // =====================================================

  Future<Map<String, dynamic>>
      activateCustomer(
    String customerId,
  ) async {
    try {
      return await _customerService
          .activateCustomer(
        customerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // DEACTIVATE CUSTOMER
  // =====================================================

  Future<Map<String, dynamic>>
      deactivateCustomer(
    String customerId,
  ) async {
    try {
      return await _customerService
          .deactivateCustomer(
        customerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // BLOCK CUSTOMER
  // =====================================================

  Future<Map<String, dynamic>>
      blockCustomer(
    String customerId,
  ) async {
    try {
      return await _customerService
          .blockCustomer(
        customerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // UNBLOCK CUSTOMER
  // =====================================================

  Future<Map<String, dynamic>>
      unblockCustomer(
    String customerId,
  ) async {
    try {
      return await _customerService
          .unblockCustomer(
        customerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // DELETE CUSTOMER
  // =====================================================

  Future<void> deleteCustomer(
    String customerId,
  ) async {
    try {
      await _customerService
          .deleteCustomer(
        customerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // CUSTOMER ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getCustomerAnalytics(
    String customerId,
  ) async {
    try {
      return await _customerService
          .getCustomerAnalytics(
        customerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // CUSTOMER ACTIVITY LOGS
  // =====================================================

  Future<List<dynamic>>
      getCustomerActivities(
    String customerId,
  ) async {
    try {
      return await _customerService
          .getCustomerActivities(
        customerId,
      );
    } catch (e) {
      rethrow;
    }
  }
}