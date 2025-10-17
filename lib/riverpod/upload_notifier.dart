import 'dart:developer';
import 'dart:io';

import 'package:flutter_riverpod/legacy.dart';
import 'package:instagram_clone/core/supabase_client.dart';
import 'package:instagram_clone/pages/post/post_mode.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

final uploadNotifier = StateNotifierProvider((ref) => UploadNotifier());

class UploadNotifier extends StateNotifier<List<UploadTaskState>> {
  UploadNotifier() : super([]);

  /// Public method to start an upload
  Future<void> uploadFile({
    required File file,
    required PostMode mode,
    Function(String fileUrl)? nextTask,
    bool isVideoPost = false,
  }) async {
    final fileName = file.path.split('/').last;
    final task = UploadTaskState(
      fileName: fileName,
      progress: 0,
      isUploading: true,
    );

    // Add task to state
    state = [...state, task];
    final taskIndex = state.length - 1;

    try {
      final supabase = Database.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception("User not logged in");

      final userId = user.id;
      final bucketName = mode.bucketName(isVideoPost: isVideoPost);
      final bucket = supabase.storage.from(bucketName);

      // Unique file path inside bucket
      final fileExt = file.path.split('.').last;
      final path =
          "$userId/${Uuid().v4()}.$fileExt"; // <-- this is the relative path

      // Upload file
      await bucket.upload(
        path, // <-- use relative path only
        file,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      // Get public URL (use the same relative path, NOT uploadedPath)
      final downloadUrl = bucket.getPublicUrl(path);

      // Update state with completed download URL
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == taskIndex)
            state[i].copyWith(
              progress: 1.0,
              isUploading: false,
              downloadUrl: downloadUrl,
            )
          else
            state[i],
      ];

      // Call next task if needed
      if (nextTask != null) {
        log("Upload completed, performing nextTask", name: "File uploader");
        nextTask(downloadUrl);
      }
    } catch (e) {
      log("❌ Upload failed", name: "File uploader", error: e);

      // Update state with error
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == taskIndex)
            state[i].copyWith(isUploading: false, error: e.toString())
          else
            state[i],
      ];
    }
  }
}

class UploadTaskState {
  final String fileName;
  final double progress;
  final bool isUploading;
  final String? downloadUrl;
  final String? error;

  const UploadTaskState({
    required this.fileName,
    required this.progress,
    this.isUploading = false,
    this.downloadUrl,
    this.error,
  });

  UploadTaskState copyWith({
    String? fileName,
    double? progress,
    bool? isUploading,
    String? downloadUrl,
    String? error,
  }) {
    return UploadTaskState(
      fileName: fileName ?? this.fileName,
      progress: progress ?? this.progress,
      isUploading: isUploading ?? this.isUploading,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      error: error ?? this.error,
    );
  }
}
