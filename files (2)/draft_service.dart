import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DraftService {
  static const _key = 'task_draft';

  Future<Map<String, String>?> loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    return Map<String, String>.from(jsonDecode(raw));
  }

  Future<void> saveDraft(Map<String, String> draft) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(draft));
  }

  Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
