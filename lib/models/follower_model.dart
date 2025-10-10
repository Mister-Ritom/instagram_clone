class Follower {
  final String id;
  final String followerId;
  final String followingId;
  final DateTime createdAt;

  Follower({
    required this.id,
    required this.followerId,
    required this.followingId,
    required this.createdAt,
  });

  factory Follower.fromMap(Map<String, dynamic> map) {
    return Follower(
      id: map['id'],
      followerId: map['follower_id'],
      followingId: map['following_id'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
