enum VisibilityType { everyone, followersOnly, specificUsers }

class PostModel {
  final String id;
  final String userId;
  final String imageUrl;
  final bool isReel;
  final String? caption;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final List<String>? tags;
  final List<String>? mentionsUsernames;
  final List<String>? mentionsUserIds; // auto-resolved
  final VisibilityType visibility; // enum instead of raw string
  final List<String>?
  visibleUserIds; // only used if visibility == specificUsers
  final DateTime? createdAt;

  PostModel({
    this.id = "",
    required this.userId,
    required this.imageUrl,
    this.isReel = false,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.caption,
    this.tags,
    this.mentionsUsernames,
    this.mentionsUserIds,
    this.visibility = VisibilityType.everyone,
    this.visibleUserIds,
    this.createdAt,
  });

  PostModel copyWith({
    String? id,
    String? userId,
    String? imageUrl,
    bool? isReel,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    String? caption,
    List<String>? tags,
    List<String>? mentionsUsernames,
    List<String>? mentionsUserIds,
    VisibilityType? visibility,
    List<String>? visibleUserIds,
    DateTime? createdAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      isReel: isReel ?? this.isReel,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      caption: caption ?? this.caption,
      tags: tags ?? this.tags,
      mentionsUsernames: mentionsUsernames ?? this.mentionsUsernames,
      mentionsUserIds: mentionsUserIds ?? this.mentionsUserIds,
      visibility: visibility ?? this.visibility,
      visibleUserIds: visibleUserIds ?? this.visibleUserIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    final videoUrl = map['video_url'] as String?;
    final imageUrl = map['image_url'] as String? ?? videoUrl;
    final isReel = videoUrl != null && map['image_url'] == null;

    VisibilityType visibility = VisibilityType.everyone;
    List<String>? visibleUserIds;

    if (map['visible'] != null) {
      final List<String> visibleList = List<String>.from(map['visible']);
      if (visibleList.contains('everyone')) {
        visibility = VisibilityType.everyone;
      } else if (visibleList.contains('followers only')) {
        visibility = VisibilityType.followersOnly;
      } else {
        visibility = VisibilityType.specificUsers;
        visibleUserIds = visibleList;
      }
    }

    return PostModel(
      id: map['id'],
      userId: map['user_id'],
      imageUrl: imageUrl!,
      isReel: isReel,
      likeCount: map['like_count'] ?? 0,
      commentCount: map['comment_count'] ?? 0,
      shareCount: map['share_count'] ?? 0,
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
      visibility: visibility,
      visibleUserIds: visibleUserIds,
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    List<String> visibleList;

    switch (visibility) {
      case VisibilityType.everyone:
        visibleList = ['everyone'];
        break;
      case VisibilityType.followersOnly:
        visibleList = ['followers only'];
        break;
      case VisibilityType.specificUsers:
        visibleList = visibleUserIds ?? [];
        break;
    }

    final map = {
      'user_id': userId,
      'caption': caption,
      'tags': tags,
      'mentions_usernames': mentionsUsernames,
      'mentions_user_ids': mentionsUserIds,
      'like_count': likeCount,
      'comment_count': commentCount,
      'share_count': shareCount,
      'visible': visibleList,
    };

    if (isReel) {
      map['video_url'] = imageUrl;
    } else {
      map['image_url'] = imageUrl;
    }

    return map;
  }
}
