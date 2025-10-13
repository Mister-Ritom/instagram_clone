import 'package:flutter/material.dart';
import 'package:instagram_clone/pages/post/camera_screen.dart';
import 'package:instagram_clone/pages/post/post_mode.dart';
import 'package:instagram_clone/pages/post/preview_screen.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:typed_data';

class GalleryScreen extends StatefulWidget {
  final ScrollController? scrollController;
  final Function(String filePath, bool isVideo)? callback;
  final PostMode mode;

  const GalleryScreen({
    super.key,
    this.scrollController,
    required this.mode,
    this.callback,
  });

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<AssetEntity> mediaItems = [];
  bool isLoading = true;
  int page = 0;
  final int pageSize = 50;
  bool hasMore = true;
  late AssetPathEntity album;

  ScrollController? _internalController;

  ScrollController get _controller =>
      widget.scrollController ?? _internalController!;

  @override
  void initState() {
    super.initState();
    _internalController =
        widget.scrollController ?? ScrollController(); // only create if null
    fetchInitialMedia();

    // Infinite scroll listener
    _controller.addListener(() {
      if (_controller.position.pixels >=
              _controller.position.maxScrollExtent - 300 &&
          hasMore &&
          !isLoading) {
        fetchMoreMedia();
      }
    });
  }

  Future<void> fetchInitialMedia() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!ps.isAuth) {
      setState(() => isLoading = false);
      return;
    }

    List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.all,
      hasAll: true,
    );

    if (albums.isEmpty) {
      setState(() => isLoading = false);
      return;
    }

    album = albums.first;
    await fetchMoreMedia();
  }

  Future<void> fetchMoreMedia() async {
    setState(() => isLoading = true);
    final List<AssetEntity> newItems = await album.getAssetListPaged(
      page: page,
      size: pageSize,
    );

    setState(() {
      mediaItems.addAll(newItems);
      page++;
      isLoading = false;
      if (newItems.length < pageSize) hasMore = false;
    });
  }

  String _formatVideoDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  void _navigateToPreview(String path, {required bool isVideo}) {
    if (widget.callback != null) {
      widget.callback!(path, isVideo);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => PreviewScreen(
                filePath: path,
                isVideo: isVideo,
                mode: widget.mode,
              ),
        ),
      );
    }
  }

  Widget buildMediaItem(AssetEntity asset) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(const ThumbnailSize(200, 300)),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          return GestureDetector(
            onTap: () async {
              final file = await asset.originFile;
              if (file != null) {
                _navigateToPreview(
                  file.path,
                  isVideo: asset.type == AssetType.video,
                );
              }
            },
            child: Stack(
              children: [
                Image.memory(
                  snapshot.data!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                if (asset.type == AssetType.video)
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _formatVideoDuration(asset.duration),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }
        return Container(color: Colors.grey[300]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: _controller,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 2 / 3,
      ),
      // Add 1 for the camera icon
      itemCount: mediaItems.length + (hasMore ? 2 : 1),
      itemBuilder: (_, index) {
        // 👇 First item: camera icon
        if (index == 0) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CameraScreen(mode: widget.mode),
                ),
              );
            },
            child: Container(
              color: Colors.grey.shade900,
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
          );
        }

        // 👇 Show loading indicator if last index and hasMore
        if (index == mediaItems.length + 1 && hasMore) {
          return const Center(child: CircularProgressIndicator());
        }

        // 👇 For all other items, shift index by -1
        return buildMediaItem(mediaItems[index - 1]);
      },
    );
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _internalController?.dispose(); // only dispose internal one
    }
    super.dispose();
  }
}
