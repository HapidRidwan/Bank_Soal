import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

/// Model untuk paket soal dalam satu mata pelajaran
class ExamPackage {
  const ExamPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.durationMinutes,
    required this.totalSoal,
  });

  final int id;
  final String name;
  final String description;
  final int durationMinutes;
  final int totalSoal;

  factory ExamPackage.fromJson(Map<String, dynamic> json) {
    return ExamPackage(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '-',
      description: json['description'] as String? ?? '',
      durationMinutes: json['durationMinutes'] as int? ?? 60,
      totalSoal: json['totalSoal'] as int? ?? 0,
    );
  }
}

/// Model untuk mata pelajaran beserta daftar paket soalnya
class Subject {
  const Subject({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.paket,
  });

  final int id;
  final String name;
  final String description;
  final String icon;
  final String color;
  final List<ExamPackage> paket;

  factory Subject.fromJson(Map<String, dynamic> json) {
    final rawPaket = json['paket'] as List<dynamic>? ?? [];
    return Subject(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '-',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? 'book',
      color: json['color'] as String? ?? '#3B82F6',
      paket: rawPaket
          .map((e) => ExamPackage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Model untuk statistik siswa
class StudentStats {
  const StudentStats({
    required this.totalExams,
    required this.avgScore,
    required this.bestScore,
    this.rank,
  });

  final int totalExams;
  final double avgScore;
  final double bestScore;
  final int? rank;

  factory StudentStats.fromJson(Map<String, dynamic> json) {
    return StudentStats(
      totalExams: json['totalExams'] as int? ?? 0,
      avgScore: (json['avgScore'] as num?)?.toDouble() ?? 0.0,
      bestScore: (json['bestScore'] as num?)?.toDouble() ?? 0.0,
      rank: json['rank'] as int?,
    );
  }
}

/// Seluruh data dashboard siswa dari API
class StudentDashboard {
  const StudentDashboard({
    required this.fullName,
    required this.username,
    required this.stats,
    required this.subjects,
    required this.totalSubjects,
    required this.totalPaket,
    required this.totalSoal,
  });

  final String fullName;
  final String username;
  final StudentStats stats;
  final List<Subject> subjects;
  final int totalSubjects;
  final int totalPaket;
  final int totalSoal;
}

/// Service untuk mengakses endpoint /api/student
class StudentService {
  StudentService._();

  static const _apiBaseUrl =
      'https://project-colab-production.up.railway.app';
  static const _accessTokenKey = 'access_token';

  /// Ambil data dashboard siswa lengkap dari API
  static Future<StudentDashboard> getDashboard() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_accessTokenKey);

    if (token == null || token.isEmpty) {
      throw Exception('Sesi habis. Silakan login ulang.');
    }

    final client = HttpClient();
    try {
      final request = await client
          .getUrl(Uri.parse('$_apiBaseUrl/api/student/dashboard'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final rawBody = await response.transform(utf8.decoder).join();
      final body = jsonDecode(rawBody) as Map<String, dynamic>;

      if (response.statusCode == 401) {
        throw Exception('Sesi habis. Silakan login ulang.');
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(body['message'] as String? ?? 'Gagal memuat data.');
      }

      // Parse user
      final userMap = body['user'] as Map<String, dynamic>? ?? {};
      final fullName = userMap['fullName'] as String? ??
          userMap['full_name'] as String? ??
          prefs.getString('user_full_name') ??
          'Siswa';
      final username = userMap['username'] as String? ??
          prefs.getString('user_username') ??
          '-';

      // Parse stats
      final statsMap = body['stats'] as Map<String, dynamic>? ?? {};
      final stats = StudentStats.fromJson(statsMap);

      // Parse subjects
      final rawSubjects = body['subjects'] as List<dynamic>? ?? [];
      final subjects = rawSubjects
          .map((e) => Subject.fromJson(e as Map<String, dynamic>))
          .toList();

      // Parse meta
      final metaMap = body['meta'] as Map<String, dynamic>? ?? {};

      return StudentDashboard(
        fullName: fullName,
        username: username,
        stats: stats,
        subjects: subjects,
        totalSubjects: metaMap['totalSubjects'] as int? ?? subjects.length,
        totalPaket: metaMap['totalPaket'] as int? ?? 0,
        totalSoal: metaMap['totalSoal'] as int? ?? 0,
      );
    } finally {
      client.close();
    }
  }
}
