import 'package:cloud_firestore/cloud_firestore.dart';

class WeightEntryModel {
  final String id;
  final double weight;
  final double heightCentimeters;
  final double bmi;
  final DateTime date;

  const WeightEntryModel({
    required this.id,
    required this.weight,
    required this.heightCentimeters,
    required this.bmi,
    required this.date,
  });

  factory WeightEntryModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return WeightEntryModel(
      id: doc.id,
      weight: (data['weight'] as num? ?? 0).toDouble(),
      heightCentimeters: (data['heightCentimeters'] as num? ?? 0).toDouble(),
      bmi: (data['bmi'] as num? ?? 0).toDouble(),
      date: (data['date'] as Timestamp? ?? Timestamp.now()).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'weight': weight,
      'heightCentimeters': heightCentimeters,
      'bmi': bmi,
      'date': Timestamp.fromDate(date),
    };
  }
}
