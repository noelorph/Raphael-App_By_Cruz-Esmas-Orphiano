import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/bmi_category.dart';

class SmartProgressHighlightService {
  SmartProgressHighlightService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  static const String _fallbackMessage =
      'I can see you are trying to build a steady rhythm, and that matters. Log one more update this week so I can spot a clearer trend for you.';

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Future<String> loadHighlight() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return _fallbackMessage;

      final userRef = _firestore.collection('users').doc(user.uid);
      final results = await Future.wait([
        userRef.get(),
        userRef.collection('weight_entries').orderBy('date').get(),
        userRef.collection('goals').get(),
        userRef.collection('reminders').get(),
      ]);

      final userDoc = results[0] as DocumentSnapshot<Map<String, dynamic>>;
      final weightSnapshot = results[1] as QuerySnapshot<Map<String, dynamic>>;
      final goalsSnapshot = results[2] as QuerySnapshot<Map<String, dynamic>>;
      final remindersSnapshot =
          results[3] as QuerySnapshot<Map<String, dynamic>>;

      return _localHighlight(
        userData: userDoc.data() ?? const {},
        weightDocs: weightSnapshot.docs,
        goalDocs: goalsSnapshot.docs,
        reminderDocs: remindersSnapshot.docs,
      );
    } catch (_) {
      return _fallbackMessage;
    }
  }

  String _localHighlight({
    required Map<String, dynamic> userData,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> weightDocs,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> goalDocs,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> reminderDocs,
  }) {
    final latestWeight = _latestWeight(weightDocs);
    final latestBmi = _latestBmi(weightDocs, userData);
    final firstMonthlyWeight = _firstMonthlyWeight(weightDocs);
    final monthlyChange = latestWeight == null || firstMonthlyWeight == null
        ? null
        : latestWeight - firstMonthlyWeight;
    final monthlyEntryCount = _monthlyWeightEntryCount(weightDocs);
    final bmiCategory = BmiCategory.fromBmi(latestBmi);
    final bmiStatus = bmiCategory.insightLabel;
    final completedGoalCount = goalDocs
        .where((doc) => doc.data()['completed'] == true)
        .length;
    final activeReminderCount = reminderDocs
        .where((doc) => doc.data()['isActive'] == true)
        .length;
    final streakCount = userData['streak'] as int? ?? 0;
    final username = _username(userData);
    final suggestion = bmiCategory.progressSuggestion;
    final progressSummary = _progressSummary(
      username: username,
      monthlyChange: monthlyChange,
      monthlyEntryCount: monthlyEntryCount,
      completedGoalCount: completedGoalCount,
      activeReminderCount: activeReminderCount,
      streakCount: streakCount,
      bmiStatus: bmiStatus,
    );

    return '$progressSummary $suggestion';
  }

  String _progressSummary({
    required String username,
    required double? monthlyChange,
    required int monthlyEntryCount,
    required int completedGoalCount,
    required int activeReminderCount,
    required int streakCount,
    required String bmiStatus,
  }) {
    final details = <String>[];

    if (monthlyChange != null && monthlyEntryCount > 1) {
      final direction = monthlyChange < 0 ? 'down' : 'up';
      details.add(
        'you are $direction ${monthlyChange.abs().toStringAsFixed(2)} kg this month',
      );
    } else if (monthlyEntryCount > 0) {
      details.add('you have started tracking your weight this month');
    }

    if (completedGoalCount > 0) {
      details.add(
        'completed $completedGoalCount goal${completedGoalCount == 1 ? '' : 's'}',
      );
    }

    if (activeReminderCount > 0) {
      details.add(
        'kept $activeReminderCount reminder${activeReminderCount == 1 ? '' : 's'} active',
      );
    }

    if (streakCount > 0) {
      details.add('built a $streakCount-day streak');
    }

    if (bmiStatus != 'Unknown') {
      details.add('your BMI is in the $bmiStatus range');
    }

    if (details.isEmpty) {
      return 'I can see you are starting to build a clearer health picture${username == 'Unknown' ? '' : ', $username'}.';
    }

    if (details.length == 1) {
      return 'I can see your effort here${username == 'Unknown' ? '' : ', $username'}, ${details.first}.';
    }

    return 'I like the progress you are building${username == 'Unknown' ? '' : ', $username'}, ${details.take(2).join(' and ')}.';
  }

  double? _latestWeight(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> weightDocs,
  ) {
    if (weightDocs.isEmpty) return null;
    return (weightDocs.last.data()['weight'] as num?)?.toDouble();
  }

  double? _latestBmi(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> weightDocs,
    Map<String, dynamic> userData,
  ) {
    if (weightDocs.isNotEmpty) {
      final bmi = (weightDocs.last.data()['bmi'] as num?)?.toDouble();
      if (bmi != null) return bmi;
    }

    return (userData['bmi'] as num?)?.toDouble();
  }

  double? _firstMonthlyWeight(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> weightDocs,
  ) {
    if (weightDocs.isEmpty) return null;

    final latestDate = _entryDate(weightDocs.last);
    if (latestDate == null) return _latestWeight(weightDocs);

    for (final doc in weightDocs) {
      final date = _entryDate(doc);
      if (date == null) continue;
      if (date.year == latestDate.year && date.month == latestDate.month) {
        return (doc.data()['weight'] as num?)?.toDouble();
      }
    }

    return _latestWeight(weightDocs);
  }

  int _monthlyWeightEntryCount(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> weightDocs,
  ) {
    if (weightDocs.isEmpty) return 0;

    final latestDate = _entryDate(weightDocs.last);
    if (latestDate == null) return weightDocs.length;

    return weightDocs.where((doc) {
      final date = _entryDate(doc);
      return date != null &&
          date.year == latestDate.year &&
          date.month == latestDate.month;
    }).length;
  }

  DateTime? _entryDate(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return (doc.data()['date'] as Timestamp?)?.toDate();
  }

  String _username(Map<String, dynamic> userData) {
    final username = (userData['username'] as String? ?? '').trim();
    if (username.isNotEmpty) return username;

    final email = (userData['email'] as String? ?? '').trim();
    final emailName = email.split('@').first.trim();
    return emailName.isEmpty ? 'Unknown' : emailName;
  }
}
