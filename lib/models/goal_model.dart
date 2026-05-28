import 'package:cloud_firestore/cloud_firestore.dart';

class GoalModel {
  final String id;
  final String title;
  final String timeframe;
  final bool completed;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const GoalModel({
    required this.id,
    required this.title,
    required this.timeframe,
    required this.completed,
    this.createdAt,
    this.updatedAt,
  });

  factory GoalModel.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return GoalModel(
      id: doc.id,
      title: data['title'] as String? ?? 'Untitled goal',
      timeframe: data['timeframe'] as String? ?? 'Anytime',
      completed: data['completed'] == true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'title': title,
      'timeframe': timeframe,
      'completed': completed,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'title': title,
      'timeframe': timeframe,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
