import 'package:flutter/material.dart';

import '../models/bmi_category.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../widgets/dashboard_surface_card.dart';

class ProfileScreen extends StatelessWidget {
  static const Color _accentColor = Color(0xFF35E8AE);

  final bool isDrawer;

  const ProfileScreen({super.key, this.isDrawer = false});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF6FAF8),
      appBar: AppBar(
        leading: isDrawer
            ? IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              )
            : null,
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: StreamBuilder<UserModel?>(
        stream: authService.currentUserProfileStream(),
        builder: (context, snapshot) {
          final user = snapshot.data;
          if (snapshot.connectionState == ConnectionState.waiting &&
              user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (user == null) {
            return const Center(child: Text('Profile details unavailable.'));
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 96),
            children: [
              DashboardSurfaceCard(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: _accentColor.withValues(alpha: 0.16),
                      backgroundImage:
                          user.profileImageUrl != null &&
                              user.profileImageUrl!.isNotEmpty
                          ? NetworkImage(user.profileImageUrl!)
                          : null,
                      child:
                          user.profileImageUrl == null ||
                              user.profileImageUrl!.isEmpty
                          ? Text(
                              _initials(user),
                              style: const TextStyle(
                                color: _accentColor,
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      user.displayUsername,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.fullName,
                      style: TextStyle(
                        color: mutedColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              DashboardSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Health Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _MetricTile(
                          label: 'Age',
                          value: user.age > 0 ? '${user.age}' : '--',
                        ),
                        _MetricTile(
                          label: 'Weight',
                          value: user.weightKilograms == null
                              ? '--'
                              : '${user.weightKilograms!.toStringAsFixed(1)} kg',
                        ),
                        _MetricTile(
                          label: 'Height',
                          value: user.heightCentimeters == null
                              ? '--'
                              : '${user.heightCentimeters!.toStringAsFixed(0)} cm',
                        ),
                        _MetricTile(
                          label: 'BMI',
                          value: user.bmi == null
                              ? '--'
                              : user.bmi!.toStringAsFixed(1),
                        ),
                        _MetricTile(label: 'Status', value: _bmiStatus(user)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              DashboardSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.workspace_premium_rounded,
                          color: _accentColor,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Workout Rewards',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (user.rewards.isEmpty)
                      Text(
                        'Finish a recommended workout to earn your first reward.',
                        style: TextStyle(
                          color: mutedColor,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final reward in user.rewards)
                            Chip(
                              avatar: const Icon(
                                Icons.emoji_events_rounded,
                                size: 18,
                              ),
                              label: Text(reward),
                              backgroundColor: _accentColor.withValues(
                                alpha: 0.16,
                              ),
                              side: BorderSide.none,
                            ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              DashboardSurfaceCard(
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: isDark
                          ? Colors.white
                          : const Color(0xFF0B0C0C),
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _signOut(context, authService),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text(
                      'Logout',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _signOut(BuildContext context, AuthService authService) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await authService.signOut();
      navigator.popUntil((route) => route.isFirst);
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Logout failed: $error'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  String _initials(UserModel user) {
    final username = user.displayUsername;
    return username.isEmpty ? 'R' : username[0].toUpperCase();
  }

  String _bmiStatus(UserModel user) {
    return BmiCategory.fromBmi(user.bmi).label;
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;

  const _MetricTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 145,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111212) : const Color(0xFFF6FAF8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.black54,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
