import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/premium_widgets.dart';

// Auth State
enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.unauthenticated);

  String? errorMessage;

  Future<bool> login(String email, String password) async {
    state = AuthState.loading;
    await Future.delayed(const Duration(seconds: 2));

    // Demo: Accept any email with password "123456"
    if (password == '123456' || email.contains('@')) {
      state = AuthState.authenticated;
      return true;
    } else {
      errorMessage = 'Invalid credentials';
      state = AuthState.error;
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    state = AuthState.loading;
    await Future.delayed(const Duration(seconds: 2));
    state = AuthState.authenticated;
    return true;
  }

  Future<bool> loginWithGoogle() async {
    state = AuthState.loading;
    await Future.delayed(const Duration(seconds: 2));
    state = AuthState.authenticated;
    return true;
  }

  void logout() {
    state = AuthState.unauthenticated;
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());

// Login Screen
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController(text: 'demo@foodflow.com');
  final _passwordController = TextEditingController(text: '123456');
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState == AuthState.loading;

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next == AuthState.authenticated) {
        context.go('/');
      }
    });

    return Scaffold(
      body: Stack(children: [
        // Background with gradient
        Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A2E), Color(0xFF0A0E1A)],
        ))),
        const BackgroundOrb(
            size: 400,
            color: AppColors.primary,
            alignment: Alignment(-1.2, -0.8)),
        const BackgroundOrb(
            size: 350,
            color: AppColors.secondary,
            alignment: Alignment(1.5, 0.5)),

        SafeArea(
            child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 40),

            // Logo & Welcome
            Center(
                child: Column(children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 30,
                        offset: const Offset(0, 10))
                  ],
                ),
                child: const Icon(Icons.restaurant_rounded,
                    color: Colors.white, size: 40),
              ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8)),
              const SizedBox(height: 24),
              Text('Welcome Back',
                      style: GoogleFonts.inter(
                          fontSize: 32, fontWeight: FontWeight.bold))
                  .animate()
                  .fadeIn(delay: 100.ms),
              const SizedBox(height: 8),
              Text('Sign in to continue ordering',
                      style: GoogleFonts.inter(
                          color: AppColors.textMuted, fontSize: 16))
                  .animate()
                  .fadeIn(delay: 150.ms),
            ])),

            const SizedBox(height: 48),

            // Email Field
            _AuthTextField(
              controller: _emailController,
              label: 'Email Address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 20),

            // Password Field
            _AuthTextField(
              controller: _passwordController,
              label: 'Password',
              icon: Icons.lock_outline_rounded,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textMuted),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.1, end: 0),

            // Forgot Password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: Text('Forgot Password?',
                    style: GoogleFonts.inter(
                        color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 24),

            // Login Button
            GradientButton(
              text: 'Sign In',
              isLoading: isLoading,
              onPressed: () => ref
                  .read(authProvider.notifier)
                  .login(_emailController.text, _passwordController.text),
            ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 24),

            // Divider
            Row(children: [
              Expanded(
                  child: Container(
                      height: 1, color: Colors.white.withOpacity(0.1))),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('or continue with',
                      style: GoogleFonts.inter(
                          color: AppColors.textMuted, fontSize: 13))),
              Expanded(
                  child: Container(
                      height: 1, color: Colors.white.withOpacity(0.1))),
            ]).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 24),

            // Social Buttons
            Row(children: [
              Expanded(
                  child: _SocialButton(
                icon: Icons.g_mobiledata_rounded,
                label: 'Google',
                color: const Color(0xFFEA4335),
                onTap: () => ref.read(authProvider.notifier).loginWithGoogle(),
              )),
              const SizedBox(width: 16),
              Expanded(
                  child: _SocialButton(
                icon: Icons.apple,
                label: 'Apple',
                color: Colors.white,
                onTap: () {},
              )),
            ]).animate().fadeIn(delay: 450.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 40),

            // Register Link
            Center(
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text("Don't have an account? ",
                  style: GoogleFonts.inter(color: AppColors.textMuted)),
              GestureDetector(
                onTap: () => context.push('/register'),
                child: Text('Sign Up',
                    style: GoogleFonts.inter(
                        color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            ])).animate().fadeIn(delay: 500.ms),
          ]),
        )),
      ]),
    );
  }
}

