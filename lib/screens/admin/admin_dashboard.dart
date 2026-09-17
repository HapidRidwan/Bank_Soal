import 'package:flutter/material.dart';
import 'package:aplikasi_bank_soal/screens/admin/admin_page_route.dart';
import 'package:aplikasi_bank_soal/screens/admin/leaderboard_page.dart';
import 'package:aplikasi_bank_soal/screens/admin/question_bank_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int selectedIndex = 0;

  static const recentSubmissions = [
    _Submission('Ahmad Fauzi', 'XII MIPA 1', 'Fisika Mandiri', '92', '10m lalu', true),
    _Submission('Rania Callista', 'XII IPS 2', 'Ekonomi Makro', '88', '24m lalu', true),
    _Submission('Dimas Pratama', 'XI MIPA 3', 'Matematika Wajib', '74', '45m lalu', false),
    _Submission('Nadia Safitri', 'XII MIPA 4', 'Biologi Sel', '96', '1j lalu', true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FE),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 22),
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      decoration: const BoxDecoration(
        color: Color(0xFFFBFBFF),
        border: Border(bottom: BorderSide(color: Color(0xFFECEEF7))),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF2E68E8),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.article_outlined, color: Colors.white, size: 29),
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ADMIN',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: Color(0xFF075FDC),
                  ),
                ),
                Text(
                  'Bank Soal',
                  style: TextStyle(fontSize: 24, height: 1, color: Color(0xFF182033)),
                ),
              ],
            ),
          ),
          _iconButton(
            Icons.notifications_none_rounded,
            () => _showMessage('Tidak ada notifikasi baru'),
            background: Colors.transparent,
            foreground: const Color(0xFF535A6C),
          ),
          const SizedBox(width: 7),
          _iconButton(Icons.person_outline, () => _showMessage('Profil admin')),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Halo, Admin Siti 👋',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w800,
            color: Color(0xFF182033),
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'Kamis, 24 Okt 2024 • SMAN 1 Jakarta',
          style: TextStyle(fontSize: 16, color: Color(0xFF5D6475)),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _buildStatCard('Soal Aktif', '2,150', '12  Bank  Paket', Icons.quiz_outlined, const Color(0xFFE8EDFF))),
            const SizedBox(width: 14),
            Expanded(child: _buildStatCard('Ujian Berjalan', '4 Sesi', '348 Siswa Online', Icons.wifi_tethering_rounded, const Color(0xFF7CE9DC), accent: const Color(0xFF087C73))),
          ],
        ),
        const SizedBox(height: 22),
        _buildIntegrityCard(),
        const SizedBox(height: 30),
        Row(
          children: [
            Container(width: 5, height: 28, decoration: BoxDecoration(color: const Color(0xFF0964D8), borderRadius: BorderRadius.circular(4))),
            const SizedBox(width: 9),
            const Expanded(child: Text('Pengumpulan Ujian Terbaru', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF182033)))),
            TextButton(onPressed: () => _showMessage('Membuka semua pengumpulan'), child: const Text('Lihat Semua', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800))),
          ],
        ),
        const SizedBox(height: 14),
        ...recentSubmissions.map(_buildSubmissionCard),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String detail, IconData icon, Color iconBackground, {Color accent = const Color(0xFF182033)}) {
    return Container(
      constraints: const BoxConstraints(minHeight: 162),
      padding: const EdgeInsets.fromLTRB(18, 20, 14, 16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF535A6C)))),
              Container(width: 44, height: 44, decoration: BoxDecoration(color: iconBackground, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: const Color(0xFF075FDC), size: 27)),
            ],
          ),
          const SizedBox(height: 18),
          Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: accent)),
          const SizedBox(height: 5),
          Text(detail, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: accent)),
        ],
      ),
    );
  }

  Widget _buildIntegrityCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(color: const Color(0xFFEFF2FF), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(width: 58, height: 58, decoration: BoxDecoration(color: const Color(0xFF075FDC), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.verified_outlined, color: Colors.white, size: 34)),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Integritas CBT Normal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF182033))),
              SizedBox(height: 7),
              Text('Seluruh room ujian berjalan tertib tanpa kendala server.', style: TextStyle(fontSize: 15, height: 1.35, color: Color(0xFF5D6475))),
            ]),
          ),
          const Text('99.8%', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: Color(0xFF075FDC))),
        ],
      ),
    );
  }

  Widget _buildSubmissionCard(_Submission submission) {
    final statusColor = submission.passed ? const Color(0xFF65E4D2) : const Color(0xFFFFD1CE);
    final scoreColor = submission.passed ? const Color(0xFF075FDC) : const Color(0xFFB51D2A);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              Container(width: 52, height: 52, decoration: BoxDecoration(color: const Color(0xFFE9EDFF), borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.person_outline, color: Color(0xFF535A6C), size: 30)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(submission.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF182033))), const SizedBox(height: 4), Text('${submission.className} • ${submission.subject}', style: const TextStyle(fontSize: 15, color: Color(0xFF5D6475)))])),
              Container(padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7), decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20)), child: Text(submission.passed ? 'Lulus' : 'Remedial', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: submission.passed ? const Color(0xFF075F70) : const Color(0xFFB51D2A)))),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1, color: Color(0xFFE3E8F5))),
          Row(children: [Text.rich(TextSpan(text: 'Nilai: ', style: const TextStyle(fontSize: 16, color: Color(0xFF5D6475)), children: [TextSpan(text: submission.score, style: TextStyle(fontWeight: FontWeight.w800, color: scoreColor)), const TextSpan(text: ' /100', style: TextStyle(color: Color(0xFF5D6475)))])), const Spacer(), const Icon(Icons.access_time_rounded, size: 20, color: Color(0xFF5D6475)), const SizedBox(width: 5), Text(submission.time, style: const TextStyle(fontSize: 15, color: Color(0xFF5D6475)))]),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    const items = [(Icons.grid_view_rounded, 'Dashboard'), (Icons.quiz_outlined, 'Bank Soal'), (Icons.bar_chart_rounded, 'Leaderboard'), (Icons.person_outline, 'Akun')];
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        setState(() => selectedIndex = index);
        if (index == 1) Navigator.pushReplacement(context, adminPageRoute(const QuestionBankPage()));
        if (index == 2) Navigator.pushReplacement(context, adminPageRoute(const LeaderboardPage()));
      },
      backgroundColor: const Color(0xFFFBFBFF),
      indicatorColor: Colors.transparent,
      destinations: items.map((item) => NavigationDestination(icon: Icon(item.$1), selectedIcon: Icon(item.$1, color: const Color(0xFF075FDC)), label: item.$2)).toList(),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap, {Color background = const Color(0xFF075FDC), Color foreground = Colors.white}) {
    return IconButton(onPressed: onTap, style: IconButton.styleFrom(backgroundColor: background, foregroundColor: foreground, fixedSize: const Size(58, 58)), icon: Icon(icon, size: 29));
  }

  BoxDecoration _cardDecoration() => BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0xFF9BA9D1).withValues(alpha: .10), blurRadius: 14, offset: const Offset(0, 5))]);

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating, margin: const EdgeInsets.all(16)));
  }
}

class _Submission {
  const _Submission(this.name, this.className, this.subject, this.score, this.time, this.passed);

  final String name;
  final String className;
  final String subject;
  final String score;
  final String time;
  final bool passed;
}
