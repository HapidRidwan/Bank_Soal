import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AuthBrand extends StatelessWidget {
  const AuthBrand({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2563EB),
                    Color(0xFF3B82F6),
                    Color(0xFF7C3AED),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: .22),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.article_outlined,
                color: Colors.white,
                size: 25,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Bank Soal',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -.6,
                color: Color(0xFF172033),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .85),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFDCE8FF)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8BB4FF).withValues(alpha: .12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 6),
              Text(
                'APLIKASI LATIHAN SOAL TERPADU',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: Color(0xFF3C4862),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AuthWelcomeCard extends StatelessWidget {
  const AuthWelcomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF8FAFF),
          ],
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
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -22,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: const Color(0xFFDBEAFE).withValues(alpha: .6),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              const Text(
                'Selamat Datang Kembali',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.4,
                  color: Color(0xFF172033),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Masuk untuk mengakses bank soal,\ndan evaluasi hasil belajar.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.7,
                  color: Color(0xFF5E6575),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AuthInputField extends StatefulWidget {
  const AuthInputField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  State<AuthInputField> createState() => _AuthInputFieldState();
}

class _AuthInputFieldState extends State<AuthInputField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasFocus = _focusNode.hasFocus;

    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F8FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasFocus ? const Color(0xFF2563EB) : const Color(0xFFE3EAFB),
            width: hasFocus ? 1.5 : 1,
          ),
          boxShadow: hasFocus
              ? [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: .12),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: const Color(0xFFB9C8E3).withValues(alpha: .08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 10),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: hasFocus
                    ? const Color(0xFFDDEBFF)
                    : const Color(0xFFEAF1FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                widget.icon,
                color: hasFocus ? const Color(0xFF2563EB) : const Color(0xFF7A8191),
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                focusNode: _focusNode,
                controller: widget.controller,
                obscureText: widget.obscureText,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF252B39),
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: widget.hintText,
                  hintStyle: const TextStyle(
                    color: Color(0xFF9AA1B2),
                    fontSize: 14,
                    height: 1.4,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                ),
              ),
            ),
            if (widget.suffixIcon != null) ...[
              const SizedBox(width: 8),
              widget.suffixIcon!,
            ],
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}

class AuthAlternativeLoginTile extends StatefulWidget {
  const AuthAlternativeLoginTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  final Widget icon;
  final String title;
  final String subtitle;
  final IconData trailing;
  final VoidCallback onTap;

  @override
  State<AuthAlternativeLoginTile> createState() => _AuthAlternativeLoginTileState();
}

class _AuthAlternativeLoginTileState extends State<AuthAlternativeLoginTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.985 : 1,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      child: InkWell(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: _pressed
                  ? [const Color(0xFFEAF1FF), const Color(0xFFF7F9FF)]
                  : [const Color(0xFFF5F7FF), const Color(0xFFFFFFFF)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _pressed ? const Color(0xFFBFD3FF) : const Color(0xFFE7ECF7),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFC9D8FF).withValues(alpha: .12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE0E3EA)),
                ),
                child: Center(child: widget.icon),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF252B39),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFF596173),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                widget.trailing,
                size: 20,
                color: const Color(0xFF7A8191),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthFooter extends StatelessWidget {
  const AuthFooter({
    super.key,
    required this.linkLabel,
    required this.onLinkTap,
  });

  final String linkLabel;
  final VoidCallback onLinkTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onLinkTap,
          child: Text(
            linkLabel,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF075FDC),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF0F9F6E),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '© 2026 Bank Soal • Semua hak dilindungi',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF6A7283),
                letterSpacing: .1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class GoogleIcon extends StatelessWidget {
  const GoogleIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFE0E3EA),
        ),
      ),
      alignment: Alignment.center,
      child: SvgPicture.asset(
        'asset/images/google.svg',
        width: 15,
        height: 15,
        fit: BoxFit.contain,
      ),
    );
  }
}
