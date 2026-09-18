import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import 'profile_service.dart';

class AuthResult {
  final bool success;
  final String message;

  AuthResult({required this.success, required this.message});
}

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _sessionKey = 'branch_planner_session_user_email';
  static const String _usersDbKey = 'branch_planner_users_database_v1';

  final Map<String, UserProfile> _usersDb = {};
  String? _currentUserEmail;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  bool get isLoggedIn => _currentUserEmail != null;

  UserProfile get currentUser {
    if (_currentUserEmail != null && _usersDb.containsKey(_currentUserEmail)) {
      return _usersDb[_currentUserEmail]!;
    }
    return UserProfile(email: _currentUserEmail ?? '');
  }

  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    final prefs = await SharedPreferences.getInstance();

    // 1. Muat database lokal pengguna
    final usersJson = prefs.getString(_usersDbKey);
    if (usersJson != null && usersJson.isNotEmpty) {
      try {
        final Map<String, dynamic> decoded =
            json.decode(usersJson) as Map<String, dynamic>;
        _usersDb.clear();
        decoded.forEach((email, data) {
          _usersDb[email.toLowerCase()] =
              UserProfile.fromMap(data as Map<String, dynamic>);
        });
      } catch (e) {
        debugPrint('Error loading users DB: $e');
        _seedDefaultUser();
      }
    } else {
      _seedDefaultUser();
    }

    // 2. Periksa sesi Supabase aktif terlebih dahulu
    final supaSession = _supabase?.auth.currentSession;
    if (supaSession != null && supaSession.user.email != null) {
      final supaEmail = supaSession.user.email!.toLowerCase();
      _currentUserEmail = supaEmail;
      final meta = supaSession.user.userMetadata;
      if (!_usersDb.containsKey(supaEmail)) {
        _usersDb[supaEmail] = UserProfile(
          name: meta?['name'] as String? ?? supaEmail.split('@').first,
          email: supaEmail,
          avatarEmoji: meta?['avatar_emoji'] as String? ?? '👩‍💼',
        );
        await _saveUsersDb();
      }
      _syncToProfileService();
    } else {
      // Periksa sesi lokal tersimpan
      final sessionEmail = prefs.getString(_sessionKey);
      if (sessionEmail != null && _usersDb.containsKey(sessionEmail.toLowerCase())) {
        _currentUserEmail = sessionEmail.toLowerCase();
        _syncToProfileService();
      } else {
        _currentUserEmail = null;
      }
    }

    _isInitialized = true;
    notifyListeners();
  }

  void _seedDefaultUser() {
    final defaultUser = UserProfile(
      name: 'Sarah Wijaya',
      email: 'sarah.wijaya@planner.id',
      password: 'planner123',
      avatarEmoji: '👩‍💼',
    );
    _usersDb[defaultUser.email.toLowerCase()] = defaultUser;
    _saveUsersDb();
  }

  Future<void> _saveUsersDb() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> toSave = {};
      _usersDb.forEach((email, profile) {
        toSave[email] = profile.toMap();
      });
      await prefs.setString(_usersDbKey, json.encode(toSave));
    } catch (e) {
      debugPrint('Error saving users DB: $e');
    }
  }

  void _syncToProfileService() {
    if (_currentUserEmail != null && _usersDb.containsKey(_currentUserEmail)) {
      final activeProfile = _usersDb[_currentUserEmail]!;
      ProfileService().updateProfile(
        name: activeProfile.name,
        email: activeProfile.email,
        avatarEmoji: activeProfile.avatarEmoji,
        avatarImagePath: activeProfile.avatarImagePath,
      );
    }
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPass = password.trim();

    // 1. Coba login via Supabase jika terhubung
    if (_supabase != null) {
      try {
        final res = await _supabase!.auth.signInWithPassword(
          email: cleanEmail,
          password: cleanPass,
        );

        if (res.user != null) {
          _currentUserEmail = cleanEmail;
          final meta = res.user!.userMetadata;
          final name = meta?['name'] as String? ?? cleanEmail.split('@').first;
          final emoji = meta?['avatar_emoji'] as String? ?? '👩‍💼';

          _usersDb[cleanEmail] = UserProfile(
            name: name,
            email: cleanEmail,
            avatarEmoji: emoji,
          );
          await _saveUsersDb();

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_sessionKey, cleanEmail);

          _syncToProfileService();
          notifyListeners();
          return AuthResult(success: true, message: 'Berhasil masuk via Supabase Cloud!');
        }
      } catch (e) {
        debugPrint('Supabase login notice: $e');
        // Jika login Supabase gagal, fallback cek akun lokal/demo (contohnya akun Sarah Wijaya)
      }
    }

    // 2. Fallback cek akun lokal (misal: Sarah Wijaya)
    if (_usersDb.containsKey(cleanEmail)) {
      final user = _usersDb[cleanEmail]!;
      if (user.password == cleanPass) {
        _currentUserEmail = cleanEmail;
        _syncToProfileService();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_sessionKey, cleanEmail);

        notifyListeners();
        return AuthResult(success: true, message: 'Berhasil masuk!');
      } else {
        return AuthResult(
          success: false,
          message: 'Kata sandi salah. Silakan periksa kembali.',
        );
      }
    }

    return AuthResult(
      success: false,
      message: 'Akun dengan email ini tidak ditemukan. Silakan daftar terlebih dahulu.',
    );
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    String avatarEmoji = '👩‍💼',
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanName = name.trim();
    final cleanPass = password.trim();

    if (cleanName.isEmpty) {
      return AuthResult(success: false, message: 'Nama lengkap wajib diisi.');
    }
    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      return AuthResult(success: false, message: 'Format email tidak valid.');
    }
    if (cleanPass.length < 6) {
      return AuthResult(success: false, message: 'Kata sandi minimal 6 karakter.');
    }

    // 1. Daftarkan ke Supabase Auth jika tersedia
    if (_supabase != null) {
      try {
        final res = await _supabase!.auth.signUp(
          email: cleanEmail,
          password: cleanPass,
          data: {
            'name': cleanName,
            'avatar_emoji': avatarEmoji,
          },
        );

        if (res.user != null) {
          final newUser = UserProfile(
            name: cleanName,
            email: cleanEmail,
            avatarEmoji: avatarEmoji,
          );

          _usersDb[cleanEmail] = newUser;
          _currentUserEmail = cleanEmail;
          await _saveUsersDb();

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_sessionKey, cleanEmail);

          _syncToProfileService();
          notifyListeners();

          return AuthResult(
            success: true,
            message: 'Registrasi Supabase Cloud berhasil! Selamat datang di BranchPlan.',
          );
        }
      } catch (e) {
        debugPrint('Supabase signup notice: $e');
        // Fallback simpan lokal jika offline atau auth endpoint memerlukan konfirmasi
      }
    }

    // 2. Simpan lokal jika offline
    final newUser = UserProfile(
      name: cleanName,
      email: cleanEmail,
      password: cleanPass,
      avatarEmoji: avatarEmoji,
    );

    _usersDb[cleanEmail] = newUser;
    _currentUserEmail = cleanEmail;
    await _saveUsersDb();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, cleanEmail);

    _syncToProfileService();
    notifyListeners();

    return AuthResult(
      success: true,
      message: 'Registrasi berhasil! Data tersimpan di perangkat.',
    );
  }

  Future<void> logout() async {
    try {
      await _supabase?.auth.signOut();
    } catch (_) {}

    _currentUserEmail = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    notifyListeners();
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_currentUserEmail == null) return false;

    if (_supabase != null && _supabase!.auth.currentUser != null) {
      try {
        await _supabase!.auth.updateUser(UserAttributes(password: newPassword));
        return true;
      } catch (e) {
        debugPrint('Supabase change password error: $e');
      }
    }

    if (_usersDb.containsKey(_currentUserEmail)) {
      final user = _usersDb[_currentUserEmail]!;
      if (user.password == currentPassword) {
        final updated = user.copyWith(password: newPassword);
        _usersDb[_currentUserEmail!] = updated;
        await _saveUsersDb();
        _syncToProfileService();
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  Future<void> updateActiveProfile({
    String? name,
    String? email,
    String? avatarEmoji,
  }) async {
    if (_currentUserEmail == null) return;

    if (_supabase != null && _supabase!.auth.currentUser != null) {
      try {
        await _supabase!.from('profiles').update({
          if (name != null) 'name': name,
          if (avatarEmoji != null) 'avatar_emoji': avatarEmoji,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', _supabase!.auth.currentUser!.id);
      } catch (e) {
        debugPrint('Supabase update profile error: $e');
      }
    }

    if (_usersDb.containsKey(_currentUserEmail)) {
      final user = _usersDb[_currentUserEmail]!;
      final updated = user.copyWith(
        name: name ?? user.name,
        email: email ?? user.email,
        avatarEmoji: avatarEmoji ?? user.avatarEmoji,
      );

      _usersDb[_currentUserEmail!] = updated;
      await _saveUsersDb();
      _syncToProfileService();
      notifyListeners();
    }
  }
}
