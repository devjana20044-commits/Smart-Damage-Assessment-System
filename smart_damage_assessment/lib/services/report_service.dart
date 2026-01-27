import 'dart:io';
import 'package:dio/dio.dart';
import '../core/api_constants.dart';
import '../models/report.dart';
import 'dio_service.dart';

/// Service for handling report-related API calls
class ReportService {
  final DioService _dioService;

  ReportService(this._dioService);

  /// Get all reports for the current user
  /// New API returns array directly, not wrapped in success/data
  Future<List<Report>> getReports() async {
    try {
      final response = await _dioService.dio.get(ApiConstants.reports);

      final responseData = response.data;
      if (responseData is List) {
        return responseData.map((json) => Report.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Invalid response format: expected array');
      }
    } on DioException catch (e) {
      rethrow;
    } catch (e) {
      throw Exception('Failed to load reports: ${e.toString()}');
    }
  }

  /// Get a specific report by ID
  /// New API returns report directly, not wrapped in success/data
  Future<Report> getReportById(int id) async {
    try {
      final response = await _dioService.dio.get('${ApiConstants.reports}/$id');

      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        return Report.fromJson(responseData);
      } else {
        throw Exception('Invalid response format: expected object');
      }
    } on DioException catch (e) {
      rethrow;
    } catch (e) {
      throw Exception('Failed to load report: ${e.toString()}');
    }
  }

  /// Create a new report with image upload
  /// New API uses raw_location and raw_description fields
  Future<Report> createReport({
    required String rawLocation,
    String? rawDescription,
    double? latitude,
    double? longitude,
    required File imageFile,
  }) async {
    try {
      // Create multipart form data with new field names
      final formData = FormData.fromMap({
        ApiConstants.rawLocation: rawLocation,
        if (rawDescription != null && rawDescription.isNotEmpty) ApiConstants.rawDescription: rawDescription,
        if (latitude != null) ApiConstants.latitude: latitude.toString(),
        if (longitude != null) ApiConstants.longitude: longitude.toString(),
        ApiConstants.image: await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await _dioService.dio.post(
        ApiConstants.reports,
        data: formData,
        options: Options(
          headers: {
            ApiConstants.contentType: ApiConstants.multipartContentType,
          },
        ),
      );

      final responseData = response.data;
      // New API returns: { "data": { "id": ..., "status": ..., "message": ... } }
      if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
        final data = responseData['data'] as Map<String, dynamic>;
        // The response only contains id and status, not the full report
        // We need to fetch the full report details
        final reportId = data['id'] as int;
        return await getReportById(reportId);
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      rethrow;
    } catch (e) {
      throw Exception('Failed to create report: ${e.toString()}');
    }
  }

  /// Create a new report with image upload (alternative method with XFile support)
  Future<Report> createReportFromXFile({
    required String rawLocation,
    String? rawDescription,
    double? latitude,
    double? longitude,
    required dynamic imageFile, // Can be XFile or File
  }) async {
    try {
      String filePath;
      String fileName;

      // Handle different file types
      if (imageFile is File) {
        filePath = imageFile.path;
        fileName = imageFile.path.split('/').last;
      } else {
        // Assume it's XFile or similar
        filePath = imageFile.path;
        fileName = imageFile.name ?? 'image.jpg';
      }

      // Create multipart form data with new field names
      final formData = FormData.fromMap({
        ApiConstants.rawLocation: rawLocation,
        if (rawDescription != null && rawDescription.isNotEmpty) ApiConstants.rawDescription: rawDescription,
        if (latitude != null) ApiConstants.latitude: latitude.toString(),
        if (longitude != null) ApiConstants.longitude: longitude.toString(),
        ApiConstants.image: await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
      });

      final response = await _dioService.dio.post(
        ApiConstants.reports,
        data: formData,
        options: Options(
          headers: {
            ApiConstants.contentType: ApiConstants.multipartContentType,
          },
        ),
      );

      final responseData = response.data;
      // New API returns: { "data": { "id": ..., "status": ..., "message": ... } }
      if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
        final data = responseData['data'] as Map<String, dynamic>;
        // The response only contains id and status, not the full report
        // We need to fetch the full report details
        final reportId = data['id'] as int;
        return await getReportById(reportId);
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      rethrow;
    } catch (e) {
      throw Exception('Failed to create report: ${e.toString()}');
    }
  }

  /// Delete a report by ID
  /// New API endpoint: DELETE /api/reports/{id}
  Future<void> deleteReport(int id) async {
    try {
      final response = await _dioService.dio.delete('${ApiConstants.reports}/$id');

      final responseData = response.data;
      // New API returns: { "message": "Report deleted successfully" }
      if (responseData is Map<String, dynamic>) {
        final message = responseData[ApiConstants.message] as String?;
        print('✅ Report deleted: $message');
      }
    } on DioException catch (e) {
      rethrow;
    } catch (e) {
      throw Exception('Failed to delete report: ${e.toString()}');
    }
  }
}
