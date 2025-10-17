import 'package:flutter/material.dart';
import 'package:iconic/iconic.dart';
import 'package:instagram_clone/pages/post/gallery_screen.dart';
import 'package:instagram_clone/pages/post/post_mode.dart';
import 'package:instagram_clone/pages/post/preview_screen.dart';
import 'package:instagram_clone/pages/screns/home_screen.dart';
import 'package:instagram_clone/utils/reusable/util_vars.dart';

class AddToPostScreen extends StatefulWidget {
  const AddToPostScreen({super.key});

  @override
  State<AddToPostScreen> createState() => _AddToPostScreenState();
}

class _AddToPostScreenState extends State<AddToPostScreen> {
  bool _isPreview = true;
  String? _currentPath;
  bool _isVideo = false;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _previewKey = GlobalKey();
  final TextEditingController _captionController = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  void _scrollToPreview() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _previewKey.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.0, // scrolls to top of preview
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            leading: IconButton(
              icon: Icon(Iconic.cross),
              onPressed: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: Text("Discard Post?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (_) => HomeScreen()),
                                (route) => false,
                              );
                            },
                            child: Text("Discard"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("Continue"),
                          ),
                        ],
                      ),
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
                            _isPreview = false;
                          });
                        },
                        child: Text("Next"),
                      ),
                    ]
                    : null,
          ),

          // Preview Screen
          if (_currentPath != null)
            SliverToBoxAdapter(
              child: SizedBox(
                key: _previewKey,
                height: 300,
                child: PreviewScreen(
                  key: ValueKey(_currentPath),
                  filePath: _currentPath,
                  isVideo: _isVideo,
                  mode: PostMode.post,
                ),
              ),
            ),

          // Gallery or Post details
          SliverToBoxAdapter(
            child:
                _isPreview
                    ? GalleryScreen(
                      mode: PostMode.post,
                      scrollController: _scrollController,
                      callback: (filePath, isVideo) {
                        setState(() {
                          _currentPath = filePath;
                          _isVideo = isVideo;
                        });
                        _scrollToPreview(); // scroll preview into view
                      },
                    )
                    : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            decoration: InputDecoration(
                              hintText: "Add a caption",
                            ),
                            controller: _captionController,
                          ),
                          Divider(),
                          rowWidget("Add audio", Iconic.music),
                          rowWidget("Tag people", Iconic.user),
                          rowWidget("Add location", Iconic.map),
                          Divider(),
                          rowWidget("Audience", Iconic.eye),
                          rowWidget(
                            "Also share on",
                            Iconic.chat_arrow_down_straight,
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              if (_currentPath == null) return;
                              await UtilVars.uploadPost(
                                filePath: _currentPath!,
                                context: context,
                                mode: PostMode.post,
                                isVideo: _isVideo,
                                caption: _captionController.text.trim(),
                              );
                              if (mounted && context.mounted) {
                                Navigator.popUntil(
                                  context,
                                  (route) => route.isFirst,
                                );
                              }
                            },
                            child: Text("Share"),
                          ),
                        ],
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget rowWidget(String text, IconData icon, {Widget? trailing}) {
    return ListTile(leading: Icon(icon), title: Text(text), trailing: trailing);
  }
}
