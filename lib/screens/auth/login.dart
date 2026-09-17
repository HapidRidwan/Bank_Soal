import 'package:aplikasi_bank_soal/widgets/auth/login_widgets.dart';
import 'package:aplikasi_bank_soal/screens/auth/forgot_password.dart';
import 'package:aplikasi_bank_soal/screens/auth/register.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  bool obscurePassword = true;
  bool rememberMe = false;

  final TextEditingController identityController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
    identityController.dispose();
    passwordController.dispose();
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
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
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
                                    const AuthWelcomeCard(),
                                    .12,
                                    .52,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildAnimatedSection(
                                    _buildLoginCard(),
                                    .2,
                                    .7,
                                  ),
                                  const SizedBox(height: 24),
                                  AuthFooter(
                                    linkLabel: 'Belum memiliki akun? Daftar Sekarang',
                                    onLinkTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) => const RegisterPage(),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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

  Widget _buildLoginCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
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
            controller: identityController,
            hintText: 'Masukkan Email',
            icon: Icons.email_outlined,
          ),
          const SizedBox(height: 8),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 14, color: Color(0xFF596173)),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Masukan Alamat Email Yang Terdaftar',
                  style: TextStyle(fontSize: 11, color: Color(0xFF596173)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kata Sandi',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF252B39),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AuthInputField(
            controller: passwordController,
            hintText: 'Masukkan kata sandi',
            icon: Icons.lock_outline,
            obscureText: obscurePassword,
            suffixIcon: GestureDetector(
              onTap: () {
                setState(() {
                  obscurePassword = !obscurePassword;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF1FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: const Color(0xFF7A8191),
                  size: 18,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    rememberMe = !rememberMe;
                  });
                },
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: rememberMe
                            ? const Color(0xFF2563EB)
                            : const Color(0xFFE4EBFF),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: rememberMe
                              ? const Color(0xFF2563EB)
                              : const Color(0xFFD8E1FF),
                          width: 1,
                        ),
                        boxShadow: rememberMe
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF2563EB)
                                      .withValues(alpha: .18),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: rememberMe
                          ? const Icon(
                              Icons.check,
                              size: 13,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 9),
                    const Text(
                      'Ingat saya',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF444B5B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ForgotPasswordPage(),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Text(
                    'Lupa Sandi?',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF075FDC),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          AnimatedScale(
            scale: 1,
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOutCubic,
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  shadowColor: const Color(0xFF2563EB).withValues(alpha: .25),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Masuk Sekarang',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.login_outlined, size: 20),
                  ],
                ),
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
                  'ATAU MASUK DENGAN',
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
            title: 'Masuk dengan akun Google',
            subtitle: 'Lanjutkan dengan akun Google Anda',
            trailing: Icons.chevron_right,
            onTap: _handleGoogleLogin,
          ),
        ],
      ),
    );
  }

  void _handleLogin() {
    FocusScope.of(context).unfocus();

    if (identityController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('email dan kata sandi wajib diisi.'),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Memproses login...'),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _handleGoogleLogin() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Membuka login dengan Google...'),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
