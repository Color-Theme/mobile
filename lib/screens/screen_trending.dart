import 'package:flutter/material.dart';

class TrendingScreen extends StatelessWidget {
  const TrendingScreen({
    super.key,
    required this.imageUrls,
    required this.buildImage,
    required this.scrollController,
    required this.loadMoreImages,
  });

  final List<String> imageUrls;
  final Widget Function(BuildContext, int) buildImage;
  final ScrollController scrollController;
  final Future<void> Function()
      loadMoreImages; // Đổi VoidCallback -> Future<void>

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: RefreshIndicator(
        onRefresh: () async {
          await loadMoreImages();
        },
        child: GridView.builder(
          controller: scrollController,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1 / 2,
          ),
          itemCount: imageUrls.length,
          itemBuilder: buildImage,
        ),
      ),
    );
  }
}
