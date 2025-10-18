import 'dart:developer';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram_clone/core/supabase_client.dart';
import 'package:instagram_clone/models/post_model.dart';
import 'package:instagram_clone/pages/post/post_mode.dart';
import 'package:instagram_clone/riverpod/upload_notifier.dart';

class UtilVars {
  static String appIcon = "assets/icons/app_icon.png";
  static String appName = "Instagram";
  static String copyright = "Ritom";

  static Future<void> uploadPost({
    required String filePath,
    required BuildContext context,
    required PostMode mode,
    required bool isVideo,
    String? caption,
    VisibilityType? visiblity,
    List<String>? visibleUserId,
  }) async {
    await ProviderScope.containerOf(context)
        .read(uploadNotifier.notifier)
        .uploadFile(
          file: File(filePath),
          mode: mode,
          isVideoPost: isVideo,
          nextTask: (fileUrl) async {
            try {
              final supabase = Database.client;
              final post = PostModel(
                userId: supabase.auth.currentUser!.id,
                imageUrl: fileUrl,
                caption: caption,
                visibility: visiblity ?? VisibilityType.everyone,
                isReel: mode == PostMode.reel,
                visibleUserIds: visibleUserId,
              );
              final map = post.toMap();
              await supabase.from(mode.databaseName()).insert(map);
              log("Post upload succesfull", name: "Post Upload");
            } catch (e, st) {
              log(
                "Post upload failed",
                name: "Post Upload",
                error: e,
                stackTrace: st,
              );
            }
          },
        );
  }

  static Future<Map<String, dynamic>?> fetchCurrentUserProfile() async {
    final currentUserId = Database.client.auth.currentUser?.id;
    if (currentUserId == null) return null;
    try {
      final response =
          await Database.client
              .from('profiles')
              .select()
              .eq('id', currentUserId)
              .maybeSingle();
      return response;
    } catch (e, st) {
      log(
        "Error fetching current user profile",
        error: e,
        stackTrace: st,
        name: "Profile fetch",
      );
      return null;
    }
  }
}
