import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const ProfileSetupScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  static const Color _accentColor = Color(0xFF35E8AE);

  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  bool _isSaving = false;

  Future<void> _saveMetrics() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      await _authService.updateBodyMetrics(
        heightCentimeters: double.parse(_heightController.text.trim()),
        weightKilograms: double.parse(_weightController.text.trim()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save body details: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF6FAF8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 430),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF050606) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF222323)
                      : const Color(0xFFE1E7E5),
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.monitor_weight_outlined,
                      color: _accentColor,
                      size: 36,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Set Up Your Profile',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add your current height and weight so Raphael can start your BMI tracker.',
                      style: TextStyle(
                        color: mutedColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _heightController,
                      decoration: const InputDecoration(
                        labelText: 'Height (cm)',
                        prefixIcon: Icon(Icons.height_rounded),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        final value = double.tryParse(val ?? '');
                        if (value == null || value < 80 || value > 260) {
                          return 'Enter a valid height in centimeters.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _weightController,
                      decoration: const InputDecoration(
                        labelText: 'Weight (kg)',
                        prefixIcon: Icon(Icons.fitness_center_rounded),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        final value = double.tryParse(val ?? '');
                        if (value == null || value < 20 || value > 400) {
                          return 'Enter a valid weight in kilograms.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    _isSaving
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
                              onPressed: _saveMetrics,
                              child: const Text('Start Tracking'),
                            ),
                          ),
                    const SizedBox(height: 10),
                    Center(
                      child: TextButton.icon(
                        onPressed: _authService.signOut,
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text('Sign out'),
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

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }
}
