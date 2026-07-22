import 'dart:io';

import 'package:dio/dio.dart';

import 'api_service.dart';

class UploadService {
  UploadService._();

  static final UploadService instance =
      UploadService._();

  // ==========================================
  // UPLOAD SINGLE IMAGE
  // ==========================================

  Future<String> uploadImage(
    File file,
  ) async {
    final fileName =
        file.path.split('/').last;

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
    });

    final response =
        await ApiService.instance.post(
      '/uploads/image',
      data: formData,
    );

    return response.data['url'] ??
        response.data['data']?['url'] ??
        '';
  }

  // ==========================================
  // UPLOAD MULTIPLE IMAGES
  // ==========================================

  Future<List<String>> uploadImages(
    List<File> files,
  ) async {
    final List<MultipartFile>
        multipartFiles = [];

    for (final file in files) {
      multipartFiles.add(
        await MultipartFile.fromFile(
          file.path,
          filename:
              file.path.split('/').last,
        ),
      );
    }

    final formData = FormData.fromMap({
      'files': multipartFiles,
    });

    final response =
        await ApiService.instance.post(
      '/uploads/images',
      data: formData,
    );

    final List urls =
        response.data['data'] ??
            response.data['urls'] ??
            [];

    return urls
        .map<String>((e) => e.toString())
        .toList();
  }

  // ==========================================
  // UPLOAD PROFILE IMAGE
  // ==========================================

  Future<String> uploadProfileImage(
    File file,
  ) async {
    final fileName =
        file.path.split('/').last;

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
    });

    final response =
        await ApiService.instance.post(
      '/uploads/profile',
      data: formData,
    );

    return response.data['url'] ??
        response.data['data']?['url'] ??
        '';
  }

  // ==========================================
  // UPLOAD DOCUMENT
  // ==========================================

  Future<String> uploadDocument(
    File file,
  ) async {
    final fileName =
        file.path.split('/').last;

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
    });

    final response =
        await ApiService.instance.post(
      '/uploads/document',
      data: formData,
    );

    return response.data['url'] ??
        response.data['data']?['url'] ??
        '';
  }

  // ==========================================
  // UPLOAD KYC DOCUMENT
  // ==========================================

  Future<String> uploadKycDocument(
    File file,
  ) async {
    final fileName =
        file.path.split('/').last;

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
    });

    final response =
        await ApiService.instance.post(
      '/uploads/kyc',
      data: formData,
    );

    return response.data['url'] ??
        response.data['data']?['url'] ??
        '';
  }

  // ==========================================
  // UPLOAD SERVICE GALLERY
  // ==========================================

  Future<List<String>>
      uploadServiceGallery(
    List<File> files,
  ) async {
    final List<MultipartFile>
        multipartFiles = [];

    for (final file in files) {
      multipartFiles.add(
        await MultipartFile.fromFile(
          file.path,
          filename:
              file.path.split('/').last,
        ),
      );
    }

    final formData = FormData.fromMap({
      'files': multipartFiles,
    });

    final response =
        await ApiService.instance.post(
      '/uploads/service-gallery',
      data: formData,
    );

    final List urls =
        response.data['data'] ??
            response.data['urls'] ??
            [];

    return urls
        .map<String>((e) => e.toString())
        .toList();
  }

  // ==========================================
  // UPLOAD CHAT IMAGE
  // ==========================================

  Future<String> uploadChatImage(
    File file,
  ) async {
    final fileName =
        file.path.split('/').last;

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
    });

    final response =
        await ApiService.instance.post(
      '/uploads/chat',
      data: formData,
    );

    return response.data['url'] ??
        response.data['data']?['url'] ??
        '';
  }

  // ==========================================
  // DELETE FILE
  // ==========================================

  Future<bool> deleteFile(
    String fileId,
  ) async {
    await ApiService.instance.delete(
      '/uploads/$fileId',
    );

    return true;
  }
}