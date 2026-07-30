import 'package:dio/dio.dart';

import '../core/network/api_service.dart';

class ComplaintService {
  ComplaintService._();

  static final ComplaintService _instance =
      ComplaintService._();

  factory ComplaintService() => _instance;

  final ApiService _api = ApiService();

  // =====================================================
  // GET ALL COMPLAINTS
  // =====================================================

  Future<Map<String, dynamic>> getComplaints({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? priority,
    String? complaintType,
  }) async {
    try {
      final response = await _api.get(
        '/admin/complaints',
        query: {
          'page': page,
          'limit': limit,
          if (search != null) 'search': search,
          if (status != null) 'status': status,
          if (priority != null) 'priority': priority,
          if (complaintType != null)
            'complaintType': complaintType,
        },
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // GET COMPLAINT DETAILS
  // =====================================================

  Future<Map<String, dynamic>>
      getComplaintDetails(
    String complaintId,
  ) async {
    try {
      final response = await _api.get(
        '/admin/complaints/$complaintId',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // ASSIGN COMPLAINT
  // =====================================================

  Future<bool> assignComplaint({
    required String complaintId,
    required String adminId,
  }) async {
    try {
      await _api.patch(
        '/admin/complaints/$complaintId/assign',
        data: {
          'adminId': adminId,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // UPDATE STATUS
  // =====================================================

  Future<bool> updateComplaintStatus({
    required String complaintId,
    required String status,
  }) async {
    try {
      await _api.patch(
        '/admin/complaints/$complaintId/status',
        data: {
          'status': status,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // UPDATE PRIORITY
  // =====================================================

  Future<bool> updatePriority({
    required String complaintId,
    required String priority,
  }) async {
    try {
      await _api.patch(
        '/admin/complaints/$complaintId/priority',
        data: {
          'priority': priority,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // ADD RESOLUTION NOTE
  // =====================================================

  Future<bool> addResolutionNote({
    required String complaintId,
    required String note,
  }) async {
    try {
      await _api.post(
        '/admin/complaints/$complaintId/notes',
        data: {
          'note': note,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // RESOLVE COMPLAINT
  // =====================================================

  Future<bool> resolveComplaint({
    required String complaintId,
    required String resolution,
  }) async {
    try {
      await _api.patch(
        '/admin/complaints/$complaintId/resolve',
        data: {
          'resolution': resolution,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // REOPEN COMPLAINT
  // =====================================================

  Future<bool> reopenComplaint(
    String complaintId,
  ) async {
    try {
      await _api.patch(
        '/admin/complaints/$complaintId/reopen',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // CLOSE COMPLAINT
  // =====================================================

  Future<bool> closeComplaint(
    String complaintId,
  ) async {
    try {
      await _api.patch(
        '/admin/complaints/$complaintId/close',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // DELETE COMPLAINT
  // =====================================================

  Future<bool> deleteComplaint(
    String complaintId,
  ) async {
    try {
      await _api.delete(
        '/admin/complaints/$complaintId',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // GET COMPLAINT MESSAGES
  // =====================================================

  Future<List<dynamic>>
      getComplaintMessages(
    String complaintId,
  ) async {
    try {
      final response = await _api.get(
        '/admin/complaints/$complaintId/messages',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // SEND RESPONSE
  // =====================================================

  Future<bool> sendResponse({
    required String complaintId,
    required String message,
  }) async {
    try {
      await _api.post(
        '/admin/complaints/$complaintId/respond',
        data: {
          'message': message,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // CUSTOMER COMPLAINTS
  // =====================================================

  Future<List<dynamic>>
      getCustomerComplaints(
    String customerId,
  ) async {
    try {
      final response = await _api.get(
        '/admin/customers/$customerId/complaints',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // PROVIDER COMPLAINTS
  // =====================================================

  Future<List<dynamic>>
      getProviderComplaints(
    String providerId,
  ) async {
    try {
      final response = await _api.get(
        '/admin/providers/$providerId/complaints',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // COMPLAINT ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getComplaintAnalytics() async {
    try {
      final response = await _api.get(
        '/admin/complaints/analytics',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // COMPLAINT STATISTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getComplaintStatistics() async {
    try {
      final response = await _api.get(
        '/admin/complaints/statistics',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // SEARCH COMPLAINTS
  // =====================================================

  Future<List<dynamic>>
      searchComplaints(
    String keyword,
  ) async {
    try {
      final response = await _api.get(
        '/admin/complaints/search',
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
  // EXPORT COMPLAINTS
  // =====================================================

  Future<Response<dynamic>>
      exportComplaints({
    String format = 'excel',
  }) async {
    try {
      return await _api.get(
        '/admin/complaints/export',
        query: {
          'format': format,
        },
      );
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // BULK CLOSE
  // =====================================================

  Future<bool> bulkCloseComplaints(
    List<String> complaintIds,
  ) async {
    try {
      await _api.post(
        '/admin/complaints/bulk-close',
        data: {
          'complaintIds': complaintIds,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // BULK DELETE
  // =====================================================

  Future<bool> bulkDeleteComplaints(
    List<String> complaintIds,
  ) async {
    try {
      await _api.post(
        '/admin/complaints/bulk-delete',
        data: {
          'complaintIds': complaintIds,
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