import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Offline-first user profile — no login required.
class UserLocalStorage {
  UserLocalStorage(this._prefs);

  final SharedPreferences _prefs;

  static const _keyOnboardingComplete = 'onboarding_complete';
  static const _keyName = 'user_name';
  static const _keyInterests = 'user_interests';
  static const _keySavedStories = 'saved_story_ids';
  static const _keyLastActiveAt = 'last_active_at';
  static const _keyGroqApiKey = 'groq_api_key';
  static const _keyContentDepth = 'content_depth';
  static const _keyReadStoryIds = 'read_story_ids';

  static Future<UserLocalStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return UserLocalStorage(prefs);
  }

  // ── Onboarding ──────────────────────────────────────────────

  bool get isOnboardingComplete => _prefs.getBool(_keyOnboardingComplete) ?? false;

  Future<void> completeOnboarding({
    required String name,
    required List<String> interests,
  }) async {
    await _prefs.setBool(_keyOnboardingComplete, true);
    await _prefs.setString(_keyName, name.trim());
    await _prefs.setStringList(_keyInterests, interests);
    await _prefs.setString(_keyLastActiveAt, DateTime.now().toIso8601String());
  }

  // ── Profile ─────────────────────────────────────────────────

  String get userName => _prefs.getString(_keyName) ?? 'there';

  String get firstName {
    final name = userName.trim();
    if (name.isEmpty) return 'there';
    return name.split(' ').first;
  }

  Future<void> setUserName(String name) => _prefs.setString(_keyName, name.trim());

  List<String> get interests => _prefs.getStringList(_keyInterests) ?? ['AI', 'Programming'];

  Future<void> setInterests(List<String> interests) =>
      _prefs.setStringList(_keyInterests, interests);

  String get contentDepth => _prefs.getString(_keyContentDepth) ?? 'normal';

  Future<void> setContentDepth(String depth) => _prefs.setString(_keyContentDepth, depth);

  // ── Groq API key (user-provided) ─────────────────────────────

  String? get groqApiKey => _prefs.getString(_keyGroqApiKey);

  bool get hasGroqKey => groqApiKey != null && groqApiKey!.isNotEmpty;

  Future<void> setGroqApiKey(String? key) async {
    if (key == null || key.isEmpty) {
      await _prefs.remove(_keyGroqApiKey);
    } else {
      await _prefs.setString(_keyGroqApiKey, key.trim());
    }
  }

  // ── Saved stories ─────────────────────────────────────────────

  Set<String> get savedStoryIds {
    final raw = _prefs.getString(_keySavedStories);
    if (raw == null) return {};
    final list = jsonDecode(raw) as List;
    return list.cast<String>().toSet();
  }

  Future<void> saveStory(String storyId) async {
    final ids = savedStoryIds;
    ids.add(storyId);
    await _prefs.setString(_keySavedStories, jsonEncode(ids.toList()));
  }

  Future<void> unsaveStory(String storyId) async {
    final ids = savedStoryIds;
    ids.remove(storyId);
    await _prefs.setString(_keySavedStories, jsonEncode(ids.toList()));
  }

  bool isStorySaved(String storyId) => savedStoryIds.contains(storyId);

  // ── Reading history ───────────────────────────────────────────

  Set<String> get readStoryIds {
    final raw = _prefs.getString(_keyReadStoryIds);
    if (raw == null) return {};
    final list = jsonDecode(raw) as List;
    return list.cast<String>().toSet();
  }

  Future<void> markStoryRead(String storyId) async {
    final ids = readStoryIds;
    ids.add(storyId);
    await _prefs.setString(_keyReadStoryIds, jsonEncode(ids.toList()));
  }

  // ── Since you last checked ────────────────────────────────────

  DateTime? get lastActiveAt {
    final raw = _prefs.getString(_keyLastActiveAt);
    return raw != null ? DateTime.tryParse(raw) : null;
  }

  Future<void> updateLastActive() =>
      _prefs.setString(_keyLastActiveAt, DateTime.now().toIso8601String());

  Future<void> resetPersonalization() async {
    await _prefs.remove(_keyReadStoryIds);
    await _prefs.remove(_keySavedStories);
  }
}
