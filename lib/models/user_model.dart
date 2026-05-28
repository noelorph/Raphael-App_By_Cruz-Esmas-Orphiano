import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final int age;
  final int streak;
  final double? heightCentimeters;
  final double? weightKilograms;
  final double? bmi;
  final String? profileImageUrl;
  final List<String> rewards;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.streak,
    this.heightCentimeters,
    this.weightKilograms,
    this.bmi,
    this.profileImageUrl,
    this.rewards = const [],
    this.createdAt,
  });

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? email : name;
  }

  String get displayUsername {
    if (username.trim().isNotEmpty) return username.trim();
    final emailName = email.split('@').first.trim();
    return emailName.isEmpty ? fullName : emailName;
  }

  bool get hasBodyMetrics {
    return heightCentimeters != null &&
        heightCentimeters! > 0 &&
        weightKilograms != null &&
        weightKilograms! > 0;
  }

  factory UserModel.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserModel(
      id: doc.id,
      email: data['email'] as String? ?? '',
      username: data['username'] as String? ?? '',
      firstName: data['firstName'] as String? ?? '',
      lastName: data['lastName'] as String? ?? '',
      age: data['age'] as int? ?? 0,
      streak: data['streak'] as int? ?? 0,
      heightCentimeters: (data['heightCentimeters'] as num?)?.toDouble(),
      weightKilograms: (data['weightKilograms'] as num?)?.toDouble(),
      bmi: (data['bmi'] as num?)?.toDouble(),
      profileImageUrl: data['profileImageUrl'] as String?,
      rewards: List<String>.from(data['rewards'] as List? ?? const []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'streak': streak,
      'heightCentimeters': heightCentimeters,
      'weightKilograms': weightKilograms,
      'bmi': bmi,
      'profileImageUrl': profileImageUrl,
      'rewards': rewards,
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
    };
  }
}
