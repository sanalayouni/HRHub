import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_theme.dart';
import '../../widgets/form_controls.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    final email = _email.text.trim();

    // Say what's missing rather than silently doing nothing — an empty field
    // used to leave the previous attempt's error on screen, which reads as
    // "correct password rejected".
    if (email.isEmpty || _password.text.isEmpty) {
      setState(() => _error = 'Enter both your email and password.');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authProvider.notifier).login(email, _password.text);
      // The router redirect takes over once auth state flips.
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = apiErrorMessage(
          error,
          fallback: 'Invalid email or password. Try again.',
        );
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.ink,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Container(
                color: palette.surface,
                child: Stack(
                  children: [
                    // Accent glows bleeding in from the card edges, as on the web.
                    Positioned(
                      left: -64,
                      top: 64,
                      child: _Glow(
                        color: palette.accent,
                        size: 224,
                        opacity: 0.6,
                      ),
                    ),
                    Positioned(
                      right: -40,
                      bottom: 0,
                      child: _Glow(
                        color: palette.accent,
                        size: 256,
                        opacity: 0.5,
                      ),
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      'assets/hrhub-logo.png',
                                      height: 36,
                                      width: 36,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'HRHub',
                                    style: heading(
                                      size: 17,
                                      color: palette.ink,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: palette.cream,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'Axia Solutions',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: palette.inkSoft,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 48),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: palette.cream,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    size: 14,
                                    color: palette.accent,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'HR Portal for Axia Solutions',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: palette.inkSoft,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Welcome Back to HRHub',
                            textAlign: TextAlign.center,
                            style: heading(
                              size: 34,
                              color: palette.ink,
                              height: 1.1,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Sign in to review requests, track decisions, and manage employee '
                            'records for Axia Solutions.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: palette.inkSoft,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 28),
                          TextField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              hintText: 'hr@axiasolutions.com',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _password,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _submit(),
                            decoration: const InputDecoration(
                              hintText: 'Password',
                            ),
                          ),
                          const SizedBox(height: 16),
                          AccentButton(
                            label: 'Sign In',
                            busy: _busy,
                            onPressed: _submit,
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: palette.coral,
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          Text(
                            'Secure access for the Axia Solutions HR team only.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: palette.inkSoft,
                            ),
                          ),
                        ],
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
}

class _Glow extends StatelessWidget {
  final Color color;
  final double size;
  final double opacity;

  const _Glow({required this.color, required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: 0),
            ],
            stops: const [0.0, 0.7],
          ),
        ),
      ),
    );
  }
}
