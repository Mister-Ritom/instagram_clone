import 'package:flutter/material.dart';
import 'package:iconic/iconic.dart';
import 'package:instagram_clone/pages/post/add_to_post_screen.dart';
import 'package:instagram_clone/pages/post/camera_screen.dart';
import 'package:instagram_clone/pages/post/gallery_screen.dart';
import 'package:instagram_clone/pages/post/post_mode.dart';
import 'package:instagram_clone/utils/widgets/horizontal_scroll_selector.dart';

class PostInterface extends StatefulWidget {
  const PostInterface({super.key});

  @override
  State<PostInterface> createState() => _PostInterfaceState();
}

class _PostInterfaceState extends State<PostInterface> {
  PostMode _currentMode = PostMode.story;
  void _openGallery() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      barrierColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 1, // starts at 60% screen height
          minChildSize: 0.4, // smallest when dragged down
          maxChildSize: 1.0, // can expand to full screen
          snap: true, // enables snapping
          snapSizes: const [0.4, 1.0], // snaps between half and full screen
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: Icon(Iconic.cross_bold, size: 18),
                          ),
                          Text(
                            "Add to ${_currentMode.displayName}",
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: () {
                              //Go to settings page
                            },
                            icon: Icon(Iconic.settings),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 160, // enough height for card + caption
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        iconCard("Drafts", Icon(Iconic.add, size: 26)),
                        iconCard(
                          "Add yours",
                          Image.network(
                            "https://img.freepik.com/free-photo/medium-shot-people-with-glasses-posing-studio_23-2150169314.jpg?semt=ais_hybrid&w=740&q=80",
                            fit: BoxFit.cover,
                          ),
                        ),
                        iconCard("Friends", Icon(Icons.person, size: 26)),
                        iconCard(
                          "Nature",
                          Image.network(
                            "https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=96&q=80",
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Add more cards here
                      ],
                    ),
                  ),
                  Expanded(
                    child: GalleryScreen(
                      scrollController: scrollController,
                      mode: _currentMode,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget iconCard(String text, Widget iconOrImage) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(bottom: 8, left: 8),
      child: Card(
        elevation: 8,
        color: Colors.grey.shade900,
        margin: null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Small icon/image
              SizedBox(
                width: 40, // small size
                height: 40,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: iconOrImage,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: size.height - 96,
            child: CameraScreen(mode: _currentMode),
          ),
          Container(
            height: 96,
            margin: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(),
            child: Row(
              children: [
                IconButton(onPressed: _openGallery, icon: Icon(Iconic.picture)),
                SizedBox(width: 12),
                SizedBox(
                  width: 300,
                  child: HorizontalScrollSelector(
                    initialIndex: 1,
                    items:
                        PostMode.values
                            .map((e) => Text(e.displayName))
                            .toList(),
                    onSelectedChanged: (index) {
                      setState(() {
                        _currentMode = PostMode.values[index];
                      });
                      if (index == 0) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AddToPostScreen(),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
