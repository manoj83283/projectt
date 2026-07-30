import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';

import '../core/network/api_service.dart';

class UploadService {
  UploadService._();

  static final UploadService _instance =
      UploadService._();

  static UploadService get instance =>
      _instance;

  final ApiService _apiService =
      ApiService.instance;

  // =========================
  // SINGLE IMAGE UPLOAD
  // =========================

  Future<String?> uploadImage({
    required File file,
    String folder = 'provider',
  }) async {
    try {
      final fileName =
          file.path.split('/').last;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        'folder': folder,
      });

      final response =
          await _apiService.upload(
        '/upload/image',
        formData,
      );

      return response['url']?.toString();
    } catch (e) {
      log('Upload Image Error: $e');
      return null;
    }
  }

  // =========================
  // MULTIPLE IMAGES UPLOAD
  // =========================

  Future<List<String>> uploadImages({
    required List<File> files,
    String folder = 'provider',
  }) async {
    try {
      final List<MultipartFile> images =
          [];

      for (final file in files) {
        images.add(
          await MultipartFile.fromFile(
            file.path,
            filename:
                file.path.split('/').last,
          ),
        );
      }

      final formData = FormData.fromMap({
        'files': images,
        'folder': folder,
      });

      final response =
          await _apiService.upload(
        '/upload/images',
        formData,
      );

      if (response['data'] == null) {
        return [];
      }

      return List<String>.from(
        response['data'],
      );
    } catch (e) {
      log('Upload Images Error: $e');
      return [];
    }
  }

  // =========================
  // PROFILE IMAGE
  // =========================

  Future<String?> uploadProfileImage(
    File file,
  ) async {
    return uploadImage(
      file: file,
      folder: 'profiles',
    );
  }

  // =========================
  // SERVICE IMAGE
  // =========================

  Future<String?> uploadServiceImage(
    File file,
  ) async {
    return uploadImage(
      file: file,
      folder: 'services',
    );
  }

  // =========================
  // PORTFOLIO IMAGE
  // =========================

  Future<String?> uploadPortfolioImage(
    File file,
  ) async {
    return uploadImage(
      file: file,
      folder: 'portfolio',
    );
  }

  // =========================
  // CHAT IMAGE
  // =========================

  Future<String?> uploadChatImage(
    File file,
  ) async {
    return uploadImage(
      file: file,
      folder: 'chat',
    );
  }

  // =========================
  // DOCUMENT UPLOAD
  // =========================

  Future<String?> uploadDocument({
    required File file,
    String folder = 'documents',
  }) async {
    try {
      final fileName =
          file.path.split('/').last;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        'folder': folder,
      });

      final response =
          await _apiService.upload(
        '/upload/document',
        formData,
      );

      return response['url']?.toString();
    } catch (e) {
      log('Upload Document Error: $e');
      return null;
    }
  }

  // =========================
  // VIDEO UPLOAD
  // =========================

  Future<String?> uploadVideo({
    required File file,
  }) async {
    try {
      final fileName =
          file.path.split('/').last;

      final formData = FormData.fromMap({
        'video': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      final response =
          await _apiService.upload(
        '/upload/video',
        formData,
      );

      return response['url']?.toString();
    } catch (e) {
      log('Upload Video Error: $e');
      return null;
    }
  }

  // =========================
  // AUDIO UPLOAD
  // =========================

  Future<String?> uploadAudio({
    required File file,
  }) async {
    try {
      final fileName =
          file.path.split('/').last;

      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      final response =
          await _apiService.upload(
        '/upload/audio',
        formData,
      );

      return response['url']?.toString();
    } catch (e) {
      log('Upload Audio Error: $e');
      return null;
    }
  }

  // =========================
  // DELETE FILE
  // =========================

  Future<bool> deleteFile({
    required String fileUrl,
  }) async {
    try {
      await _apiService.delete(
        '/upload/delete',
        body: {
          'fileUrl': fileUrl,
        },
      );

      return true;
    } catch (e) {
      log('Delete File Error: $e');
      return false;
    }
  }

  // =========================
  // GET SIGNED URL
  // =========================

  Future<String?> getSignedUrl({
    required String fileName,
  }) async {
    try {
      final response =
          await _apiService.get(
        '/upload/signed-url?fileName=$fileName',
      );

      return response['url']?.toString();
    } catch (e) {
      log('Signed URL Error: $e');
      return null;
    }
  }
}