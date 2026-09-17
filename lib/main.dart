import 'package:aplikasi_bank_soal/screens/auth/login.dart';
import 'package:aplikasi_bank_soal/screens/admin/admin_dashboard.dart';
import 'package:aplikasi_bank_soal/screens/admin/leaderboard_page.dart';
import 'package:aplikasi_bank_soal/screens/admin/question_bank_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bank Soal',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
        ),
      ),
      home: const LoginPage(),
      routes: {
        '/admin': (_) => const AdminDashboardPage(),
        '/admin/questions': (_) => const QuestionBankPage(),
        '/admin/leaderboard': (_) => const LeaderboardPage(),
      },
    );
  }
}
