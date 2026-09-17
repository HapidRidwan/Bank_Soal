import 'package:flutter/material.dart';
import 'package:aplikasi_bank_soal/screens/admin/admin_dashboard.dart';
import 'package:aplikasi_bank_soal/screens/admin/admin_page_route.dart';
import 'package:aplikasi_bank_soal/screens/admin/question_bank_page.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final searchController = TextEditingController();
  final students = const [
    _Student(4, 'Rania Callista', 'XII MIPA 1', '88', true, '62m'),
    _Student(5, 'Budi Santoso', 'XII MIPA 1', '85', true, '55m'),
    _Student(6, 'Siti Rahmawati', 'XII MIPA 1', '81', true, '64m'),
    _Student(7, 'Dimas Pratama', 'XII MIPA 1', '72', false, '75m'),
    _Student(8, 'Kevin Sanjaya', 'XII MIPA 1', '70', false, '82m'),
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FE),
      body: SafeArea(child: Column(children: [_buildHeader(), Expanded(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(20, 17, 20, 24), child: _buildContent()))])),
      bottomNavigationBar: _buildNavigation(),
    );
  }

  Widget _buildHeader() => Container(padding: const EdgeInsets.fromLTRB(20, 14, 20, 18), decoration: const BoxDecoration(color: Color(0xFFFBFBFF), border: Border(bottom: BorderSide(color: Color(0xFFECEEF7)))), child: Row(children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFF2E68E8), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.article_outlined, color: Colors.white, size: 29)), const SizedBox(width: 11), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('ADMIN', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: Color(0xFF075FDC))), Text('Leaderboard', style: TextStyle(fontSize: 24, height: 1, color: Color(0xFF182033)))])), const Icon(Icons.notifications_none_rounded, size: 28, color: Color(0xFF535A6C)), const SizedBox(width: 11), IconButton(onPressed: () {}, style: IconButton.styleFrom(backgroundColor: const Color(0xFF075FDC), foregroundColor: Colors.white), icon: const Icon(Icons.person_outline))]));

  Widget _buildContent() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('EVALUASI AKADEMIK', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1, color: Color(0xFF075FDC))),
    const SizedBox(height: 5),
    const Text('Leaderboard Siswa', style: TextStyle(fontSize: 31, fontWeight: FontWeight.w800, color: Color(0xFF182033))),
    const SizedBox(height: 5),
    const Text('Peringkat & performa ujian peserta terverifikasi otomatis.', style: TextStyle(fontSize: 16, height: 1.45, color: Color(0xFF5D6475))),
    const SizedBox(height: 20),
    _buildSelectors(),
    const SizedBox(height: 24),
    _buildPodium(),
    const SizedBox(height: 25),
    Row(children: [const Expanded(child: Text('Peringkat Lengkap', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: Color(0xFF182033)))), const Text('Menampilkan 4 - 8 dari 36', style: TextStyle(color: Color(0xFF5D6475)))]),
    const SizedBox(height: 12),
    TextField(controller: searchController, onChanged: (_) => setState(() {}), decoration: InputDecoration(hintText: 'Cari nama siswa atau NISN...', prefixIcon: const Icon(Icons.search_rounded), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(vertical: 16))),
    const SizedBox(height: 12),
    ...students.where(_matchesSearch).map(_buildStudentRow),
    const SizedBox(height: 10),
    _buildClassAverage(),
  ]);

  Widget _buildSelectors() => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFEFF2FF), borderRadius: BorderRadius.circular(14)), child: Column(children: [_selector(Icons.assignment_outlined, 'Paket Ujian Aktif', 'PAS Ganjil 2024/2025 - Fisika Terapan'), const SizedBox(height: 10), _selector(Icons.groups_outlined, 'Rombongan Belajar', 'Kelas XII MIPA 1 (36 Siswa)'), const SizedBox(height: 14), Container(height: 48, padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: const Color(0xFFE4E9FF), borderRadius: BorderRadius.circular(8)), child: Row(children: [Expanded(child: _tab('Nilai Ujian', true)), Expanded(child: _tab('Akurasi Soal', false)), Expanded(child: _tab('Rata-rata Sem.', false))]))]));

  Widget _selector(IconData icon, String label, String value) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 6)]), child: Row(children: [Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFFE8EDFF), borderRadius: BorderRadius.circular(7)), child: Icon(icon, color: const Color(0xFF075FDC))), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF5D6475))), Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF182033)))])), const Icon(Icons.keyboard_arrow_down_rounded)]));
  Widget _tab(String label, bool active) => Container(alignment: Alignment.center, decoration: BoxDecoration(color: active ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(5)), child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700, color: active ? const Color(0xFF075FDC) : const Color(0xFF535A6C))));

  Widget _buildPodium() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.emoji_events_outlined, color: Color(0xFFB45309), size: 28),
              SizedBox(width: 7),
              Expanded(child: Text('Top 3 Peraih Skor Tertinggi', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: Color(0xFF182033)))),
              Text('KKM: 75', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF075FDC))),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _podiumStudent('Ahmad Fauzi', '92', '2', const Color(0xFFE1E8FF), 132),
              _podiumStudent('Nadia Safitri', '98', '1', const Color(0xFF075FDC), 175),
              _podiumStudent('Zahra Putri', '90', '3', const Color(0xFFFFDCCF), 120),
            ],
          ),
        ],
      ),
    );
  }

  Widget _podiumStudent(String name, String score, String rank, Color color, double height) {
    final isWinner = rank == '1';
    return Expanded(
      child: Column(
        children: [
          Container(width: 62, height: 62, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(19)), child: const Icon(Icons.person, size: 34, color: Color(0xFF535A6C))),
          const SizedBox(height: 7),
          Text(name, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF182033))),
          const SizedBox(height: 5),
          Container(
            height: height,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: isWinner ? const Color(0xFF075FDC) : const Color(0xFFE1E8FF), borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(score, style: TextStyle(fontSize: 31, fontWeight: FontWeight.w800, color: isWinner ? Colors.white : const Color(0xFF182033))),
                Text('Poin', style: TextStyle(color: isWinner ? Colors.white70 : const Color(0xFF5D6475))),
                const SizedBox(height: 7),
                Text('#$rank', style: TextStyle(fontWeight: FontWeight.w800, color: isWinner ? Colors.white : const Color(0xFF075FDC))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentRow(_Student student) {
    final passedColor = student.passed ? const Color(0xFF7CE9DC) : const Color(0xFFFFD1CE);
    final scoreColor = student.passed ? const Color(0xFF075FDC) : const Color(0xFFB51D2A);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          SizedBox(width: 28, child: Text('#${student.rank}', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF535A6C)))),
          Container(width: 43, height: 43, decoration: BoxDecoration(color: const Color(0xFFE8EDFF), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.person, color: Color(0xFF535A6C))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(student.name, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF182033))), const SizedBox(height: 3), Text('${student.className} • ${student.time}', style: const TextStyle(fontSize: 12, color: Color(0xFF5D6475)))])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4), color: passedColor, child: Text(student.passed ? 'Lulus' : 'Remedial', style: TextStyle(fontSize: 12, color: scoreColor))),
          const SizedBox(width: 9),
          Column(children: [Text(student.score, style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: scoreColor)), const Text('Poin', style: TextStyle(fontSize: 11, color: Color(0xFF5D6475)))]),
        ],
      ),
    );
  }

  Widget _buildClassAverage() => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFEFF2FF), borderRadius: BorderRadius.circular(13)), child: const Row(children: [Icon(Icons.analytics_outlined, color: Color(0xFF087C73)), SizedBox(width: 10), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Rata-rata Kelas', style: TextStyle(color: Color(0xFF5D6475))), SizedBox(height: 3), Text('82.4 / 100', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF182033)))]), Spacer(), Icon(Icons.chevron_left_rounded, size: 30), Text('Halaman 1', style: TextStyle(fontWeight: FontWeight.w700)), Icon(Icons.chevron_right_rounded, size: 30)]));

  Widget _buildNavigation() => NavigationBar(selectedIndex: 2, onDestinationSelected: _navigate, backgroundColor: const Color(0xFFFBFBFF), indicatorColor: Colors.transparent, destinations: const [NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'Dashboard'), NavigationDestination(icon: Icon(Icons.quiz_outlined), label: 'Bank Soal'), NavigationDestination(icon: Icon(Icons.bar_chart_rounded), label: 'Leaderboard'), NavigationDestination(icon: Icon(Icons.person_outline), label: 'Akun')]);
  void _navigate(int index) { if (index == 0) Navigator.pushReplacement(context, adminPageRoute(const AdminDashboardPage())); if (index == 1) Navigator.pushReplacement(context, adminPageRoute(const QuestionBankPage())); }
  bool _matchesSearch(_Student student) => searchController.text.trim().isEmpty || student.name.toLowerCase().contains(searchController.text.trim().toLowerCase());
  BoxDecoration _cardDecoration() => BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: const Color(0xFF9BA9D1).withValues(alpha: .10), blurRadius: 13, offset: const Offset(0, 5))]);
}

class _Student {
  const _Student(this.rank, this.name, this.className, this.score, this.passed, this.time);
  final int rank;
  final String name;
  final String className;
  final String score;
  final bool passed;
  final String time;
}
