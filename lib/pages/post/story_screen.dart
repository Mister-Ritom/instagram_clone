import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconic/iconic.dart';
import 'package:instagram_clone/core/supabase_client.dart';
import 'package:instagram_clone/models/post_model.dart';
import 'package:instagram_clone/models/story_model.dart';
import 'package:instagram_clone/pages/post/post_mode.dart';
import 'package:instagram_clone/pages/post/preview_screen.dart';
import 'package:instagram_clone/riverpod/upload_notifier.dart';
import 'package:instagram_clone/utils/widgets/profile_picture.dart';

class StoryScreen extends StatelessWidget {
  final String filePath;
  final bool isVideo;
  const StoryScreen({super.key, required this.filePath, required this.isVideo});

  Widget _buildActionIcon(VoidCallback onClick, IconData icon) {
    return ActionIcon(onClick: onClick, icon: icon);
  }

  void _uploadPost(
    VisibilityType? visiblity,
    BuildContext context, {
    List<String>? visibleTo,
  }) async {
    await ProviderScope.containerOf(context)
        .read(uploadNotifier.notifier)
        .uploadFile(
          file: File(filePath),
          mode: PostMode.story,
          isVideoPost: isVideo,
          nextTask: (fileUrl) async {
            try {
              final supabase = Database.client;
              final post = StoryModel(
                userId: supabase.auth.currentUser!.id,
                imageUrl: fileUrl,
                visibility: visiblity ?? VisibilityType.everyone,
                visibleUserIds: visibleTo,
              );
              final map = post.toMap();
              await supabase.from(PostMode.story.databaseName()).insert(map);
              log("Story upload succesfull", name: "Story Upload");
            } catch (e, st) {
              log(
                "Story upload failed",
                name: "Story Upload",
                error: e,
                stackTrace: st,
              );
            }
          },
        );
    if (context.mounted) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height - 128,
                child: PreviewScreen(filePath: filePath, isVideo: isVideo),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 128,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () => _uploadPost(null, context),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          borderRadius: BorderRadius.all(Radius.circular(32)),
                        ),

                        height: 48,
                        width: 152,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ProfilePicture(size: 24),
                            SizedBox(width: 8),
                            Text(
                              "Your story",
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      //add closefriends feature
                      onTap:
                          () => _uploadPost(
                            VisibilityType.specificUsers,
                            context,
                            visibleTo: [],
                          ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          borderRadius: BorderRadius.all(Radius.circular(32)),
                        ),

                        height: 48,
                        width: 152,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.lightGreen,
                              ),
                              child: Icon(Iconic.star, size: 20),
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Close friends",
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white,
                      child: Transform.translate(
                        offset: const Offset(
                          -4,
                          0,
                        ), // this icon is not actully centred(dont know why) so we offset to center
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {},
                          icon: const Icon(
                            Iconic.arrow_right,
                            size: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 8),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 10,
            height: 80,
            width: MediaQuery.of(context).size.width,
            child: AppBar(
              backgroundColor: Colors.transparent,
              actionsPadding: EdgeInsets.zero,
              leading: _buildActionIcon(() {
                Navigator.of(context).pop();
              }, Iconic.cross),
              actions: [
                _buildActionIcon(() {}, Iconic.text),
                _buildActionIcon(() {}, Iconic.sticker),
                _buildActionIcon(() {}, Iconic.music),
                _buildActionIcon(() {}, Iconic.star_octogram),
                _buildActionIcon(() {}, Icons.menu),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ActionIcon extends StatefulWidget {
  final VoidCallback onClick;
  final IconData icon;

  const ActionIcon({super.key, required this.onClick, required this.icon});

  @override
  State<ActionIcon> createState() => _ActionIconState();
}

class _ActionIconState extends State<ActionIcon> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onClick();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: _isPressed ? 42 : 56,
        height: _isPressed ? 42 : 56,
        decoration: BoxDecoration(
          color: _isPressed ? Colors.grey.shade700 : Colors.grey.shade800,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            widget.icon,
            size: _isPressed ? 18 : 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
