import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/iam.dart';

class SessionStorageService {
  static final SessionStorageService _instance =
      SessionStorageService._internal();
  factory SessionStorageService() => _instance;
  SessionStorageService._internal();

  static const String _keyAccessToken = 'ilmiya_access_token';
  static const String _keyRefreshToken = 'ilmiya_refresh_token';
  static const String _keyTenantId = 'ilmiya_tenant_id';
  static const String _keyUserProfile = 'ilmiya_user_profile';
  static const String _keySchoolName = 'ilmiya_school_name';
  static const String _keyThemeMode = 'ilmiya_theme_mode';
  static const String _keyCurrentTab = 'ilmiya_current_tab';

  SharedPreferences? _prefs;
  final Map<String, dynamic> _memoryFallback = {};

  Future<void> init() async {
    if (_prefs != null) return;
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (_) {
      // In isolated test environments or restricted runtimes, fallback gracefully to in-memory map
    }
  }

  @visibleForTesting
  void resetForTesting() {
    _memoryFallback.clear();
    _prefs?.clear();
  }

  // --- Auth Session ---
  String? get accessToken {
    return _prefs?.getString(_keyAccessToken) ??
        _memoryFallback[_keyAccessToken] as String?;
  }

  String? get refreshToken {
    return _prefs?.getString(_keyRefreshToken) ??
        _memoryFallback[_keyRefreshToken] as String?;
  }

  String? get tenantId {
    return _prefs?.getString(_keyTenantId) ??
        _memoryFallback[_keyTenantId] as String?;
  }

  UserProfileResponse? get userProfile {
    final raw = _prefs?.getString(_keyUserProfile) ??
        _memoryFallback[_keyUserProfile] as String?;
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return UserProfileResponse.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  String? get schoolName {
    return _prefs?.getString(_keySchoolName) ??
        _memoryFallback[_keySchoolName] as String?;
  }

  Future<void> saveAuthSession({
    String? accessToken,
    String? refreshToken,
    String? tenantId,
    UserProfileResponse? user,
    String? schoolName,
  }) async {
    if (accessToken != null) {
      _memoryFallback[_keyAccessToken] = accessToken;
      await _prefs?.setString(_keyAccessToken, accessToken);
    }
    if (refreshToken != null) {
      _memoryFallback[_keyRefreshToken] = refreshToken;
      await _prefs?.setString(_keyRefreshToken, refreshToken);
    }
    if (tenantId != null && tenantId.isNotEmpty) {
      _memoryFallback[_keyTenantId] = tenantId;
      await _prefs?.setString(_keyTenantId, tenantId);
    }
    if (user != null) {
      final jsonStr = jsonEncode(user.toJson());
      _memoryFallback[_keyUserProfile] = jsonStr;
      await _prefs?.setString(_keyUserProfile, jsonStr);
    }
    if (schoolName != null && schoolName.isNotEmpty) {
      _memoryFallback[_keySchoolName] = schoolName;
      await _prefs?.setString(_keySchoolName, schoolName);
    }
  }

  Future<void> saveTokens({String? accessToken, String? refreshToken}) async {
    if (accessToken != null) {
      _memoryFallback[_keyAccessToken] = accessToken;
      await _prefs?.setString(_keyAccessToken, accessToken);
    }
    if (refreshToken != null) {
      _memoryFallback[_keyRefreshToken] = refreshToken;
      await _prefs?.setString(_keyRefreshToken, refreshToken);
    }
  }

  Future<void> saveTenantId(String tenantId) async {
    if (tenantId.isNotEmpty) {
      _memoryFallback[_keyTenantId] = tenantId;
      await _prefs?.setString(_keyTenantId, tenantId);
    }
  }

  Future<void> saveUserProfile(UserProfileResponse? user,
      [String? schoolName]) async {
    if (user != null) {
      final jsonStr = jsonEncode(user.toJson());
      _memoryFallback[_keyUserProfile] = jsonStr;
      await _prefs?.setString(_keyUserProfile, jsonStr);
    } else {
      _memoryFallback.remove(_keyUserProfile);
      await _prefs?.remove(_keyUserProfile);
    }
    if (schoolName != null && schoolName.isNotEmpty) {
      _memoryFallback[_keySchoolName] = schoolName;
      await _prefs?.setString(_keySchoolName, schoolName);
    }
  }

  Future<void> clearAuthSession() async {
    _memoryFallback.remove(_keyAccessToken);
    _memoryFallback.remove(_keyRefreshToken);
    _memoryFallback.remove(_keyTenantId);
    _memoryFallback.remove(_keyUserProfile);
    _memoryFallback.remove(_keySchoolName);

    await _prefs?.remove(_keyAccessToken);
    await _prefs?.remove(_keyRefreshToken);
    await _prefs?.remove(_keyTenantId);
    await _prefs?.remove(_keyUserProfile);
    await _prefs?.remove(_keySchoolName);
  }

  // --- Theme Mode ---
  ThemeMode? get themeMode {
    final val = _prefs?.getString(_keyThemeMode) ??
        _memoryFallback[_keyThemeMode] as String?;
    if (val == 'dark') return ThemeMode.dark;
    if (val == 'light') return ThemeMode.light;
    if (val == 'system') return ThemeMode.system;
    return null;
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final str = mode == ThemeMode.dark
        ? 'dark'
        : mode == ThemeMode.light
            ? 'light'
            : 'system';
    _memoryFallback[_keyThemeMode] = str;
    await _prefs?.setString(_keyThemeMode, str);
  }

  // --- Current Tab ---
  int? get currentTab {
    return _prefs?.getInt(_keyCurrentTab) ??
        _memoryFallback[_keyCurrentTab] as int?;
  }

  Future<void> saveCurrentTab(int tab) async {
    _memoryFallback[_keyCurrentTab] = tab;
    await _prefs?.setInt(_keyCurrentTab, tab);
  }
}

final SessionStorageService sessionStorageService = SessionStorageService();
