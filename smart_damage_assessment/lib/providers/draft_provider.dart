import 'package:flutter/material.dart';
import '../models/draft_report.dart';
import '../services/draft_service.dart';

class DraftProvider with ChangeNotifier {
  final DraftService _draftService;
  List<DraftReport> _drafts = [];
  bool _isLoading = false;

  DraftProvider(this._draftService);

  List<DraftReport> get drafts => _drafts;
  bool get isLoading => _isLoading;

  Future<void> loadDrafts() async {
    _isLoading = true;
    notifyListeners();
    _drafts = await _draftService.getDrafts();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveDraft(DraftReport draft) async {
    await _draftService.saveDraft(draft);
    await loadDrafts();
  }

  Future<void> deleteDraft(String id) async {
    await _draftService.deleteDraft(id);
    await loadDrafts();
  }
}
