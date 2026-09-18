import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class ProfileService extends ChangeNotifier {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  static const String _storageKey = 'branch_planner_user_profile_v2';

  UserProfile _profile = UserProfile();
  bool _isInitialized = false;

  UserProfile get profile => _profile;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString(_storageKey);

    if (savedData != null && savedData.isNotEmpty) {
      try {
        _profile = UserProfile.fromJson(savedData);
      } catch (e) {
        debugPrint('Error loading profile: $e');
        _profile = UserProfile();
      }
    } else {
      _profile = UserProfile();
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, _profile.toJson());
    } catch (e) {
      debugPrint('Error saving profile: $e');
    }
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? avatarEmoji,
    String? avatarImagePath,
  }) async {
    _profile = _profile.copyWith(
      name: name,
      email: email,
      avatarEmoji: avatarEmoji,
      avatarImagePath: avatarImagePath,
    );
    notifyListeners();
    await _saveToStorage();
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_profile.password != currentPassword) {
      return false; // Password lama salah
    }
    _profile = _profile.copyWith(password: newPassword);
    notifyListeners();
    await _saveToStorage();
    return true;
  }

  Future<void> updateAlarmSettings({
    bool? defaultAlarmHMinus1,
    String? defaultAlarmHMinus1Time,
    bool? defaultAlarmHariH,
    String? defaultAlarmHariHTime,
    bool? autoAlertFallback,
  }) async {
    _profile = _profile.copyWith(
      defaultAlarmHMinus1: defaultAlarmHMinus1,
      defaultAlarmHMinus1Time: defaultAlarmHMinus1Time,
      defaultAlarmHariH: defaultAlarmHariH,
      defaultAlarmHariHTime: defaultAlarmHariHTime,
      autoAlertFallback: autoAlertFallback,
    );
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> setThemeMode(String themeMode) async {
    _profile = _profile.copyWith(themeMode: themeMode);
    notifyListeners();
    await _saveToStorage();
  }
}
