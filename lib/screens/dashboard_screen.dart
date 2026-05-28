import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/goal_model.dart';
import '../models/reminder_model.dart';
import '../models/user_model.dart';
import '../models/weight_entry_model.dart';
import '../services/auth_service.dart';
import '../services/daily_health_fact_service.dart';
import '../services/date_format_service.dart';
import '../services/reminder_service.dart';
import '../services/smart_progress_highlight_service.dart';
import '../services/weight_tracker_service.dart';
import '../widgets/dashboard_surface_card.dart';
import '../widgets/section_title.dart';
import '../widgets/weight_delta_chart.dart';
import './profile_screen.dart';
import './recommendation_screen.dart';
import './weight_tracker_screen.dart';

class DashboardScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;
  final ValueListenable<List<GoalModel>> goalsOverviewListenable;
  final VoidCallback? onOpenReminders;

  const DashboardScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.goalsOverviewListenable,
    this.onOpenReminders,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const Color _accentColor = Color(0xFF35E8AE);
  final AuthService _authService = AuthService();
  final DateFormatService _dateFormatService = const DateFormatService();
  final DailyHealthFactService _dailyHealthFactService =
      DailyHealthFactService();
  final ReminderService _reminderService = ReminderService();
  final SmartProgressHighlightService _smartProgressHighlightService =
      SmartProgressHighlightService();
  final WeightTrackerService _weightTrackerService = WeightTrackerService();

  int _lastStreakCount = 0;
  late final Stream<UserModel?> _userProfileStream;
  late final Future<String> _dailyFactFuture;
  late final Future<String> _smartProgressHighlightFuture;
  late final Stream<List<ReminderModel>> _remindersOverviewStream;
  late final Stream<List<WeightEntryModel>> _weightEntriesOverviewStream;

  @override
  void initState() {
    super.initState();
    _userProfileStream = _authService.currentUserProfileStream();
    _dailyFactFuture = _dailyHealthFactService.loadTodayFact();
    _smartProgressHighlightFuture = _smartProgressHighlightService
        .loadHighlight();
    _remindersOverviewStream = _reminderService.watchReminders();
    _weightEntriesOverviewStream = _weightTrackerService.watchEntries();
  }

  Widget _buildQuickOverviewContent({required int streakCount}) {
    final overviewMutedColor = _quickOverviewMutedColor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _buildStreakOverviewBox(streakCount)),
            const SizedBox(width: 12),
            Expanded(child: _buildActiveGoalsOverviewBox(overviewMutedColor)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildWeightOverviewBox(overviewMutedColor)),
            const SizedBox(width: 12),
            Expanded(child: _buildReminderOverviewBox(overviewMutedColor)),
          ],
        ),
      ],
    );
  }

  Color _quickOverviewMutedColor() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Colors.white.withValues(alpha: 0.84)
        : const Color(0xFF394541);
  }

  Widget _buildFunFactContent(Color mutedColor) {
    return FutureBuilder<String>(
      future: _dailyFactFuture,
      builder: (context, factSnapshot) {
        final fact = factSnapshot.data;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: Text(
                factSnapshot.connectionState == ConnectionState.waiting &&
                        fact == null
                    ? 'Preparing today\'s fun fact...'
                    : '"${fact ?? 'A short walk after meals can support digestion and help you feel more energized. 🚶'}"',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: mutedColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSmartProgressHighlightCard(Color mutedColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DashboardSurfaceCard(
      child: FutureBuilder<String>(
        future: _smartProgressHighlightFuture,
        builder: (context, snapshot) {
          final isLoading =
              snapshot.connectionState == ConnectionState.waiting &&
              snapshot.data == null;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: _accentColor),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Raphael\'s Insight 🧐',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: isLoading
                    ? Row(
                        key: const ValueKey('smart-progress-loading'),
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: _accentColor,
                              backgroundColor: isDark
                                  ? Colors.white12
                                  : const Color(0xFFE4EBE8),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Reading your progress...',
                              style: TextStyle(
                                color: mutedColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Text(
                        snapshot.data ??
                            'You are building a steady rhythm. Log one more update this week so I can spot a clearer trend for you.',
                        key: const ValueKey('smart-progress-message'),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
              ),
              const SizedBox(height: 14),
              Divider(
                height: 1,
                color: isDark ? Colors.white10 : const Color(0xFFE1E7E5),
              ),
              const SizedBox(height: 14),
              _buildFunFactContent(mutedColor),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGreetingCard(UserModel? user, Color mutedColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final username = user?.displayUsername.trim().isNotEmpty == true
        ? user!.displayUsername.trim()
        : 'Raphael';
    final greeting = _timeGreeting();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF101A16), Color(0xFF133229), Color(0xFF1E3F55)]
              : const [Color(0xFFE8FFF6), Color(0xFFDFF3FF), Color(0xFFFFF2D7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFCFE7DF),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? _accentColor : const Color(0xFF80DCC5)).withValues(
              alpha: isDark ? 0.12 : 0.22,
            ),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.72),
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.white,
                width: 1.4,
              ),
            ),
            child: Icon(
              _greetingIcon(),
              color: isDark ? _accentColor : const Color(0xFF0D9276),
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello $username, Good $greeting!',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF12231F),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    height: 1.18,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Your wellness dashboard is ready for today.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : mutedColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakOverviewBox(int streakCount) {
    return Container(
      height: 132,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8A00), Color(0xFFFF3D77), Color(0xFF7C4DFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF3D77).withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -12,
            top: -16,
            child: Icon(
              Icons.local_fire_department_rounded,
              color: Colors.white.withValues(alpha: 0.18),
              size: 82,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.38),
                      ),
                    ),
                    child: const Icon(
                      Icons.local_fire_department_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$streakCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Text(
                'Daily Streak',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                streakCount == 1 ? '1 day strong' : '$streakCount days strong',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.92),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReminderOverviewBox(Color mutedColor) {
    return StreamBuilder<List<ReminderModel>>(
      stream: _remindersOverviewStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildReminderListBox(
            mutedColor: mutedColor,
            count: 0,
            lines: const ['Unavailable'],
          );
        }

        final activeReminders = (snapshot.data ?? const [])
            .where((reminder) => reminder.isActive)
            .toList();
        final closestReminders = _closestReminders(activeReminders);
        final isLoading =
            snapshot.connectionState == ConnectionState.waiting &&
            snapshot.data == null;

        return _buildReminderListBox(
          mutedColor: mutedColor,
          count: activeReminders.length,
          lines: isLoading
              ? const ['Loading...']
              : closestReminders.isEmpty
              ? const ['No active reminders']
              : closestReminders
                    .map(
                      (reminder) =>
                          '${reminder.title} at ${_dateFormatService.reminderTime(reminder)}',
                    )
                    .toList(),
        );
      },
    );
  }

  Widget _buildReminderListBox({
    required Color mutedColor,
    required int count,
    required List<String> lines,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: widget.onOpenReminders,
      child: Column(
        children: [
          Container(
            height: 132,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF101211) : const Color(0xFFF6FAF8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF2B2D2C)
                    : const Color(0xFFE1E7E5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.notifications_active_rounded,
                      color: _accentColor,
                      size: 20,
                    ),
                    const Spacer(),
                    Text(
                      '$count',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Reminders',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                for (final line in lines.take(3))
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      '- $line',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: mutedColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }

  IconData _greetingIcon() {
    final hour = DateTime.now().hour;
    if (hour < 12) return Icons.wb_sunny_rounded;
    if (hour < 17) return Icons.wb_twilight_rounded;
    return Icons.nights_stay_rounded;
  }

  Widget _buildActiveGoalsOverviewBox(Color mutedColor) {
    return ValueListenableBuilder<List<GoalModel>>(
      valueListenable: widget.goalsOverviewListenable,
      builder: (context, goals, child) {
        final completedCount = goals.where((goal) => goal.completed).length;
        final totalCount = goals.length;
        final activeCount = totalCount - completedCount;

        return _buildGoalProgressBox(
          mutedColor: mutedColor,
          completedCount: completedCount,
          totalCount: totalCount,
          subtitle: activeCount == 0
              ? 'No active goals'
              : '$activeCount active goals',
        );
      },
    );
  }

  Widget _buildGoalProgressBox({
    required Color mutedColor,
    required int completedCount,
    required int totalCount,
    required String subtitle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = totalCount == 0 ? 0.0 : completedCount / totalCount;

    return Container(
      height: 132,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF101211) : const Color(0xFFF6FAF8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF2B2D2C) : const Color(0xFFE1E7E5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.track_changes_rounded,
                color: _accentColor,
                size: 20,
              ),
              const Spacer(),
              Text(
                '$completedCount/$totalCount',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              SizedBox(
                width: 42,
                height: 42,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 5,
                      color: _accentColor,
                      backgroundColor: isDark
                          ? const Color(0xFF252525)
                          : const Color(0xFFE4EBE8),
                    ),
                    Center(
                      child: Text(
                        '${(progress * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Goals Progress',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: mutedColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeightOverviewBox(Color mutedColor) {
    return StreamBuilder<List<WeightEntryModel>>(
      stream: _weightEntriesOverviewStream,
      builder: (context, snapshot) {
        final entries = snapshot.data ?? const <WeightEntryModel>[];
        final latest = entries.isEmpty ? null : entries.last;
        final monthlyEntries = latest == null
            ? const <WeightEntryModel>[]
            : entries
                  .where(
                    (entry) =>
                        entry.date.year == latest.date.year &&
                        entry.date.month == latest.date.month &&
                        !entry.date.isAfter(latest.date),
                  )
                  .toList();

        return _buildWeightTrackerBox(
          latest: latest,
          chartEntries: monthlyEntries,
          isLoading:
              snapshot.connectionState == ConnectionState.waiting &&
              latest == null,
          mutedColor: mutedColor,
        );
      },
    );
  }

  Widget _buildWeightTrackerBox({
    required WeightEntryModel? latest,
    required List<WeightEntryModel> chartEntries,
    required bool isLoading,
    required Color mutedColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WeightTrackerScreen()),
      ),
      child: Container(
        height: 132,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF101211) : const Color(0xFFF6FAF8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? const Color(0xFF2B2D2C) : const Color(0xFFE1E7E5),
          ),
        ),
        child: latest == null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.monitor_weight_outlined,
                    color: _accentColor,
                    size: 20,
                  ),
                  const SizedBox(height: 22),
                  Text(
                    isLoading ? 'Weight: Loading...' : 'Weight: --',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'No entries yet',
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.monitor_weight_outlined,
                    color: _accentColor,
                    size: 20,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Weight: ${latest.weight.toStringAsFixed(1)} kg',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    _formatWeightDateTime(latest.date),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 32,
                    width: double.infinity,
                    child: WeightDeltaChart(
                      entries: chartEntries.isEmpty ? [latest] : chartEntries,
                      lineColor: _accentColor,
                      fillColor: _accentColor.withValues(alpha: 0.12),
                      labelColor: mutedColor,
                      startLabel: _dateFormatService.compactMonthDay(
                        chartEntries.isEmpty
                            ? latest.date
                            : chartEntries.first.date,
                      ),
                      endLabel: _dateFormatService.compactMonthDay(latest.date),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  List<ReminderModel> _closestReminders(
    List<ReminderModel> reminders, {
    int limit = 3,
  }) {
    if (reminders.isEmpty) return const [];

    final sorted = [...reminders]
      ..sort(
        (a, b) => _nextReminderDateTime(a).compareTo(_nextReminderDateTime(b)),
      );

    return sorted.take(limit).toList();
  }

  DateTime _nextReminderDateTime(ReminderModel reminder) {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      reminder.hour,
      reminder.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  String _formatWeightDateTime(DateTime date) {
    return _dateFormatService.compactDateTime(date);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF6FAF8),
      endDrawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.8,
        backgroundColor: isDark ? Colors.black : const Color(0xFFF6FAF8),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(left: Radius.circular(24)),
        ),
        child: const ProfileScreen(isDrawer: true),
      ),
      body: StreamBuilder<UserModel?>(
        stream: _userProfileStream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            _lastStreakCount = snapshot.data!.streak;
          }
          final user = snapshot.data;
          final streakCount = _lastStreakCount;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 96),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Raphael',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Your wellness dashboard',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Builder(
                        builder: (context) {
                          return IconButton.filled(
                            style: IconButton.styleFrom(
                              backgroundColor: _accentColor,
                              foregroundColor: Colors.black,
                            ),
                            icon: Text(
                              _profileInitial(user),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            onPressed: () =>
                                Scaffold.of(context).openEndDrawer(),
                            tooltip: 'Profile',
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        style: IconButton.styleFrom(
                          foregroundColor: _accentColor,
                        ),
                        icon: const Icon(Icons.wb_sunny_rounded),
                        onPressed: () =>
                            widget.onThemeChanged(!widget.isDarkMode),
                        tooltip: 'Toggle theme',
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _buildGreetingCard(user, mutedColor),
                  const SizedBox(height: 24),
                  const SectionTitle(
                    icon: Icons.dashboard_rounded,
                    title: 'Quick Overview',
                    color: _accentColor,
                  ),
                  const SizedBox(height: 12),
                  DashboardSurfaceCard(
                    child: _buildQuickOverviewContent(streakCount: streakCount),
                  ),
                  const SizedBox(height: 12),
                  _buildSmartProgressHighlightCard(mutedColor),
                  const SizedBox(height: 24),
                  const SectionTitle(
                    icon: Icons.explore_rounded,
                    title: 'Explore More',
                    color: _accentColor,
                  ),
                  const SizedBox(height: 12),
                  DashboardSurfaceCard(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RecommendationsScreen(),
                        ),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: _accentColor,
                            child: Icon(Icons.spa_rounded, color: Colors.black),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Personalized Recommendations',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Healthy foods, calorie guides, and workouts',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: mutedColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: mutedColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _profileInitial(UserModel? user) {
    final username = user?.displayUsername ?? '';
    return username.isEmpty ? 'R' : username[0].toUpperCase();
  }
}
