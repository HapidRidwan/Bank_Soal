import 'package:flutter/material.dart';

class AddQuestionPage extends StatefulWidget {
  const AddQuestionPage({super.key});

  @override
  State<AddQuestionPage> createState() => _AddQuestionPageState();
}

class _AddQuestionPageState extends State<AddQuestionPage>
    with SingleTickerProviderStateMixin {
  final questionController = TextEditingController();
  final explanationController = TextEditingController();
  final optionControllers = List.generate(4, (_) => TextEditingController());
  late final AnimationController animationController;
  String subject = 'Fisika';
  String questionType = 'Pilihan Ganda';
  String difficulty = 'Sedang';
  int correctOption = 0;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    questionController.dispose();
    explanationController.dispose();
    for (final controller in optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBFBFF),
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Tambah Soal',
          style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF182033)),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        top: false,
        child: FadeTransition(
          opacity: CurvedAnimation(parent: animationController, curve: Curves.easeOut),
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, .04), end: Offset.zero)
                .animate(CurvedAnimation(parent: animationController, curve: Curves.easeOutCubic)),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              children: [
                _buildIntro(),
                const SizedBox(height: 16),
                _buildBasicInfo(),
                const SizedBox(height: 16),
                _buildQuestionEditor(),
                const SizedBox(height: 16),
                if (questionType == 'Pilihan Ganda') _buildOptions(),
                if (questionType == 'Pilihan Ganda') const SizedBox(height: 16),
                _buildExplanation(),
                const SizedBox(height: 22),
                _buildActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntro() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EDFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.auto_awesome_rounded, color: Color(0xFF075FDC), size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Buat soal yang jelas, terukur, dan siap digunakan dalam ujian.',
              style: TextStyle(fontSize: 15, height: 1.4, color: Color(0xFF33405C)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return _section(
      title: 'Informasi Dasar',
      icon: Icons.tune_rounded,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _dropdown('Mata Pelajaran', subject, ['Fisika', 'Matematika', 'Biologi', 'Bahasa Indonesia'], (value) => setState(() => subject = value!))),
              const SizedBox(width: 10),
              Expanded(child: _dropdown('Tingkat', difficulty, ['Mudah', 'Sedang', 'Tinggi'], (value) => setState(() => difficulty = value!))),
            ],
          ),
          const SizedBox(height: 14),
          _dropdown('Tipe Soal', questionType, ['Pilihan Ganda', 'Essay'], (value) => setState(() => questionType = value!)),
        ],
      ),
    );
  }

  Widget _buildQuestionEditor() {
    return _section(
      title: 'Pertanyaan',
      icon: Icons.help_outline_rounded,
      child: _input(questionController, 'Tulis pertanyaan soal di sini...', maxLines: 6),
    );
  }

  Widget _buildOptions() {
    return _section(
      title: 'Pilihan Jawaban',
      icon: Icons.list_alt_rounded,
      trailing: const Text('Pilih kunci jawaban', style: TextStyle(fontSize: 12, color: Color(0xFF7A8191))),
      child: Column(
        children: List.generate(optionControllers.length, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: index == optionControllers.length - 1 ? 0 : 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => correctOption = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 34,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: correctOption == index ? const Color(0xFF075FDC) : const Color(0xFFE8EDFF),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      String.fromCharCode(65 + index),
                      style: TextStyle(fontWeight: FontWeight.w800, color: correctOption == index ? Colors.white : const Color(0xFF535A6C)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: _input(optionControllers[index], 'Isi pilihan ${String.fromCharCode(65 + index)}')),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildExplanation() {
    return _section(
      title: 'Pembahasan',
      icon: Icons.menu_book_outlined,
      child: _input(explanationController, 'Tambahkan pembahasan atau rubrik penilaian...', maxLines: 4),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15), foregroundColor: const Color(0xFF535A6C), side: const BorderSide(color: Color(0xFFD9DFEF)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11))),
            child: const Text('Batal'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _saveQuestion,
            icon: const Icon(Icons.check_rounded),
            label: const Text('Simpan Soal'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15), backgroundColor: const Color(0xFF075FDC), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11))),
          ),
        ),
      ],
    );
  }

  Widget _section({required String title, required IconData icon, required Widget child, Widget? trailing}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0xFF9BA9D1).withValues(alpha: .1), blurRadius: 14, offset: const Offset(0, 5))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(icon, size: 21, color: const Color(0xFF075FDC)), const SizedBox(width: 8), Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF182033)))), ..._optionalWidget(trailing)]), const SizedBox(height: 14), child]),
    );
  }

  List<Widget> _optionalWidget(Widget? widget) => widget == null ? const [] : [widget];

  Widget _dropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label, filled: true, fillColor: const Color(0xFFF7F8FE), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
    );
  }

  Widget _input(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextField(controller: controller, maxLines: maxLines, decoration: InputDecoration(hintText: hint, filled: true, fillColor: const Color(0xFFF7F8FE), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none), contentPadding: const EdgeInsets.all(14)));
  }

  void _saveQuestion() {
    if (questionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pertanyaan wajib diisi.')));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Soal berhasil disimpan.')));
    Future<void>.delayed(const Duration(milliseconds: 500), () {
      if (mounted) Navigator.of(context).pop();
    });
  }
}
