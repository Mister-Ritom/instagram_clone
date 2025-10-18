class Comment {
  final String? id; // auto-generated
  final String postId;
  final String userId;
  final String content;
  final List<String>? tags;
  final List<String>? mentionsUsernames;
  final List<String>? mentionsUserIds; // auto-resolved
  final DateTime? createdAt;

  Comment({
    this.id,
    required this.postId,
    required this.userId,
    required this.content,
    this.tags,
    this.mentionsUsernames,
    this.mentionsUserIds,
    this.createdAt,
  });

  factory Comment.fromMap(Map<String, dynamic> map) => Comment(
    id: map['id'],
    postId: map['post_id'],
    userId: map['user_id'],
    content: map['text'],
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
    'post_id': postId,
    'user_id': userId,
    'text': content,
    'tags': tags,
    'mentions_usernames': mentionsUsernames,
    // do NOT include id or mentions_user_ids
  };
}
