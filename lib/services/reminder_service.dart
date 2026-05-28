import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/reminder_model.dart';

class ReminderService {
  ReminderService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FlutterLocalNotificationsPlugin? notificationsPlugin,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _notificationsPlugin =
           notificationsPlugin ?? FlutterLocalNotificationsPlugin();

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  CollectionReference<Map<String, dynamic>> get _remindersRef {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user found');
    return _firestore.collection('users').doc(user.uid).collection('reminders');
  }

  Future<void> initializeNotifications() async {
    try {
      tz.initializeTimeZones();
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const settings = InitializationSettings(android: androidSettings);

      await _notificationsPlugin.initialize(settings);
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } catch (_) {
      // Browser builds do not support the native notification setup path.
    }
  }

  Stream<List<ReminderModel>> watchReminders() {
    return _remindersRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(ReminderModel.fromDocument).toList(),
        );
  }

  Future<void> addReminder({
    required String title,
    required int hour,
    required int minute,
  }) async {
    final newDoc = _remindersRef.doc();
    final reminder = ReminderModel(
      id: newDoc.id,
      title: title,
      hour: hour,
      minute: minute,
      isActive: true,
    );

    await newDoc.set(reminder.toMap());
    await scheduleNotification(reminder);
  }

  Future<void> toggleReminder(ReminderModel reminder) async {
    final updatedReminder = ReminderModel(
      id: reminder.id,
      title: reminder.title,
      hour: reminder.hour,
      minute: reminder.minute,
      isActive: !reminder.isActive,
      createdAt: reminder.createdAt,
    );

    await _remindersRef.doc(reminder.id).update({
      'isActive': updatedReminder.isActive,
    });
    await scheduleNotification(updatedReminder);
  }

  Future<void> deleteReminder(String reminderId) async {
    try {
      await _notificationsPlugin.cancel(reminderId.hashCode);
    } catch (_) {}
    await _remindersRef.doc(reminderId).delete();
  }

  Future<void> scheduleNotification(ReminderModel reminder) async {
    try {
      final notificationId = reminder.id.hashCode;
      if (!reminder.isActive) {
        await _notificationsPlugin.cancel(notificationId);
        return;
      }

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

      const androidDetails = AndroidNotificationDetails(
        'reminder_channel_id',
        'Daily Reminders',
        channelDescription: 'Channel for health and daily habit reminders',
        importance: Importance.max,
        priority: Priority.high,
      );

      await _notificationsPlugin.zonedSchedule(
        notificationId,
        reminder.title,
        'Time for your scheduled reminder!',
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {
      // Keep web and unsupported platforms from breaking the reminders screen.
    }
  }

  Timer startWebReminderTimer({
    required List<ReminderModel> Function() remindersProvider,
    required void Function(ReminderModel reminder) onReminderTriggered,
  }) {
    return Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();

      for (final reminder in remindersProvider()) {
        if (!reminder.isActive) continue;

        final shouldTrigger =
            now.hour == reminder.hour &&
            now.minute == reminder.minute &&
            now.second == 0;
        if (!shouldTrigger) continue;

        onReminderTriggered(reminder);
        _remindersRef.doc(reminder.id).update({'isActive': false});
      }
    });
  }
}
