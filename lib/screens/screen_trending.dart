import 'dart:math';

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
  final VoidCallback loadMoreImages;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          // Reset the imageUrls list
          imageUrls.clear();
          imageUrls.addAll(List.generate(
              15,
              (index) =>
                  'https://picsum.photos/seed/${Random().nextInt(1000)}/1170/2532'));
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
