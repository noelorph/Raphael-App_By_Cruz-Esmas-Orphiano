import 'package:flutter/material.dart';
import 'package:raphael/models/goal_model.dart';
import 'package:raphael/screens/chatbot_page.dart';
import 'package:raphael/screens/reminders_page.dart';
import './dashboard_screen.dart';
import './goal_page.dart';

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const HomeScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final ValueNotifier<List<GoalModel>> _goalsOverviewNotifier = ValueNotifier(
    const [],
  );

  @override
  void dispose() {
    _goalsOverviewNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // List of screens corresponding to bottom navigation items
    final List<Widget> screens = [
      DashboardScreen(
        isDarkMode: widget.isDarkMode,
        onThemeChanged: widget.onThemeChanged,
        goalsOverviewListenable: _goalsOverviewNotifier,
        onOpenReminders: () {
          setState(() {
            _currentIndex = 1;
          });
        },
      ),
      const RemindersPage(),
      GoalsPage(goalsOverviewNotifier: _goalsOverviewNotifier),
      const ChatbotPage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active_rounded),
            label: 'Reminders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes_rounded),
            label: 'Goals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            label: 'Chat',
          ),
        ],
      ),
    );
  }
}
