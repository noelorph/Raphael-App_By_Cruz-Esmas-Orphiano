import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/weight_entry_model.dart';

class WeightTrackerService {
  WeightTrackerService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>>? get _entriesRef {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    return _firestore.collection('users').doc(uid).collection('weight_entries');
  }

  DocumentReference<Map<String, dynamic>>? get _userRef {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    return _firestore.collection('users').doc(uid);
  }

  Future<List<WeightEntryModel>> loadEntries() async {
    final entriesRef = _entriesRef;
    if (entriesRef == null) return [];

    final snapshot = await entriesRef.orderBy('date').get();
    return snapshot.docs.map(WeightEntryModel.fromDocument).toList();
  }

  Stream<List<WeightEntryModel>> watchEntries() {
    final entriesRef = _entriesRef;
    if (entriesRef == null) return Stream.value(const []);

    return entriesRef
        .orderBy('date')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(WeightEntryModel.fromDocument).toList(),
        );
  }

  Future<double?> loadProfileHeight() async {
    final userRef = _userRef;
    if (userRef == null) return null;

    final snapshot = await userRef.get();
    final height = snapshot.data()?['heightCentimeters'] as num?;
    return height?.toDouble();
  }

  Future<void> saveEntry({
    required double weight,
    required double heightCentimeters,
  }) async {
    final entriesRef = _entriesRef;
    if (entriesRef == null) return;

    final heightMeters = heightCentimeters / 100;
    final bmi = weight / (heightMeters * heightMeters);

    await entriesRef.add({
      'weight': weight,
      'heightCentimeters': heightCentimeters,
      'bmi': bmi,
      'date': Timestamp.now(),
    });

    await _userRef?.set({
      'weightKilograms': weight,
      'heightCentimeters': heightCentimeters,
      'bmi': bmi,
      'bodyMetricsUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<bool> updateLatestEntry({
    required String entryId,
    required double weight,
    required double heightCentimeters,
  }) async {
    final entriesRef = _entriesRef;
    if (entriesRef == null) return false;

    final latestSnapshot = await entriesRef
        .orderBy('date', descending: true)
        .limit(1)
        .get();
    if (latestSnapshot.docs.isEmpty ||
        latestSnapshot.docs.first.id != entryId) {
      return false;
    }

    final heightMeters = heightCentimeters / 100;
    final bmi = weight / (heightMeters * heightMeters);

    await entriesRef.doc(entryId).set({
      'weight': weight,
      'heightCentimeters': heightCentimeters,
      'bmi': bmi,
    }, SetOptions(merge: true));

    await _userRef?.set({
      'weightKilograms': weight,
      'heightCentimeters': heightCentimeters,
      'bmi': bmi,
      'bodyMetricsUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return true;
  }
}
