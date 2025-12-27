class UserProfile {
  final String userId;
  final String nickname;
  final DateTime createdAt;

  UserProfile({
    required this.userId,
    required this.nickname,
    required this.createdAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      userId: map['user_id'],
      nickname: map['nickname'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
