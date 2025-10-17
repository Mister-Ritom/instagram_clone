import 'package:flutter/material.dart';
import 'package:instagram_clone/pages/post/camera_screen.dart';
import 'package:instagram_clone/pages/post/post_mode.dart';
import 'package:instagram_clone/pages/post/story_screen.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:typed_data';

class GalleryScreen extends StatefulWidget {
  final Function(String filePath, bool isVideo)? callback;
  final PostMode mode;

  /// When false, GridView disables its own scrolling and relies on parent scroll.
  final bool scrollable;

  /// Optional: callback to notify parent when more items should be loaded
  final VoidCallback? onLoadMore;

  const GalleryScreen({
    super.key,
    required this.mode,
    this.callback,
    this.scrollable = true,
    this.onLoadMore,
  });

  @override
  State<GalleryScreen> createState() => GalleryScreenState();
}

class GalleryScreenState extends State<GalleryScreen> {
  List<AssetEntity> mediaItems = [];
  bool isLoading = true;
  int page = 0;
  final int pageSize = 50;
  bool hasMore = true;
  late AssetPathEntity album;

  late ScrollController _internalController;

  @override
  void initState() {
    super.initState();
    _internalController = ScrollController();
    fetchInitialMedia();

    // Infinite scroll listener only if scrollable internally
    if (widget.scrollable) {
      _internalController.addListener(() {
        if (_internalController.position.pixels >=
                _internalController.position.maxScrollExtent - 300 &&
            hasMore &&
            !isLoading) {
          fetchMoreMedia();
        }
      });
    }
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

    // Notify parent if provided
    if (!widget.scrollable && hasMore && widget.onLoadMore != null) {
      widget.onLoadMore!();
    }
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
          builder: (_) => StoryScreen(filePath: path, isVideo: isVideo),
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
      controller: widget.scrollable ? _internalController : null,
      physics:
          widget.scrollable
              ? null
              : const NeverScrollableScrollPhysics(), // disable internal scroll if parent scrolls
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 2 / 3,
      ),
      itemCount: mediaItems.length + (hasMore ? 2 : 1),
      itemBuilder: (_, index) {
        if (index == 0) {
          // Camera Icon
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

        // Show loading indicator if last index
        if (index == mediaItems.length + 1 && hasMore) {
          return const Center(child: CircularProgressIndicator());
        }

        // Shift index by -1 for actual media
        return buildMediaItem(mediaItems[index - 1]);
      },
    );
  }

  @override
  void dispose() {
    _internalController.dispose();
    super.dispose();
  }
}
