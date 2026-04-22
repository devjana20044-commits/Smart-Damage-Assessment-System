import 'dart:io';
import 'package:flutter/material.dart';
import '../models/report.dart';
import '../services/report_service.dart';

class ReportProvider with ChangeNotifier {
  final ReportService _reportService;

  List<Report> _reports = [];
  Report? _currentReport;
  bool _isLoading = false;
  String? _errorMessage;

  ReportProvider(this._reportService);

  List<Report> get reports => _reports;
  Report? get currentReport => _currentReport;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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

  Future<bool> createReport({
    required String userInputLocation,
    String? userNotes,
    double? latitude,
    double? longitude,
    File? singleImage,
    List<File>? images,
    File? pdfFile,
    List<String>? videoLinks,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _reportService.createReport(
        rawLocation: userInputLocation,
        rawDescription: userNotes,
        latitude: latitude,
        longitude: longitude,
        singleImage: singleImage,
        images: images,
        pdfFile: pdfFile,
        videoLinks: videoLinks,
      );

      final reportId = result['id'] as int;
      if (reportId > 0) {
        await fetchReports();
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createReportWithMultimedia({
    required String userInputLocation,
    String? userNotes,
    double? latitude,
    double? longitude,
    List<File>? images,
    File? pdfFile,
    List<String>? videoLinks,
  }) async {
    return createReport(
      userInputLocation: userInputLocation,
      userNotes: userNotes,
      latitude: latitude,
      longitude: longitude,
      images: images,
      pdfFile: pdfFile,
      videoLinks: videoLinks,
    );
  }

  Future<void> refreshReports() async {
    await fetchReports();
  }

  void clearCurrentReport() {
    _currentReport = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  List<Report> getReportsByStatus(String status) {
    return _reports
        .where(
          (report) =>
              report.damageAssessment.status.name.toLowerCase() ==
              status.toLowerCase(),
        )
        .toList();
  }

  List<Report> get pendingReports => getReportsByStatus('pending');
  List<Report> get completedReports => getReportsByStatus('completed');
  List<Report> get rejectedReports => getReportsByStatus('rejected');

  Future<bool> deleteReport(int reportId) async {
    _setLoading(true);
    _clearError();

    try {
      await _reportService.deleteReport(reportId);
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
