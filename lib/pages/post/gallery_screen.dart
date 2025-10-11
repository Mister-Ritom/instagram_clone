import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:typed_data';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

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

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchInitialMedia();

    // Infinite scroll listener
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 300 &&
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

    // Get albums including "Recent"
    List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.all, // images + videos
      hasAll: true,
    );

    if (albums.isEmpty) {
      setState(() => isLoading = false);
      return;
    }

    album = albums.first; // default: Recent / All Media
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
      if (newItems.length < pageSize) {
        hasMore = false; // no more media
      }
    });
  }

  String _formatVideoDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  Widget buildMediaItem(AssetEntity asset) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(
        const ThumbnailSize(200, 300),
      ), // portrait
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          return Stack(
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
          );
        }
        return Container(color: Colors.grey[300]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gallery')),
      body: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(4),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          childAspectRatio: 2 / 3, // portrait
        ),
        itemCount: mediaItems.length + (hasMore ? 1 : 0),
        itemBuilder: (_, index) {
          if (index < mediaItems.length) {
            return buildMediaItem(mediaItems[index]);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
