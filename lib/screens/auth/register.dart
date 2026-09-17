import 'package:aplikasi_bank_soal/widgets/auth/login_widgets.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _scaleAnimation = Tween<double>(begin: .92, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(.05, 1, curve: Curves.easeOutBack),
      ),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic))
            .animate(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform.translate(
                    offset: _slideAnimation.value,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 24,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: Column(
                            children: [
                              const SizedBox(height: 8),
                              const AuthBrand(),
                              const SizedBox(height: 20),
                              _buildAnimatedSection(
                                _buildWelcomeCard(),
                                .12,
                                .52,
                              ),
                              const SizedBox(height: 16),
                              _buildAnimatedSection(
                                _buildRegisterCard(),
                                .2,
                                .7,
                              ),
                              const SizedBox(height: 24),
                              AuthFooter(
                                linkLabel: 'Sudah memiliki akun? Masuk Sekarang',
                                onLinkTap: () => Navigator.of(context).pop(),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSection(Widget child, double begin, double end) {
    final animation = CurvedAnimation(
      parent: _animationController,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, .06),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFF)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6EBF8)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFBFD3FF).withValues(alpha: .18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 18),
          Text(
            'Buat Akun Baru',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -.4,
              color: Color(0xFF172033),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Daftar untuk mengakses bank soal dan\nevaluasi hasil belajar.',
            style: TextStyle(
              fontSize: 14,
              height: 1.7,
              color: Color(0xFF5E6575),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 17, 16, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFF9FBFF)],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Username'),
          const SizedBox(height: 8),
          AuthInputField(
            controller: usernameController,
            hintText: 'Masukkan Username',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
          _buildLabel('Email'),
          const SizedBox(height: 8),
          AuthInputField(
            controller: emailController,
            hintText: 'Masukkan Email',
            icon: Icons.email_outlined,
          ),
          const SizedBox(height: 16),
          _buildLabel('Kata Sandi'),
          const SizedBox(height: 8),
          AuthInputField(
            controller: passwordController,
            hintText: 'Masukkan kata sandi',
            icon: Icons.lock_outline,
            obscureText: obscurePassword,
            suffixIcon: _buildVisibilityButton(
              obscurePassword,
              () => setState(() => obscurePassword = !obscurePassword),
            ),
          ),
          const SizedBox(height: 16),
          _buildLabel('Konfirmasi Password'),
          const SizedBox(height: 8),
          AuthInputField(
            controller: confirmPasswordController,
            hintText: 'Masukkan ulang kata sandi',
            icon: Icons.lock_reset_outlined,
            obscureText: obscureConfirmPassword,
            suffixIcon: _buildVisibilityButton(
              obscureConfirmPassword,
              () => setState(
                () => obscureConfirmPassword = !obscureConfirmPassword,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _handleRegister,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Daftar Sekarang',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.person_add_alt_1_outlined, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: const [
              Expanded(child: Divider(color: Color(0xFFE2E6EF), thickness: 1)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'ATAU DAFTAR DENGAN',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .4,
                    color: Color(0xFF7A8191),
                  ),
                ),
              ),
              Expanded(child: Divider(color: Color(0xFFE2E6EF), thickness: 1)),
            ],
          ),
          const SizedBox(height: 12),
          AuthAlternativeLoginTile(
            icon: const GoogleIcon(),
            title: 'Daftar dengan akun Google',
            subtitle: 'Buat akun menggunakan Google Anda',
            trailing: Icons.chevron_right,
            onTap: _handleGoogleRegister,
          ),
        ],
      ),
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

  void _handleRegister() {
    FocusScope.of(context).unfocus();

    if (usernameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      _showMessage('Semua data wajib diisi.');
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _showMessage('Konfirmasi kata sandi tidak cocok.');
      return;
    }

    _showMessage('Pendaftaran berhasil diproses.');
  }

  void _handleGoogleRegister() {
    _showMessage('Membuka pendaftaran dengan Google...');
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
