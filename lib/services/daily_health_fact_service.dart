import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DailyHealthFactService {
  DailyHealthFactService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GenerativeModel? model,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _model =
           model ??
           FirebaseAI.googleAI().generativeModel(
             model: 'gemini-2.5-flash',
             systemInstruction: Content.system(_systemInstruction),
           );

  static const String _systemInstruction =
      'You are Raphael, an empathetic health, fitness, and wellness companion coach. '
      'Your absolute core duty is to give helpful advice regarding nutrition, physical workouts, hydration, sleep cycles, and mindfulness. ';

  static const String _fallbackFact =
      'A short walk after meals can support digestion and help you feel more energized. 🚶';

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GenerativeModel _model;

  Future<String> loadTodayFact() async {
    final user = _auth.currentUser;
    if (user == null) return _fallbackFact;

    final todayId = _todayId();
    final factRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('daily_health_facts')
        .doc(todayId);

    final savedFact = await factRef.get();
    final text = savedFact.data()?['text'] as String?;
    if (text != null && text.trim().isNotEmpty) return text.trim();

    final generatedFact = await _generateFact();
    await factRef.set({
      'text': generatedFact,
      'date': todayId,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return generatedFact;
  }

  Future<String> _generateFact() async {
    try {
      final response = await _model.generateContent([
        Content.text(
          'Generate one short, friendly, health-related fun fact for today. '
          'Keep it easy to understand, positive, and non-medical. '
          'Use one cute emoji only if it naturally fits. '
          'Do not mention diseases, diagnoses, treatments, or scary health warnings. '
          'Maximum 1 sentence.',
        ),
      ]);

      final fact = response.text?.trim();
      if (fact == null || fact.isEmpty) return _fallbackFact;

      return fact.replaceAll(RegExp(r'^["“]|["”]$'), '');
    } catch (_) {
      return _fallbackFact;
    }
  }

  String _todayId() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }
}
