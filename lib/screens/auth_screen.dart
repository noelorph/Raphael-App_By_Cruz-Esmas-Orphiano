import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'profile_setup_screen.dart';

class AuthGate extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const AuthGate({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _holdAuthScreenForSignup = false;

  void _handleRegistrationStarted() {
    if (!_holdAuthScreenForSignup) {
      setState(() => _holdAuthScreenForSignup = true);
    }
  }

  void _handleRegistrationFinished() {
    if (_holdAuthScreenForSignup) {
      setState(() => _holdAuthScreenForSignup = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData && !_holdAuthScreenForSignup) {
          return StreamBuilder<UserModel?>(
            stream: authService.currentUserProfileStream(),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final profile = profileSnapshot.data;
              if (profile == null || !profile.hasBodyMetrics) {
                return ProfileSetupScreen(
                  isDarkMode: widget.isDarkMode,
                  onThemeChanged: widget.onThemeChanged,
                );
              }

              return HomeScreen(
                isDarkMode: widget.isDarkMode,
                onThemeChanged: widget.onThemeChanged,
              );
            },
          );
        }
        return AuthScreen(
          onRegistrationStarted: _handleRegistrationStarted,
          onRegistrationFinished: _handleRegistrationFinished,
        );
      },
    );
  }
}

class AuthScreen extends StatefulWidget {
  final VoidCallback? onRegistrationStarted;
  final VoidCallback? onRegistrationFinished;

  const AuthScreen({
    super.key,
    this.onRegistrationStarted,
    this.onRegistrationFinished,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  static const Color _accentColor = Color(0xFF35E8AE);

  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  String _email = '';
  String _password = '';
  String _username = '';
  String _firstName = '';
  String _lastName = '';
  int _age = 0;
  bool _isLoginMode = true;
  bool _isLoading = false;

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);
    try {
      if (_isLoginMode) {
        await _authService.signIn(email: _email, password: _password);
      } else {
        widget.onRegistrationStarted?.call();
        await _authService.signUp(
          email: _email,
          password: _password,
          username: _username,
          firstName: _firstName,
          lastName: _lastName,
          age: _age,
        );
        widget.onRegistrationFinished?.call();
        if (!mounted) return;
        _formKey.currentState!.reset();
        setState(() => _isLoginMode = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account successfully created. Please log in.'),
            backgroundColor: _accentColor,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!_isLoginMode) widget.onRegistrationFinished?.call();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Authentication failed'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      if (!_isLoginMode) widget.onRegistrationFinished?.call();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? Colors.white60 : Colors.black54;
    final surfaceColor = isDark ? const Color(0xFF050606) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF222323)
        : const Color(0xFFE1E7E5);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF6FAF8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 430),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.track_changes_rounded,
                      color: _accentColor,
                      size: 34,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _isLoginMode ? 'Welcome to Raphael' : 'Create Account',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isLoginMode
                          ? 'Sign in to keep tracking your progress.'
                          : 'Start your health goals with a fresh checklist.',
                      style: TextStyle(
                        color: mutedColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 26),
                    if (!_isLoginMode) ...[
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.alternate_email_rounded),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (val) {
                          final username = val?.trim() ?? '';
                          if (username.length < 3) {
                            return 'Username must be at least 3 characters.';
                          }
                          if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
                            return 'Use letters, numbers, or underscores only.';
                          }
                          return null;
                        },
                        onSaved: (val) => _username = val!.trim(),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'First Name',
                                prefixIcon: Icon(Icons.person_outline_rounded),
                              ),
                              textCapitalization: TextCapitalization.words,
                              validator: (val) => val!.trim().isNotEmpty
                                  ? null
                                  : 'Enter your first name.',
                              onSaved: (val) => _firstName = val!.trim(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Last Name',
                                prefixIcon: Icon(Icons.badge_outlined),
                              ),
                              textCapitalization: TextCapitalization.words,
                              validator: (val) => val!.trim().isNotEmpty
                                  ? null
                                  : 'Enter your last name.',
                              onSaved: (val) => _lastName = val!.trim(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Age',
                          prefixIcon: Icon(Icons.cake_outlined),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          final age = int.tryParse(val ?? '');
                          if (age == null || age < 5 || age > 120) {
                            return 'Enter a valid age.';
                          }
                          return null;
                        },
                        onSaved: (val) => _age = int.parse(val!.trim()),
                      ),
                      const SizedBox(height: 14),
                    ],
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) => val!.contains('@')
                          ? null
                          : 'Please enter a valid email.',
                      onSaved: (val) => _email = val!.trim(),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline_rounded),
                      ),
                      obscureText: true,
                      validator: (val) => val!.length >= 6
                          ? null
                          : 'Password must be at least 6 characters.',
                      onSaved: (val) => _password = val!.trim(),
                    ),
                    const SizedBox(height: 24),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48),
                                backgroundColor: _accentColor,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: _submitForm,
                              child: Text(_isLoginMode ? 'Login' : 'Sign Up'),
                            ),
                          ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() => _isLoginMode = !_isLoginMode);
                        },
                        child: Text(
                          _isLoginMode
                              ? 'New here? Create an account'
                              : 'Already have an account? Login',
                        ),
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
