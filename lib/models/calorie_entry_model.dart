import 'package:cloud_firestore/cloud_firestore.dart';

class CalorieEntryModel {
  final String id;
  final String label;
  final int calories;
  final DateTime createdAt;

  const CalorieEntryModel({
    required this.id,
    required this.label,
    required this.calories,
    required this.createdAt,
  });

  factory CalorieEntryModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return CalorieEntryModel(
      id: doc.id,
      label: data['label'] as String? ?? 'Food entry',
      calories: (data['calories'] as num? ?? 0).round(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'calories': calories,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
