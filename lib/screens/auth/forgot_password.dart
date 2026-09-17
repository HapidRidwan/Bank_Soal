import 'package:aplikasi_bank_soal/screens/auth/reset_password.dart';
import 'package:aplikasi_bank_soal/widgets/auth/login_widgets.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();
  bool isSending = false;
  bool linkSent = false;

  @override
  void dispose() {
    emailController.dispose();
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
                      linkLabel: 'Ingat kata sandi? Kembali masuk',
                      onLinkTap: () => Navigator.of(context).pop(),
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
      child: linkSent ? _buildSuccessState() : _buildRequestState(),
    );
  }

  Widget _buildRequestState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIcon(Icons.mark_email_read_outlined),
        const SizedBox(height: 18),
        const Text(
          'Lupa kata sandi?',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            color: Color(0xFF172033),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Masukkan email akun Anda. Kami akan mengirimkan link untuk membuat kata sandi baru.',
          style: TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF5E6575)),
        ),
        const SizedBox(height: 22),
        const Text(
          'Email',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF252B39),
          ),
        ),
        const SizedBox(height: 8),
        AuthInputField(
          controller: emailController,
          hintText: 'Masukkan email terdaftar',
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: isSending ? null : _sendResetLink,
            style: _buttonStyle(),
            child: isSending
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
                        'Kirim Link Reset',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.send_outlined, size: 19),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIcon(Icons.check_rounded, color: const Color(0xFF0F9F6E)),
        const SizedBox(height: 18),
        const Text(
          'Link reset terkirim',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            color: Color(0xFF172033),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Periksa kotak masuk ${emailController.text.trim()} dan ikuti link di dalam email untuk mengatur ulang kata sandi.',
          style: const TextStyle(
            fontSize: 14,
            height: 1.6,
            color: Color(0xFF5E6575),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEFFBF6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFC9F1DE)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 18, color: Color(0xFF0F9F6E)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Demo: tombol di bawah membuka halaman tujuan link reset. Pada produksi, halaman ini dibuka dari deep link email Laravel.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: Color(0xFF236B50),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      ResetPasswordPage(email: emailController.text.trim()),
                ),
              );
            },
            style: _buttonStyle(),
            child: const Text(
              'Buka Halaman Reset',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: TextButton(
            onPressed: () => setState(() => linkSent = false),
            child: const Text('Kirim ulang ke email lain'),
          ),
        ),
      ],
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

  Future<void> _sendResetLink() async {
    FocusScope.of(context).unfocus();
    final email = emailController.text.trim();
    if (!_isValidEmail(email)) {
      _showMessage('Masukkan alamat email yang valid.');
      return;
    }

    setState(() => isSending = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      isSending = false;
      linkSent = true;
    });
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
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
