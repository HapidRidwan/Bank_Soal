import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class AuthUser {
  const AuthUser({
    required this.role,
    this.id,
    this.username,
    this.email,
    this.fullName,
    this.avatarUrl,
  });

  final String role;
  final int? id;
  final String? username;
  final String? email;
  final String? fullName;
  final String? avatarUrl;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final role = json['role'] as String? ?? 'user';
    return AuthUser(
      role: role,
      id: json['id'] as int?,
      username: json['username'] as String?,
      email: json['email'] as String?,
      fullName: json['fullName'] as String? ?? json['full_name'] as String?,
      avatarUrl: json['avatarUrl'] as String? ?? json['avatar_url'] as String?,
    );
  }
}

class AuthService {
  AuthService._();

  /// Base URL API Railway production
  static const _apiBaseUrl =
      'https://project-colab-production.up.railway.app';

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userRoleKey = 'user_role';

  static Future<AuthUser> login({
    required String identity,
    required String password,
  }) async {
    final client = HttpClient();
    try {
      // Endpoint: POST /api/auth/login (Node.js/Express backend Railway)
      // Response: { accessToken, refreshToken, user: { id, username, email, fullName, role, ... } }
      final request =
          await client.postUrl(Uri.parse('$_apiBaseUrl/api/auth/login'));
      request.headers.contentType = ContentType.json;
      request.headers.set('Accept', 'application/json');
      // Field: identity (email/username) & password
      request.write(jsonEncode({'identity': identity, 'password': password}));

      final response = await request.close();
      final rawBody = await response.transform(utf8.decoder).join();
      final body = jsonDecode(rawBody) as Map<String, dynamic>;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = body['message'] as String? ?? 'Login gagal.';
        throw Exception(message);
      }

      final preferences = await SharedPreferences.getInstance();

      // Token ada di root: body['accessToken']
      final token = body['accessToken'] as String? ??
          body['access_token'] as String? ??
          body['token'] as String?;
      if (token != null) {
        await preferences.setString(_accessTokenKey, token);
      }

      // Refresh token di root: body['refreshToken']
      final refreshToken = body['refreshToken'] as String? ??
          body['refresh_token'] as String?;
      if (refreshToken != null) {
        await preferences.setString(_refreshTokenKey, refreshToken);
      }

      // User object di root: body['user']
      final userData = body['user'] as Map<String, dynamic>? ?? body;
      final authUser = AuthUser.fromJson(userData);

      // Simpan data user ke preferences
      await preferences.setString(_userRoleKey, authUser.role);
      if (authUser.fullName != null) {
        await preferences.setString('user_full_name', authUser.fullName!);
      }
      if (authUser.username != null) {
        await preferences.setString('user_username', authUser.username!);
      }
      if (authUser.email != null) {
        await preferences.setString('user_email', authUser.email!);
      }

      return authUser;
    } finally {
      client.close();
    }
  }

  /// Ambil token yang tersimpan
  static Future<String?> getToken() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_accessTokenKey);
  }

  /// Ambil role user yang tersimpan
  static Future<String?> getUserRole() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_userRoleKey);
  }

  /// Logout - hapus semua data sesi
  static Future<void> logout() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_accessTokenKey);
    await preferences.remove(_refreshTokenKey);
    await preferences.remove(_userRoleKey);
  }
}