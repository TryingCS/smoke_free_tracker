// lib/models/user_profile.dart
class UserProfile {
  final String userId;
  final String nickname;
  final int personalBestDays; // ADD THIS
  final DateTime createdAt;

  UserProfile({
    required this.userId,
    required this.nickname,
    required this.personalBestDays, // ADD THIS
    required this.createdAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      userId: map['user_id'],
      nickname: map['nickname'],
      personalBestDays: map['personal_best_days'] ?? 0, // ADD THIS
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'nickname': nickname,
      'personal_best_days': personalBestDays,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
