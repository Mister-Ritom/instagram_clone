import 'package:flutter/material.dart';
import 'package:instagram_clone/pages/post/camera_screen.dart';
import 'package:instagram_clone/pages/post/gallery_screen.dart';

class PostInterface extends StatefulWidget {
  const PostInterface({super.key});

  @override
  State<PostInterface> createState() => _PostInterfaceState();
}

class _PostInterfaceState extends State<PostInterface> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: CameraScreen());
  }
}
