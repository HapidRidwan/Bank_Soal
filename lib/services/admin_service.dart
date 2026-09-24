import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

/// Statistik ringkasan untuk dashboard admin
class AdminStats {
  const AdminStats({
    required this.totalSoal,
    required this.packageAktif,
    required this.mataPelajaran,
    required this.totalSiswa,
  });

  final int totalSoal;
  final int packageAktif;
  final int mataPelajaran;
  final int totalSiswa;

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalSoal: json['totalSoal'] as int? ?? 0,
      packageAktif: json['packageAktif'] as int? ?? 0,
      mataPelajaran: json['mataPelajaran'] as int? ?? 0,
      totalSiswa: json['totalSiswa'] as int? ?? 0,
    );
  }
}

/// Item package untuk ringkasan dan inventory
class AdminPackageItem {
  const AdminPackageItem({
    required this.id,
    required this.paketName,
    required this.subjectName,
    required this.totalSoal,
    required this.createdAt,
    this.description = '',
    this.durationMinutes = 60,
    this.isActive = true,
  });

  final int id;
  final String paketName;
  final String subjectName;
  final int totalSoal;
  final String createdAt;
  final String description;
  final int durationMinutes;
  final bool isActive;

  factory AdminPackageItem.fromJson(Map<String, dynamic> json) {
    return AdminPackageItem(
      id: json['id'] as int? ?? 0,
      paketName: json['paketName'] as String? ?? '-',
      subjectName: json['subjectName'] as String? ?? '-',
      totalSoal: json['totalSoal'] as int? ?? 0,
      createdAt: json['createdAt'] as String? ?? '-',
      description: json['description'] as String? ?? '',
      durationMinutes: json['durationMinutes'] as int? ?? 60,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

/// Log pengerjaan ujian per siswa
class AdminStudentExamLog {
  const AdminStudentExamLog({
    required this.name,
    required this.email,
    required this.nilai,
    required this.status,
    required this.completedAt,
  });

  final String name;
  final String email;
  final String nilai;
  final String status;
  final String completedAt;

  factory AdminStudentExamLog.fromJson(Map<String, dynamic> json) {
    final rawNilai = json['nilai'];
    final nilaiStr = rawNilai != null ? rawNilai.toString() : '0';
    return AdminStudentExamLog(
      name: json['name'] as String? ?? '-',
      email: json['email'] as String? ?? '-',
      nilai: nilaiStr,
      status: json['status'] as String? ?? 'Belum Lulus',
      completedAt: json['completedAt'] as String? ?? '-',
    );
  }
}

/// Rekap nilai per package
class AdminRekapItem {
  const AdminRekapItem({
    required this.id,
    required this.paketName,
    required this.subjectName,
    required this.siswaMengerjakan,
    required this.rataRata,
    required this.students,
  });

  final int id;
  final String paketName;
  final String subjectName;
  final int siswaMengerjakan;
  final String rataRata;
  final List<AdminStudentExamLog> students;

  factory AdminRekapItem.fromJson(Map<String, dynamic> json) {
    final rawAvg = json['avgScore'];
    final avgStr = rawAvg != null ? rawAvg.toString() : '-';
    final rawStudents = json['students'] as List<dynamic>? ?? [];

    return AdminRekapItem(
      id: json['id'] as int? ?? 0,
      paketName: json['paketName'] as String? ?? '-',
      subjectName: json['subjectName'] as String? ?? '-',
      siswaMengerjakan: json['siswaMengerjakan'] as int? ?? 0,
      rataRata: avgStr,
      students: rawStudents
          .map((e) => AdminStudentExamLog.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Seluruh data dashboard admin
class AdminDashboardData {
  const AdminDashboardData({
    required this.adminName,
    required this.adminRole,
    required this.stats,
    required this.recentPackages,
  });

  final String adminName;
  final String adminRole;
  final AdminStats stats;
  final List<AdminPackageItem> recentPackages;
}

/// Service untuk memanggil API admin di Railway
class AdminService {
  AdminService._();

  static const _apiBaseUrl = 'https://project-colab-production.up.railway.app';
  static const _accessTokenKey = 'access_token';

  static Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_accessTokenKey);
    if (token == null || token.isEmpty) {
      throw Exception('Sesi habis. Silakan login kembali sebagai admin.');
    }
    return token;
  }

  /// Ambil data Ringkasan Dashboard Admin (Stats + Recent Packages)
  static Future<AdminDashboardData> getDashboard() async {
    final token = await _getToken();
    final prefs = await SharedPreferences.getInstance();
    final client = HttpClient();

    try {
      final request = await client.getUrl(Uri.parse('$_apiBaseUrl/api/admin/dashboard'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final rawBody = await response.transform(utf8.decoder).join();
      final body = jsonDecode(rawBody) as Map<String, dynamic>;

      if (response.statusCode == 401) {
        throw Exception('Sesi habis. Silakan login kembali.');
      }
      if (response.statusCode == 403) {
        throw Exception('Akses ditolak. Akun bukan Admin/Guru.');
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(body['message'] as String? ?? 'Gagal memuat dashboard admin.');
      }

      final adminMap = body['admin'] as Map<String, dynamic>? ?? {};
      final name = adminMap['fullName'] as String? ??
          adminMap['username'] as String? ??
          prefs.getString('user_full_name') ??
          prefs.getString('user_username') ??
          'Admin';
      final role = adminMap['role'] as String? ??
          prefs.getString('user_role') ??
          'Admin';

      final statsMap = body['stats'] as Map<String, dynamic>? ?? {};
      final stats = AdminStats.fromJson(statsMap);

      final recentList = body['recentPackages'] as List<dynamic>? ?? [];
      final recentPackages = recentList
          .map((e) => AdminPackageItem.fromJson(e as Map<String, dynamic>))
          .toList();

      return AdminDashboardData(
        adminName: name,
        adminRole: role,
        stats: stats,
        recentPackages: recentPackages,
      );
    } finally {
      client.close();
    }
  }

  /// Ambil data seluruh package soal (Inventory)
  static Future<List<AdminPackageItem>> getInventory() async {
    final token = await _getToken();
    final client = HttpClient();

    try {
      final request = await client.getUrl(Uri.parse('$_apiBaseUrl/api/admin/inventory'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final rawBody = await response.transform(utf8.decoder).join();
      final body = jsonDecode(rawBody) as Map<String, dynamic>;

      if (response.statusCode == 401) {
        throw Exception('Sesi habis. Silakan login kembali.');
      }
      if (response.statusCode == 403) {
        throw Exception('Akses ditolak. Akun bukan Admin/Guru.');
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(body['message'] as String? ?? 'Gagal memuat inventory.');
      }

      final rawPackages = body['packages'] as List<dynamic>? ?? [];
      return rawPackages
          .map((e) => AdminPackageItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } finally {
      client.close();
    }
  }

  /// Ambil data Rekap Nilai Siswa
  static Future<List<AdminRekapItem>> getRekap() async {
    final token = await _getToken();
    final client = HttpClient();

    try {
      final request = await client.getUrl(Uri.parse('$_apiBaseUrl/api/admin/rekap'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final rawBody = await response.transform(utf8.decoder).join();
      final body = jsonDecode(rawBody) as Map<String, dynamic>;

      if (response.statusCode == 401) {
        throw Exception('Sesi habis. Silakan login kembali.');
      }
      if (response.statusCode == 403) {
        throw Exception('Akses ditolak. Akun bukan Admin/Guru.');
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(body['message'] as String? ?? 'Gagal memuat rekap nilai.');
      }

      final rawRekap = body['rekap'] as List<dynamic>? ?? [];
      return rawRekap
          .map((e) => AdminRekapItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } finally {
      client.close();
    }
  }
}
