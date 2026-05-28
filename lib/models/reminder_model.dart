import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderModel {
  final String id;
  final String title;
  final int hour;
  final int minute;
  final bool isActive;
  final DateTime? createdAt;

  const ReminderModel({
    required this.id,
    required this.title,
    required this.hour,
    required this.minute,
    required this.isActive,
    this.createdAt,
  });

  factory ReminderModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return ReminderModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      hour: data['hour'] as int? ?? 0,
      minute: data['minute'] as int? ?? 0,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'hour': hour,
      'minute': minute,
      'isActive': isActive,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
