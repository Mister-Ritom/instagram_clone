import 'package:flutter/material.dart';
import 'package:iconic/iconic.dart';
import 'package:instagram_clone/pages/post/gallery_screen.dart';
import 'package:instagram_clone/pages/post/post_mode.dart';
import 'package:instagram_clone/pages/post/preview_screen.dart';
import 'package:instagram_clone/pages/screns/home_screen.dart';

class AddToPostScreen extends StatefulWidget {
  const AddToPostScreen({super.key});

  @override
  State<AddToPostScreen> createState() => _AddToPostScreenState();
}

class _AddToPostScreenState extends State<AddToPostScreen> {
  bool _isPreview = true;
  String? _currentPath = null;
  bool _isVideo = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Iconic.cross),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Discard Post?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => HomeScreen()),
                          (Route<dynamic> route) =>
                              false, // this removes all previous routes
                        );
                      },
                      child: Text("Discard"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Continue"),
                    ),
                  ],
                );
              },
            );
          },
        ),
        title: Text("New Post"),
        actions:
            _isPreview
                ? [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isPreview = true;
                      });
                    },
                    child: Text("Next"),
                  ),
                ]
                : null,
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            SizedBox(
              height: 300,
              child: PreviewScreen(
                key: ValueKey(_currentPath),
                filePath: _currentPath,
                isVideo: _isVideo,
                mode: PostMode.post,
              ),
            ),
            Expanded(
              child: GalleryScreen(
                mode: PostMode.post,
                callback: (filePath, isVideo) {
                  setState(() {
                    _currentPath = filePath;
                    _isVideo = isVideo;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
