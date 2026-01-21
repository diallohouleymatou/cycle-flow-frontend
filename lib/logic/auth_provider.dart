import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/services/api_service.dart';
import '../data/services/crypto_service.dart';

class UserProfile {
  final String id;
  final String email;
  final String name;
  final String language;
  String? profileImagePath; // Local path

  UserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.language,
    this.profileImagePath,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      email: json['email'],
      name: json['name'] ?? '',
      language: json['language'] ?? 'fr',
      profileImagePath: json['profileImagePath'],
    );
  }

  UserProfile copyWith({String? profileImagePath}) {
    return UserProfile(
      id: id,
      email: email,
      name: name,
      language: language,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }
}

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final CryptoService _crypto = CryptoService();

  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;
  bool _isOnboardingCompleted = false;
  UserProfile? _user;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  bool get isOnboardingCompleted => _isOnboardingCompleted;
  UserProfile? get user => _user;
  ApiService get api => _api;

  AuthProvider() {
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isOnboardingCompleted = prefs.getBool('onboardingCompleted') ?? false;

    // Also try to load local profile image if user exists (mock persistence)
    final imagePath = prefs.getString('profileImagePath');
    if (_user != null && imagePath != null) {
      _user = _user!.copyWith(profileImagePath: imagePath);
    }

    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingCompleted', true);
    _isOnboardingCompleted = true;
    notifyListeners();
  }

  Future<void> updateProfileImage(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileImagePath', path);
    if (_user != null) {
      _user = _user!.copyWith(profileImagePath: path);
      notifyListeners();
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    String? name,
    int? birthYear,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _api.post('/auth/register', {
        'email': email,
        'password': password,
        'name': name,
        'birthYear': birthYear,
      });

      return await login(email, password);
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.post('/auth/login', {
        'email': email,
        'password': password,
      });

      _api.setToken(response['access_token']);
      _user = UserProfile.fromJson(response['user']);

      // Initialize Crypto with a key derived from password for local storage security
      final keyBytes = sha256.convert(utf8.encode(password)).toString();
      _crypto.setKeyFromHex(keyBytes);

      _isAuthenticated = true;

      // Load local image if available
      final prefs = await SharedPreferences.getInstance();
      final imagePath = prefs.getString('profileImagePath');
      if (imagePath != null) {
        _user = _user!.copyWith(profileImagePath: imagePath);
      }

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _api.setToken('');
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
