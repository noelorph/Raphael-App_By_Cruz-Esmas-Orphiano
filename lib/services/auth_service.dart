import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Stream<UserModel?> currentUserProfileStream() {
    final uid = currentUser?.uid;
    if (uid == null) return Stream.value(null);

    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromDocument(doc);
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    required String firstName,
    required String lastName,
    required int age,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    try {
      final uid = userCredential.user!.uid;
      await userCredential.user!.updateDisplayName(
        '$firstName $lastName'.trim(),
      );

      await _firestore
          .collection('users')
          .doc(uid)
          .set(
            UserModel(
              id: uid,
              email: email,
              username: username,
              firstName: firstName,
              lastName: lastName,
              age: age,
              streak: 1,
            ).toMap(),
          );

      final goalsRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('goals');
      await goalsRef.add({
        'title': 'Drink 3 Liters of Water',
        'timeframe': 'Daily',
        'completed': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await goalsRef.add({
        'title': 'Walk 10,000 steps',
        'timeframe': 'Daily',
        'completed': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } finally {
      await _auth.signOut();
    }
  }

  Future<void> signOut() {
    return _auth.signOut();
  }

  Future<void> updateBodyMetrics({
    required double heightCentimeters,
    required double weightKilograms,
  }) async {
    final uid = currentUser?.uid;
    if (uid == null) return;

    final heightMeters = heightCentimeters / 100;
    final bmi = weightKilograms / (heightMeters * heightMeters);

    await _firestore.collection('users').doc(uid).set({
      'heightCentimeters': heightCentimeters,
      'weightKilograms': weightKilograms,
      'bmi': bmi,
      'bodyMetricsUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('weight_entries')
        .add({
          'weight': weightKilograms,
          'heightCentimeters': heightCentimeters,
          'bmi': bmi,
          'date': Timestamp.now(),
        });
  }

  Future<void> addReward(String reward) async {
    final uid = currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).set({
      'rewards': FieldValue.arrayUnion([reward]),
    }, SetOptions(merge: true));
  }
}
