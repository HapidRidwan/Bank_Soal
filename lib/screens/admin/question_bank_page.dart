import 'package:flutter/material.dart';
import 'package:aplikasi_bank_soal/screens/admin/add_question_page.dart';
import 'package:aplikasi_bank_soal/screens/admin/admin_dashboard.dart';
import 'package:aplikasi_bank_soal/screens/admin/admin_page_route.dart';
import 'package:aplikasi_bank_soal/screens/admin/leaderboard_page.dart';

class QuestionBankPage extends StatefulWidget {
  const QuestionBankPage({super.key});

  @override
  State<QuestionBankPage> createState() => _QuestionBankPageState();
}

class _QuestionBankPageState extends State<QuestionBankPage> {
  final searchController = TextEditingController();
  int selectedCategory = 0;
  String selectedClass = 'Kelas XII';
  String selectedType = 'Semua tipe';
  final categories = const ['Semua (2.150)', 'Fisika (420)', 'Matematika (560)', 'Biologi (310)'];

  static const questions = [
    _Question('Fisika', 'FSK-XII-2024-018', 'Sedang', 'Sebuah benda bermassa 2 kg dilepaskan dari puncak bidang miring licin dengan kemiringan 30° terhadap bidang horizontal. Jika percepatan gravitasi 10 m/s², berapakah percepatannya?', ['5 m/s²', '5√2 m/s²', '10 m/s²', '10√2 m/s²'], 1, '4 Poin'),
    _Question('Matematika', 'MTK-XII-2024-001', 'Tinggi', "Kalkulus & Aturan Rantai: Tentukan turunan pertama f'(x) dari fungsi aljabar f(x) = (3x² - 5)⁴ untuk setiap x bilangan real!", ["f'(x) = 24x(3x² - 5)³", "f'(x) = 12x(3x² - 5)³"], 0, '5 Poin'),
    _Question('Biologi', 'BIO-XII-2024-009', 'Tinggi', 'Transkripsi Sel & Modifikasi: Pada proses sintesis protein eukariotik, jelaskan 3 tahapan pematangan pra-mRNA menjadi mRNA matang.', [], 0, '10 Poin'),
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
      body: SafeArea(child: Column(children: [_buildHeader(), Expanded(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(16, 18, 16, 24), child: _buildContent()))])),
      bottomNavigationBar: _buildNavigation(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      decoration: const BoxDecoration(color: Color(0xFFFBFBFF), border: Border(bottom: BorderSide(color: Color(0xFFECEEF7)))),
      child: Row(children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFF2E68E8), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.article_outlined, color: Colors.white, size: 29)),
        const SizedBox(width: 11),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('ADMIN', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: Color(0xFF075FDC))), Text('Bank Soal', style: TextStyle(fontSize: 24, height: 1, color: Color(0xFF182033)))])),
        IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded, size: 28, color: Color(0xFF535A6C))),
        IconButton(onPressed: () {}, style: IconButton.styleFrom(backgroundColor: const Color(0xFF075FDC), foregroundColor: Colors.white), icon: const Icon(Icons.person_outline)),
      ]),
    );
  }

  Widget _buildContent() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Katalog Bank Soal', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF182033))),
                SizedBox(height: 4),
                Text('2.150 Butir Soal Terdaftar', style: TextStyle(fontSize: 17, color: Color(0xFF5D6475))),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(context, adminPageRoute(const AddQuestionPage())),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Tambah Soal'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E68E8), foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11))),
          ),
        ],
      ),
      const SizedBox(height: 18),
      Row(children: [
        Expanded(child: TextField(controller: searchController, onChanged: (_) => setState(() {}), decoration: InputDecoration(hintText: 'Cari butir soal, topik, atau mata pelajaran...', prefixIcon: const Icon(Icons.search_rounded), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(vertical: 17)))),
        const SizedBox(width: 10),
        IconButton(onPressed: () => _showMessage('Filter lanjutan'), style: IconButton.styleFrom(fixedSize: const Size(52, 52), backgroundColor: const Color(0xFFE8EDFF), foregroundColor: const Color(0xFF075FDC)), icon: const Icon(Icons.tune_rounded)),
      ]),
      const SizedBox(height: 16),
      SizedBox(height: 48, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: categories.length, separatorBuilder: (_, _) => const SizedBox(width: 8), itemBuilder: (context, index) => ChoiceChip(label: Text(categories[index]), selected: selectedCategory == index, onSelected: (_) => setState(() => selectedCategory = index), selectedColor: const Color(0xFF2E68E8), labelStyle: TextStyle(fontWeight: FontWeight.w700, color: selectedCategory == index ? Colors.white : const Color(0xFF535A6C)), backgroundColor: Colors.white, side: BorderSide.none, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8)))),
      const SizedBox(height: 14),
      Row(children: [Expanded(child: _filterButton(selectedClass, Icons.school_outlined, () => _chooseFilter('Kelas'))), const SizedBox(width: 8), Expanded(child: _filterButton(selectedType, Icons.category_outlined, () => _chooseFilter('Tipe')))]),
      const SizedBox(height: 18),
      ...questions.where(_matchesSearch).map(_buildQuestionCard),
      const SizedBox(height: 4),
      _buildLoadMore(),
    ]);
  }

  Widget _filterButton(String text, IconData icon, VoidCallback onTap) {
    return OutlinedButton.icon(onPressed: onTap, icon: Icon(icon, size: 18), label: Expanded(child: Text(text, overflow: TextOverflow.ellipsis)), style: OutlinedButton.styleFrom(alignment: Alignment.centerLeft, foregroundColor: const Color(0xFF535A6C), backgroundColor: const Color(0xFFEFF2FF), side: BorderSide.none, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14)));
  }

  Widget _buildQuestionCard(_Question question) {
    return Container(margin: const EdgeInsets.only(bottom: 14), padding: const EdgeInsets.fromLTRB(18, 16, 18, 15), decoration: _cardDecoration(), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: BoxDecoration(color: const Color(0xFFE8EDFF), borderRadius: BorderRadius.circular(6)), child: Text(question.subject, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF075FDC)))), const SizedBox(width: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: BoxDecoration(color: const Color(0xFFEFF2FF), borderRadius: BorderRadius.circular(6)), child: Text(question.code, style: const TextStyle(fontSize: 12, color: Color(0xFF5D6475)))), const SizedBox(width: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: BoxDecoration(color: const Color(0xFF7CE9DC), borderRadius: BorderRadius.circular(6)), child: const Text('• Aktif', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF087C73)))), const Spacer(), IconButton(onPressed: () => _showMessage('Menu soal'), icon: const Icon(Icons.more_vert_rounded))]),
      const SizedBox(height: 12),
      Row(children: [Text(question.points, style: const TextStyle(color: Color(0xFF535A6C))), const SizedBox(width: 14), const Icon(Icons.trending_up_rounded, size: 18, color: Color(0xFFB51D2A)), const SizedBox(width: 4), Text('Tingkat: ${question.difficulty}', style: const TextStyle(color: Color(0xFF535A6C)))]),
      const SizedBox(height: 12),
      Text(question.prompt, style: const TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF182033))),
      if (question.options.isNotEmpty) ...[const SizedBox(height: 14), GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 7, mainAxisSpacing: 7, childAspectRatio: 3.8), itemCount: question.options.length, itemBuilder: (_, index) => Container(padding: const EdgeInsets.symmetric(horizontal: 10), decoration: BoxDecoration(color: index == question.answerIndex ? const Color(0xFF075FDC) : const Color(0xFFEFF2FF), borderRadius: BorderRadius.circular(7)), alignment: Alignment.centerLeft, child: Text('${String.fromCharCode(65 + index)}  ${question.options[index]}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w600, color: index == question.answerIndex ? Colors.white : const Color(0xFF535A6C)))))],
      const SizedBox(height: 14),
      const Divider(color: Color(0xFFE6EAF4)),
      Row(children: [const Text('Diperbarui 2 jam lalu', style: TextStyle(color: Color(0xFF7A8191))), const Spacer(), IconButton(onPressed: () {}, icon: const Icon(Icons.visibility_outlined, color: Color(0xFF535A6C))), IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined, color: Color(0xFF075FDC))), IconButton(onPressed: () {}, icon: const Icon(Icons.delete_outline, color: Color(0xFFB51D2A)))]),
    ]));
  }

  Widget _buildLoadMore() => Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16), decoration: BoxDecoration(color: const Color(0xFFE8EDFF), borderRadius: BorderRadius.circular(12)), child: const Text('⌄ Muat Lebih Banyak (15 dari 2.150)', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF075FDC))));

  Widget _buildNavigation() => NavigationBar(selectedIndex: 1, onDestinationSelected: _navigate, backgroundColor: const Color(0xFFFBFBFF), indicatorColor: Colors.transparent, destinations: const [NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'Dashboard'), NavigationDestination(icon: Icon(Icons.quiz_outlined), label: 'Bank Soal'), NavigationDestination(icon: Icon(Icons.bar_chart_rounded), label: 'Leaderboard'), NavigationDestination(icon: Icon(Icons.person_outline), label: 'Akun')]);

  void _navigate(int index) { if (index == 0) Navigator.pushReplacement(context, adminPageRoute(const AdminDashboardPage())); if (index == 2) Navigator.pushReplacement(context, adminPageRoute(const LeaderboardPage())); }
  void _chooseFilter(String type) { _showMessage('Pilih $type'); }
  bool _matchesSearch(_Question question) => searchController.text.trim().isEmpty || '${question.subject} ${question.code} ${question.prompt}'.toLowerCase().contains(searchController.text.trim().toLowerCase());
  void _showMessage(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating, margin: const EdgeInsets.all(16)));
  BoxDecoration _cardDecoration() => BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: const Color(0xFF9BA9D1).withValues(alpha: .10), blurRadius: 13, offset: const Offset(0, 5))]);
}

class _Question {
  const _Question(this.subject, this.code, this.difficulty, this.prompt, this.options, this.answerIndex, this.points);
  final String subject;
  final String code;
  final String difficulty;
  final String prompt;
  final List<String> options;
  final int answerIndex;
  final String points;
}
