import 'package:instagram_clone/models/post_model.dart';

class StoryModel {
  final String? id; // auto-generated
  final String userId;
  final String imageUrl;
  final String? caption;
  final List<String>? tags;
  final List<String>? mentionsUsernames;
  final List<String>? mentionsUserIds; // auto-resolved
  final VisibilityType visibility; // enum for visibility
  final List<String>? visibleUserIds; // used if visibility == specificUsers
  final DateTime? createdAt;
  final DateTime? expiresAt;

  StoryModel({
    this.id,
    required this.userId,
    required this.imageUrl,
    this.caption,
    this.tags,
    this.mentionsUsernames,
    this.mentionsUserIds,
    this.visibility = VisibilityType.everyone,
    this.visibleUserIds,
    this.createdAt,
    this.expiresAt,
  });

  factory StoryModel.fromMap(Map<String, dynamic> map) {
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

    return StoryModel(
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
      visibility: visibility,
      visibleUserIds: visibleUserIds,
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      expiresAt:
          map['expires_at'] != null ? DateTime.parse(map['expires_at']) : null,
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

    return {
      'user_id': userId,
      'image_url': imageUrl,
      'caption': caption,
      'tags': tags,
      'mentions_usernames': mentionsUsernames,
      'visible': visibleList,
      // do NOT include id or mentions_user_ids
    };
  }
}
