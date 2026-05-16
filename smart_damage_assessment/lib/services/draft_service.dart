import 'package:shared_preferences/shared_preferences.dart';
import '../models/draft_report.dart';

class DraftService {
  static const _key = 'draft_reports';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<List<DraftReport>> getDrafts() async {
    final prefs = await _prefs;
    final encoded = prefs.getString(_key);
    if (encoded == null) return [];
    return DraftReport.decodeList(encoded);
  }

  Future<void> saveDraft(DraftReport draft) async {
    final drafts = await getDrafts();
    final index = drafts.indexWhere((d) => d.id == draft.id);
    if (index != -1) {
      drafts[index] = draft;
    } else {
      drafts.insert(0, draft);
    }
    await _saveAll(drafts);
  }

  Future<void> deleteDraft(String id) async {
    final drafts = await getDrafts();
    drafts.removeWhere((d) => d.id == id);
    await _saveAll(drafts);
  }

  Future<void> _saveAll(List<DraftReport> drafts) async {
    final prefs = await _prefs;
    await prefs.setString(_key, DraftReport.encodeList(drafts));
  }
}
