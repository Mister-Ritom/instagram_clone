import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PreviewScreen extends StatefulWidget {
  final String? filePath;
  final bool isVideo;

  const PreviewScreen({
    super.key,
    required this.filePath,
    required this.isVideo,
  });

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    if (widget.isVideo && widget.filePath != null) {
      _videoController = VideoPlayerController.file(File(widget.filePath!))
        ..initialize().then((_) {
          setState(() {});
          _videoController!.setLooping(true);
          _videoController!.play();
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.filePath == null) {
      return Container();
    }
    return widget.isVideo
        ? (_videoController != null && _videoController!.value.isInitialized)
            ? AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            )
            : const CircularProgressIndicator()
        : Image.file(File(widget.filePath!), fit: BoxFit.contain);
  }
}
