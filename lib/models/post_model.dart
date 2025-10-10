class Post {
  final String? id; // auto-generated
  final String userId;
  final String imageUrl;
  final String? caption;
  final List<String>? tags;
  final List<String>? mentionsUsernames;
  final List<String>? mentionsUserIds; // auto-resolved
  final DateTime? createdAt;

  Post({
    this.id,
    required this.userId,
    required this.imageUrl,
    this.caption,
    this.tags,
    this.mentionsUsernames,
    this.mentionsUserIds,
    this.createdAt,
  });

  factory Post.fromMap(Map<String, dynamic> map) => Post(
    id: map['id'],
    userId: map['user_id'],
    imageUrl: map['image_url'],
    caption: map['caption'],
    tags: map['tags'] != null ? List<String>.from(map['tags']) : null,
    mentionsUsernames:
        map['mentions_usernames'] != null
            ? List<String>.from(map['mentions_usernames'])
            : null,
    mentionsUserIds:
        map['mentions_user_ids'] != null
            ? List<String>.from(map['mentions_user_ids'])
            : null,
    createdAt:
        map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
  );

  Map<String, dynamic> toMap() => {
    'user_id': userId,
    'image_url': imageUrl,
    'caption': caption,
    'tags': tags,
    'mentions_usernames': mentionsUsernames,
    // do NOT include id or mentions_user_ids
  };
}
