import 'dart:io';

import 'package:dio/dio.dart';

import '../core/network/api_service.dart';

class FileUploadService {
  FileUploadService._();

  static final FileUploadService _instance =
      FileUploadService._();

  factory FileUploadService() => _instance;

  final ApiService _api = ApiService();

  // =====================================================
  // UPLOAD SINGLE IMAGE
  // =====================================================

  Future<Map<String, dynamic>> uploadImage(
    File file,
  ) async {
    try {
      final fileName =
          file.path.split('/').last;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      final response = await _api.post(
        '/admin/uploads/image',
        data: formData,
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // UPLOAD MULTIPLE IMAGES
  // =====================================================

  Future<List<dynamic>> uploadImages(
    List<File> files,
  ) async {
    try {
      final formData = FormData();

      for (final file in files) {
        formData.files.add(
          MapEntry(
            'files',
            await MultipartFile.fromFile(
              file.path,
              filename:
                  file.path.split('/').last,
            ),
          ),
        );
      }

      final response = await _api.post(
        '/admin/uploads/images',
        data: formData,
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // UPLOAD DOCUMENT
  // =====================================================

  Future<Map<String, dynamic>>
      uploadDocument(
    File file,
  ) async {
    try {
      final formData = FormData.fromMap({
        'file':
            await MultipartFile.fromFile(
          file.path,
          filename:
              file.path.split('/').last,
        ),
      });

      final response = await _api.post(
        '/admin/uploads/document',
        data: formData,
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // UPLOAD VIDEO
  // =====================================================

  Future<Map<String, dynamic>> uploadVideo(
    File file,
  ) async {
    try {
      final formData = FormData.fromMap({
        'file':
            await MultipartFile.fromFile(
          file.path,
          filename:
              file.path.split('/').last,
        ),
      });

      final response = await _api.post(
        '/admin/uploads/video',
        data: formData,
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // UPLOAD PROVIDER KYC FILE
  // =====================================================

  Future<Map<String, dynamic>>
      uploadKycDocument({
    required File file,
    required String type,
  }) async {
    try {
      final formData = FormData.fromMap({
        'type': type,
        'file':
            await MultipartFile.fromFile(
          file.path,
          filename:
              file.path.split('/').last,
        ),
      });

      final response = await _api.post(
        '/admin/uploads/kyc',
        data: formData,
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // UPLOAD BANNER
  // =====================================================

  Future<Map<String, dynamic>>
      uploadBanner(
    File file,
  ) async {
    try {
      final formData = FormData.fromMap({
        'file':
            await MultipartFile.fromFile(
          file.path,
          filename:
              file.path.split('/').last,
        ),
      });

      final response = await _api.post(
        '/admin/uploads/banner',
        data: formData,
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // UPLOAD CATEGORY IMAGE
  // =====================================================

  Future<Map<String, dynamic>>
      uploadCategoryImage(
    File file,
  ) async {
    try {
      final formData = FormData.fromMap({
        'file':
            await MultipartFile.fromFile(
          file.path,
          filename:
              file.path.split('/').last,
        ),
      });

      final response = await _api.post(
        '/admin/uploads/category',
        data: formData,
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // UPLOAD SERVICE IMAGE
  // =====================================================

  Future<Map<String, dynamic>>
      uploadServiceImage(
    File file,
  ) async {
    try {
      final formData = FormData.fromMap({
        'file':
            await MultipartFile.fromFile(
          file.path,
          filename:
              file.path.split('/').last,
        ),
      });

      final response = await _api.post(
        '/admin/uploads/service',
        data: formData,
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // DELETE FILE
  // =====================================================

  Future<bool> deleteFile({
    required String fileId,
  }) async {
    try {
      await _api.delete(
        '/admin/uploads/$fileId',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // GET FILE DETAILS
  // =====================================================

  Future<Map<String, dynamic>>
      getFileDetails(
    String fileId,
  ) async {
    try {
      final response = await _api.get(
        '/admin/uploads/$fileId',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // GET UPLOAD HISTORY
  // =====================================================

  Future<Map<String, dynamic>>
      getUploadHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _api.get(
        '/admin/uploads/history',
        query: {
          'page': page,
          'limit': limit,
        },
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // GET STORAGE STATISTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getStorageStatistics() async {
    try {
      final response = await _api.get(
        '/admin/uploads/statistics',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // BULK DELETE FILES
  // =====================================================

  Future<bool> bulkDeleteFiles(
    List<String> fileIds,
  ) async {
    try {
      await _api.post(
        '/admin/uploads/bulk-delete',
        data: {
          'fileIds': fileIds,
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