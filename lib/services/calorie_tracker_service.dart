import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/calorie_entry_model.dart';

class CalorieTrackerService {
  CalorieTrackerService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>>? get _entriesRef {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('calorie_entries');
  }

  Stream<List<CalorieEntryModel>> todayEntriesStream() {
    final entriesRef = _entriesRef;
    if (entriesRef == null) return Stream.value(const []);

    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);

    return entriesRef
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfToday),
        )
        .snapshots()
        .map((snapshot) {
          final entries = snapshot.docs
              .map(CalorieEntryModel.fromDocument)
              .toList();
          entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return entries;
        });
  }

  Future<void> addEntry({required String label, required int calories}) async {
    final entriesRef = _entriesRef;
    if (entriesRef == null) return;

    await entriesRef.add(
      CalorieEntryModel(
        id: '',
        label: label,
        calories: calories,
        createdAt: DateTime.now(),
      ).toMap(),
    );
  }
}
