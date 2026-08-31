import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/work_request_draft.dart';

class WorkRequestDraftStorage {
  const WorkRequestDraftStorage({
    this.key = 'work_request_create_draft_v1',
  });

  final String key;

  Future<WorkRequestDraft?> loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return WorkRequestDraft.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveDraft(WorkRequestDraft draft) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(draft.toJson()));
  }

  Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
