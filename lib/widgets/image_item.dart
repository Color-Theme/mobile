import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mobile/screens/fullscreen_image_screen.dart';

class ImageItem extends StatefulWidget {
  final Map<String, dynamic> image;
  final List<Map<String, dynamic>> imageList;
  final int index;

  const ImageItem({
    Key? key,
    required this.image,
    required this.imageList,
    required this.index,
  }) : super(key: key);

  @override
  State<ImageItem> createState() => _ImageItemState();
}

class _ImageItemState extends State<ImageItem>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final String? imageUrl = widget.image['url'];
    final int? imageId = widget.image['id'];

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            if (imageUrl != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullscreenImageScreen(
                    imageUrls: widget.imageList
                        .map((e) => e['url'] as String)
                        .toList(),
                    initialIndex: widget.index,
                  ),
                ),
              );
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      fadeInDuration: Duration.zero,
                      placeholder: (context, url) =>
                          _loadFromCacheOrShowLoader(url),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error, color: Colors.red),
                    )
                  : const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey)),
            ],
          ),
        ),
        if (imageId != null)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              color: Colors.black.withOpacity(0.5),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Row(
                children: [
                  const Icon(Icons.download, color: Colors.white, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    imageId.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _loadFromCacheOrShowLoader(String url) {
    return FutureBuilder<FileInfo?>(
      future: DefaultCacheManager().getFileFromCache(url),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData &&
            snapshot.data != null) {
          return Image.file(snapshot.data!.file, fit: BoxFit.cover);
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
