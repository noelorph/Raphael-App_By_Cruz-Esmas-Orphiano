import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/goal_model.dart';

class GoalService {
  GoalService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>>? get _goalsRef {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    return _firestore.collection('users').doc(uid).collection('goals');
  }

  Stream<List<GoalModel>> watchGoals() {
    final goalsRef = _goalsRef;
    if (goalsRef == null) return Stream.value(const []);

    return goalsRef.snapshots().map(
      (snapshot) =>
          snapshot.docs.map(GoalModel.fromDocument).toList()
            ..sort((a, b) => a.title.compareTo(b.title)),
    );
  }

  Future<List<GoalModel>> loadGoals() async {
    final goalsRef = _goalsRef;
    if (goalsRef == null) return const [];

    final snapshot = await goalsRef.get();
    return snapshot.docs.map(GoalModel.fromDocument).toList()
      ..sort((a, b) => a.title.compareTo(b.title));
  }

  Future<void> saveGoal({
    String? goalId,
    required String title,
    required String timeframe,
  }) async {
    final goalsRef = _goalsRef;
    if (goalsRef == null) return;

    final goal = GoalModel(
      id: goalId ?? '',
      title: title,
      timeframe: timeframe,
      completed: false,
    );

    if (goalId == null) {
      await goalsRef.add(goal.toCreateMap());
    } else {
      await goalsRef.doc(goalId).update(goal.toUpdateMap());
    }
  }

  Future<void> deleteGoal(String goalId) async {
    final goalsRef = _goalsRef;
    if (goalsRef == null) return;
    await goalsRef.doc(goalId).delete();
  }

  Future<void> toggleGoalCompletion(String goalId, bool completed) async {
    final goalsRef = _goalsRef;
    if (goalsRef == null) return;

    await goalsRef.doc(goalId).update({
      'completed': completed,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
