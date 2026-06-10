import 'dart:io';
import 'package:dio/dio.dart';
import '../core/api_constants.dart';
import '../models/report.dart';
import 'dio_service.dart';

class ReportService {
  final DioService _dioService;

  ReportService(this._dioService);

  Future<List<Report>> getReports() async {
    try {
      final response = await _dioService.dio.get(ApiConstants.reports);

      final responseData = response.data;
      if (responseData is List) {
        return responseData
            .map((json) => Report.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('data')) {
        final data = responseData['data'];
        if (data is List) {
          return data
              .map((json) => Report.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }

      throw Exception('Invalid response format: expected array');
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Failed to load reports: ${e.toString()}');
    }
  }

  Future<Report> getReportById(int id) async {
    try {
      final response = await _dioService.dio.get('${ApiConstants.reports}/$id');

      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        return Report.fromJson(responseData);
      }

      throw Exception('Invalid response format: expected object');
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Failed to load report: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> createReport({
    required String rawLocation,
    String? rawDescription,
    double? latitude,
    double? longitude,
    File? singleImage,
    List<File>? images,
    File? pdfFile,
    List<String>? videoLinks,
  }) async {
    try {
      final Map<String, dynamic> formDataMap = {
        ApiConstants.rawLocation: rawLocation,
        if (rawDescription != null && rawDescription.isNotEmpty)
          ApiConstants.rawDescription: rawDescription,
        if (latitude != null) ApiConstants.latitude: latitude.toString(),
        if (longitude != null) ApiConstants.longitude: longitude.toString(),
      };

      if (images != null && images.isNotEmpty) {
        formDataMap[ApiConstants.images] = await Future.wait(
          images.map(
            (img) => MultipartFile.fromFile(
              img.path,
              filename: img.path.split('/').last,
            ),
          ),
        );
      } else if (singleImage != null) {
        formDataMap[ApiConstants.image] = await MultipartFile.fromFile(
          singleImage.path,
          filename: singleImage.path.split('/').last,
        );
      }

      if (pdfFile != null) {
        formDataMap[ApiConstants.pdfFile] = await MultipartFile.fromFile(
          pdfFile.path,
          filename: pdfFile.path.split('/').last,
        );
      }

      if (videoLinks != null && videoLinks.isNotEmpty) {
        formDataMap[ApiConstants.videoLinks] = videoLinks;
      }

      final formData = FormData.fromMap(formDataMap);

      final response = await _dioService.dio.post(
        ApiConstants.reports,
        data: formData,
      );

      final responseData = response.data;
      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('data')) {
        return responseData['data'] as Map<String, dynamic>;
      }

      throw Exception('Invalid response format');
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Failed to create report: ${e.toString()}');
    }
  }

  Future<Report> updateReport({
    required int id,
    String? rawLocation,
    String? rawDescription,
    double? latitude,
    double? longitude,
    File? singleImage,
    List<File>? images,
    File? pdfFile,
    List<String>? videoLinks,
    List<String>? remainingOldImages,
  }) async {
    try {
      final hasNewFiles = (images != null && images.isNotEmpty) ||
          (singleImage != null) ||
          (pdfFile != null);

      if (hasNewFiles) {
        final Map<String, dynamic> formDataMap = {'_method': 'PUT'};

        if (rawLocation != null) {
          formDataMap[ApiConstants.rawLocation] = rawLocation;
        }
        if (rawDescription != null && rawDescription.isNotEmpty) {
          formDataMap[ApiConstants.rawDescription] = rawDescription;
        }
        if (latitude != null) {
          formDataMap[ApiConstants.latitude] = latitude.toString();
        }
        if (longitude != null) {
          formDataMap[ApiConstants.longitude] = longitude.toString();
        }

        if (remainingOldImages != null) {
          for (int i = 0; i < remainingOldImages.length; i++) {
            formDataMap['remaining_old_images[$i]'] = remainingOldImages[i];
          }
        }

        if (images != null && images.isNotEmpty) {
          formDataMap[ApiConstants.images] = await Future.wait(
            images.map(
              (img) => MultipartFile.fromFile(
                img.path,
                filename: img.path.split('/').last,
              ),
            ),
          );
        } else if (singleImage != null) {
          formDataMap[ApiConstants.image] = await MultipartFile.fromFile(
            singleImage.path,
            filename: singleImage.path.split('/').last,
          );
        }

        if (pdfFile != null) {
          formDataMap[ApiConstants.pdfFile] = await MultipartFile.fromFile(
            pdfFile.path,
            filename: pdfFile.path.split('/').last,
          );
        }

        if (videoLinks != null) {
          for (int i = 0; i < videoLinks.length; i++) {
            formDataMap['video_links[$i]'] = videoLinks[i];
          }
        }

        final formData = FormData.fromMap(formDataMap);

        final response = await _dioService.dio.post(
          '${ApiConstants.reports}/$id',
          data: formData,
        );

        final responseData = response.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          return Report.fromJson(responseData['data'] as Map<String, dynamic>);
        }
        if (responseData is Map<String, dynamic>) {
          return Report.fromJson(responseData);
        }
        throw Exception('Invalid response format');
      } else {
        final Map<String, dynamic> jsonData = {};

        if (rawLocation != null) {
          jsonData[ApiConstants.rawLocation] = rawLocation;
        }
        if (rawDescription != null) {
          jsonData[ApiConstants.rawDescription] = rawDescription;
        }
        if (latitude != null) {
          jsonData[ApiConstants.latitude] = latitude;
        }
        if (longitude != null) {
          jsonData[ApiConstants.longitude] = longitude;
        }

        jsonData['remaining_old_images'] = remainingOldImages ?? [];
        jsonData['video_links'] = videoLinks ?? [];

        final response = await _dioService.dio.put(
          '${ApiConstants.reports}/$id',
          data: jsonData,
        );

        final responseData = response.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          return Report.fromJson(responseData['data'] as Map<String, dynamic>);
        }
        if (responseData is Map<String, dynamic>) {
          return Report.fromJson(responseData);
        }
        throw Exception('Invalid response format');
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Failed to update report: ${e.toString()}');
    }
  }

  Future<void> deleteReport(int id) async {
    try {
      await _dioService.dio.delete('${ApiConstants.reports}/$id');
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Failed to delete report: ${e.toString()}');
    }
  }
}
