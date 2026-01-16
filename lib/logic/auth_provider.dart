import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../data/services/api_service.dart';
import '../data/services/crypto_service.dart';

class UserProfile {
  final String id;
  final String email;
  final String name;
  final String language;

  UserProfile({required this.id, required this.email, required this.name, required this.language});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      email: json['email'],
      name: json['name'] ?? '',
      language: json['language'] ?? 'fr',
    );
  }
}

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final CryptoService _crypto = CryptoService();
  
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;
  UserProfile? _user;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  UserProfile? get user => _user;
  ApiService get api => _api;

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
        'password': password
      });
      
      _api.setToken(response['access_token']);
      _user = UserProfile.fromJson(response['user']);
      
      // Initialize Crypto with a key derived from password for local storage security
      final keyBytes = sha256.convert(utf8.encode(password)).toString();
      _crypto.setKeyFromHex(keyBytes);
      
      _isAuthenticated = true;
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