// Register Screen
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final bool _obscurePassword = true;
  bool _agreeToTerms = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState == AuthState.loading;

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next == AuthState.authenticated) {
        context.go('/');
      }
    });

    return Scaffold(
      body: Stack(children: [
        Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF1A1A2E), Color(0xFF0A0E1A)],
        ))),
        const BackgroundOrb(
            size: 350,
            color: AppColors.secondary,
            alignment: Alignment(-1, -0.6)),
        const BackgroundOrb(
            size: 300, color: AppColors.accent, alignment: Alignment(1.2, 0.8)),
        SafeArea(
            child: Column(children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              GlassIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => context.pop(),
                  size: 44),
            ]),
          ),

          Expanded(
              child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Create Account',
                      style: GoogleFonts.inter(
                          fontSize: 32, fontWeight: FontWeight.bold))
                  .animate()
                  .fadeIn(),
              const SizedBox(height: 8),
              Text('Join FoodFlow and start ordering',
                      style: GoogleFonts.inter(
                          color: AppColors.textMuted, fontSize: 16))
                  .animate()
                  .fadeIn(delay: 50.ms),

              const SizedBox(height: 40),

              _AuthTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline_rounded)
                  .animate()
                  .fadeIn(delay: 100.ms)
                  .slideY(begin: 0.1, end: 0),
              const SizedBox(height: 20),
              _AuthTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress)
                  .animate()
                  .fadeIn(delay: 150.ms)
                  .slideY(begin: 0.1, end: 0),
              const SizedBox(height: 20),
              _AuthTextField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword)
                  .animate()
                  .fadeIn(delay: 200.ms)
                  .slideY(begin: 0.1, end: 0),
              const SizedBox(height: 20),
              _AuthTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword)
                  .animate()
                  .fadeIn(delay: 250.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 24),

              // Terms Checkbox
              Row(children: [
                GestureDetector(
                  onTap: () => setState(() => _agreeToTerms = !_agreeToTerms),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      gradient:
                          _agreeToTerms ? AppColors.gradientPrimary : null,
                      color: _agreeToTerms ? null : AppColors.card,
                      borderRadius: BorderRadius.circular(6),
                      border: _agreeToTerms
                          ? null
                          : Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: _agreeToTerms
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 16)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: Text.rich(TextSpan(children: [
                  TextSpan(
                      text: 'I agree to the ',
                      style: GoogleFonts.inter(
                          color: AppColors.textMuted, fontSize: 13)),
                  TextSpan(
                      text: 'Terms of Service',
                      style: GoogleFonts.inter(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  TextSpan(
                      text: ' and ',
                      style: GoogleFonts.inter(
                          color: AppColors.textMuted, fontSize: 13)),
                  TextSpan(
                      text: 'Privacy Policy',
                      style: GoogleFonts.inter(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ]))),
              ]).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 32),

              GradientButton(
                text: 'Create Account',
                isLoading: isLoading,
                gradient: AppColors.gradientSecondary,
                onPressed: _agreeToTerms
                    ? () => ref.read(authProvider.notifier).register(
                        _nameController.text,
                        _emailController.text,
                        _passwordController.text)
                    : () {},
              ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 32),

              Center(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Text("Already have an account? ",
                        style: GoogleFonts.inter(color: AppColors.textMuted)),
                    GestureDetector(
                        onTap: () => context.pop(),
                        child: Text('Sign In',
                            style: GoogleFonts.inter(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold))),
                  ])).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 40),
            ]),
          )),
        ])),
      ]),
    );
  }
}

// Reusable Auth TextField
class _AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;

  const _AuthTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(color: Colors.white),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.inter(color: AppColors.textMuted),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 22),
            suffixIcon: suffixIcon,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
      );
}

// Social Button
class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SocialButton(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 10),
            Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ]),
        ),
      );
}
