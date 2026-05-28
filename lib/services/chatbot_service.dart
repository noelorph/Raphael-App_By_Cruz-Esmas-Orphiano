import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatbotService {
  ChatbotService({
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
      'Your absolute core duty is to give helpful advice regarding nutrition, physical workouts, hydration, sleep cycles, and mindfulness. '
      'If the user asks you questions about unrelated topics like programming, video games, history, or celebrities, '
      'politely guide them back to talking about their lifestyle and health goals. Keep responses encouraging but concise.'
      'make a humane response and have a conversation, you can also send emoji to make the user feel like talking to other person. '
      'Use the user\'s username naturally if it is provided, but do not overuse it.';

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GenerativeModel _model;

  CollectionReference<Map<String, dynamic>> get _chatRef {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user found');
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('chat_messages');
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchMessages() {
    return _chatRef.orderBy('timestamp', descending: false).snapshots();
  }

  Future<void> sendMessage(String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    await _chatRef.add({
      'text': trimmedText,
      'sender': 'user',
      'timestamp': FieldValue.serverTimestamp(),
    });

    final historySnapshot = await _chatRef
        .orderBy('timestamp', descending: true)
        .limit(10)
        .get();
    final conversationHistory = _buildConversationHistory(
      historySnapshot.docs,
      trimmedText,
    );
    final username = await _loadUsername();
    if (username != null) {
      conversationHistory.insert(
        0,
        Content.text('The user\'s username is $username.'),
      );
    }

    final replyText = await _generateReply(conversationHistory);

    await _chatRef.add({
      'text': replyText,
      'sender': 'model',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<String> _generateReply(List<Content> conversationHistory) async {
    try {
      final response = await _model.generateContent(conversationHistory);
      final replyText = response.text?.trim();

      if (replyText == null || replyText.isEmpty) {
        return _fallbackReply;
      }

      return replyText;
    } catch (_) {
      return _fallbackReply;
    }
  }

  static const String _fallbackReply =
      "I'm a little quiet right now, but I'm still here with you. For now, keep it simple: drink some water, take a short walk, or log one small win today.";

  List<Content> _buildConversationHistory(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    String fallbackText,
  ) {
    final history = <Content>[];

    for (final doc in docs.reversed) {
      final data = doc.data();
      final messageText = data['text'] as String? ?? '';
      if (messageText.isEmpty) continue;

      if (data['sender'] == 'user') {
        history.add(Content.text(messageText));
      } else {
        history.add(Content.model([TextPart(messageText)]));
      }
    }

    if (history.isEmpty) {
      history.add(Content.text(fallbackText));
    }

    return history;
  }

  Future<String?> _loadUsername() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final snapshot = await _firestore.collection('users').doc(user.uid).get();
    final data = snapshot.data();
    if (data == null) return null;

    final username = (data['username'] as String? ?? '').trim();
    if (username.isNotEmpty) return username;

    final email = (data['email'] as String? ?? '').trim();
    final emailName = email.split('@').first.trim();
    return emailName.isEmpty ? null : emailName;
  }
}
