import 'dart:async';

import 'package:flutter/material.dart';

import '../models/reminder_model.dart';
import '../services/reminder_service.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  final ReminderService _reminderService = ReminderService();

  Timer? _webReminderTimer;
  List<ReminderModel> _cachedReminders = [];

  @override
  void initState() {
    super.initState();
    _reminderService.initializeNotifications();
    _webReminderTimer = _reminderService.startWebReminderTimer(
      remindersProvider: () => _cachedReminders,
      onReminderTriggered: _showReminderAlert,
    );
  }

  @override
  void dispose() {
    _webReminderTimer?.cancel();
    super.dispose();
  }

  void _showReminderAlert(ReminderModel reminder) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.alarm_on_rounded, color: Color(0xFF35E8AE)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'REMINDER ALERT',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
                  Text(
                    reminder.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF111212),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _addNewReminder() async {
    final titleController = TextEditingController();

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null || !mounted) {
      titleController.dispose();
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF050606) : Colors.white,
          title: Text(
            'Reminder Title',
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          content: TextField(
            controller: titleController,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: 'e.g., Take Vitamin D',
              hintStyle: TextStyle(
                color: isDark ? Colors.white54 : Colors.black45,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: isDark ? Colors.white24 : Colors.black12,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                final title = titleController.text.trim();
                if (title.isNotEmpty) {
                  await _reminderService.addReminder(
                    title: title,
                    hour: pickedTime.hour,
                    minute: pickedTime.minute,
                  );
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text(
                'Save',
                style: TextStyle(color: Color(0xFF35E8AE)),
              ),
            ),
          ],
        );
      },
    );

    titleController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewReminder,
        backgroundColor: const Color(0xFF35E8AE),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, size: 32),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reminders',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Stay on track with your health',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              StreamBuilder<List<ReminderModel>>(
                stream: _reminderService.watchReminders(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final reminders = snapshot.data ?? const [];
                  _cachedReminders = reminders;

                  if (reminders.isEmpty) {
                    return Expanded(
                      child: Center(
                        child: Text(
                          'No reminders added yet.',
                          style: TextStyle(
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                        ),
                      ),
                    );
                  }

                  return Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.notifications_none_rounded,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Today's Reminders",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.swipe_left_rounded,
                                  size: 14,
                                  color: isDark
                                      ? Colors.white38
                                      : Colors.black38,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Swipe card to delete',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white38
                                        : Colors.black38,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.separated(
                            itemCount: reminders.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final reminder = reminders[index];
                              final timeOfDay = TimeOfDay(
                                hour: reminder.hour,
                                minute: reminder.minute,
                              );

                              return Dismissible(
                                key: Key(reminder.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.delete_sweep_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                                onDismissed: (_) => _reminderService
                                    .deleteReminder(reminder.id),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey.withValues(alpha: 0.1),
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 22,
                                        backgroundColor: const Color(
                                          0xFF35E8AE,
                                        ).withValues(alpha: 0.1),
                                        child: const Icon(
                                          Icons.notifications_active_rounded,
                                          color: Color(0xFF35E8AE),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              reminder.title,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.access_time,
                                                  size: 14,
                                                  color: Colors.grey,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  timeOfDay.format(context),
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Switch(
                                        value: reminder.isActive,
                                        activeThumbColor: const Color(
                                          0xFF35E8AE,
                                        ),
                                        onChanged: (_) => _reminderService
                                            .toggleReminder(reminder),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
