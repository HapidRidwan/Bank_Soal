import 'package:aplikasi_bank_soal/widgets/auth/login_widgets.dart';
import 'package:flutter/material.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key, this.email, this.token});

  final String? email;
  final String? token;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final passwordController = TextEditingController();
  final confirmationController = TextEditingController();
  bool obscurePassword = true;
  bool obscureConfirmation = true;
  bool isSaving = false;
  bool passwordUpdated = false;

  @override
  void dispose() {
    passwordController.dispose();
    confirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF6F9FF), Color(0xFFEFF4FF), Color(0xFFF9FBFF)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: const Color(0xFF252B39),
                        tooltip: 'Kembali',
                      ),
                    ),
                    const SizedBox(height: 4),
                    const AuthBrand(),
                    const SizedBox(height: 24),
                    _buildCard(),
                    const SizedBox(height: 24),
                    AuthFooter(
                      linkLabel: 'Sudah ingat kata sandi? Kembali masuk',
                      onLinkTap: () => Navigator.of(context).popUntil(
                        (route) => route.isFirst,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF9FBFF)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9ECF3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFBFD3FF).withValues(alpha: .18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: passwordUpdated ? _buildSuccessState() : _buildForm(),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIcon(Icons.lock_reset_outlined),
        const SizedBox(height: 18),
        const Text(
          'Buat kata sandi baru',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            color: Color(0xFF172033),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.email == null || widget.email!.isEmpty
              ? 'Gunakan kata sandi baru yang kuat untuk melindungi akun Anda.'
              : 'Perbarui kata sandi untuk ${widget.email}.',
          style: const TextStyle(
            fontSize: 14,
            height: 1.6,
            color: Color(0xFF5E6575),
          ),
        ),
        const SizedBox(height: 22),
        _buildLabel('Kata Sandi Baru'),
        const SizedBox(height: 8),
        AuthInputField(
          controller: passwordController,
          hintText: 'Masukkan kata sandi baru',
          icon: Icons.lock_outline,
          obscureText: obscurePassword,
          suffixIcon: _buildVisibilityButton(
            obscurePassword,
            () => setState(() => obscurePassword = !obscurePassword),
          ),
        ),
        const SizedBox(height: 16),
        _buildLabel('Konfirmasi Kata Sandi'),
        const SizedBox(height: 8),
        AuthInputField(
          controller: confirmationController,
          hintText: 'Masukkan ulang kata sandi',
          icon: Icons.lock_reset_outlined,
          obscureText: obscureConfirmation,
          suffixIcon: _buildVisibilityButton(
            obscureConfirmation,
            () => setState(() => obscureConfirmation = !obscureConfirmation),
          ),
        ),
        const SizedBox(height: 12),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, size: 15, color: Color(0xFF596173)),
            SizedBox(width: 5),
            Expanded(
              child: Text(
                'Gunakan minimal 8 karakter dengan kombinasi huruf dan angka.',
                style: TextStyle(fontSize: 11, color: Color(0xFF596173)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: isSaving ? null : _updatePassword,
            style: _buttonStyle(),
            child: isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Simpan Kata Sandi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.check_rounded, size: 20),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState() {
    return Column(
      children: [
        _buildIcon(Icons.check_circle_outline, color: const Color(0xFF0F9F6E)),
        const SizedBox(height: 18),
        const Text(
          'Kata sandi diperbarui',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            color: Color(0xFF172033),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Kata sandi baru Anda sudah aktif. Silakan masuk kembali menggunakan kata sandi tersebut.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF5E6575)),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            style: _buttonStyle(),
            child: const Text(
              'Kembali ke Halaman Masuk',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Color(0xFF252B39),
      ),
    );
  }

  Widget _buildVisibilityButton(bool isObscured, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFFEAF1FF),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          isObscured
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: const Color(0xFF7A8191),
          size: 18,
        ),
      ),
    );
  }

  Widget _buildIcon(IconData icon, {Color color = const Color(0xFF2563EB)}) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: color, size: 27),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: const Color(0xFF2563EB),
      disabledBackgroundColor: const Color(0xFF9AB8F4),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Future<void> _updatePassword() async {
    FocusScope.of(context).unfocus();
    final password = passwordController.text;
    final confirmation = confirmationController.text;

    if (password.length < 8) {
      _showMessage('Kata sandi harus memiliki minimal 8 karakter.');
      return;
    }
    if (password != confirmation) {
      _showMessage('Konfirmasi kata sandi tidak cocok.');
      return;
    }

    setState(() => isSaving = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      isSaving = false;
      passwordUpdated = true;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
