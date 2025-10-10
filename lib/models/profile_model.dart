class Profile {
  final String? id; // optional, auto-generated
  final String username;
  final String? fullName;
  final String? bio;
  final List<String>? mentionsUsernames; // typed mentions
  final List<String>? mentionsUserIds; // auto-resolved
  final String? avatarUrl;
  final String? website;
  final bool isPrivate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Profile({
    this.id,
    required this.username,
    this.fullName,
    this.bio,
    this.mentionsUsernames,
    this.mentionsUserIds,
    this.avatarUrl,
    this.website,
    this.isPrivate = false,
    this.createdAt,
    this.updatedAt,
  });

  factory Profile.fromMap(Map<String, dynamic> map) => Profile(
    id: map['id'],
    username: map['username'],
    fullName: map['full_name'],
    bio: map['bio'],
    mentionsUsernames:
        map['mentions_usernames'] != null
            ? List<String>.from(map['mentions_usernames'])
            : null,
    mentionsUserIds:
        map['mentions_user_ids'] != null
            ? List<String>.from(map['mentions_user_ids'])
            : null,
    avatarUrl: map['avatar_url'],
    website: map['website'],
    isPrivate: map['is_private'] ?? false,
    createdAt:
        map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    updatedAt:
        map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
  );

  Map<String, dynamic> toMap() => {
    'username': username,
    'full_name': fullName,
    'bio': bio,
    'mentions_usernames': mentionsUsernames,
    'avatar_url': avatarUrl,
    'website': website,
    'is_private': isPrivate,
    // no id, no createdAt/updatedAt
  };
}
