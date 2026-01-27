import 'dart:io';
import 'package:flutter/material.dart';
import '../models/report.dart';
import '../services/report_service.dart';

/// Provider for managing reports state
class ReportProvider with ChangeNotifier {
  final ReportService _reportService;

  List<Report> _reports = [];
  Report? _currentReport;
  bool _isLoading = false;
  String? _errorMessage;

  ReportProvider(this._reportService);

  // Getters
  List<Report> get reports => _reports;
  Report? get currentReport => _currentReport;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch all reports for the current user
  Future<void> fetchReports() async {
    _setLoading(true);
    _clearError();

    try {
      _reports = await _reportService.getReports();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch a specific report by ID
  Future<bool> fetchReportById(int id) async {
    _setLoading(true);
    _clearError();

    try {
      _currentReport = await _reportService.getReportById(id);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Create a new report
  Future<bool> createReport({
    required String userInputLocation,
    String? userNotes,
    double? latitude,
    double? longitude,
    required File imageFile,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final newReport = await _reportService.createReport(
        rawLocation: userInputLocation,
        rawDescription: userNotes,
        latitude: latitude,
        longitude: longitude,
        imageFile: imageFile,
      );

      // Add to reports list
      _reports.insert(0, newReport);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Create a new report with XFile support
  Future<bool> createReportFromXFile({
    required String userInputLocation,
    String? userNotes,
    double? latitude,
    double? longitude,
    required dynamic imageFile,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final newReport = await _reportService.createReportFromXFile(
        rawLocation: userInputLocation,
        rawDescription: userNotes,
        latitude: latitude,
        longitude: longitude,
        imageFile: imageFile,
      );

      // Add to reports list
      _reports.insert(0, newReport);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh reports list
  Future<void> refreshReports() async {
    await fetchReports();
  }

  /// Clear current report
  void clearCurrentReport() {
    _currentReport = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _clearError();
  }

  /// Get reports by status
  List<Report> getReportsByStatus(String status) {
    return _reports.where((report) =>
        report.damageAssessment.status.name.toLowerCase() == status.toLowerCase()).toList();
  }

  /// Get pending reports
  List<Report> get pendingReports => getReportsByStatus('pending');

  /// Get processed reports
  List<Report> get processedReports => getReportsByStatus('processed');

  /// Get failed reports
  List<Report> get failedReports => getReportsByStatus('failed');

  /// Delete a report by ID
  Future<bool> deleteReport(int reportId) async {
    _setLoading(true);
    _clearError();

    try {
      await _reportService.deleteReport(reportId);

      // Remove from reports list
      _reports.removeWhere((report) => report.id == reportId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}